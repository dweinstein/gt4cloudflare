Class {
	#name : 'BaselineOfGt4Cloudflare',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGt4Cloudflare',
	#package : 'BaselineOfGt4Cloudflare'
}

{ #category : 'loading' }
BaselineOfGt4Cloudflare class >> loadLepiter [
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
BaselineOfGt4Cloudflare >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'Gt4Cloudflare'
		]
]
