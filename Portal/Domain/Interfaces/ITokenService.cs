using Portal.Domain.Entities;

namespace Portal.Domain.Interfaces;

public interface ITokenService
{
    string CreateToken(ApplicationUser user);
}