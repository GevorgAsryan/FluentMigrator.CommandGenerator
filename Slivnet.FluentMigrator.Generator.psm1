function migrate-empty
{
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [parameter(Position = 0,
            Mandatory = $true)]
        [string] $Name,
        [string] $ProjectName,
        [switch] $AddTimeStampToClassName)
    $timestamp = (Get-Date -Format yyyyMMddHHmmss)
    $class_name_timestamp = (Get-Date -Format yyyyMMdd_HHmmss)

    if ($ProjectName) {
        $project = Get-Project $ProjectName
        if ($project -is [array])
        {
            throw "More than one project '$ProjectName' was found. Please specify the full name of the one to use."
        }
    }
    else {
        $project = Get-Project
    }
    
    # if the $name parameter contains a string '{T}', then replace it with the timestamp but with a underscore between the
    # yyyyMMdd part and the HHmmss part
    if ($AddTimeStampToClassName) {
        $name = [System.String]::Replace($name, "{T}", $class_name_timestamp)   
    }

    $namespace = $project.Properties.Item("DefaultNamespace").Value.ToString() + ".Migrations"
    $projectPath = [System.IO.Path]::GetDirectoryName($project.FullName)
    $migrationsPath = [System.IO.Path]::Combine($projectPath, "Migrations")
    $outputPath = [System.IO.Path]::Combine($migrationsPath, "$timestamp" + "_$name.cs")

    if (-not (Test-Path $migrationsPath))
    {
        [System.IO.Directory]::CreateDirectory($migrationsPath)
    }

    "using FluentMigrator;

namespace $namespace
{
    [Migration($timestamp)]
    public class $name : DatabaseMigrationBase
    {
        public override void Up()
        {
        }

        public override void Down()
        {
        }
    }
}" | Out-File -Encoding "UTF8" -Force $outputPath

    $project.ProjectItems.AddFromFile($outputPath)
    $project.Save($null)
}



function migrate-sql
{
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [parameter(Position = 0,
            Mandatory = $true)]
        [string] $Name,
        [string] $ProjectName,
        [switch] $AddTimeStampToClassName)
    $timestamp = (Get-Date -Format yyyyMMddHHmmss)
    $class_name_timestamp = (Get-Date -Format yyyyMMdd_HHmmss)

    if ($ProjectName) {
        $project = Get-Project $ProjectName
        if ($project -is [array])
        {
            throw "More than one project '$ProjectName' was found. Please specify the full name of the one to use."
        }
    }
    else {
        $project = Get-Project
    }
    
    # if the $name parameter contains a string '{T}', then replace it with the timestamp but with a underscore between the
    # yyyyMMdd part and the HHmmss part
    if ($AddTimeStampToClassName) {
        $name = [System.String]::Replace($name, "{T}", $class_name_timestamp)   
    }

    $namespace = $project.Properties.Item("DefaultNamespace").Value.ToString() + ".Migrations"
    $projectPath = [System.IO.Path]::GetDirectoryName($project.FullName)
    $migrationsPath = [System.IO.Path]::Combine($projectPath, "Migrations")
    $sqlMigrationPath = [System.IO.Path]::Combine($projectPath, "Sqls")
    $migrationoutputPath = [System.IO.Path]::Combine($migrationsPath, "$timestamp" + "_$name.cs")
    $sqloutputPath = [System.IO.Path]::Combine($sqlMigrationPath, "$timestamp" + "_$name.sql")
    $sqlDirectoryAfterBuild = "Sqls/"+ "$timestamp" + "_$name.sql"

    # Creating Migration File

    if (-not (Test-Path $migrationsPath))
    {
        [System.IO.Directory]::CreateDirectory($migrationsPath)
    }

    "using FluentMigrator;
using Kofile.Vanguard.Database.Migrator.Utils;

