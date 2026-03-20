"
I wrap the result of the /scrape endpoint — elements extracted from a page via CSS selectors.

My elements accessor returns a collection of Gt4CloudflareScrapeElement instances, one per selector. Created via fromDictionary: from the API response.
"
Class {
	#name : 'Gt4CloudflareScrapeResult',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'elements'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareScrapeResult class >> fromDictionary: aDictionary [
	| result |
	result := self new.
	result rawData: aDictionary.
	result elements: ((aDictionary at: 'result') collect: [ :each |
		Gt4CloudflareScrapeElement fromDictionary: each ]).
	^ result
]

{ #category : 'accessing' }
Gt4CloudflareScrapeResult >> elements [
	^ elements
]

{ #category : 'accessing' }
Gt4CloudflareScrapeResult >> elements: anObject [
	elements := anObject
]

{ #category : 'gt - views' }
Gt4CloudflareScrapeResult >> gtElementsFor: aView [
	<gtView>
	elements ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Elements';
		priority: 1;
		items: [ elements ];
		column: 'Selector' text: [ :el | el selector ] weight: 2;
		column: 'Results' text: [ :el | el results size ] weight: 1
]

{ #category : 'gt - views' }
Gt4CloudflareScrapeResult >> gtRawDataFor: aView [
	<gtView>
	rawData ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Raw data';
		priority: 10;
		object: [ rawData ];
		view: #gtItemsFor:
]

{ #category : 'printing' }
Gt4CloudflareScrapeResult >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		print: (elements ifNil: [ 0 ] ifNotNil: [ elements size ]);
		nextPutAll: ' selectors)'
]

{ #category : 'accessing' }
Gt4CloudflareScrapeResult >> rawData [
	^ rawData
]

{ #category : 'accessing' }
Gt4CloudflareScrapeResult >> rawData: anObject [
	rawData := anObject
]
