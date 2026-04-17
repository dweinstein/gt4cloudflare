Class {
	#name : 'Gt4CloudflareKvNamespaces',
	#superclass : 'Object',
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'gt - views' }
Gt4CloudflareKvNamespaces >> gtNamespacesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Namespaces';
		priority: 1;
		items: [ self items ];
		column: 'Title' text: [ :ns | ns title ifNil: [ '' ] ] weight: 2;
		column: 'ID' text: [ :ns | ns id ifNil: [ '' ] ] weight: 3
]
