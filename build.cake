var target = Argument("target", "Default");

var artifactsDir = Directory("./artifacts");

Task("Clean")
    .Does(() =>
{
    CleanDirectory(artifactsDir);
});

Task("Package")
    .IsDependentOn("Clean")
    .Does(() =>
{
    NuGetPack("./FluentMigrator.CommandGenerator.nuspec", new NuGetPackSettings
    {
        OutputDirectory = artifactsDir,
    });
});

Task("Default")
    .IsDependentOn("Package");

RunTarget(target);
