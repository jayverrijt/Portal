using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Portal.Data;
using Portal.Data.Repositories;
using Portal.Domain.Entities;
using Xunit;

namespace Portal.Tests;

public class ProjectSharingTests
{
    private PortalDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<PortalDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        return new PortalDbContext(options);
    }

    [Fact]
    public async Task GetProjectsForUserAsync_ShouldInclude_SharedProjects()
    {
        // Arrange
        var context = CreateDbContext();
        var ownerId = "owner-user-1";
        var sharedUserId = "shared-user-2";

        var sharedUser = new ApplicationUser
        {
            Id = sharedUserId,
            UserName = "test@portal.local",
            Email = "test@portal.local"
        };

        var project = new Project
        {
            Id = Guid.NewGuid(),
            Title = "Portal Shared Test Project",
            OwnerId = ownerId,
            SharedWithUsers = new List<ApplicationUser> { sharedUser }
        };

        context.Users.Add(sharedUser);
        context.Projects.Add(project);
        await context.SaveChangesAsync();

        var repo = new ProjectRepository(context);

        // Act
        var results = (await repo.GetProjectsForUserAsync(sharedUserId)).ToList();

        // Assert
        results.Should().NotBeEmpty();
        results.Should().ContainSingle(p => p.Id == project.Id);
    }
}