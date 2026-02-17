# Entity Framework Core - Database-First Setup

This project is configured to use Entity Framework Core with a **Database-First** approach.

## Prerequisites

1. SQL Server or LocalDB installed
2. A database created with tables
3. .NET 8.0 SDK
4. Entity Framework Core tools

## Setup Instructions

### 1. Install EF Core Tools (if not already installed)

```bash
dotnet tool install --global dotnet-ef
```

### 2. Configure Connection String

Update the connection string in `App.config`:

```xml
<connectionStrings>
  <add name="DefaultConnection" 
       connectionString="YOUR_CONNECTION_STRING_HERE" 
       providerName="Microsoft.EntityFrameworkCore.SqlServer" />
</connectionStrings>
```

**Connection String Examples:**

- **LocalDB**: `Server=(localdb)\mssqllocaldb;Database=StacksOfSnapsDb;Trusted_Connection=True;`
- **SQL Server (Windows Auth)**: `Server=localhost;Database=StacksOfSnapsDb;Integrated Security=True;TrustServerCertificate=True;`
- **SQL Server (SQL Auth)**: `Server=localhost;Database=StacksOfSnapsDb;User Id=sa;Password=YourPassword;TrustServerCertificate=True;`

### 3. Scaffold Database

Run the following command from the project directory to generate entity classes and DbContext from your existing database:

```bash
dotnet ef dbcontext scaffold "YourConnectionString" Microsoft.EntityFrameworkCore.SqlServer -o Data/Models -c ApplicationDbContext --context-dir Data --force
```

**Example:**

```bash
dotnet ef dbcontext scaffold "Server=(localdb)\mssqllocaldb;Database=StacksOfSnapsDb;Trusted_Connection=True;" Microsoft.EntityFrameworkCore.SqlServer -o Data/Models -c ApplicationDbContext --context-dir Data --force
```

This command will:
- Generate entity classes in the `Data/Models` folder
- Update `ApplicationDbContext.cs` with DbSet properties
- Add model configurations in `OnModelCreating`

### 4. Using the DbContext

After scaffolding, you can use the DbContext in your application:

```csharp
using StacksOfSnaps.Data;

// Create a new instance of the DbContext
using (var context = new ApplicationDbContext())
{
    // Query data
    var items = context.YourEntity.ToList();
    
    // Add new data
    context.YourEntity.Add(new YourEntity { /* properties */ });
    context.SaveChanges();
}
```

## Database-First Workflow

1. **Make changes to the database** using SQL Server Management Studio or other tools
2. **Re-scaffold** the DbContext to update entity classes:
   ```bash
   dotnet ef dbcontext scaffold "YourConnectionString" Microsoft.EntityFrameworkCore.SqlServer -o Data/Models -c ApplicationDbContext --context-dir Data --force
   ```

## Important Notes

- The `--force` flag will overwrite existing files, so be careful if you've made manual changes
- Entity classes will be generated as partial classes, allowing you to extend them
- The `ApplicationDbContext` is also a partial class with a `OnModelCreatingPartial` method for custom configurations
- Never commit sensitive connection strings to source control

## Packages Included

- `Microsoft.EntityFrameworkCore` (v8.0.0) - Core EF functionality
- `Microsoft.EntityFrameworkCore.SqlServer` (v8.0.0) - SQL Server provider
- `Microsoft.EntityFrameworkCore.Tools` (v8.0.0) - EF Core tools for scaffolding
- `Microsoft.EntityFrameworkCore.Design` (v8.0.0) - Design-time support
- `System.Configuration.ConfigurationManager` (v8.0.0) - For reading App.config
