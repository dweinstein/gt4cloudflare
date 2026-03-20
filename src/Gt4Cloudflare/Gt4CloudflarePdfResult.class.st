"
I wrap the binary result of the /pdf endpoint — a PDF document of a rendered page.

Send me saveToFile: to write the PDF to disk. My bytes accessor returns the raw PDF bytes.
"
Class {
	#name : 'Gt4CloudflarePdfResult',
	#superclass : 'Object',
	#instVars : [
		'bytes'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'accessing' }
Gt4CloudflarePdfResult >> bytes [
	^ bytes
]

{ #category : 'accessing' }
Gt4CloudflarePdfResult >> bytes: anObject [
	bytes := anObject
]

{ #category : 'printing' }
Gt4CloudflarePdfResult >> printOn: aStream [
	| size |
	super printOn: aStream.
	size := bytes ifNil: [ 0 ] ifNotNil: [ bytes size ].
	aStream nextPutAll: ' ('.
	size > 1048576
		ifTrue: [ aStream print: (size / 1048576.0) rounded; nextPutAll: ' MB' ]
		ifFalse: [ size > 1024
			ifTrue: [ aStream print: (size / 1024.0) rounded; nextPutAll: ' KB' ]
			ifFalse: [ aStream print: size; nextPutAll: ' bytes' ] ].
	aStream nextPut: $)
]

{ #category : 'actions' }
Gt4CloudflarePdfResult >> saveToFile: aFileReference [
	aFileReference binaryWriteStreamDo: [ :stream |
		stream nextPutAll: bytes ]
]
