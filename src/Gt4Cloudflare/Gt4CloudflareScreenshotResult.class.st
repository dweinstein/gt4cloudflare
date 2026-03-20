"
I wrap the binary result of the /screenshot endpoint — a PNG or JPEG image of a rendered page.

Send me asForm to get a Pharo Form for display. Send me saveToFile: to write the image to disk. Inspect me to see the screenshot in the GT inspector.
"
Class {
	#name : 'Gt4CloudflareScreenshotResult',
	#superclass : 'Object',
	#instVars : [
		'bytes',
		'contentType'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'converting' }
Gt4CloudflareScreenshotResult >> asForm [
	^ ImageReadWriter formFromStream: bytes readStream
]

{ #category : 'accessing' }
Gt4CloudflareScreenshotResult >> bytes [
	^ bytes
]

{ #category : 'accessing' }
Gt4CloudflareScreenshotResult >> bytes: anObject [
	bytes := anObject
]

{ #category : 'accessing' }
Gt4CloudflareScreenshotResult >> contentType [
	^ contentType
]

{ #category : 'accessing' }
Gt4CloudflareScreenshotResult >> contentType: aString [
	contentType := aString
]

{ #category : 'gt - views' }
Gt4CloudflareScreenshotResult >> gtImageFor: aView [
	<gtView>
	bytes ifNil: [ ^ aView empty ].
	^ aView explicit
		title: 'Screenshot';
		priority: 1;
		stencil: [ self asForm asElement ]
]

{ #category : 'printing' }
Gt4CloudflareScreenshotResult >> printOn: aStream [
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
Gt4CloudflareScreenshotResult >> saveToFile: aFileReference [
	aFileReference binaryWriteStreamDo: [ :stream |
		stream nextPutAll: bytes ]
]
