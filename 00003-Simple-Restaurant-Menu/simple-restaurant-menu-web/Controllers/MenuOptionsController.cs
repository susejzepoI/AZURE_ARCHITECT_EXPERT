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

    public MenuOptionsController(
        ILogger<MenuOptionsController> logger,
        BlobServiceClient blobServiceClient)
    {
        _logger = logger;
        _blobServiceClient = blobServiceClient;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<string>>> Get(
        CancellationToken cancellationToken)
    {
        var containerNames = new List<string>();
        try
        {
            await foreach (var container in _blobServiceClient.GetBlobContainersAsync(
                cancellationToken: cancellationToken))
            {
                containerNames.Add(container.Name);
            }

            return Ok(containerNames);
        }
        catch (RequestFailedException ex)
        {
            _logger.LogError(
                ex,
                "Error retrieving menu options from Blob Storage. Status code: {Status}.",
                ex.Status);
            return StatusCode(
                StatusCodes.Status503ServiceUnavailable,
                "Menu categories are temporarily unavailable.");
        }
        catch (AuthenticationFailedException ex)
        {
            _logger.LogError(ex, "Azure authentication failed while retrieving menu options.");
            return StatusCode(
                StatusCodes.Status503ServiceUnavailable,
                "Menu categories are temporarily unavailable.");
        }
    }
}