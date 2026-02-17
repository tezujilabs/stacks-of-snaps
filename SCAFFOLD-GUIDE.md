# EF Core Database Scaffolding Guide

This guide explains how to use the PowerShell script to scaffold Entity Framework Core models from an existing database.

## Prerequisites

1. **.NET SDK** - Must be installed (version 8.0 or later)
2. **Entity Framework Core Tools** - The script will attempt to install if missing
3. **Database** - Must exist and be accessible
4. **Connection String** - Must be configured in `StacksOfSnaps/App.config`

## Quick Start

### Basic Usage

Run the script from the repository root:

```powershell
.\scaffold-db.ps1
```

This will:
- Read the connection string from `App.config`
- Scaffold all tables from the database
- Generate entity classes in `StacksOfSnaps/Data/Models/`
- Update `ApplicationDbContext` in `StacksOfSnaps/Data/`

### Force Overwrite

To overwrite existing files without confirmation:

```powershell
.\scaffold-db.ps1 -Force
```

### Custom Connection String

To use a different connection string:

```powershell
.\scaffold-db.ps1 -ConnectionString "Server=localhost;Database=MyDb;Trusted_Connection=True;TrustServerCertificate=True;"
```

### Scaffold Specific Tables

To scaffold only specific tables:

```powershell
.\scaffold-db.ps1 -Tables "Users,Products,Orders"
```

### Custom Output Directories

To customize where files are generated:

```powershell
.\scaffold-db.ps1 -OutputDir "Models" -ContextDir "Data/Context"
```

## Advanced Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `-ConnectionString` | Database connection string | Read from App.config |
| `-OutputDir` | Directory for entity classes | `Data/Models` |
| `-ContextName` | Name of DbContext class | `ApplicationDbContext` |
| `-ContextDir` | Directory for DbContext file | `Data` |
| `-Force` | Overwrite without prompting | `false` |
| `-Tables` | Comma-separated list of tables | All tables |

## Examples

### Example 1: Basic Scaffold
```powershell
.\scaffold-db.ps1
```

### Example 2: Scaffold with Force Overwrite
```powershell
.\scaffold-db.ps1 -Force
```

### Example 3: Scaffold Specific Tables
```powershell
.\scaffold-db.ps1 -Tables "Customers,Orders,Products" -Force
```

### Example 4: Custom Configuration
```powershell
.\scaffold-db.ps1 `
    -ConnectionString "Server=(localdb)\mssqllocaldb;Database=StacksOfSnapsDb;Trusted_Connection=True;" `
    -OutputDir "Entities" `
    -ContextName "MyDbContext" `
    -ContextDir "Data/Context" `
    -Force
```

## Configuring Connection String

Edit `StacksOfSnaps/App.config` to set your connection string:

```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <connectionStrings>
    <add name="DefaultConnection" 
         connectionString="Server=(localdb)\mssqllocaldb;Database=StacksOfSnapsDb;Trusted_Connection=True;" 
         providerName="Microsoft.EntityFrameworkCore.SqlServer" />
  </connectionStrings>
</configuration>
```

### Common Connection String Formats

**LocalDB:**
```
Server=(localdb)\mssqllocaldb;Database=StacksOfSnapsDb;Trusted_Connection=True;
```

**SQL Server (Windows Authentication):**
```
Server=localhost;Database=StacksOfSnapsDb;Integrated Security=True;TrustServerCertificate=True;
```

**SQL Server (SQL Authentication):**
```
Server=localhost;Database=StacksOfSnapsDb;User Id=sa;Password=YourPassword;TrustServerCertificate=True;
```

**Azure SQL Database:**
```
Server=tcp:yourserver.database.windows.net,1433;Database=StacksOfSnapsDb;User ID=yourusername;Password=yourpassword;Encrypt=True;TrustServerCertificate=False;
```

## Troubleshooting

### EF Tools Not Found

If you see an error about EF tools not being found, install them manually:

```powershell
dotnet tool install --global dotnet-ef
```

Or update existing tools:

```powershell
dotnet tool update --global dotnet-ef
```

### Connection Failed

1. Verify the database exists
2. Check the connection string in `App.config`
3. Ensure you have necessary permissions
4. Test the connection using SQL Server Management Studio or Azure Data Studio

### Files Not Generated

1. Ensure the database has tables
2. Check that the output directories exist or can be created
3. Run with `-Force` to overwrite existing files

### Permission Denied

Run PowerShell as Administrator if you encounter permission issues.

## What Gets Generated

When you run the scaffold script, the following files are created/updated:

1. **Entity Classes** - One class per table in `Data/Models/`:
   - Properties matching database columns
   - Navigation properties for relationships
   - Data annotations for constraints

2. **DbContext** - Updated `ApplicationDbContext.cs` in `Data/`:
   - DbSet properties for each entity
   - Fluent API configuration in `OnModelCreating`
   - Relationship configurations

## Database-First Workflow

1. **Create/Update Database** - Make changes to your database schema
2. **Run Scaffold Script** - Execute `.\scaffold-db.ps1 -Force`
3. **Review Generated Code** - Check entity classes and DbContext
4. **Use in Application** - Access data through the DbContext

## Best Practices

1. **Version Control** - Commit generated files to track changes
2. **Backup First** - Backup existing files before re-scaffolding
3. **Custom Code** - Use partial classes to add custom code that won't be overwritten
4. **Regular Updates** - Re-scaffold when database schema changes
5. **Test Connection** - Verify database connection before scaffolding

## Script Features

- ✓ Automatic connection string reading from App.config
- ✓ EF Core tools installation check and auto-install
- ✓ Colored console output for better readability
- ✓ Error handling with helpful messages
- ✓ Confirmation prompt (unless using `-Force`)
- ✓ Support for selective table scaffolding
- ✓ Customizable output locations

## Getting Help

To see all available options:

```powershell
Get-Help .\scaffold-db.ps1 -Detailed
```

For examples:

```powershell
Get-Help .\scaffold-db.ps1 -Examples
```
