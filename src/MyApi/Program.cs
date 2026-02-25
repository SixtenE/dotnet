var builder = WebApplication.CreateBuilder(args);

// Cloud Run expects applications to listen on port 8080.
builder.WebHost.UseUrls("http://0.0.0.0:8080");

var app = builder.Build();

app.MapGet("/health", () => "ok");

app.Run();
