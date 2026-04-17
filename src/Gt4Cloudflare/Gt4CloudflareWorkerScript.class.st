Class {
	#name : 'Gt4CloudflareWorkerScript',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'client'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareWorkerScript class >> fromDictionary: aDictionary [
	^ self new rawData: aDictionary
]

{ #category : 'accessing' }
Gt4CloudflareWorkerScript >> client [
	^ client
]

{ #category : 'accessing' }
Gt4CloudflareWorkerScript >> client: aClient [
	client := aClient
]

{ #category : 'accessing' }
Gt4CloudflareWorkerScript >> createdOn [
	^ rawData at: 'created_on' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
Gt4CloudflareWorkerScript >> etag [
	^ rawData at: 'etag' ifAbsent: [ nil ]
]

{ #category : 'gt - actions' }
Gt4CloudflareWorkerScript >> gtDeleteActionFor: anAction [
	<gtAction>
	client ifNil: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons cancel;
		tooltip: 'Delete this Worker script';
		priority: 10;
		action: [ :aButton |
			client deleteScript: self name.
			aButton phlow spawnObject: 'Deleted: ' , self name ]
]

{ #category : 'gt - views' }
Gt4CloudflareWorkerScript >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ {
			'Name' -> (self name ifNil: [ '' ]).
			'ID' -> (self id ifNil: [ '' ]).
			'ETag' -> (self etag ifNil: [ '' ]).
			'Created' -> (self createdOn ifNil: [ '' ]).
			'Modified' -> (self modifiedOn ifNil: [ '' ]).
			'KV Bindings' -> self hasKvBindings } ];
		column: 'Field' text: #key;
		column: 'Value' text: #value
]

{ #category : 'gt - views' }
Gt4CloudflareWorkerScript >> gtRawDataFor: aView [
	<gtView>
	^ aView forward
		title: 'Raw data';
		priority: 10;
		object: [ rawData ];
		view: #gtTreeFor:context:
]

{ #category : 'accessing' }
Gt4CloudflareWorkerScript >> hasKvBindings [
	| bindings |
	bindings := rawData at: 'bindings' ifAbsent: [ #() ].
	^ bindings anySatisfy: [ :b | (b at: 'type' ifAbsent: [ '' ]) = 'kv_namespace' ]
]

{ #category : 'accessing' }
Gt4CloudflareWorkerScript >> id [
	^ rawData at: 'id' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
Gt4CloudflareWorkerScript >> modifiedOn [
	^ rawData at: 'modified_on' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
Gt4CloudflareWorkerScript >> name [
	"Script name (same as id for user-uploaded scripts)."
	^ self id
]

{ #category : 'printing' }
Gt4CloudflareWorkerScript >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: (self name ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
Gt4CloudflareWorkerScript >> rawData [
	^ rawData
]

{ #category : 'accessing' }
Gt4CloudflareWorkerScript >> rawData: aDictionary [
	rawData := aDictionary
]
