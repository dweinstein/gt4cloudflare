Class {
	#name : 'Gt4CloudflareWebhookEvents',
	#superclass : 'Object',
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'gt - views' }
Gt4CloudflareWebhookEvents >> gtEventsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Events';
		priority: 1;
		items: [ self items sorted: [ :a :b | 
			(a timestamp ifNil: [ '' ]) > (b timestamp ifNil: [ '' ]) ] ];
		column: 'Timestamp' text: [ :e | e timestamp ifNil: [ '' ] ] weight: 2;
		column: 'Method' text: [ :e | e method ifNil: [ '' ] ] weight: 0.7;
		column: 'Path' text: [ :e | e path ifNil: [ '' ] ] weight: 1.5;
		column: 'Source IP' text: [ :e | e sourceIp ifNil: [ '' ] ] weight: 1
]