namespace $namespace
{
    [Tags(""TENANT"")]
    [Migration($timestamp)]
    public class $name : DatabaseMigrationBase
    {
        public override void Up()
        {
            Execute.Sql(SqlResolver.GetMigrationSqlWithCurrentTenantSchema(@""$sqlDirectoryAfterBuild""));
        }

        public override void Down()
        {
        }
    }
}" | Out-File -Encoding "UTF8" -Force $migrationoutputPath

    $project.ProjectItems.AddFromFile($migrationoutputPath)
    $project.Save($null)

    # Create Sql File 
        if (-not (Test-Path $sqlMigrationPath))
    {
        [System.IO.Directory]::CreateDirectory($sqlMigrationPath)
    }

    "-- please alter database object if you want to change existing objects" | Out-File -Encoding "UTF8" -Force $sqloutputPath

    $project.ProjectItems.AddFromFile($sqloutputPath)
    $project.Save($null)


}

function migrate-vanguard-sql
{
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [parameter(Position = 0,
            Mandatory = $true)]
        [string] $Name,
        [string] $ProjectName,
        [switch] $AddTimeStampToClassName)
    $timestamp = (Get-Date -Format yyyyMMddHHmmss)
    $class_name_timestamp = (Get-Date -Format yyyyMMdd_HHmmss)

    if ($ProjectName) {
        $project = Get-Project $ProjectName
        if ($project -is [array])
        {
            throw "More than one project '$ProjectName' was found. Please specify the full name of the one to use."
        }
    }
    else {
        $project = Get-Project
    }
    
    # if the $name parameter contains a string '{T}', then replace it with the timestamp but with a underscore between the
    # yyyyMMdd part and the HHmmss part
    if ($AddTimeStampToClassName) {
        $name = [System.String]::Replace($name, "{T}", $class_name_timestamp)   
    }

    $namespace = $project.Properties.Item("DefaultNamespace").Value.ToString() + ".Migrations"
    $projectPath = [System.IO.Path]::GetDirectoryName($project.FullName)
    $migrationsPath = [System.IO.Path]::Combine($projectPath, "Migrations")
    $sqlMigrationPath = [System.IO.Path]::Combine($projectPath, "Sqls/VANGUARD")
    $migrationoutputPath = [System.IO.Path]::Combine($migrationsPath, "$timestamp" + "_$name.cs")
    $sqloutputPath = [System.IO.Path]::Combine($sqlMigrationPath, "$timestamp" + "_VANGUARD" + "_$name.sql")
    $sqlDirectoryAfterBuild = "Sqls/VANGUARD/"+ "$timestamp" + "_VANGUARD" + "_$name.sql"

    # Creating Migration File

    if (-not (Test-Path $migrationsPath))
    {
        [System.IO.Directory]::CreateDirectory($migrationsPath)
    }

    "using FluentMigrator;
using Kofile.Vanguard.Database.Migrator.Utils;

namespace $namespace
{
    [Tags(""VANGUARD"")]
    [Migration($timestamp)]
    public class $name : DatabaseMigrationBase
    {
        public override void Up()
        {
            Execute.Script(@""$sqlDirectoryAfterBuild"");
        }

        public override void Down()
        {
        }
    }
}" | Out-File -Encoding "UTF8" -Force $migrationoutputPath

    $project.ProjectItems.AddFromFile($migrationoutputPath)
    $project.Save($null)

    # Create Sql File 
        if (-not (Test-Path $sqlMigrationPath))
    {
        [System.IO.Directory]::CreateDirectory($sqlMigrationPath)
    }

    "-- please alter database object if you want to change existing objects" | Out-File -Encoding "UTF8" -Force $sqloutputPath

    $project.ProjectItems.AddFromFile($sqloutputPath)
    $project.Save($null)


}

Export-ModuleMember @( 'migrate-vanguard-sql' )
Export-ModuleMember @( 'migrate-empty' )
Export-ModuleMember @( 'migrate-sql' )
