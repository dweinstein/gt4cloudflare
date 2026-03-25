Class {
	#name : 'Gt4CloudflareDynamicWorkerClient',
	#superclass : 'Object',
	#instVars : [
		'hostUrl',
		'authToken',
		'history'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerClient >> authToken [
	^ authToken
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerClient >> authToken: aString [
	authToken := aString
]

{ #category : 'private' }
Gt4CloudflareDynamicWorkerClient >> checkForErrors: aResponse [
	aResponse ifNil: [ Error signal: 'Dynamic Worker host: empty response' ].
	(aResponse respondsTo: #at:ifAbsent:) ifFalse: [ ^ aResponse ].
	(aResponse at: 'success' ifAbsent: [ true ])
		ifFalse: [
			| message |
			message := aResponse at: 'error' ifAbsent: [ 'unknown error' ].
			Error signal: 'Dynamic Worker error: ' , message asString ].
	^ aResponse
]

{ #category : 'gt - extensions' }
Gt4CloudflareDynamicWorkerClient >> gtCallsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Calls';
		priority: 10;
		items: [ history reversed ];
		column: 'Method' text: [ :pair | pair key method ] weight: 0.15;
		column: 'URL' text: [ :pair | pair key uri asString ] weight: 0.55;
		column: 'Status' text: [ :pair | pair value statusLine printString ] weight: 0.3
]

{ #category : 'gt - extensions' }
Gt4CloudflareDynamicWorkerClient >> gtConfigurationFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Configuration';
		priority: 5;
		items: [ {
			'Host URL' -> (hostUrl ifNil: [ 'not set' ]) asString.
			'Auth token' -> (authToken ifNil: [ 'not set' ] ifNotNil: [ :t | (t first: (3 min: t size)) , '...' ]).
			'API calls' -> history size asString.
		} ];
		column: 'Key' text: #key weight: 0.3;
		column: 'Value' text: #value weight: 0.7
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerClient >> history [
	^ history
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerClient >> hostUrl [
	^ hostUrl
]

{ #category : 'accessing' }
Gt4CloudflareDynamicWorkerClient >> hostUrl: aString [
	hostUrl := aString asZnUrl
]

{ #category : 'initialization' }
Gt4CloudflareDynamicWorkerClient >> initialize [
	super initialize.
	history := OrderedCollection new
]

{ #category : 'private' }
Gt4CloudflareDynamicWorkerClient >> initializeClient [
	| aClient |
	aClient := ZnClient new.
	aClient forJsonREST.
	aClient timeout: 120.
	aClient setBearerAuthentication: authToken.
	^ aClient
]

{ #category : 'private' }
Gt4CloudflareDynamicWorkerClient >> post: aDictionary [
	| aClient response |
	aClient := self initializeClient.
	aClient url: hostUrl.
	aClient contents: aDictionary.
	response := aClient post.
	history add: (aClient request -> aClient response).
	^ self checkForErrors: response
]

{ #category : 'printing' }
Gt4CloudflareDynamicWorkerClient >> printOn: aStream [
	aStream
		nextPutAll: 'DynamicWorkerClient(';
		nextPutAll: (hostUrl ifNil: [ 'unconfigured' ] ifNotNil: [ :u | u asString ]);
		nextPut: $)
]

{ #category : 'api' }
Gt4CloudflareDynamicWorkerClient >> runCode: aCodeString language: aLanguageString [
	^ self runCode: aCodeString language: aLanguageString options: Dictionary new
]

{ #category : 'api' }
Gt4CloudflareDynamicWorkerClient >> runCode: aCodeString language: aLanguageString options: aDictionary [
	| payload response |
	payload := aDictionary copy.
	payload at: 'code' put: aCodeString.
	payload at: 'language' put: aLanguageString.
	response := self post: payload.
	^ Gt4CloudflareDynamicWorkerResult fromDictionary: response
]

{ #category : 'api' }
Gt4CloudflareDynamicWorkerClient >> runJavaScript: aCodeString [
	^ self runCode: aCodeString language: 'javascript'
]

{ #category : 'api' }
Gt4CloudflareDynamicWorkerClient >> runPython: aCodeString [
	^ self runCode: aCodeString language: 'python'
]
