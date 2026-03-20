"
I represent an async crawl job from the /crawl endpoint.

I track job status (running, completed, errored), records of crawled pages, and browser seconds used. Send me refresh to poll for updated status. I hold a reference to the client for polling.

My records accessor returns a collection of Gt4CloudflareCrawlRecord instances. Use the Refresh action button in the inspector to poll for updates.
"
Class {
	#name : 'Gt4CloudflareCrawlJob',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'jobId',
		'status',
		'total',
		'finished',
		'browserSecondsUsed',
		'records',
		'cursor',
		'client'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareCrawlJob class >> fromDictionary: aDictionary withClient: aClient [
	| job resultData |
	job := self new.
	job rawData: aDictionary.
	job client: aClient.
	resultData := aDictionary at: 'result'.
	job jobId: (resultData at: 'id' ifAbsent: [ nil ]).
	job status: (resultData at: 'status' ifAbsent: [ nil ]).
	job total: (resultData at: 'total' ifAbsent: [ nil ]).
	job finished: (resultData at: 'finished' ifAbsent: [ nil ]).
	job browserSecondsUsed: (resultData at: 'browserSecondsUsed' ifAbsent: [ nil ]).
	job cursor: (resultData at: 'cursor' ifAbsent: [ nil ]).
	job records: ((resultData at: 'records' ifAbsent: [ #() ])
		collect: [ :each | Gt4CloudflareCrawlRecord fromDictionary: each ]).
	^ job
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> browserSecondsUsed [
	^ browserSecondsUsed
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> browserSecondsUsed: anObject [
	browserSecondsUsed := anObject
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> client [
	^ client
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> client: anObject [
	client := anObject
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> cursor [
	^ cursor
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> cursor: anObject [
	cursor := anObject
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> finished [
	^ finished
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> finished: anObject [
	finished := anObject
]

{ #category : 'gt - views' }
Gt4CloudflareCrawlJob >> gtRecordsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Records';
		priority: 1;
		items: [ self records ];
		column: 'URL' text: [ :r | r url ] weight: 4;
		column: 'Status' text: [ :r | r status ] weight: 1
]

{ #category : 'gt - views' }
Gt4CloudflareCrawlJob >> gtRefreshActionFor: anAction [
	<gtAction>
	client ifNil: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons refresh;
		tooltip: 'Refresh';
		priority: 1;
		action: [ :aButton |
			| updated |
			updated := self refresh.
			aButton phlow spawnObject: updated ]
]

{ #category : 'gt - views' }
Gt4CloudflareCrawlJob >> gtStatusFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Status';
		priority: 2;
		items: [ {
			'Job ID' -> (jobId ifNil: [ '' ]).
			'Status' -> (status ifNil: [ '' ]).
			'Total' -> (total ifNil: [ '' ]).
			'Finished' -> (finished ifNil: [ '' ]).
			'Browser seconds' -> (browserSecondsUsed ifNil: [ '' ]).
			'Cursor' -> (cursor ifNil: [ '' ]) } ];
		column: 'Property' text: [ :assoc | assoc key ] weight: 1;
		column: 'Value' text: [ :assoc | assoc value ] weight: 3
]

{ #category : 'testing' }
Gt4CloudflareCrawlJob >> isCompleted [
	^ status = 'completed'
]

{ #category : 'testing' }
Gt4CloudflareCrawlJob >> isRunning [
	^ status = 'running'
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> jobId [
	^ jobId
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> jobId: aString [
	jobId := aString
]

{ #category : 'printing' }
Gt4CloudflareCrawlJob >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: (status ifNil: [ '?' ]);
		nextPutAll: ' - ';
		print: self records size;
		nextPutAll: ' records)'
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> rawData [
	^ rawData
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> rawData: anObject [
	rawData := anObject
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> records [
	^ records ifNil: [ #() ]
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> records: anObject [
	records := anObject
]

{ #category : 'actions' }
Gt4CloudflareCrawlJob >> refresh [
	"Poll the API for updated status and records"
	client ifNil: [ Error signal: 'No client set for refresh' ].
	^ client getCrawl: jobId
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> status [
	^ status
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> status: aString [
	status := aString
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> total [
	^ total
]

{ #category : 'accessing' }
Gt4CloudflareCrawlJob >> total: anObject [
	total := anObject
]
