using C.SocietyApi.Core;

namespace C.SocietyApi.Tests;

public class UnitTest1
{
    [Fact]
    public void Test1()
    {
        var service = new BadgeService();

        var result = service.TestBadge();
        
        Assert.Equivalent("badge",result);
    }
}