using Azure.Identity;
using Azure.Storage.Blobs;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();

// Add services to the container.
var blobServiceUri = builder.Configuration["BlobStorage:ServiceUri"]
                        ?? throw new InvalidOperationException("BlobStorage:ServiceUri is not configured in appsettings.json.");

builder.Services.AddSingleton(new BlobServiceClient(new Uri(blobServiceUri), new DefaultAzureCredential()));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();


app.MapControllerRoute(
    name: "default",
    pattern: "{controller}/{action=Index}/{id?}");

app.MapFallbackToFile("index.html");

app.Run();
