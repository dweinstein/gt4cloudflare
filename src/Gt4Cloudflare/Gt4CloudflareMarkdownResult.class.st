Class {
	#name : 'Gt4CloudflareMarkdownResult',
	#superclass : 'Object',
	#instVars : [
		'results',
		'rawData'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareMarkdownResult class >> fromDictionary: aDictionary [
	| items |
	items := (aDictionary at: 'result' ifAbsent: [ #() ])
		collect: [ :each | Gt4CloudflareMarkdownFileResult fromDictionary: each ].
	^ self new
		results: items;
		rawData: aDictionary
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownResult >> first [
	"Convenience for single-file conversions"
	^ results first
]

{ #category : 'gt - views' }
Gt4CloudflareMarkdownResult >> gtRawDataFor: aView [
	<gtView>
	^ aView forward
		title: 'Raw data';
		priority: 10;
		object: [ rawData ];
		view: #gtTreeFor:
]

{ #category : 'gt - views' }
Gt4CloudflareMarkdownResult >> gtResultsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Results';
		priority: 1;
		items: [ results ];
		column: 'Name' text: #name weight: 3;
		column: 'Format' text: #format weight: 1;
		column: 'Tokens' text: [ :r | r tokens asString ] weight: 1;
		column: 'MIME' text: #mimeType weight: 2
]

{ #category : 'printing' }
Gt4CloudflareMarkdownResult >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		print: results size;
		nextPutAll: ' files)'
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownResult >> rawData [
	^ rawData
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownResult >> rawData: aDictionary [
	rawData := aDictionary
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownResult >> results [
	^ results
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownResult >> results: aCollection [
	results := aCollection
]
