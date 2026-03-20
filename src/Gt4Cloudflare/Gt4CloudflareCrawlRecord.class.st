"
I represent a single crawled page from a crawl job.

I hold the page url, status (completed, errored, skipped, etc.), and content in one or more formats: markdown, html, json. My metadata dictionary contains the HTTP status code, page title, and final URL.
"
Class {
	#name : 'Gt4CloudflareCrawlRecord',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'url',
		'status',
		'markdown',
		'html',
		'json',
		'metadata'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareCrawlRecord class >> fromDictionary: aDictionary [
	^ self new
		rawData: aDictionary;
		url: (aDictionary at: 'url' ifAbsent: [ nil ]);
		status: (aDictionary at: 'status' ifAbsent: [ nil ]);
		markdown: (aDictionary at: 'markdown' ifAbsent: [ nil ]);
		html: (aDictionary at: 'html' ifAbsent: [ nil ]);
		json: (aDictionary at: 'json' ifAbsent: [ nil ]);
		metadata: (aDictionary at: 'metadata' ifAbsent: [ nil ])
]

{ #category : 'gt - views' }
Gt4CloudflareCrawlRecord >> gtContentFor: aView [
	<gtView>
	| content |
	content := markdown ifNil: [ html ifNil: [ ^ aView empty ] ].
	^ aView textEditor
		title: 'Content';
		priority: 1;
		text: [ content ]
]

{ #category : 'gt - views' }
Gt4CloudflareCrawlRecord >> gtMetadataFor: aView [
	<gtView>
	metadata ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Metadata';
		priority: 5;
		object: [ metadata ];
		view: #gtItemsFor:
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> html [
	^ html
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> html: anObject [
	html := anObject
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> json [
	^ json
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> json: anObject [
	json := anObject
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> markdown [
	^ markdown
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> markdown: anObject [
	markdown := anObject
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> metadata [
	^ metadata
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> metadata: anObject [
	metadata := anObject
]

{ #category : 'printing' }
Gt4CloudflareCrawlRecord >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: (url ifNil: [ '?' ] ifNotNil: [ url truncateWithElipsisTo: 50 ]);
		nextPutAll: ' - ';
		nextPutAll: (status ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> rawData [
	^ rawData
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> rawData: anObject [
	rawData := anObject
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> status [
	^ status
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> status: anObject [
	status := anObject
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> title [
	^ metadata ifNotNil: [ metadata at: 'title' ifAbsent: [ '' ] ] ifNil: [ '' ]
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> url [
	^ url
]

{ #category : 'accessing' }
Gt4CloudflareCrawlRecord >> url: anObject [
	url := anObject
]
