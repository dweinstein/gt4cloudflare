"
I represent a single CSS selector match from the /scrape endpoint.

My selector is the CSS selector string. My results is an array of dictionaries, each with keys: text, html, attributes, width, height, top, left.
"
Class {
	#name : 'Gt4CloudflareScrapeElement',
	#superclass : 'Object',
	#instVars : [
		'selector',
		'results'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareScrapeElement class >> fromDictionary: aDictionary [
	^ self new
		selector: (aDictionary at: 'selector');
		results: (aDictionary at: 'results' ifAbsent: [ #() ])
]

{ #category : 'gt - views' }
Gt4CloudflareScrapeElement >> gtResultsFor: aView [
	<gtView>
	results ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Results';
		priority: 1;
		items: [ results ];
		column: 'Text' text: [ :r | (r at: 'text' ifAbsent: [ '' ]) truncateWithElipsisTo: 80 ] weight: 3;
		column: 'Width' text: [ :r | r at: 'width' ifAbsent: [ '' ] ] weight: 1;
		column: 'Height' text: [ :r | r at: 'height' ifAbsent: [ '' ] ] weight: 1
]

{ #category : 'printing' }
Gt4CloudflareScrapeElement >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: (selector ifNil: [ '?' ]);
		nextPutAll: ': ';
		print: (results ifNil: [ 0 ] ifNotNil: [ results size ]);
		nextPutAll: ' results)'
]

{ #category : 'accessing' }
Gt4CloudflareScrapeElement >> results [
	^ results
]

{ #category : 'accessing' }
Gt4CloudflareScrapeElement >> results: anObject [
	results := anObject
]

{ #category : 'accessing' }
Gt4CloudflareScrapeElement >> selector [
	^ selector
]

{ #category : 'accessing' }
Gt4CloudflareScrapeElement >> selector: aString [
	selector := aString
]
