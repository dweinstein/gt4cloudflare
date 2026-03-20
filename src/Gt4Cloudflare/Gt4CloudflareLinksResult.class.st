"
I wrap the result of the /links endpoint — all discovered links on a page.

My links accessor returns an array of URL strings. Supports filtering via visibleLinksOnly and excludeExternalLinks options.
"
Class {
	#name : 'Gt4CloudflareLinksResult',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'links'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareLinksResult class >> fromDictionary: aDictionary [
	^ self new
		rawData: aDictionary;
		links: (aDictionary at: 'result' ifAbsent: [ #() ])
]

{ #category : 'gt - views' }
Gt4CloudflareLinksResult >> gtLinksFor: aView [
	<gtView>
	links ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Links';
		priority: 1;
		items: [ links ];
		column: 'URL' text: [ :url | url ]
]

{ #category : 'gt - search' }
Gt4CloudflareLinksResult >> gtSearchLinksFor: aSearch [
	<gtSearch>
	^ aSearch list
		title: 'Links';
		priority: 1;
		items: [ links ifNil: [ #() ] ];
		itemsLimit: Float infinity;
		filterBySubstring
]

{ #category : 'accessing' }
Gt4CloudflareLinksResult >> links [
	^ links
]

{ #category : 'accessing' }
Gt4CloudflareLinksResult >> links: anObject [
	links := anObject
]

{ #category : 'printing' }
Gt4CloudflareLinksResult >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		print: (links ifNil: [ 0 ] ifNotNil: [ links size ]);
		nextPutAll: ' links)'
]

{ #category : 'accessing' }
Gt4CloudflareLinksResult >> rawData [
	^ rawData
]

{ #category : 'accessing' }
Gt4CloudflareLinksResult >> rawData: anObject [
	rawData := anObject
]
