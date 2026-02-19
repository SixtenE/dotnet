using Microsoft.AspNetCore.Mvc;

namespace DotNet8.WebApi.Controllers;

[ApiController]
[Route("[controller]")]
public class HelloWorldController(ILogger<HelloWorldController> logger) : ControllerBase {

    [HttpGet] [Route("")]// Matches GET requests to /HelloWorld
    public IActionResult GetHelloWorld() {
        logger.LogInformation("Hello World endpoint was hit.");

        return Ok("Hello World! 🍡");
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
}
