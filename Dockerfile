FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY DotNet8.ScalarWebApi.csproj ./
RUN dotnet restore DotNet8.ScalarWebApi.csproj
COPY . .
RUN dotnet publish DotNet8.ScalarWebApi.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "DotNet8.ScalarWebApi.dll"]
