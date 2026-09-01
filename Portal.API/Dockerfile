FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Alleen de 3 benodigde csproj bestanden voor de API kopiëren en restoren
COPY ["Portal.API/Portal.API.csproj", "Portal.API/"]
COPY ["Portal/Portal.csproj", "Portal/"]
COPY ["Portal.Data/Portal.Data.csproj", "Portal.Data/"]
RUN dotnet restore "Portal.API/Portal.API.csproj"

# Volledige source kopiëren en publiceren
COPY . .
WORKDIR "/src/Portal.API"
RUN dotnet publish "Portal.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "Portal.API.dll"]
