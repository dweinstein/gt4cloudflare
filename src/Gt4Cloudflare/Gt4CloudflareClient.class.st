"
I am the hub client for the Cloudflare Browser Rendering REST API.

I manage authentication (Bearer token), the base URL, account ID, and request history. I create a fresh ZnClient per request and record every request/response pair in my history.

API key is loaded from ~/.secrets/cloudflare-api-key.txt via my class-side withApiKeyFromFile.

Endpoints:
- contentForUrl: — fully rendered HTML
- scrapeUrl:elements: — CSS selector extraction
- jsonFromUrl:prompt: — AI-powered structured data extraction
- linksForUrl: — link discovery
- startCrawl: / getCrawl: / deleteCrawl: — async website crawling
- screenshotUrl: — page screenshot (PNG)
- pdfForUrl: — page as PDF
- verifyToken — check token validity

See Gt4CloudflareExamples for usage examples.
See the Lepiter page ""Gt4Cloudflare - Browser Rendering API Client"" for full documentation.
"
Class {
	#name : 'Gt4CloudflareClient',
	#superclass : 'Object',
	#instVars : [
		'baseUrl',
		'apiKey',
		'accountId',
		'history'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareClient class >> apiKeyFileContents [
	^ self defaultApiKeyFile contents trimBoth
]

{ #category : 'defaults' }
Gt4CloudflareClient class >> defaultApiKeyFile [
	^ FileLocator home / '.secrets' / 'cloudflare-api-key.txt'
]

{ #category : 'defaults' }
Gt4CloudflareClient class >> defaultBaseUrl [
	^ 'https://api.cloudflare.com/client/v4' asZnUrl
]

{ #category : 'instance creation' }
Gt4CloudflareClient class >> withApiKeyFromFile [
	^ self new apiKey: self apiKeyFileContents
]

{ #category : 'accessing' }
Gt4CloudflareClient >> accountId [
	^ accountId
]

{ #category : 'accessing' }
Gt4CloudflareClient >> accountId: aString [
	accountId := aString
]

{ #category : 'accessing' }
Gt4CloudflareClient >> apiKey [
	^ apiKey
]

{ #category : 'accessing' }
Gt4CloudflareClient >> apiKey: aString [
	apiKey := aString
]

{ #category : 'accessing' }
Gt4CloudflareClient >> baseUrl [
	^ baseUrl
]

{ #category : 'accessing' }
Gt4CloudflareClient >> baseUrl: anObject [
	baseUrl := anObject asZnUrl
]

{ #category : 'private' }
Gt4CloudflareClient >> checkForErrors: aResponse [
	aResponse ifNil: [ Error signal: 'Cloudflare API: empty response' ].
	(aResponse respondsTo: #at:ifAbsent:) ifFalse: [ ^ aResponse ].
	(aResponse at: 'success' ifAbsent: [ true ])
		ifFalse: [
			| errors message |
			errors := aResponse at: 'errors' ifAbsent: [ nil ].
			message := (errors isNil or: [ errors isEmpty ])
				ifTrue: [ 'unknown error' ]
				ifFalse: [ errors first at: 'message' ifAbsent: [ 'unknown error' ] ].
			Error signal: 'Cloudflare API error: ' , message ].
	^ aResponse
]

{ #category : 'api - content' }
Gt4CloudflareClient >> contentForHtml: anHtmlString [
	"Render raw HTML and return fully rendered content"
	| response |
	response := self post: 'content' withEntity: { 'html' -> anHtmlString } asDictionary.
	^ Gt4CloudflareContentResult new html: (response at: 'result')
]

{ #category : 'api - content' }
Gt4CloudflareClient >> contentForUrl: aUrl [
	"Fetch fully rendered HTML for a URL"
	| response |
	response := self post: 'content' withEntity: { 'url' -> aUrl } asDictionary.
	^ Gt4CloudflareContentResult new html: (response at: 'result')
]

{ #category : 'api - content' }
Gt4CloudflareClient >> contentForUrl: aUrl options: aDictionary [
	"Fetch fully rendered HTML with extra options (gotoOptions, cookies, etc)"
	| entity response |
	entity := aDictionary copy.
	entity at: 'url' put: aUrl.
	response := self post: 'content' withEntity: entity.
	^ Gt4CloudflareContentResult new html: (response at: 'result')
]

{ #category : 'private' }
Gt4CloudflareClient >> delete: anEndpoint [
	| aClient response |
	aClient := self initializeClient.
	aClient url: (self endpointUrl: anEndpoint).
	aClient entity: nil.
	response := aClient delete.
	history add: (aClient request -> aClient response).
	^ self checkForErrors: response
]

{ #category : 'api - crawl' }
Gt4CloudflareClient >> deleteCrawl: aJobId [
	"Cancel an in-progress crawl job"
	^ self delete: 'crawl/' , aJobId
]

{ #category : 'private' }
Gt4CloudflareClient >> endpointUrl: anEndpointPath [
	^ baseUrl / 'accounts' / accountId / 'browser-rendering' / anEndpointPath
]

{ #category : 'private' }
Gt4CloudflareClient >> get: anEndpoint withParams: aListOfAssocs [
	| aClient response |
	aClient := self initializeClient.
	aClient url: (self endpointUrl: anEndpoint).
	aListOfAssocs do: [ :aPair |
		aClient queryAt: aPair key put: aPair value ].
	aClient entity: nil.
	response := aClient get.
	history add: (aClient request -> aClient response).
	^ self checkForErrors: response
]

{ #category : 'api - crawl' }
Gt4CloudflareClient >> getCrawl: aJobId [
	"Get crawl job status and results"
	| response |
	response := self get: 'crawl/' , aJobId withParams: #().
	^ Gt4CloudflareCrawlJob fromDictionary: response withClient: self
]

{ #category : 'api - crawl' }
Gt4CloudflareClient >> getCrawl: aJobId limit: aLimit [
	"Get crawl results with limit"
	| response |
	response := self get: 'crawl/' , aJobId
		withParams: { 'limit' -> aLimit asString }.
	^ Gt4CloudflareCrawlJob fromDictionary: response withClient: self
]

{ #category : 'gt - views' }
Gt4CloudflareClient >> gtCallsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Calls';
		priority: 5;
		items: [ history reversed ];
		column: 'URL' text: [ :pair | pair key url ] weight: 3;
		column: 'Method' text: [ :pair | pair key method ] weight: 1;
		column: 'Status' text: [ :pair |
			pair value
				ifNil: [ 'no response' ]
				ifNotNil: [ :r | r statusLine printString ] ] weight: 2
]

{ #category : 'gt - views' }
Gt4CloudflareClient >> gtClearHistoryActionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons cancel;
		tooltip: 'Clear history';
		priority: 80;
		action: [ :aButton :aTab |
			history removeAll.
			aTab viewContentElement phlow update ]
]

{ #category : 'gt - views' }
Gt4CloudflareClient >> gtConfigurationFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Configuration';
		priority: 1;
		items: [ {
			'Base URL' -> baseUrl printString.
			'Account ID' -> (accountId ifNil: [ '(not set)' ]).
			'API Key' -> (apiKey
				ifNil: [ '(not set)' ]
				ifNotNil: [ (apiKey first: (4 min: apiKey size)) , '...' , (apiKey last: (4 min: apiKey size)) ]).
			'History' -> history size asString , ' calls' } ];
		column: 'Property' text: [ :assoc | assoc key ] weight: 1;
		column: 'Value' text: [ :assoc | assoc value ] weight: 3
]

{ #category : 'gt - views' }
Gt4CloudflareClient >> gtEndpointsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Endpoints';
		priority: 3;
		items: [ {
			'/content' -> 'contentForUrl:' -> 'Fully rendered HTML after JS execution'.
			'/scrape' -> 'scrapeUrl:elements:' -> 'Extract elements via CSS selectors'.
			'/json' -> 'jsonFromUrl:prompt:' -> 'AI-powered structured data extraction'.
			'/links' -> 'linksForUrl:' -> 'Discover all links on a page'.
			'/crawl' -> 'startCrawl:' -> 'Async multi-page website crawling'.
			'/screenshot' -> 'screenshotUrl:' -> 'Capture page as PNG image'.
			'/pdf' -> 'pdfForUrl:' -> 'Generate PDF from page'.
			'/tokens/verify' -> 'verifyToken' -> 'Check API token validity' } ];
		column: 'Path' text: [ :item | item key key ] weight: 2;
		column: 'Method' text: [ :item | item key value ] weight: 3;
		column: 'Description' text: [ :item | item value ] weight: 5
]

{ #category : 'gt - views' }
Gt4CloudflareClient >> gtVerifyTokenActionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons accept;
		tooltip: 'Verify token';
		priority: 10;
		action: [ :aButton |
			| result |
			result := [ self verifyToken ] on: Error do: [ :e | e messageText ].
			aButton phlow spawnObject: result ]
]

{ #category : 'accessing' }
Gt4CloudflareClient >> history [
	^ history
]

{ #category : 'initialization' }
Gt4CloudflareClient >> initialize [
	super initialize.
	baseUrl := self class defaultBaseUrl.
	history := OrderedCollection new
]

{ #category : 'private' }
Gt4CloudflareClient >> initializeClient [
	| aClient |
	aClient := ZnClient new.
	aClient forJsonREST.
	aClient timeout: 120.
	aClient setBearerAuthentication: apiKey.
	^ aClient
]

{ #category : 'private' }
Gt4CloudflareClient >> initializeRawClient [
	"Client for endpoints returning binary data (screenshot, pdf)"
	| aClient |
	aClient := ZnClient new.
	aClient timeout: 120.
	aClient setBearerAuthentication: apiKey.
	aClient headerAt: 'Content-Type' put: 'application/json'.
	^ aClient
]

{ #category : 'api - json' }
Gt4CloudflareClient >> jsonFromUrl: aUrl prompt: aPrompt [
	"Extract structured data from URL using AI with a natural language prompt"
	| entity response |
	entity := Dictionary new.
	entity at: 'url' put: aUrl.
	entity at: 'prompt' put: aPrompt.
	response := self post: 'json' withEntity: entity.
	^ Gt4CloudflareJsonResult fromDictionary: response
]

{ #category : 'api - json' }
Gt4CloudflareClient >> jsonFromUrl: aUrl prompt: aPrompt responseFormat: aSchemaDict [
	"Extract structured data using both prompt and schema"
	| entity response |
	entity := Dictionary new.
	entity at: 'url' put: aUrl.
	entity at: 'prompt' put: aPrompt.
	entity at: 'response_format' put: aSchemaDict.
	response := self post: 'json' withEntity: entity.
	^ Gt4CloudflareJsonResult fromDictionary: response
]

{ #category : 'api - json' }
Gt4CloudflareClient >> jsonFromUrl: aUrl responseFormat: aSchemaDict [
	"Extract structured data from URL using a JSON schema"
	| entity response |
	entity := Dictionary new.
	entity at: 'url' put: aUrl.
	entity at: 'response_format' put: aSchemaDict.
	response := self post: 'json' withEntity: entity.
	^ Gt4CloudflareJsonResult fromDictionary: response
]

{ #category : 'api - links' }
Gt4CloudflareClient >> linksForUrl: aUrl [
	"Extract all links from a URL"
	^ self linksForUrl: aUrl options: Dictionary new
]

{ #category : 'api - links' }
Gt4CloudflareClient >> linksForUrl: aUrl options: aDictionary [
	"Extract links with options (visibleLinksOnly, excludeExternalLinks, gotoOptions, etc)"
	| entity response |
	entity := aDictionary copy.
	entity at: 'url' put: aUrl.
	response := self post: 'links' withEntity: entity.
	^ Gt4CloudflareLinksResult fromDictionary: response
]

{ #category : 'api - pdf' }
Gt4CloudflareClient >> pdfForUrl: aUrl [
	"Generate a PDF of a URL. Returns a Gt4CloudflarePdfResult."
	^ self pdfForUrl: aUrl options: Dictionary new
]

{ #category : 'api - pdf' }
Gt4CloudflareClient >> pdfForUrl: aUrl options: aDictionary [
	"Generate a PDF with options (pdfOptions, viewport, etc)"
	| entity bytes |
	entity := aDictionary copy.
	entity at: 'url' put: aUrl.
	bytes := self postBinary: 'pdf' withEntity: entity.
	^ Gt4CloudflarePdfResult new bytes: bytes
]

{ #category : 'private' }
Gt4CloudflareClient >> post: anEndpoint withEntity: aDictionary [
	| aClient response |
	aClient := self initializeClient.
	aClient url: (self endpointUrl: anEndpoint).
	aClient contents: aDictionary.
	response := aClient post.
	history add: (aClient request -> aClient response).
	^ self checkForErrors: response
]

{ #category : 'private' }
Gt4CloudflareClient >> postBinary: anEndpoint withEntity: aDictionary [
	"POST returning binary response (for screenshot, pdf)"
	| aClient |
	aClient := self initializeRawClient.
	aClient url: (self endpointUrl: anEndpoint).
	aClient
		entity: (ZnEntity json: (NeoJSONWriter toString: aDictionary)).
	aClient beBinary.
	aClient post.
	history add: (aClient request -> aClient response).
	aClient isSuccess ifFalse: [
		Error signal: 'Request failed: ' , aClient response statusLine printString ].
	^ aClient response entity bytes
]

{ #category : 'private' }
Gt4CloudflareClient >> postRaw: anEndpoint withEntity: aDictionary [
	"POST returning raw response (for screenshot, pdf, content)"
	| aClient |
	aClient := self initializeRawClient.
	aClient url: (self endpointUrl: anEndpoint).
	aClient
		entity: (ZnEntity json: (NeoJSONWriter toString: aDictionary)).
	aClient post.
	history add: (aClient request -> aClient response).
	aClient isSuccess ifFalse: [
		Error signal: 'Request failed: ' , aClient response statusLine printString ].
	^ aClient contents
]

{ #category : 'printing' }
Gt4CloudflareClient >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: (accountId ifNil: [ 'no account' ]);
		nextPutAll: ', ';
		print: history size;
		nextPutAll: ' calls)'
]

{ #category : 'api - scrape' }
Gt4CloudflareClient >> scrapeUrl: aUrl elements: anArrayOfSelectors [
	"Scrape elements from a URL using CSS selectors"
	| entity response |
	entity := Dictionary new.
	entity at: 'url' put: aUrl.
	entity at: 'elements' put: (anArrayOfSelectors collect: [ :sel |
		{ 'selector' -> sel } asDictionary ]).
	response := self post: 'scrape' withEntity: entity.
	^ (Gt4CloudflareScrapeResult fromDictionary: response) url: aUrl
]

{ #category : 'api - scrape' }
Gt4CloudflareClient >> scrapeUrl: aUrl elements: anArrayOfSelectors options: aDictionary [
	"Scrape with extra options (gotoOptions, waitForSelector, etc)"
	| entity response |
	entity := aDictionary copy.
	entity at: 'url' put: aUrl.
	entity at: 'elements' put: (anArrayOfSelectors collect: [ :sel |
		{ 'selector' -> sel } asDictionary ]).
	response := self post: 'scrape' withEntity: entity.
	^ (Gt4CloudflareScrapeResult fromDictionary: response) url: aUrl
]

{ #category : 'api - screenshot' }
Gt4CloudflareClient >> screenshotUrl: aUrl [
	"Take a screenshot of a URL. Returns a Gt4CloudflareScreenshotResult."
	^ self screenshotUrl: aUrl options: Dictionary new
]

{ #category : 'api - screenshot' }
Gt4CloudflareClient >> screenshotUrl: aUrl options: aDictionary [
	"Take a screenshot with options (screenshotOptions, viewport, selector, etc)"
	| entity bytes |
	entity := aDictionary copy.
	entity at: 'url' put: aUrl.
	bytes := self postBinary: 'screenshot' withEntity: entity.
	^ Gt4CloudflareScreenshotResult new
		bytes: bytes;
		contentType: 'image/png'
]

{ #category : 'api - crawl' }
Gt4CloudflareClient >> startCrawl: aUrl [
	"Start a crawl job for a URL. Returns a Gt4CloudflareCrawlJob."
	^ self startCrawl: aUrl options: Dictionary new
]

{ #category : 'api - crawl' }
Gt4CloudflareClient >> startCrawl: aUrl options: aDictionary [
	"Start a crawl job with options (limit, depth, formats, etc). Returns a Gt4CloudflareCrawlJob."
	| entity response |
	entity := aDictionary copy.
	entity at: 'url' put: aUrl.
	response := self post: 'crawl' withEntity: entity.
	^ Gt4CloudflareCrawlJob new
		client: self;
		jobId: (response at: 'result');
		status: 'running';
		rawData: response
]

{ #category : 'api - auth' }
Gt4CloudflareClient >> verifyToken [
	"Verify the API token is valid. Returns the raw response dictionary."
	| aClient response |
	aClient := self initializeClient.
	aClient url: baseUrl / 'accounts' / accountId / 'tokens' / 'verify'.
	aClient entity: nil.
	response := aClient get.
	history add: (aClient request -> aClient response).
	^ response
]
