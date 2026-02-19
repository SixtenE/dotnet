# WebApi Example with Scalar API Documentation
![.Net](https://img.shields.io/badge/.NET-5C2D91?style=for-the-badge&logo=.net&logoColor=white)
![C#](https://img.shields.io/badge/c%23-%23239120.svg?style=for-the-badge&logo=csharp&logoColor=white)

This project demonstrates a simple Web API built with ASP.NET Core **targeting .NET 8**, showcasing interactive API
documentation using [Scalar](https://github.com/domaindrivendev/Swashbuckle.AspNetCore).

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/_R3Eu2?referralCode=Al2B-n)

## Live Demonstration

This template offers a live demonstration of the API's functionality through the integrated Scalar UI.  This interactive environment provides a hands-on experience for understanding and testing the API endpoints.

**Access the Live API Demonstration:** [**View Interactive Demo**](https://dotnet8.scalarwebapi.dangos.dev/scalar/v1)

## Getting Started

Follow these steps to run the Web API example on your local machine.

### Prerequisites

- **[.NET SDK 8.0](https://dotnet.microsoft.com/download)** - Make sure you have the **.NET SDK 8.0** installed to build
  and run ASP.NET Core applications. This project is built and tested using **.NET 8**.

### Running the Application

1. **Clone the repository:** If you haven't already, clone this GitHub repository to your local machine.

``` bash
git clone https://github.com/dangos-dev/DotNet8.ScalarWebApi.git
cd DotNet8.ScalarWebApi
```

2. **Run the application:** Execute the following dotnet CLI command to start the Web API:

``` bash
 dotnet run
```

3. **Access API Documentation:** Once the application is running, you can access the API documentation through your web
   browser:
    - **Scalar UI:** Open your browser and navigate to the `/scalar` endpoint. For example:
      `https://localhost:5001/scalar/v1` or `http://localhost:5000/scalar/v1`. The specific port will be shown in the console
      output when you run the application.

    - **OpenAPI JSON:** The raw OpenAPI document in JSON format is available at `/openapi/v1.json`. For example:
      `https://localhost:5001/openapi/v1.json`

## API Endpoints

The `HelloWorldController` in this example provides the following endpoints:

- **GET /HelloWorld**

    - **Description:** Returns a simple "Hello World! 🍡" greeting message.
    - **Response Example (200 OK):**

      ```
      Hello World! 🍡
      ```

- **GET /HelloWorld/echo**

    - **Description:** This endpoint echoes back the message provided in the `message` query parameter.
    - **Query Parameters:**
        - `message` (string, required): The message you want to be echoed.
    - **Request Example:**

        ```
        /HelloWorld/echo?message=YourTestMessage
        ```

    - **Response Example (200 OK):**

        ```
        Echo: YourTestMessage
        ```

    - **Error Response (400 Bad Request):**
        - **Condition:** If the `message` query parameter is missing or empty.
        - **Response Body:**

            ```
            Please provide a message to echo.
            ```

## Key Files

Here are the key code files for this template:

- **`Program.cs`**: The main application startup file, configuring services and middleware, including Scalar for API
  documentation.

- **`Controllers/HelloWorldController.cs`**: Defines the `HelloWorldController` with the API endpoints.

  ``` csharp
      ApiController]  
      [Route("[controller]")]  
      public class HelloWorldController(ILogger<HelloWorldController> logger) : ControllerBase {  
    
          [HttpGet] [Route("")]// Matches GET requests to /HelloWorld  
          public IActionResult GetHelloWorld() {  
              logger.LogInformation("Hello World endpoint was hit.");  
    
              return Ok("Hello World! 🍡");  
          }
      }
  ```

## Scalar Configuration

Scalar API documentation is configured in `Program.cs` using the `app.MapScalarApiReference` extension method.

```csharp
app.MapScalarApiReference(
    opt => {
        opt.Title = "WebApi with Scalar Example";
        opt.Theme = ScalarTheme.BluePlanet;
        opt.DefaultHttpClient = new(ScalarTarget.Http, ScalarClient.Http11);
    }
);
```

- **`Title`**: Sets the title of the documentation displayed in the Scalar UI (e.g., "WebApi Example").
- **`Theme`**: Applies the `BluePlanet` theme to customize the appearance of the Scalar UI.
- **`DefaultHttpClient`**: Configures the default HTTP client settings for Scalar.

## Dependencies

This project relies on the following NuGet packages:

- [Scalar.AspNetCore](https://www.google.com/url?sa=E&source=gmail&q=https://www.nuget.org/packages/Scalar.AspNetCore):
  For integrating Scalar API documentation into ASP.NET Core.
- [Swashbuckle.AspNetCore.SwaggerGen](https://www.google.com/url?sa=E&source=gmail&q=https://www.nuget.org/packages/Swashbuckle.AspNetCore.SwaggerGen) & [Swashbuckle.AspNetCore.SwaggerUI](https://www.google.com/url?sa=E&source=gmail&q=https://www.nuget.org/packages/Swashbuckle.AspNetCore.SwaggerUI):
  Used by Scalar for OpenAPI document generation and UI.

## Author

This template is a basic example to help you get started with building ASP.NET Core Web APIs using .NET 8 and
documenting them with Scalar. Feel free to use and modify it for your own projects.