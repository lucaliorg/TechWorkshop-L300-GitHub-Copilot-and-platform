using Microsoft.AspNetCore.Mvc;
using OpenAI.Chat;
using ZavaStorefront.Services;

namespace ZavaStorefront.Controllers;

public class ChatController : Controller
{
    private readonly ChatService _chatService;
    private readonly ILogger<ChatController> _logger;

    public ChatController(ChatService chatService, ILogger<ChatController> logger)
    {
        _chatService = chatService;
        _logger = logger;
    }

    public IActionResult Index()
    {
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> Send([FromBody] ChatRequest request)
    {
        if (string.IsNullOrWhiteSpace(request?.Message))
        {
            return BadRequest(new { error = "Message cannot be empty." });
        }

        var messages = new List<ChatMessage>
        {
            new SystemChatMessage("You are a helpful assistant for Zava Storefront customers."),
            new UserChatMessage(request.Message)
        };

        _logger.LogInformation("Sending chat message to AI endpoint");
        var response = await _chatService.GetResponseAsync(messages);

        return Json(new { response });
    }
}

public class ChatRequest
{
    public string? Message { get; set; }
}
