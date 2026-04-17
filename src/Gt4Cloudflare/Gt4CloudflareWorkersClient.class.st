Class {
	#name : 'Gt4CloudflareWorkersClient',
	#superclass : 'Object',
	#instVars : [
		'baseUrl',
		'apiKey',
		'accountId',
		'history'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareWorkersClient class >> apiKeyFileContents [
	^ self defaultApiKeyFile contents trimBoth
]

{ #category : 'defaults' }
Gt4CloudflareWorkersClient class >> defaultApiKeyFile [
	^ FileLocator home / '.secrets' / 'cloudflare-api-key.txt'
]

{ #category : 'instance creation' }
Gt4CloudflareWorkersClient class >> withApiKeyFromFile [
	^ self new apiKey: self apiKeyFileContents
]

{ #category : 'accessing' }
Gt4CloudflareWorkersClient >> accountId [
	^ accountId
]

{ #category : 'accessing' }
Gt4CloudflareWorkersClient >> accountId: aString [
	accountId := aString
]

{ #category : 'private' }
Gt4CloudflareWorkersClient >> accountUrl [
	^ baseUrl / 'accounts' / accountId
]

{ #category : 'accessing' }
Gt4CloudflareWorkersClient >> apiKey [
	^ apiKey
]

{ #category : 'accessing' }
Gt4CloudflareWorkersClient >> apiKey: aString [
	apiKey := aString
]

{ #category : 'accessing' }
Gt4CloudflareWorkersClient >> baseUrl [
	^ baseUrl
]

{ #category : 'accessing' }
Gt4CloudflareWorkersClient >> baseUrl: anObject [
	baseUrl := anObject asZnUrl
]

{ #category : 'private' }
Gt4CloudflareWorkersClient >> checkForErrors: aResponse [
	aResponse ifNil: [ Error signal: 'Cloudflare Workers API: empty response' ].
	(aResponse respondsTo: #at:ifAbsent:) ifFalse: [ ^ aResponse ].
	(aResponse at: 'success' ifAbsent: [ true ])
		ifFalse: [
			| errors message |
			errors := aResponse at: 'errors' ifAbsent: [ nil ].
			message := (errors isNil or: [ errors isEmpty ])
				ifTrue: [ 'unknown error' ]
				ifFalse: [ errors first at: 'message' ifAbsent: [ 'unknown error' ] ].
			Error signal: 'Cloudflare Workers API error: ' , message ].
	^ aResponse
]

{ #category : 'api - kv' }
Gt4CloudflareWorkersClient >> createKvNamespace: aTitle [
	"POST /accounts/{account_id}/storage/kv/namespaces — create a new KV namespace."
	| url response |
	url := self accountUrl / 'storage' / 'kv' / 'namespaces'.
	response := self post: url withEntity: { 'title' -> aTitle } asDictionary.
	^ (Gt4CloudflareKvNamespace fromDictionary: (response at: 'result')) client: self
]

{ #category : 'private' }
Gt4CloudflareWorkersClient >> delete: aUrl [
	| aClient response |
	aClient := self initializeClient.
	aClient url: aUrl.
	aClient entity: nil.
	response := aClient delete.
	history add: (aClient request -> aClient response).
	^ self checkForErrors: response
]

{ #category : 'api - kv' }
Gt4CloudflareWorkersClient >> deleteKvNamespace: aNamespaceId [
	"DELETE /accounts/{account_id}/storage/kv/namespaces/{namespace_id}"
	| url |
	url := self accountUrl / 'storage' / 'kv' / 'namespaces' / aNamespaceId.
	^ self delete: url
]

{ #category : 'api - scripts' }
Gt4CloudflareWorkersClient >> deleteScript: aScriptName [
	"DELETE /accounts/{account_id}/workers/scripts/{script_name}"
	^ self delete: self accountUrl / 'workers' / 'scripts' / aScriptName
]

{ #category : 'api - subdomain' }
Gt4CloudflareWorkersClient >> disableSubdomain: aScriptName [
	"POST /accounts/{account_id}/workers/scripts/{script_name}/subdomain — disable workers.dev for a script."
	| url |
	url := self accountUrl / 'workers' / 'scripts' / aScriptName / 'subdomain'.
	^ self post: url withEntity: { 'enabled' -> false } asDictionary
]

{ #category : 'api - subdomain' }
Gt4CloudflareWorkersClient >> enableSubdomain: aScriptName [
	"POST /accounts/{account_id}/workers/scripts/{script_name}/subdomain — enable workers.dev for a script."
	| url |
	url := self accountUrl / 'workers' / 'scripts' / aScriptName / 'subdomain'.
	^ self post: url withEntity: { 'enabled' -> true } asDictionary
]

{ #category : 'private' }
Gt4CloudflareWorkersClient >> get: aUrl [
	| aClient response |
	aClient := self initializeClient.
	aClient url: aUrl.
	aClient entity: nil.
	response := aClient get.
	history add: (aClient request -> aClient response).
	^ self checkForErrors: response
]

{ #category : 'api - subdomain' }
Gt4CloudflareWorkersClient >> getSubdomain [
	"GET /accounts/{account_id}/workers/subdomain — get the account's workers.dev subdomain name."
	| response |
	response := self get: self accountUrl / 'workers' / 'subdomain'.
	^ (response at: 'result') at: 'subdomain'
]

{ #category : 'gt - views' }
Gt4CloudflareWorkersClient >> gtCallsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Calls';
		priority: 5;
		items: [ history reversed ];
		column: 'URL' text: [ :pair | pair key url ] weight: 3;
		column: 'Method' text: [ :pair | pair key method ] weight: 1;
		column: 'Status' text: [ :pair |
			pair value
				ifNil: [ 'no response' ]
				ifNotNil: [ :r | r statusLine printString ] ] weight: 2
]

{ #category : 'gt - views' }
Gt4CloudflareWorkersClient >> gtClearHistoryActionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons cancel;
		tooltip: 'Clear history';
		priority: 80;
		action: [ :aButton :aTab |
			history removeAll.
			aTab viewContentElement phlow update ]
]

{ #category : 'gt - views' }
Gt4CloudflareWorkersClient >> gtConfigurationFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Configuration';
		priority: 1;
		items: [ {
			'Base URL' -> baseUrl printString.
			'Account ID' -> (accountId ifNil: [ '(not set)' ]).
			'API Key' -> (apiKey
				ifNil: [ '(not set)' ]
				ifNotNil: [ (apiKey first: (4 min: apiKey size)) , '...' , (apiKey last: (4 min: apiKey size)) ]).
			'History' -> history size asString , ' calls' } ];
		column: 'Property' text: [ :assoc | assoc key ] weight: 1;
		column: 'Value' text: [ :assoc | assoc value ] weight: 3
]

{ #category : 'gt - views' }
Gt4CloudflareWorkersClient >> gtEndpointsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Endpoints';
		priority: 3;
		items: [ {
			'Scripts' -> 'listScripts' -> 'List all Worker scripts'.
			'Scripts' -> 'uploadScript:code:' -> 'Upload/update a Worker script'.
			'Scripts' -> 'deleteScript:' -> 'Delete a Worker script'.
			'Subdomain' -> 'getSubdomain' -> 'Get workers.dev subdomain'.
			'Subdomain' -> 'enableSubdomain:' -> 'Enable workers.dev for a script'.
			'Subdomain' -> 'scriptUrl:' -> 'Public URL for a script'.
			'KV' -> 'createKvNamespace:' -> 'Create a KV namespace'.
			'KV' -> 'listKvNamespaces' -> 'List KV namespaces'.
			'KV' -> 'kvGet:namespace:' -> 'Read a KV value'.
			'KV' -> 'kvPut:value:namespace:' -> 'Write a KV value'.
			'KV' -> 'kvListKeys:' -> 'List keys in a namespace' } ];
		column: 'Area' text: [ :item | item key key ] weight: 1;
		column: 'Method' text: [ :item | item key value ] weight: 3;
		column: 'Description' text: [ :item | item value ] weight: 4
]

{ #category : 'accessing' }
Gt4CloudflareWorkersClient >> history [
	^ history
]

{ #category : 'initialization' }
Gt4CloudflareWorkersClient >> initialize [
	super initialize.
	baseUrl := 'https://api.cloudflare.com/client/v4' asZnUrl.
	history := OrderedCollection new
]

{ #category : 'private' }
Gt4CloudflareWorkersClient >> initializeClient [
	| aClient |
	aClient := ZnClient new.
	aClient forJsonREST.
	aClient timeout: 120.
	aClient setBearerAuthentication: apiKey.
	^ aClient
]

{ #category : 'api - kv' }
Gt4CloudflareWorkersClient >> kvDelete: aKey namespace: aNamespaceId [
	"DELETE /accounts/{account_id}/storage/kv/namespaces/{namespace_id}/values/{key_name}"
	| url |
	url := self accountUrl / 'storage' / 'kv' / 'namespaces' / aNamespaceId / 'values' / aKey.
	^ self delete: url
]

{ #category : 'api - kv' }
Gt4CloudflareWorkersClient >> kvGet: aKey namespace: aNamespaceId [
	"GET /accounts/{account_id}/storage/kv/namespaces/{namespace_id}/values/{key_name} — read a value.
	KV returns raw bytes; we decode to UTF-8 string."
	| aClient url response |
	url := self accountUrl / 'storage' / 'kv' / 'namespaces' / aNamespaceId / 'values' / aKey.
	aClient := ZnClient new.
	aClient timeout: 120.
	aClient setBearerAuthentication: apiKey.
	aClient url: url.
	aClient get.
	history add: (aClient request -> aClient response).
	aClient isSuccess ifFalse: [
		Error signal: 'KV read failed: ' , aClient response statusLine printString ].
	response := aClient response entity.
	^ response bytes
		ifNil: [ response contents ]
		ifNotNil: [ :b | b utf8Decoded ]
]

{ #category : 'api - kv' }
Gt4CloudflareWorkersClient >> kvListKeys: aNamespaceId [
	"GET /accounts/{account_id}/storage/kv/namespaces/{namespace_id}/keys — list all keys."
	^ self kvListKeys: aNamespaceId prefix: nil limit: nil
]

{ #category : 'api - kv' }
Gt4CloudflareWorkersClient >> kvListKeys: aNamespaceId prefix: aPrefixOrNil limit: aLimitOrNil [
	"List keys with optional prefix filter and limit."
	| aClient url response |
	url := self accountUrl / 'storage' / 'kv' / 'namespaces' / aNamespaceId / 'keys'.
	aClient := self initializeClient.
	aClient url: url.
	aPrefixOrNil ifNotNil: [ :p | aClient queryAt: 'prefix' put: p ].
	aLimitOrNil ifNotNil: [ :l | aClient queryAt: 'limit' put: l asString ].
	aClient entity: nil.
	response := aClient get.
	history add: (aClient request -> aClient response).
	^ self checkForErrors: response
]

{ #category : 'api - kv' }
Gt4CloudflareWorkersClient >> kvPut: aKey value: aValueString namespace: aNamespaceId [
	"PUT /accounts/{account_id}/storage/kv/namespaces/{namespace_id}/values/{key_name} — write a value."
	| aClient url |
	url := self accountUrl / 'storage' / 'kv' / 'namespaces' / aNamespaceId / 'values' / aKey.
	aClient := ZnClient new.
	aClient timeout: 120.
	aClient setBearerAuthentication: apiKey.
	aClient url: url.
	aClient entity: (ZnEntity text: aValueString).
	aClient put.
	history add: (aClient request -> aClient response).
	aClient isSuccess ifFalse: [
		Error signal: 'KV write failed: ' , aClient response statusLine printString ].
	^ aClient contents
]

{ #category : 'api - kv' }
Gt4CloudflareWorkersClient >> listKvNamespaces [
	"GET /accounts/{account_id}/storage/kv/namespaces — list all KV namespaces."
	| url response items |
	url := self accountUrl / 'storage' / 'kv' / 'namespaces'.
	response := self get: url.
	items := (response at: 'result') collect: [ :each |
		(Gt4CloudflareKvNamespace fromDictionary: each) client: self ].
	^ Gt4CloudflareKvNamespaces withAll: items
]

{ #category : 'api - scripts' }
Gt4CloudflareWorkersClient >> listScripts [
	"GET /accounts/{account_id}/workers/scripts — list all Worker scripts."
	| response items |
	response := self get: self accountUrl / 'workers' / 'scripts'.
	items := (response at: 'result') collect: [ :each |
		(Gt4CloudflareWorkerScript fromDictionary: each) client: self ].
	^ Gt4CloudflareWorkerScripts withAll: items
]

{ #category : 'private' }
Gt4CloudflareWorkersClient >> post: aUrl withEntity: aDictionary [
	| aClient response |
	aClient := self initializeClient.
	aClient url: aUrl.
	aClient contents: aDictionary.
	response := aClient post.
	history add: (aClient request -> aClient response).
	^ self checkForErrors: response
]

{ #category : 'printing' }
Gt4CloudflareWorkersClient >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: (accountId ifNil: [ 'no account' ]);
		nextPutAll: ', ';
		print: history size;
		nextPutAll: ' calls)'
]

{ #category : 'private' }
Gt4CloudflareWorkersClient >> put: aUrl withEntity: aDictionary [
	| aClient response |
	aClient := self initializeClient.
	aClient url: aUrl.
	aClient contents: aDictionary.
	response := aClient put.
	history add: (aClient request -> aClient response).
	^ self checkForErrors: response
]

{ #category : 'private' }
Gt4CloudflareWorkersClient >> putMultipart: aUrl metadata: aMetadataDict script: aJsString [
	"Upload a Worker script as multipart form data with metadata + JS module."
	| aClient entity metaPart scriptPart response |
	aClient := ZnClient new.
	aClient timeout: 120.
	aClient setBearerAuthentication: apiKey.
	aClient url: aUrl.
	entity := ZnMultiPartFormDataEntity new.
	metaPart := ZnMimePart
		fieldName: 'metadata'
		entity: (ZnEntity json: (NeoJSONWriter toString: aMetadataDict)).
	entity addPart: metaPart.
	scriptPart := ZnMimePart
		fieldName: 'worker.js'
		fileName: 'worker.js'
		entity: (ZnEntity
			with: aJsString
			type: 'application/javascript+module' asZnMimeType).
	entity addPart: scriptPart.
	aClient entity: entity.
	aClient put.
	history add: (aClient request -> aClient response).
	response := NeoJSONReader fromString: aClient contents.
	^ self checkForErrors: response
]

{ #category : 'api - subdomain' }
Gt4CloudflareWorkersClient >> scriptUrl: aScriptName [
	"Return the public workers.dev URL for a script."
	| subdomain |
	subdomain := self getSubdomain.
	^ 'https://' , aScriptName , '.' , subdomain , '.workers.dev'
]

{ #category : 'api - scripts' }
Gt4CloudflareWorkersClient >> uploadScript: aScriptName code: aJsString [
	"PUT /accounts/{account_id}/workers/scripts/{script_name} — upload/update a Worker script as ES module."
	| metadata url response |
	metadata := Dictionary new.
	metadata at: 'main_module' put: 'worker.js'.
	metadata at: 'compatibility_date' put: Date today yyyymmdd.
	url := self accountUrl / 'workers' / 'scripts' / aScriptName.
	response := self putMultipart: url metadata: metadata script: aJsString.
	^ (Gt4CloudflareWorkerScript fromDictionary: (response at: 'result')) client: self
]

{ #category : 'api - scripts' }
Gt4CloudflareWorkersClient >> uploadScript: aScriptName code: aJsString bindings: aBindingsArray [
	"Upload a Worker script with KV or other bindings.
	aBindingsArray is an array of dictionaries, e.g.:
	  { { 'type' -> 'kv_namespace'. 'name' -> 'STORE'. 'namespace_id' -> '...' } asDictionary }"
	| metadata url response |
	metadata := Dictionary new.
	metadata at: 'main_module' put: 'worker.js'.
	metadata at: 'compatibility_date' put: Date today yyyymmdd.
	metadata at: 'bindings' put: aBindingsArray.
	url := self accountUrl / 'workers' / 'scripts' / aScriptName.
	response := self putMultipart: url metadata: metadata script: aJsString.
	^ (Gt4CloudflareWorkerScript fromDictionary: (response at: 'result')) client: self
]
