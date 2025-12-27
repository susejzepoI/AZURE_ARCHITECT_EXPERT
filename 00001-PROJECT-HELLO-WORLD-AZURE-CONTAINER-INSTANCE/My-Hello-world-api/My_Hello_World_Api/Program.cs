var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapGet("/", 
        () =>
        {
            var pEnvironmentVariable = Environment.GetEnvironmentVariable("APP_ENVIRONMENT") ?? "Not Set";
            return "Hello world from my Azure Container Instance (" + pEnvironmentVariable +")!.";
        }
        
        );

app.MapGet(
    "/info", () =>
    {
        var pEnvironmentVariable = Environment.GetEnvironmentVariable("APP_ENVIRONMENT") ?? "Not Set";
        return Results.Ok(
            new
            {
                ServiceCollection = "Hello World API",
                appEnv = pEnvironmentVariable,
                timeUTC = DateTime.UtcNow
            }
        );
    }
);

app.Run();