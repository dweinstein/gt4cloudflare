"
I wrap the result of the /content endpoint — the fully rendered HTML of a page after JavaScript execution.

My html accessor returns the HTML string. Inspect me to see the HTML source view.
"
Class {
	#name : 'Gt4CloudflareContentResult',
	#superclass : 'Object',
	#instVars : [
		'html'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'gt - views' }
Gt4CloudflareContentResult >> gtHtmlSourceFor: aView [
	<gtView>
	html ifNil: [ ^ aView empty ].
	^ aView textEditor
		title: 'HTML source';
		priority: 1;
		text: [ html ]
]

{ #category : 'accessing' }
Gt4CloudflareContentResult >> html [
	^ html
]

{ #category : 'accessing' }
Gt4CloudflareContentResult >> html: aString [
	html := aString
]

{ #category : 'printing' }
Gt4CloudflareContentResult >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		print: (html ifNil: [ 0 ] ifNotNil: [ html size ]);
		nextPutAll: ' chars)'
]
