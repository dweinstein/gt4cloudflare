"
I provide gtExample methods for the Gt4Cloudflare package.

My examples use inline JSON fixtures (no API calls needed) to create and assert on response model objects. Each example returns the object for inspection and composition.

See the Lepiter page ""Gt4Cloudflare - Browser Rendering API Client"" for documentation.
"
Class {
	#name : 'Gt4CloudflareExamples',
	#superclass : 'Object',
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'examples - client' }
Gt4CloudflareExamples >> client [
	<gtExample>
	| aClient |
	aClient := Gt4CloudflareClient new
		accountId: 'test-account-id';
		apiKey: 'test-api-key'.
	self assert: aClient accountId equals: 'test-account-id'.
	self assert: aClient history isEmpty.
	^ aClient
]

{ #category : 'examples - content' }
Gt4CloudflareExamples >> contentResult [
	<gtExample>
	| aResult |
	aResult := Gt4CloudflareContentResult new
		html: '<!DOCTYPE html><html><head><title>Test</title></head><body><h1>Hello</h1></body></html>'.
	self assert: aResult html isNotNil.
	self assert: (aResult html includesSubstring: '<h1>Hello</h1>').
	^ aResult
]

{ #category : 'examples - crawl' }
Gt4CloudflareExamples >> crawlJob [
	<gtExample>
	| aJson aJob |
	aJson := self crawlJobJson.
	aJob := Gt4CloudflareCrawlJob fromDictionary: aJson withClient: nil.
	self assert: aJob jobId equals: 'job-abc-123'.
	self assert: aJob isCompleted.
	self assert: aJob records size equals: 3.
	self assert: aJob total equals: 3.
	self assert: aJob finished equals: 3.
	^ aJob
]

{ #category : 'examples - fixtures' }
Gt4CloudflareExamples >> crawlJobJson [
	^ NeoJSONObject fromString: '{
		"success": true,
		"result": {
			"id": "job-abc-123",
			"status": "completed",
			"total": 3,
			"finished": 3,
			"browserSecondsUsed": 12,
			"records": [
				{
					"url": "https://example.com/",
					"status": "completed",
					"markdown": "# Example\n\nWelcome to the example site.",
					"metadata": {"status": 200, "title": "Example", "url": "https://example.com/"}
				},
				{
					"url": "https://example.com/about",
					"status": "completed",
					"markdown": "# About\n\nThis is the about page.",
					"metadata": {"status": 200, "title": "About", "url": "https://example.com/about"}
				},
				{
					"url": "https://example.com/404",
					"status": "errored",
					"metadata": {"status": 404, "title": "Not Found", "url": "https://example.com/404"}
				}
			]
		}
	}'
]

{ #category : 'examples - crawl' }
Gt4CloudflareExamples >> crawlRecord [
	<gtExample>
	| aRecord |
	aRecord := self crawlJob records first.
	self assert: aRecord url equals: 'https://example.com/'.
	self assert: aRecord status equals: 'completed'.
	self assert: aRecord title equals: 'Example'.
	self assert: (aRecord markdown includesSubstring: 'Welcome').
	^ aRecord
]

{ #category : 'examples - json' }
Gt4CloudflareExamples >> jsonResult [
	<gtExample>
	| aJson aResult |
	aJson := self jsonResultJson.
	aResult := Gt4CloudflareJsonResult fromDictionary: aJson.
	self assert: (aResult result at: 'title') equals: 'Example Site'.
	self assert: (aResult result at: 'links') size equals: 2.
	^ aResult
]

{ #category : 'examples - fixtures' }
Gt4CloudflareExamples >> jsonResultJson [
	^ NeoJSONObject fromString: '{
		"success": true,
		"result": {
			"title": "Example Site",
			"description": "A sample website for testing",
			"links": [
				{"text": "Home", "href": "/"},
				{"text": "About", "href": "/about"}
			]
		}
	}'
]

{ #category : 'examples - links' }
Gt4CloudflareExamples >> linksResult [
	<gtExample>
	| aJson aResult |
	aJson := NeoJSONObject fromString: '{
		"success": true,
		"result": [
			"https://example.com/",
			"https://example.com/about",
			"https://example.com/contact"
		]
	}'.
	aResult := Gt4CloudflareLinksResult fromDictionary: aJson.
	self assert: aResult links size equals: 3.
	self assert: aResult links first equals: 'https://example.com/'.
	^ aResult
]

{ #category : 'examples - markdown' }
Gt4CloudflareExamples >> markdownErrorResultExample [
	<gtExample>
	| result |
	result := Gt4CloudflareMarkdownFileResult fromDictionary: {
		'name' -> 'broken.xyz'.
		'mimeType' -> 'application/octet-stream'.
		'format' -> 'error'.
		'tokens' -> 0.
		'data' -> ''.
		'error' -> 'Unsupported file format' } asDictionary.
	self assert: result isError.
	self assert: result error equals: 'Unsupported file format'.
	^ result
]

{ #category : 'examples - markdown' }
Gt4CloudflareExamples >> markdownFileResultExample [
	<gtExample>
	| result |
	result := Gt4CloudflareMarkdownFileResult fromDictionary: {
		'name' -> 'document.pdf'.
		'mimeType' -> 'application/pdf'.
		'format' -> 'markdown'.
		'tokens' -> 1234.
		'data' -> '# Sample Document

This is a sample PDF converted to markdown.

## Section 1

Some content here.' } asDictionary.
	self assert: result name equals: 'document.pdf'.
	self assert: result mimeType equals: 'application/pdf'.
	self assert: result format equals: 'markdown'.
	self assert: result tokens equals: 1234.
	self assert: result isError not.
	^ result
]

{ #category : 'examples - markdown' }
Gt4CloudflareExamples >> markdownResultExample [
	<gtExample>
	| result |
	result := Gt4CloudflareMarkdownResult fromDictionary: {
		'success' -> true.
		'result' -> {
			{
				'name' -> 'report.pdf'.
				'mimeType' -> 'application/pdf'.
				'format' -> 'markdown'.
				'tokens' -> 2500.
				'data' -> '# Report

Executive summary...' } asDictionary.
			{
				'name' -> 'photo.jpeg'.
				'mimeType' -> 'image/jpeg'.
				'format' -> 'markdown'.
				'tokens' -> 150.
				'data' -> '![Image description](photo.jpeg)

A cat sitting on a windowsill.' } asDictionary } } asDictionary.
	self assert: result results size equals: 2.
	self assert: result first name equals: 'report.pdf'.
	^ result
]

{ #category : 'examples - scrape' }
Gt4CloudflareExamples >> scrapeElement [
	<gtExample>
	| anElement |
	anElement := self scrapeResult elements first.
	self assert: anElement selector equals: 'h1'.
	self assert: anElement results size equals: 1.
	^ anElement
]

{ #category : 'examples - scrape' }
Gt4CloudflareExamples >> scrapeResult [
	<gtExample>
	| aJson aResult |
	aJson := self scrapeResultJson.
	aResult := Gt4CloudflareScrapeResult fromDictionary: aJson.
	self assert: aResult elements size equals: 2.
	self assert: aResult elements first selector equals: 'h1'.
	self assert: (aResult elements first results first at: 'text') equals: 'Welcome to Example'.
	^ aResult
]

{ #category : 'examples - fixtures' }
Gt4CloudflareExamples >> scrapeResultJson [
	^ NeoJSONObject fromString: '{
		"success": true,
		"result": [
			{
				"selector": "h1",
				"results": [
					{
						"text": "Welcome to Example",
						"html": "<h1>Welcome to Example</h1>",
						"attributes": [{"name": "class", "value": "title"}],
						"width": 800,
						"height": 48,
						"top": 100,
						"left": 0
					}
				]
			},
			{
				"selector": "meta[name=description]",
				"results": [
					{
						"text": "",
						"html": "<meta name=\"description\" content=\"An example page\">",
						"attributes": [
							{"name": "name", "value": "description"},
							{"name": "content", "value": "An example page"}
						],
						"width": 0,
						"height": 0,
						"top": 0,
						"left": 0
					}
				]
			}
		]
	}'
]
