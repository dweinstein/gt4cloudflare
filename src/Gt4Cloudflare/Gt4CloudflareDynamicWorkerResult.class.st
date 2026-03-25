Class {
	#name : 'Gt4CloudflareDynamicWorkerResult',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'status',
		'body',
		'logs',
		'language',
		'error'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareDynamicWorkerResult class >> fromDictionary: aDictionary [
	^ self new
		rawData: aDictionary;
		status: (aDictionary at: 'status' ifAbsent: [ nil ]);
		body: (aDictionary at: 'body' ifAbsent: [ '' ]);
		logs: (aDictionary at: 'logs' ifAbsent: [ #() ]);
		language: (aDictionary at: 'language' ifAbsent: [ 'unknown' ]);
		error: (aDictionary at: 'error' ifAbsent: [ nil ])
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> body [
	^ body
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> body: anObject [
	body := anObject
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> bodyJson [
	^ [ STONJSON fromString: body ] on: Error do: [ nil ]
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> bodyLines [
	^ body lines
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> error [
	^ error
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> error: anObject [
	error := anObject
]

{ #category : 'gt - extensions' }
Gt4CloudflareDynamicWorkerResult >> gtBodyFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Body';
		priority: 10;
		text: [ body ifNil: [ '' ] ]
]

{ #category : 'gt - extensions' }
Gt4CloudflareDynamicWorkerResult >> gtFilesFor: aView [
	<gtView>
	body ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Files';
		priority: 15;
		items: [ self bodyLines select: [ :line | line beginsWith: '/' ] ];
		column: 'Path' text: [ :aLine | aLine ]
]

{ #category : 'gt - extensions' }
Gt4CloudflareDynamicWorkerResult >> gtLogsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Logs';
		priority: 20;
		items: [ logs ifNil: [ #() ] ];
		column: 'Level' text: [ :aLog | aLog at: 'level' ifAbsent: [ '' ] ] weight: 0.15;
		column: 'Message' text: [ :aLog | 
			| msg |
			msg := aLog at: 'message' ifAbsent: [ '' ].
			msg isArray
				ifTrue: [ ', ' join: (msg collect: #asString) ]
				ifFalse: [ msg asString ] ] weight: 0.85
]

{ #category : 'gt - extensions' }
Gt4CloudflareDynamicWorkerResult >> gtNewFilesFor: aView [
	<gtView>
	| json newFiles |
	json := self bodyJson.
	json ifNil: [ ^ aView empty ].
	newFiles := json at: 'new_files_after_install' ifAbsent: [ nil ].
	newFiles ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'New files (post-install)';
		priority: 13;
		items: [ newFiles ];
		column: 'Path' text: [ :f | f at: 'path' ifAbsent: [ '' ] ] weight: 0.7;
		column: 'Size' text: [ :f | 
			| size |
			size := f at: 'size' ifAbsent: [ -1 ].
			size >= 0
				ifTrue: [ size asStringWithCommas , ' bytes' ]
				ifFalse: [ 'unknown' ] ] weight: 0.3
]

{ #category : 'gt - extensions' }
Gt4CloudflareDynamicWorkerResult >> gtParsedBodyFor: aView [
	<gtView>
	| json |
	json := self bodyJson.
	json ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Parsed body';
		priority: 12;
		object: [ json ]
]

{ #category : 'gt - extensions' }
Gt4CloudflareDynamicWorkerResult >> gtSummaryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Summary';
		priority: 5;
		items: [ {
			'Status' -> (status ifNil: [ 'n/a' ]) asString.
			'Language' -> (language ifNil: [ 'n/a' ]).
			'Success' -> self isSuccess asString.
			'Body size' -> (body ifNil: [ '' ]) size asString , ' chars'.
			'Log entries' -> (logs ifNil: [ #() ]) size asString.
			'Error' -> (error ifNil: [ 'none' ]).
		} ];
		column: 'Key' text: #key weight: 0.3;
		column: 'Value' text: #value weight: 0.7
]

{ #category : 'testing' }
Gt4CloudflareDynamicWorkerResult >> isSuccess [
	^ error isNil and: [ status = 200 ]
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> language [
	^ language
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> language: anObject [
	language := anObject
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> logs [
	^ logs
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> logs: anObject [
	logs := anObject
]

{ #category : 'printing' }
Gt4CloudflareDynamicWorkerResult >> printOn: aStream [
	aStream
		nextPutAll: 'DynamicWorkerResult(';
		nextPutAll: (language ifNil: [ '?' ]);
		nextPutAll: ', status=';
		print: status;
		nextPut: $)
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> rawData [
	^ rawData
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> rawData: anObject [
	rawData := anObject
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> status [
	^ status
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerResult >> status: anObject [
	status := anObject
]
