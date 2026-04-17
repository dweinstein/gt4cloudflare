Class {
	#name : 'Gt4CloudflareWebhookEvent',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'kvKey'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareWebhookEvent class >> fromDictionary: aDictionary [
	^ self new rawData: aDictionary
]

{ #category : 'instance creation' }
Gt4CloudflareWebhookEvent class >> fromJsonString: aString [
	^ self fromDictionary: (STONJSON fromString: aString)
]

{ #category : 'instance creation' }
Gt4CloudflareWebhookEvent class >> fromJsonString: aString kvKey: aKeyString [
	^ (self fromJsonString: aString) kvKey: aKeyString
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> body [
	"The original webhook payload body (string or parsed object)."
	^ rawData at: 'body' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> contentType [
	^ self headers at: 'content-type' ifAbsent: [ nil ]
]

{ #category : 'gt - views' }
Gt4CloudflareWebhookEvent >> gtBodyFor: aView [
	<gtView>
	self body ifNil: [ ^ aView empty ].
	^ aView textEditor
		title: 'Body';
		priority: 5;
		text: [ self body isString
			ifTrue: [ self body ]
			ifFalse: [ NeoJSONWriter toStringPretty: self body ] ]
]

{ #category : 'gt - views' }
Gt4CloudflareWebhookEvent >> gtDetailsFor: aView [
	<gtView>
	| details |
	details := OrderedCollection new.
	details add: 'Timestamp' -> (self timestamp ifNil: [ '' ]).
	details add: 'Method' -> (self method ifNil: [ '' ]).
	details add: 'Path' -> (self path ifNil: [ '' ]).
	details add: 'URL' -> (self url ifNil: [ '' ]).
	details add: 'Source IP' -> (self sourceIp ifNil: [ '' ]).
	details add: 'Content-Type' -> (self contentType ifNil: [ '' ]).
	details add: 'Signature' -> (self signatureHeader ifNil: [ 'none' ]).
	kvKey ifNotNil: [ details add: 'KV Key' -> kvKey ].
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ details ];
		column: 'Field' text: #key;
		column: 'Value' text: #value
]

{ #category : 'gt - views' }
Gt4CloudflareWebhookEvent >> gtHeadersFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Headers';
		priority: 3;
		items: [ self headers associations sorted: [ :a :b | a key < b key ] ];
		column: 'Header' text: #key weight: 1;
		column: 'Value' text: #value weight: 2
]

{ #category : 'gt - views' }
Gt4CloudflareWebhookEvent >> gtParsedBodyFor: aView [
	<gtView>
	| parsed |
	parsed := self parsedBody.
	(parsed isNil or: [ parsed isString ]) ifTrue: [ ^ aView empty ].
	^ aView forward
		title: 'Parsed body';
		priority: 6;
		object: [ parsed ];
		view: #gtTreeFor:context:
]

{ #category : 'gt - views' }
Gt4CloudflareWebhookEvent >> gtRawDataFor: aView [
	<gtView>
	^ aView forward
		title: 'Raw data';
		priority: 10;
		object: [ rawData ];
		view: #gtTreeFor:context:
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> headers [
	^ rawData at: 'headers' ifAbsent: [ Dictionary new ]
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> kvKey [
	^ kvKey
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> kvKey: aString [
	kvKey := aString
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> method [
	^ rawData at: 'method' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> parsedBody [
	"If body is JSON, parse it. Otherwise return body as-is."
	| b |
	b := self body.
	b ifNil: [ ^ nil ].
	(b isString and: [ b trimBoth beginsWith: '{' ])
		ifTrue: [ ^ [ STONJSON fromString: b ] on: Error do: [ :e | b ] ].
	^ b
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> path [
	^ rawData at: 'path' ifAbsent: [ nil ]
]

{ #category : 'printing' }
Gt4CloudflareWebhookEvent >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: (self method ifNil: [ '?' ]);
		space;
		nextPutAll: (self path ifNil: [ '/' ]);
		nextPutAll: ' · ';
		nextPutAll: (self timestamp ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> rawData [
	^ rawData
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> rawData: aDictionary [
	rawData := aDictionary
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> signatureHeader [
	"Return the webhook signature header if present (e.g. x-storylane-signature)."
	self headers keysAndValuesDo: [ :k :v |
		(k asLowercase includesSubstring: 'signature') ifTrue: [ ^ v ] ].
	^ nil
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> sourceIp [
	^ rawData at: 'sourceIp' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> timestamp [
	^ rawData at: 'timestamp' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
Gt4CloudflareWebhookEvent >> url [
	^ rawData at: 'url' ifAbsent: [ nil ]
]
