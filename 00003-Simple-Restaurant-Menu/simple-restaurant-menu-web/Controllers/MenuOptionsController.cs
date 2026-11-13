using Azure;
using Azure.Identity;
using Azure.Storage.Blobs;
using Microsoft.AspNetCore.Mvc;

namespace simple_restaurant_menu_web.Controllers;

[ApiController]
[Route("[controller]")]
public class MenuOptionsController : ControllerBase
{

    private readonly ILogger<MenuOptionsController> _logger;
    private readonly BlobServiceClient _blobServiceClient;
    private readonly HashSet<string> _menuContainerNames;

    public MenuOptionsController(
        ILogger<MenuOptionsController> logger,
        BlobServiceClient blobServiceClient,
        IConfiguration configuration)
    {
        _logger = logger;
        _blobServiceClient = blobServiceClient;
        _menuContainerNames = configuration
            .GetSection("BlobStorage:MenuContainers")
            .Get<string[]>()?
            .ToHashSet(StringComparer.Ordinal)
            ?? throw new InvalidOperationException(
                "BlobStorage:MenuContainers must contain the menu container names.");
    }

    [HttpGet]
    public ActionResult<IReadOnlyList<string>> Get()
    {
        return Ok(_menuContainerNames.Order(StringComparer.Ordinal).ToArray());
    }

    [HttpGet("{containerName}/images")]
    public async Task<ActionResult<IReadOnlyList<MenuImage>>> GetImages(
        string containerName,
        CancellationToken cancellationToken)
    {
        if (!IsMenuContainer(containerName))
        {
            return NotFound("Menu category was not found.");
        }

        try
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            var images = new List<MenuImage>();

            await foreach (var blob in containerClient.GetBlobsAsync(
                cancellationToken: cancellationToken))
            {
                if (!TryGetImageContentType(blob.Name, out _))
                {
                    continue;
                }

                var imageUrl =
                    $"/MenuOptions/{Uri.EscapeDataString(containerName)}/image?blobName={Uri.EscapeDataString(blob.Name)}";
                images.Add(new MenuImage(blob.Name, imageUrl));
            }

            return Ok(images);
        }
        catch (RequestFailedException ex) when (ex.Status == StatusCodes.Status404NotFound)
        {
            return NotFound("Menu category was not found.");
        }
        catch (RequestFailedException ex)
        {
            _logger.LogError(
                ex,
                "Error retrieving images from container {ContainerName}. Status code: {Status}.",
                containerName,
                ex.Status);
            return StatusCode(
                StatusCodes.Status503ServiceUnavailable,
                "Menu images are temporarily unavailable.");
        }
        catch (AuthenticationFailedException ex)
        {
            _logger.LogError(ex, "Azure authentication failed while retrieving menu images.");
            return StatusCode(
                StatusCodes.Status503ServiceUnavailable,
                "Menu images are temporarily unavailable.");
        }
    }

    [HttpGet("{containerName}/image")]
    public async Task<IActionResult> GetImage(
        string containerName,
        [FromQuery] string blobName,
        CancellationToken cancellationToken)
    {
        if (!IsMenuContainer(containerName)
            || string.IsNullOrWhiteSpace(blobName)
            || !TryGetImageContentType(blobName, out var contentType))
        {
            return BadRequest("Invalid menu image.");
        }

        try
        {
            var blobClient = _blobServiceClient
                .GetBlobContainerClient(containerName)
                .GetBlobClient(blobName);
            var download = await blobClient.DownloadStreamingAsync(
                cancellationToken: cancellationToken);

            Response.Headers["X-Content-Type-Options"] = "nosniff";
            Response.Headers.CacheControl = "private, max-age=300";
            return File(download.Value.Content, contentType);
        }
        catch (RequestFailedException ex) when (ex.Status == StatusCodes.Status404NotFound)
        {
            return NotFound();
        }
        catch (RequestFailedException ex)
        {
            _logger.LogError(
                ex,
                "Error downloading image {BlobName} from container {ContainerName}. Status code: {Status}.",
                blobName,
                containerName,
                ex.Status);
            return StatusCode(
                StatusCodes.Status503ServiceUnavailable,
                "Menu image is temporarily unavailable.");
        }
        catch (AuthenticationFailedException ex)
        {
            _logger.LogError(ex, "Azure authentication failed while downloading a menu image.");
            return StatusCode(
                StatusCodes.Status503ServiceUnavailable,
                "Menu image is temporarily unavailable.");
        }
    }

    private bool IsMenuContainer(string containerName)
    {
        return _menuContainerNames.Contains(containerName)
            && containerName.Length is >= 3 and <= 63
            && char.IsAsciiLetterOrDigit(containerName[0])
            && char.IsAsciiLetterOrDigit(containerName[^1])
            && containerName.All(character =>
                char.IsAsciiLetterOrDigit(character) && !char.IsUpper(character)
                || character == '-')
            && !containerName.Contains("--", StringComparison.Ordinal);
    }

    private static bool TryGetImageContentType(string blobName, out string contentType)
    {
        contentType = Path.GetExtension(blobName).ToLowerInvariant() switch
        {
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".gif" => "image/gif",
            ".webp" => "image/webp",
            ".bmp" => "image/bmp",
            ".avif" => "image/avif",
            ".tif" or ".tiff" => "image/tiff",
            _ => string.Empty
        };

        return contentType.Length > 0;
    }

    public sealed record MenuImage(string Name, string ImageUrl);
}