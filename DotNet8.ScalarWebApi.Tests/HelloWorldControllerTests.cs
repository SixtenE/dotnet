using System.Net;
using System.Net.Http.Headers;
using System.Text;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace DotNet8.ScalarWebApi.Tests;

public class HelloWorldControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public HelloWorldControllerTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetHelloWorld_ReturnsOk()
    {
        var response = await _client.GetAsync("/HelloWorld");

        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("Hello", content);
    }

    [Fact]
    public async Task GetEcho_WithMessage_ReturnsEcho()
    {
        var response = await _client.GetAsync("/HelloWorld/echo?message=test");

        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("Echo: test", content);
    }

    [Fact]
    public async Task GetEcho_WithoutMessage_ReturnsBadRequest()
    {
        var response = await _client.GetAsync("/HelloWorld/echo");

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task PostGenerate_WithoutPrompt_ReturnsBadRequest()
    {
        StringContent content = new("""{"prompt":"","aiModel":"anthropic/claude-sonnet-4"}""", Encoding.UTF8);
        content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

        var response = await _client.PostAsync("/generate", content);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
