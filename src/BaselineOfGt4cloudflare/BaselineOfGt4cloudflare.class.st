Class {
	#name : 'BaselineOfGt4cloudflare',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGt4cloudflare',
	#package : 'BaselineOfGt4cloudflare'
}

{ #category : 'loading' }
BaselineOfGt4cloudflare class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'gt4cloudflare' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : 'baseline' }
BaselineOfGt4cloudflare >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'Gt4Cloudflare'
		]
]
