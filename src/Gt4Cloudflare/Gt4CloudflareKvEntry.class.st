Class {
	#name : 'Gt4CloudflareKvEntry',
	#superclass : 'Object',
	#instVars : [
		'key',
		'value',
		'metadata',
		'expiration'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'accessing' }
Gt4CloudflareKvEntry >> expiration [
	^ expiration
]

{ #category : 'accessing' }
Gt4CloudflareKvEntry >> expiration: anObject [
	expiration := anObject
]

{ #category : 'gt - views' }
Gt4CloudflareKvEntry >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ {
			'Key' -> (key ifNil: [ '' ]).
			'Value' -> (value ifNil: [ '(not loaded)' ]).
			'Metadata' -> (metadata ifNil: [ '' ] ifNotNil: [ metadata printString ]).
			'Expiration' -> (expiration ifNil: [ 'none' ] ifNotNil: [ expiration printString ]) } ];
		column: 'Field' text: #key;
		column: 'Value' text: #value
]

{ #category : 'accessing' }
Gt4CloudflareKvEntry >> key [
	^ key
]

{ #category : 'accessing' }
Gt4CloudflareKvEntry >> key: aString [
	key := aString
]

{ #category : 'accessing' }
Gt4CloudflareKvEntry >> metadata [
	^ metadata
]

{ #category : 'accessing' }
Gt4CloudflareKvEntry >> metadata: anObject [
	metadata := anObject
]

{ #category : 'printing' }
Gt4CloudflareKvEntry >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: (key ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
Gt4CloudflareKvEntry >> value [
	^ value
]

{ #category : 'accessing' }
Gt4CloudflareKvEntry >> value: anObject [
	value := anObject
]
