using Microsoft.EntityFrameworkCore;

namespace StacksOfSnaps.Data
{
    /// <summary>
    /// Database context for Entity Framework Core - Database-First approach.
    /// 
    /// Database-First Setup Instructions:
    /// 1. Ensure you have a database created with tables
    /// 2. Update the connection string in App.config
    /// 3. Use the following command to scaffold the database:
    ///    dotnet ef dbcontext scaffold "YourConnectionString" Microsoft.EntityFrameworkCore.SqlServer -o Data/Models -c ApplicationDbContext --context-dir Data --force
    /// 
    /// Example:
    ///    dotnet ef dbcontext scaffold "Server=(localdb)\mssqllocaldb;Database=StacksOfSnapsDb;Trusted_Connection=True;" Microsoft.EntityFrameworkCore.SqlServer -o Data/Models -c ApplicationDbContext --context-dir Data --force
    /// 
    /// This will generate:
    /// - Entity classes in Data/Models folder
    /// - Updated ApplicationDbContext with DbSet properties and model configuration
    /// </summary>
    public partial class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext()
        {
        }

        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                // Read connection string from App.config
                var connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString;
                
                if (string.IsNullOrEmpty(connectionString))
                {
                    throw new InvalidOperationException(
                        "Database connection string 'DefaultConnection' is not configured in App.config. " +
                        "Please add a connection string to the <connectionStrings> section of App.config.");
                }
                
                optionsBuilder.UseSqlServer(connectionString);
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Model configuration will be scaffolded here when you run the scaffold command
            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
