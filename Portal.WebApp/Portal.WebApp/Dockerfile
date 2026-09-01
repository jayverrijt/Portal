FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Csproj bestanden voor de Blazor WebApp en Client kopiëren en restoren
COPY ["Portal.WebApp/Portal.WebApp/Portal.WebApp.csproj", "Portal.WebApp/Portal.WebApp/"]
COPY ["Portal.WebApp/Portal.WebApp.Client/Portal.WebApp.Client.csproj", "Portal.WebApp/Portal.WebApp.Client/"]
COPY ["Portal/Portal.csproj", "Portal/"]
RUN dotnet restore "Portal.WebApp/Portal.WebApp/Portal.WebApp.csproj"

# Volledige source kopiëren en publiceren
COPY . .
WORKDIR "/src/Portal.WebApp/Portal.WebApp"
RUN dotnet publish "Portal.WebApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "Portal.WebApp.dll"]
