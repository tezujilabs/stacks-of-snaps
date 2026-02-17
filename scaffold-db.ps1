#Requires -Version 5.1

<#
.SYNOPSIS
    Scaffolds Entity Framework Core database models from an existing database.

.DESCRIPTION
    This script automates the process of scaffolding Entity Framework Core models
    from an existing database using the database-first approach. It reads the
    connection string from App.config and generates entity classes and updates
    the DbContext.

.PARAMETER ConnectionString
    The database connection string. If not provided, reads from App.config.

.PARAMETER OutputDir
    The output directory for generated entity classes. Default: "Data/Models"

.PARAMETER ContextName
    The name of the DbContext class. Default: "ApplicationDbContext"

.PARAMETER ContextDir
    The directory for the DbContext file. Default: "Data"

.PARAMETER Force
    Force overwrite existing files without prompting.

.PARAMETER Tables
    Comma-separated list of specific tables to scaffold. If not specified, all tables are scaffolded.

.EXAMPLE
    .\scaffold-db.ps1
    Scaffolds all tables using connection string from App.config

.EXAMPLE
    .\scaffold-db.ps1 -Force
    Scaffolds all tables and overwrites existing files without prompting

.EXAMPLE
    .\scaffold-db.ps1 -ConnectionString "Server=localhost;Database=MyDb;Trusted_Connection=True;"
    Scaffolds using a custom connection string

.EXAMPLE
    .\scaffold-db.ps1 -Tables "Users,Products"
    Scaffolds only the Users and Products tables

.NOTES
    Prerequisites:
    - .NET SDK must be installed
    - Entity Framework Core tools must be installed (dotnet ef)
    - Database must exist and be accessible
    - Connection string must be valid
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ConnectionString,

    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "Data/Models",

    [Parameter(Mandatory=$false)]
    [string]$ContextName = "ApplicationDbContext",

    [Parameter(Mandatory=$false)]
    [string]$ContextDir = "Data",

    [Parameter(Mandatory=$false)]
    [switch]$Force,

    [Parameter(Mandatory=$false)]
    [string]$Tables
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Helper function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to read connection string from App.config
function Get-ConnectionStringFromConfig {
    param(
        [string]$ConfigPath
    )
    
    if (-not (Test-Path $ConfigPath)) {
        throw "App.config not found at: $ConfigPath"
    }

    try {
        [xml]$config = Get-Content $ConfigPath
        $connectionString = $config.configuration.connectionStrings.add | 
            Where-Object { $_.name -eq "DefaultConnection" } | 
            Select-Object -ExpandProperty connectionString

        if ([string]::IsNullOrWhiteSpace($connectionString)) {
            throw "Connection string 'DefaultConnection' not found in App.config"
        }

        return $connectionString
    }
    catch {
        throw "Failed to read connection string from App.config: $_"
    }
}

# Function to check if dotnet ef tools are installed
function Test-EfToolsInstalled {
    try {
        $efVersion = dotnet ef --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Entity Framework Core tools found: $efVersion" "Green"
            return $true
        }
    }
    catch {
        return $false
    }
    return $false
}

# Function to install dotnet ef tools
function Install-EfTools {
    Write-ColorOutput "`nEntity Framework Core tools not found." "Yellow"
    Write-ColorOutput "Installing dotnet-ef tools globally..." "Yellow"
    
    try {
        dotnet tool install --global dotnet-ef
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Successfully installed dotnet-ef tools" "Green"
            return $true
        }
        else {
            throw "Failed to install dotnet-ef tools"
        }
    }
    catch {
        Write-ColorOutput "✗ Failed to install dotnet-ef tools: $_" "Red"
        Write-ColorOutput "`nPlease install manually using: dotnet tool install --global dotnet-ef" "Yellow"
        return $false
    }
}

