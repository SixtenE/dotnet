using Microsoft.AspNetCore.Mvc;
using OpenAI;
using OpenAI.Chat;
using System.ClientModel;
using System.ClientModel.Primitives;
using System.Net.Http;
using System.Text.Json;

namespace DotNet8.WebApi.Controllers;

public class GroqProviderHandler : DelegatingHandler
{
    public GroqProviderHandler() : base(new HttpClientHandler()) { }

    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken ct)
    {
        if (request.Content is not null &&
            request.Method == HttpMethod.Post)
        {
            var json = await request.Content.ReadAsStringAsync(ct);
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;

            using var ms = new MemoryStream();
            using (var writer = new Utf8JsonWriter(ms))
            {
                writer.WriteStartObject();

                foreach (var prop in root.EnumerateObject())
                {
                    if (prop.NameEquals("provider"))
                    {
                        continue;
                    }

                    prop.WriteTo(writer);
                }

                writer.WritePropertyName("provider");
                writer.WriteStartObject();
                writer.WritePropertyName("order");
                writer.WriteStartArray();
                writer.WriteStringValue("Groq");
                writer.WriteEndArray();
                writer.WriteBoolean("allow_fallbacks", false);
                writer.WriteEndObject();

                writer.WriteEndObject();
            }

            request.Content = new ByteArrayContent(ms.ToArray())
            {
                Headers =
                {
                    ContentType = new("application/json")
                }
            };
        }

        return await base.SendAsync(request, ct);
    }
}

[ApiController]
[Route("[controller]")]
public class HelloWorldController(ILogger<HelloWorldController> logger, IConfiguration configuration) : ControllerBase {
    public sealed class GenerateRequest {
        public string Prompt { get; init; } = string.Empty;
        public string AiModel { get; init; } = string.Empty;
    }


    [HttpGet] [Route("")]// Matches GET requests to /HelloWorld
    public IActionResult GetHelloWorld() {
        logger.LogInformation("Hello World endpoint was hit.");

        return Ok("Hello, please check the README.md file for more information.");
    }

    [HttpGet("echo")]// Matches GET requests to /HelloWorld/echo
    public IActionResult GetEcho([FromQuery] string message) {

        if (string.IsNullOrEmpty(message)){
            logger.LogWarning("No message provided to the Echo endpoint.");

            return BadRequest("Please provide a message to echo.");
        }

        logger.LogInformation($"Echo endpoint was hit with message: {message}");

        return Ok($"Echo: {message}");
    }

    [HttpGet("/health")]
    public IActionResult GetHealth() {
        return Ok("Healthy Sean");
    }

    [HttpPost("/generate")] // Matches POST requests to /generate
    [Consumes("application/json")]
    public async Task<IActionResult> GenerateAsync([FromBody] GenerateRequest request) {
        if (string.IsNullOrWhiteSpace(request.Prompt)) {
            return BadRequest("Please provide a prompt in the request body.");
        }
        if (string.IsNullOrWhiteSpace(request.AiModel)) {
            return BadRequest("Please provide an aiModel in the request body.");
        }

        string? apiKey = configuration["OpenRouter:ApiKey"];
        if (string.IsNullOrWhiteSpace(apiKey)) {
            logger.LogError("OpenRouter API key is not configured.");
            return StatusCode(500, "Server configuration error: OpenRouter API key is missing.");
        }

        OpenAIClientOptions options = new() {
            Endpoint = new Uri("https://openrouter.ai/api/v1")
        };
        options.Transport = new HttpClientPipelineTransport(new HttpClient(new GroqProviderHandler()));

        ApiKeyCredential credential = new(apiKey);
        ChatClient client = new(request.AiModel, credential, options);

        ClientResult<ChatCompletion> response = await client.CompleteChatAsync(request.Prompt);
        string? answer = response.Value.Content.FirstOrDefault()?.Text;

        if (string.IsNullOrWhiteSpace(answer)) {
            return StatusCode(502, "The AI provider returned an empty response.");
        }

        return Ok(answer);
    }
}