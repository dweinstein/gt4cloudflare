Class {
	#name : 'Gt4CloudflareMarkdownFileResult',
	#superclass : 'Object',
	#instVars : [
		'name',
		'mimeType',
		'format',
		'tokens',
		'data',
		'error'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareMarkdownFileResult class >> fromDictionary: aDictionary [
	^ self new
		name: (aDictionary at: 'name' ifAbsent: [ nil ]);
		mimeType: (aDictionary at: 'mimeType' ifAbsent: [ nil ]);
		format: (aDictionary at: 'format' ifAbsent: [ nil ]);
		tokens: (aDictionary at: 'tokens' ifAbsent: [ 0 ]);
		data: (aDictionary at: 'data' ifAbsent: [ '' ]);
		error: (aDictionary at: 'error' ifAbsent: [ nil ])
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> data [
	^ data
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> data: aString [
	data := aString
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> error [
	^ error
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> error: aString [
	error := aString
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> format [
	^ format
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> format: aString [
	format := aString
]

{ #category : 'gt - views' }
Gt4CloudflareMarkdownFileResult >> gtMarkdownFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Markdown';
		priority: 1;
		text: [ data ifNil: [ '' ] ]
]

{ #category : 'gt - views' }
Gt4CloudflareMarkdownFileResult >> gtSummaryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Summary';
		priority: 2;
		items: [ {
			'Name' -> (name ifNil: [ '' ]).
			'MIME Type' -> (mimeType ifNil: [ '' ]).
			'Format' -> (format ifNil: [ '' ]).
			'Tokens' -> tokens asString.
			'Error' -> (error ifNil: [ '(none)' ]) } ];
		column: 'Property' text: #key weight: 1;
		column: 'Value' text: #value weight: 3
]

{ #category : 'testing' }
Gt4CloudflareMarkdownFileResult >> isError [
	^ format = 'error'
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> mimeType [
	^ mimeType
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> mimeType: aString [
	mimeType := aString
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> name [
	^ name
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> name: aString [
	name := aString
]

{ #category : 'printing' }
Gt4CloudflareMarkdownFileResult >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: (name ifNil: [ 'unnamed' ]);
		nextPutAll: ', ';
		print: tokens;
		nextPutAll: ' tokens)'
]

{ #category : 'actions' }
Gt4CloudflareMarkdownFileResult >> saveToFile: aFileReference [
	"Write the markdown content to a file"
	aFileReference asFileReference writeStreamDo: [ :s | s nextPutAll: data ].
	^ aFileReference asFileReference
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> tokens [
	^ tokens
]

{ #category : 'accessing' }
Gt4CloudflareMarkdownFileResult >> tokens: anInteger [
	tokens := anInteger
]
