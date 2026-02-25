FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/MyApi/MyApi.csproj src/MyApi/
RUN dotnet restore src/MyApi/MyApi.csproj
COPY src/MyApi/. src/MyApi/
RUN dotnet publish src/MyApi/MyApi.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MyApi.dll"]
