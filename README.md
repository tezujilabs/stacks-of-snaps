# Stacks of Snaps

A WPF application using Entity Framework Core with a database-first approach.

## Overview

This project is built with:
- .NET 8.0
- WPF (Windows Presentation Foundation)
- Entity Framework Core 8.0
- SQL Server / LocalDB

## Database Setup

This application uses a **database-first** approach with Entity Framework Core. This means the database schema is the source of truth, and the entity classes are generated from the database.

### Prerequisites

1. .NET SDK 8.0 or later
2. SQL Server, SQL Server Express, or LocalDB
3. PowerShell 5.1 or later

### Quick Start

1. **Configure Connection String**
   
   Edit `StacksOfSnaps/App.config` and update the connection string:
   ```xml
   <add name="DefaultConnection" 
        connectionString="Server=(localdb)\mssqllocaldb;Database=StacksOfSnapsDb;Trusted_Connection=True;" 
        providerName="Microsoft.EntityFrameworkCore.SqlServer" />
   ```

2. **Create Your Database**
   
   Create a database with tables using your preferred tool (SQL Server Management Studio, Azure Data Studio, etc.)

3. **Scaffold Entity Models**
   
   Run the PowerShell script to generate entity classes from your database:
   ```powershell
   .\scaffold-db.ps1
   ```

   For more options and examples, see [SCAFFOLD-GUIDE.md](SCAFFOLD-GUIDE.md)

## EF Core Scaffolding

The repository includes a PowerShell script (`scaffold-db.ps1`) to automate Entity Framework Core scaffolding.

### Basic Usage

```powershell
# Scaffold all tables
.\scaffold-db.ps1

# Force overwrite existing files
.\scaffold-db.ps1 -Force

# Scaffold specific tables only
.\scaffold-db.ps1 -Tables "Users,Products,Orders"

# Use custom connection string
.\scaffold-db.ps1 -ConnectionString "Server=localhost;Database=MyDb;Trusted_Connection=True;"
```

### What the Script Does

- Reads connection string from `App.config` (or uses provided one)
- Checks and installs EF Core tools if needed
- Generates entity classes in `StacksOfSnaps/Data/Models/`
- Updates `ApplicationDbContext` in `StacksOfSnaps/Data/`
- Provides colored output and helpful error messages

For detailed documentation, see [SCAFFOLD-GUIDE.md](SCAFFOLD-GUIDE.md)

## Building the Application

```bash
dotnet build StacksOfSnaps/StacksOfSnaps.csproj
```

## Running the Application

```bash
dotnet run --project StacksOfSnaps/StacksOfSnaps.csproj
```

## Project Structure

```
stacks-of-snaps/
├── scaffold-db.ps1              # PowerShell script for EF scaffolding
├── SCAFFOLD-GUIDE.md            # Detailed scaffolding guide
└── StacksOfSnaps/
    ├── StacksOfSnaps.csproj     # Project file
    ├── App.config               # Configuration including connection strings
    ├── Data/
    │   ├── ApplicationDbContext.cs    # EF Core DbContext
    │   └── Models/              # Generated entity classes (after scaffolding)
    ├── App.xaml                 # WPF application definition
    └── MainWindow.xaml          # Main window UI
```

## Development Workflow

1. Make changes to your database schema
2. Run `.\scaffold-db.ps1 -Force` to regenerate entity models
3. Build and test your application
4. Commit the generated files to version control

## Database-First Best Practices

- **Version Control**: Always commit generated entity classes
- **Partial Classes**: Use partial classes to add custom code that won't be overwritten
- **Regular Updates**: Re-scaffold when database schema changes
- **Connection Strings**: Keep sensitive connection strings out of version control
- **Documentation**: Document your database schema changes

## Troubleshooting

### EF Tools Not Found

Install EF Core tools globally:
```powershell
dotnet tool install --global dotnet-ef
```

### Connection Issues

1. Verify SQL Server/LocalDB is running
2. Check connection string in `App.config`
3. Ensure you have permissions to access the database
4. Test connection using SQL Server Management Studio

### Scaffolding Fails

See [SCAFFOLD-GUIDE.md](SCAFFOLD-GUIDE.md) for detailed troubleshooting steps.

## License

[Add your license information here]

## Contributing

[Add contribution guidelines here]
