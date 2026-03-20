# Gt4Cloudflare

A [Glamorous Toolkit](https://gtoolkit.com) client for the [Cloudflare Browser Rendering REST API](https://developers.cloudflare.com/browser-rendering/rest-api/).

Render pages, scrape content, extract structured data with AI, discover links, take screenshots, generate PDFs, and crawl websites — all from GT with rich inspector views.

## Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `contentForUrl:` | `/content` | Fully rendered HTML after JS execution |
| `scrapeUrl:elements:` | `/scrape` | Extract elements via CSS selectors |
| `jsonFromUrl:prompt:` | `/json` | AI-powered structured data extraction |
| `linksForUrl:` | `/links` | Discover all links on a page |
| `startCrawl:` | `/crawl` | Async multi-page website crawling |
| `screenshotUrl:` | `/screenshot` | Capture page as PNG image |
| `pdfForUrl:` | `/pdf` | Generate PDF from page |
| `verifyToken` | `/tokens/verify` | Check API token validity |

## Setup

1. Create a Cloudflare API token with **Browser Rendering - Edit** permission
2. Save it to `~/.secrets/cloudflare-api-key.txt`
3. Load the package and create a client:

```smalltalk
client := Gt4CloudflareClient withApiKeyFromFile
    accountId: 'your-account-id'.
```

## Usage

```smalltalk
"Render a page"
client contentForUrl: 'https://example.com'.

"Scrape elements"
client scrapeUrl: 'https://example.com' elements: #('h1' 'p').

"AI-powered extraction"
client jsonFromUrl: 'https://example.com' prompt: 'Extract the title and links'.

"Discover links"
client linksForUrl: 'https://example.com'.

"Screenshot"
client screenshotUrl: 'https://example.com'.

"PDF"
result := client pdfForUrl: 'https://example.com'.
result saveToFile: '/tmp/example.pdf' asFileReference.

"Crawl a site"
job := client startCrawl: 'https://example.com'
    options: { 'limit' -> 10. 'formats' -> #('markdown') } asDictionary.
client getCrawl: job jobId.
```

All methods accept an `options:` variant for advanced parameters (`gotoOptions`, `viewport`, `cookies`, etc).

## Classes

| Class | Purpose |
|-------|---------|
| `Gt4CloudflareClient` | Hub client with auth, HTTP methods, request history |
| `Gt4CloudflareContentResult` | Rendered HTML from `/content` |
| `Gt4CloudflareScrapeResult` | Scraped elements from `/scrape` |
| `Gt4CloudflareScrapeElement` | Single CSS selector match with results |
| `Gt4CloudflareJsonResult` | AI-extracted JSON from `/json` |
| `Gt4CloudflareLinksResult` | Extracted links from `/links` |
| `Gt4CloudflareCrawlJob` | Async crawl job status and records from `/crawl` |
| `Gt4CloudflareCrawlRecord` | Individual crawled page (markdown, HTML, metadata) |
| `Gt4CloudflareScreenshotResult` | PNG/JPEG screenshot from `/screenshot` |
| `Gt4CloudflarePdfResult` | PDF bytes from `/pdf` |
| `Gt4CloudflareExamples` | Fixture-based gtExample methods |

## Installation

```smalltalk
Metacello new
    baseline: 'Gt4Cloudflare';
    repository: 'github://dweinstein/gt4cloudflare/src';
    load.
```

## Load Lepiter

After installing with Metacello:

```smalltalk
#BaselineOfGt4cloudflare asClass loadLepiter
```

This loads three documentation pages:
- **Gt4Cloudflare - Browser Rendering API Client** — setup, endpoint docs, architecture, live examples
- **Gt4Cloudflare - API Reference** — full API specs for all endpoints
- **Gt4Cloudflare - Playground** — runnable snippets for experimentation
