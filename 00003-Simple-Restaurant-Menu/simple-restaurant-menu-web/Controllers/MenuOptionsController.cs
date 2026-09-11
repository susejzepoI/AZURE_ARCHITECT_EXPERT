using Microsoft.AspNetCore.Mvc;

namespace simple_restaurant_menu_web.Controllers;

[ApiController]
[Route("[controller]")]
public class MenuOptionsController : ControllerBase
{
    private static readonly string[] Options = new[]
    {
        "starters", "mains", "desserts", "sides", "non-alcoholic-beverages", "alcoholic-beverages", "backups"
    };

    private readonly ILogger<MenuOptionsController> _logger;

    public MenuOptionsController(ILogger<MenuOptionsController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    public IEnumerable<string> Get()
    {
        return Options;
    }
}