"
I wrap the result of the /json endpoint — structured data extracted from a page by AI (Llama 3.3 70B by default).

My result accessor returns the extracted data as a NeoJSONObject. The extraction is guided by a natural language prompt, a JSON schema (response_format), or both.
"
Class {
	#name : 'Gt4CloudflareJsonResult',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'result'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareJsonResult class >> fromDictionary: aDictionary [
	^ self new
		rawData: aDictionary;
		result: (aDictionary at: 'result')
]

{ #category : 'gt - views' }
Gt4CloudflareJsonResult >> gtRawDataFor: aView [
	<gtView>
	rawData ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Raw data';
		priority: 10;
		object: [ rawData ];
		view: #gtItemsFor:
]

{ #category : 'gt - views' }
Gt4CloudflareJsonResult >> gtResultFor: aView [
	<gtView>
	result ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Result';
		priority: 1;
		object: [ result ];
		view: #gtItemsFor:
]

{ #category : 'printing' }
Gt4CloudflareJsonResult >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' ('.
	result
		ifNil: [ aStream nextPutAll: 'empty' ]
		ifNotNil: [
			(result respondsTo: #keys)
				ifTrue: [ aStream nextPutAll: (', ' join: (result keys collect: #asString)) ]
				ifFalse: [ aStream nextPutAll: result printString truncateWithElipsisTo: 40 ] ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
Gt4CloudflareJsonResult >> rawData [
	^ rawData
]

{ #category : 'accessing' }
Gt4CloudflareJsonResult >> rawData: anObject [
	rawData := anObject
]

{ #category : 'accessing' }
Gt4CloudflareJsonResult >> result [
	^ result
]

{ #category : 'accessing' }
Gt4CloudflareJsonResult >> result: anObject [
	result := anObject
]
