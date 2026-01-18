// Cloud Quote API
// Code to Cloud - Azure Essentials Training
// Lesson 05: Windows Compute

using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();

var app = builder.Build();

// Quote data - inspirational cloud computing quotes
var quotes = new List<Quote>
{
    new(1, "There is no cloud, it's just someone else's computer... that scales infinitely.", "Unknown", "humor"),
    new(2, "Move fast and ship things. The cloud handles the rest.", "Code to Cloud", "philosophy"),
    new(3, "The cloud is not about the cloud. It's about what the cloud enables.", "Satya Nadella", "vision"),
    new(4, "Infrastructure as code: because clicking buttons doesn't scale.", "DevOps Wisdom", "automation"),
    new(5, "In the cloud, every problem is a scaling problem waiting to happen.", "Unknown", "architecture"),
    new(6, "Serverless is not about no servers. It's about no server management.", "Code to Cloud", "serverless"),
    new(7, "The best time to migrate to the cloud was yesterday. The second best time is now.", "Code to Cloud", "migration"),
    new(8, "Availability zones: because hardware fails, but your app shouldn't.", "Azure Best Practices", "reliability"),
    new(9, "Pay for what you use, scale for what you need.", "Cloud Economics", "cost"),
    new(10, "From code to cloud in minutes, not months.", "Code to Cloud", "devops")
};

// Root endpoint
app.MapGet("/", () => Results.Ok(new
{
    message = "☁️ Welcome to the Cloud Quote API!",
    version = "1.0.0",
    author = "Code to Cloud",
    endpoints = new[]
    {
        "GET /api/quotes - List all quotes",
        "GET /api/quotes/random - Get a random quote",
        "GET /api/quotes/{id} - Get a specific quote",
        "GET /health - Health check"
    }
}));

// Get all quotes
app.MapGet("/api/quotes", () => Results.Ok(new
{
    count = quotes.Count,
    quotes = quotes
}));

// Get random quote
app.MapGet("/api/quotes/random", () =>
{
    var random = new Random();
    var quote = quotes[random.Next(quotes.Count)];
    return Results.Ok(new
    {
        quote.Id,
        quote.Text,
        quote.Author,
        quote.Category,
        timestamp = DateTime.UtcNow
    });
});

// Get quote by ID
app.MapGet("/api/quotes/{id:int}", (int id) =>
{
    var quote = quotes.FirstOrDefault(q => q.Id == id);
    return quote is not null
        ? Results.Ok(quote)
        : Results.NotFound(new { error = "Quote not found", id });
});

// Health check
app.MapGet("/health", () => Results.Ok(new
{
    status = "healthy",
    service = "Cloud Quote API",
    environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production",
    timestamp = DateTime.UtcNow,
    region = Environment.GetEnvironmentVariable("WEBSITE_SITE_NAME") ?? "local"
}));

app.Run();

// Quote record
record Quote(int Id, string Text, string Author, string Category);
