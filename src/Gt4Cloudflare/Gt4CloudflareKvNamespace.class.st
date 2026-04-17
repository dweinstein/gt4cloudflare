Class {
	#name : 'Gt4CloudflareKvNamespace',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'client'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareKvNamespace class >> fromDictionary: aDictionary [
	^ self new rawData: aDictionary
]

{ #category : 'accessing' }
Gt4CloudflareKvNamespace >> client [
	^ client
]

{ #category : 'accessing' }
Gt4CloudflareKvNamespace >> client: aClient [
	client := aClient
]

{ #category : 'api' }
Gt4CloudflareKvNamespace >> deleteKey: aKey [
	^ client kvDelete: aKey namespace: self id
]

{ #category : 'api' }
Gt4CloudflareKvNamespace >> get: aKey [
	"Read a value by key."
	^ client kvGet: aKey namespace: self id
]

{ #category : 'gt - actions' }
Gt4CloudflareKvNamespace >> gtDeleteActionFor: anAction [
	<gtAction>
	client ifNil: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons cancel;
		tooltip: 'Delete this KV namespace';
		priority: 10;
		action: [ :aButton |
			client deleteKvNamespace: self id.
			aButton phlow spawnObject: 'Deleted: ' , self title ]
]

{ #category : 'gt - views' }
Gt4CloudflareKvNamespace >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ {
			'Title' -> (self title ifNil: [ '' ]).
			'ID' -> (self id ifNil: [ '' ]) } ];
		column: 'Field' text: #key;
		column: 'Value' text: #value
]

{ #category : 'gt - views' }
Gt4CloudflareKvNamespace >> gtKeysFor: aView [
	<gtView>
	client ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Keys';
		priority: 2;
		items: [ (self listKeys at: 'result' ifAbsent: [ #() ])
			collect: [ :each |
				Gt4CloudflareKvEntry new
					key: (each at: 'name');
					metadata: (each at: 'metadata' ifAbsent: [ nil ]);
					expiration: (each at: 'expiration' ifAbsent: [ nil ]) ] ];
		column: 'Key' text: [ :e | e key ] weight: 3;
		column: 'Expiration' text: [ :e | e expiration ifNil: [ '' ] ] weight: 1
]

{ #category : 'gt - views' }
Gt4CloudflareKvNamespace >> gtRawDataFor: aView [
	<gtView>
	^ aView forward
		title: 'Raw data';
		priority: 10;
		object: [ rawData ];
		view: #gtTreeFor:context:
]

{ #category : 'accessing' }
Gt4CloudflareKvNamespace >> id [
	^ rawData at: 'id' ifAbsent: [ nil ]
]

{ #category : 'api' }
Gt4CloudflareKvNamespace >> listKeys [
	"List all keys in this namespace via the client."
	^ client kvListKeys: self id
]

{ #category : 'api' }
Gt4CloudflareKvNamespace >> listKeysWithPrefix: aPrefix [
	^ client kvListKeys: self id prefix: aPrefix limit: nil
]

{ #category : 'printing' }
Gt4CloudflareKvNamespace >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: (self title ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'api' }
Gt4CloudflareKvNamespace >> put: aKey value: aValueString [
	"Write a value."
	^ client kvPut: aKey value: aValueString namespace: self id
]

{ #category : 'accessing' }
Gt4CloudflareKvNamespace >> rawData [
	^ rawData
]

{ #category : 'accessing' }
Gt4CloudflareKvNamespace >> rawData: aDictionary [
	rawData := aDictionary
]

{ #category : 'accessing' }
Gt4CloudflareKvNamespace >> title [
	^ rawData at: 'title' ifAbsent: [ nil ]
]
