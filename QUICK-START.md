# Quick Start Examples for EF Scaffolding

## Most Common Use Cases

### 1. First Time Scaffolding
```powershell
# Run from repository root
.\scaffold-db.ps1
```
This will:
- Read connection string from App.config
- Install EF tools if needed
- Prompt for confirmation
- Generate all entity classes

### 2. Update After Database Changes
```powershell
# Force overwrite to update entities after schema changes
.\scaffold-db.ps1 -Force
```
Use this when:
- You modified database tables
- You added/removed columns
- You changed relationships

### 3. Scaffold Specific Tables Only
```powershell
# Only generate entities for selected tables
.\scaffold-db.ps1 -Tables "Users,Products,Orders,Categories" -Force
```
Useful when:
- Working with a large database
- Only need specific tables
- Testing the scaffold process

### 4. Use Different Database
```powershell
# Connect to a different database
.\scaffold-db.ps1 -ConnectionString "Server=localhost;Database=TestDb;Trusted_Connection=True;TrustServerCertificate=True;"
```

### 5. Custom Output Location
```powershell
# Put entities in a different folder
.\scaffold-db.ps1 -OutputDir "Entities" -ContextDir "Database" -Force
```

## Pre-Scaffolding Checklist

Before running the script, ensure:

- [ ] Database exists and has tables
- [ ] Connection string in App.config is correct
- [ ] You have permissions to access the database
- [ ] SQL Server/LocalDB service is running
- [ ] .NET SDK is installed

## Testing Your Connection

Test your database connection before scaffolding:

```powershell
# Quick connection test using sqlcmd (if available)
sqlcmd -S "(localdb)\mssqllocaldb" -Q "SELECT @@VERSION"

# Or using PowerShell
dotnet ef dbcontext info --project StacksOfSnaps/StacksOfSnaps.csproj
```

## After Scaffolding

Once scaffolding completes:

1. **Review Generated Files**
   - Check `StacksOfSnaps/Data/Models/` for entity classes
   - Review `StacksOfSnaps/Data/ApplicationDbContext.cs`

2. **Build the Project**
   ```powershell
   dotnet build StacksOfSnaps/StacksOfSnaps.csproj
   ```

3. **Commit to Version Control**
   ```powershell
   git add StacksOfSnaps/Data/
   git commit -m "Update entity models from database"
   ```

## Common Scenarios

### Scenario: Table Added to Database
```powershell
# Re-scaffold to add the new table
.\scaffold-db.ps1 -Force
```

### Scenario: Column Added/Removed
```powershell
# Re-scaffold to update entity properties
.\scaffold-db.ps1 -Force
```

### Scenario: Working with Multiple Databases
```powershell
# Development database
.\scaffold-db.ps1 -ConnectionString "Server=(localdb)\mssqllocaldb;Database=DevDb;Trusted_Connection=True;"

# Production snapshot (don't use -Force to review changes first)
.\scaffold-db.ps1 -ConnectionString "Server=prod-server;Database=ProdDb;User Id=readonly;Password=***;"
```

### Scenario: Large Database - Incremental Scaffolding
```powershell
# First, scaffold core tables
.\scaffold-db.ps1 -Tables "Users,Roles,Permissions" -Force

# Then add more tables
.\scaffold-db.ps1 -Tables "Products,Categories,Inventory" -Force

# Finally, add remaining tables
.\scaffold-db.ps1 -Force
```

## Troubleshooting Quick Fixes

### Error: "Connection string not found"
**Fix:** Edit `StacksOfSnaps/App.config` and add:
```xml
<add name="DefaultConnection" 
     connectionString="Server=(localdb)\mssqllocaldb;Database=StacksOfSnapsDb;Trusted_Connection=True;" 
     providerName="Microsoft.EntityFrameworkCore.SqlServer" />
```

### Error: "Cannot connect to database"
**Fix:** Ensure SQL Server is running:
```powershell
# Start LocalDB
sqllocaldb start mssqllocaldb

# Check LocalDB instances
sqllocaldb info
```

### Error: "No tables found"
**Fix:** Verify database has tables:
```powershell
sqlcmd -S "(localdb)\mssqllocaldb" -d StacksOfSnapsDb -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES"
```

### Error: "dotnet ef command not found"
**Fix:** Install EF tools:
```powershell
dotnet tool install --global dotnet-ef
```

## Integration with Git

### Recommended .gitignore Entries
The repository should already have these in `.gitignore`, but verify:
```
# Build artifacts
bin/
obj/

# User-specific files
*.user
*.suo
```

**Note:** Generated entity classes SHOULD be committed to version control!

## Next Steps

After successful scaffolding:

1. Review the generated entity classes
2. Add any custom properties using partial classes
3. Update your application to use the DbContext
4. Test database operations
5. See [SCAFFOLD-GUIDE.md](SCAFFOLD-GUIDE.md) for advanced topics

## Need More Help?

- Full documentation: [SCAFFOLD-GUIDE.md](SCAFFOLD-GUIDE.md)
- Project overview: [README.md](README.md)
- PowerShell help: `Get-Help .\scaffold-db.ps1 -Detailed`
