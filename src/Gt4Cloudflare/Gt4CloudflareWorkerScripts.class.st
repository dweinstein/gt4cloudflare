Class {
	#name : 'Gt4CloudflareWorkerScripts',
	#superclass : 'Object',
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'gt - views' }
Gt4CloudflareWorkerScripts >> gtScriptsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Scripts';
		priority: 1;
		items: [ self items ];
		column: 'Name' text: [ :s | s name ifNil: [ '' ] ] weight: 2;
		column: 'Modified' text: [ :s | s modifiedOn ifNil: [ '' ] ] weight: 2;
		column: 'KV' text: [ :s | s hasKvBindings ifTrue: [ 'yes' ] ifFalse: [ '' ] ] weight: 0.5
]