# Main script execution
try {
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "  EF Core Database Scaffold Script" "Cyan"
    Write-ColorOutput "========================================`n" "Cyan"

    # Determine the project directory
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $projectDir = Join-Path $scriptDir "StacksOfSnaps"
    
    if (-not (Test-Path $projectDir)) {
        throw "Project directory not found at: $projectDir"
    }

    Write-ColorOutput "Project directory: $projectDir" "Gray"
    
    # Change to project directory
    Push-Location $projectDir

    try {
        # Check if .csproj exists
        $csprojPath = Join-Path $projectDir "StacksOfSnaps.csproj"
        if (-not (Test-Path $csprojPath)) {
            throw "Project file not found at: $csprojPath"
        }

        Write-ColorOutput "✓ Project file found" "Green"

        # Check/Install EF tools
        if (-not (Test-EfToolsInstalled)) {
            if (-not (Install-EfTools)) {
                throw "Cannot proceed without EF Core tools"
            }
        }

        # Get connection string
        if ([string]::IsNullOrWhiteSpace($ConnectionString)) {
            Write-ColorOutput "`nReading connection string from App.config..." "Gray"
            $configPath = Join-Path $projectDir "App.config"
            $ConnectionString = Get-ConnectionStringFromConfig -ConfigPath $configPath
            Write-ColorOutput "✓ Connection string loaded from App.config" "Green"
        }
        else {
            Write-ColorOutput "✓ Using provided connection string" "Green"
        }

        # Build the scaffold command
        $scaffoldCmd = "dotnet ef dbcontext scaffold `"$ConnectionString`" Microsoft.EntityFrameworkCore.SqlServer"
        $scaffoldCmd += " -o `"$OutputDir`""
        $scaffoldCmd += " -c $ContextName"
        $scaffoldCmd += " --context-dir `"$ContextDir`""
        
        if ($Force) {
            $scaffoldCmd += " --force"
        }

        if (-not [string]::IsNullOrWhiteSpace($Tables)) {
            $tableList = $Tables -split ','
            foreach ($table in $tableList) {
                $scaffoldCmd += " -t $($table.Trim())"
            }
        }

        # Display configuration
        Write-ColorOutput "`n----------------------------------------" "Cyan"
        Write-ColorOutput "Scaffold Configuration:" "Cyan"
        Write-ColorOutput "----------------------------------------" "Cyan"
        Write-ColorOutput "Output Directory : $OutputDir" "White"
        Write-ColorOutput "Context Name     : $ContextName" "White"
        Write-ColorOutput "Context Directory: $ContextDir" "White"
        Write-ColorOutput "Force Overwrite  : $Force" "White"
        if (-not [string]::IsNullOrWhiteSpace($Tables)) {
            Write-ColorOutput "Tables          : $Tables" "White"
        }
        else {
            Write-ColorOutput "Tables          : All tables" "White"
        }
        Write-ColorOutput "----------------------------------------`n" "Cyan"

        # Confirm before proceeding (unless Force is specified)
        if (-not $Force) {
            $confirmation = Read-Host "Do you want to proceed with scaffolding? (Y/N)"
            if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
                Write-ColorOutput "`nScaffolding cancelled by user." "Yellow"
                exit 0
            }
        }

        # Execute scaffold command
        Write-ColorOutput "`nExecuting scaffold command..." "Yellow"
        Write-ColorOutput "Command: $scaffoldCmd`n" "Gray"
        
        Invoke-Expression $scaffoldCmd
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "`n========================================" "Green"
            Write-ColorOutput "  ✓ Scaffolding completed successfully!" "Green"
            Write-ColorOutput "========================================" "Green"
            Write-ColorOutput "`nGenerated files:" "White"
            Write-ColorOutput "- Entity classes in: $OutputDir" "White"
            Write-ColorOutput "- DbContext in: $ContextDir/$ContextName.cs`n" "White"
        }
        else {
            throw "Scaffold command failed with exit code: $LASTEXITCODE"
        }
    }
    finally {
        # Return to original directory
        Pop-Location
    }
}
catch {
    Write-ColorOutput "`n========================================" "Red"
    Write-ColorOutput "  ✗ Scaffolding failed!" "Red"
    Write-ColorOutput "========================================" "Red"
    Write-ColorOutput "Error: $_`n" "Red"
    
    Write-ColorOutput "Troubleshooting tips:" "Yellow"
    Write-ColorOutput "1. Ensure the database exists and is accessible" "Yellow"
    Write-ColorOutput "2. Verify the connection string in App.config" "Yellow"
    Write-ColorOutput "3. Check that you have permissions to access the database" "Yellow"
    Write-ColorOutput "4. Ensure .NET SDK and EF Core tools are installed" "Yellow"
    Write-ColorOutput "5. Run 'dotnet ef' to verify EF tools are available`n" "Yellow"
    
    exit 1
}
