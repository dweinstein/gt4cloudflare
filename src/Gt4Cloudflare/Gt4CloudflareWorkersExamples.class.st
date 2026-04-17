Class {
	#name : 'Gt4CloudflareWorkersExamples',
	#superclass : 'Object',
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'examples - client' }
Gt4CloudflareWorkersExamples >> client [
	<gtExample>
	| aClient |
	aClient := Gt4CloudflareWorkersClient new
		accountId: 'test-account-id';
		apiKey: 'test-api-key'.
	self assert: aClient accountId equals: 'test-account-id'.
	self assert: aClient history isEmpty.
	^ aClient
]

{ #category : 'examples - kv' }
Gt4CloudflareWorkersExamples >> kvEntry [
	<gtExample>
	| entry |
	entry := Gt4CloudflareKvEntry new
		key: 'evt:2025-04-10T14:30:00.000Z:a1b2c3d4';
		value: '{"timestamp":"2025-04-10T14:30:00.000Z","method":"POST"}';
		metadata: nil;
		expiration: 1749542400.
	self assert: entry key isNotNil.
	self assert: (entry key beginsWith: 'evt:').
	^ entry
]

{ #category : 'examples - kv' }
Gt4CloudflareWorkersExamples >> kvNamespace [
	<gtExample>
	| ns |
	ns := Gt4CloudflareKvNamespace fromDictionary: self kvNamespaceJson.
	self assert: ns id equals: 'ns-abc-123'.
	self assert: ns title equals: 'storylane-webhook-events'.
	^ ns
]

{ #category : 'examples - fixtures' }
Gt4CloudflareWorkersExamples >> kvNamespaceJson [
	^ NeoJSONObject fromString: '{
		"id": "ns-abc-123",
		"title": "storylane-webhook-events"
	}'
]

{ #category : 'examples - kv' }
Gt4CloudflareWorkersExamples >> kvNamespaces [
	<gtExample>
	| namespaces |
	namespaces := Gt4CloudflareKvNamespaces withAll: {
		self kvNamespace.
		Gt4CloudflareKvNamespace fromDictionary: (NeoJSONObject fromString: '{
			"id": "ns-def-456",
			"title": "other-namespace"
		}') }.
	self assert: namespaces items size equals: 2.
	^ namespaces
]

{ #category : 'examples - webhook events' }
Gt4CloudflareWorkersExamples >> webhookEvent [
	<gtExample>
	| event |
	event := Gt4CloudflareWebhookEvent
		fromJsonString: self webhookEventJson
		kvKey: 'evt:2025-04-10T14:30:00.000Z:a1b2c3d4'.
	self assert: event timestamp equals: '2025-04-10T14:30:00.000Z'.
	self assert: event method equals: 'POST'.
	self assert: event path equals: '/'.
	self assert: event sourceIp equals: '203.0.113.42'.
	self assert: event contentType equals: 'application/json'.
	self assert: event signatureHeader equals: 'abc123sig=='.
	self assert: event kvKey isNotNil.
	^ event
]

{ #category : 'examples - fixtures' }
Gt4CloudflareWorkersExamples >> webhookEventAnonymousJson [
	^ '{
		"timestamp": "2025-04-10T15:05:00.000Z",
		"method": "POST",
		"url": "https://storylane-webhook.myaccount.workers.dev/",
		"path": "/",
		"headers": {
			"content-type": "application/json",
			"cf-connecting-ip": "198.51.100.7",
			"user-agent": "Storylane-Webhook/1.0"
		},
		"body": "{\"id\":\"sess-456\",\"name\":\"Quick Demo\",\"completion\":30,\"time_spent\":22}",
		"sourceIp": "198.51.100.7"
	}'
]

{ #category : 'examples - fixtures' }
Gt4CloudflareWorkersExamples >> webhookEventJson [
	^ '{
		"timestamp": "2025-04-10T14:30:00.000Z",
		"method": "POST",
		"url": "https://storylane-webhook.myaccount.workers.dev/",
		"path": "/",
		"headers": {
			"content-type": "application/json",
			"x-storylane-signature": "abc123sig==",
			"cf-connecting-ip": "203.0.113.42",
			"user-agent": "Storylane-Webhook/1.0"
		},
		"body": "{\"id\":\"sess-123\",\"name\":\"Product Tour\",\"lead\":{\"email\":\"jane@acme.com\",\"first_name\":\"Jane\",\"last_name\":\"Doe\"},\"buyer_reveal\":{\"company_name\":\"Acme Corp\",\"company_domain\":\"acme.com\"},\"completion\":85,\"time_spent\":142}",
		"sourceIp": "203.0.113.42"
	}'
]

{ #category : 'examples - webhook events' }
Gt4CloudflareWorkersExamples >> webhookEventParsedBody [
	<gtExample>
	| event parsed |
	event := self webhookEvent.
	parsed := event parsedBody.
	self assert: (parsed at: 'id') equals: 'sess-123'.
	self assert: (parsed at: 'name') equals: 'Product Tour'.
	self assert: ((parsed at: 'lead') at: 'email') equals: 'jane@acme.com'.
	self assert: ((parsed at: 'buyer_reveal') at: 'company_name') equals: 'Acme Corp'.
	^ parsed
]

{ #category : 'examples - webhook events' }
Gt4CloudflareWorkersExamples >> webhookEvents [
	<gtExample>
	| events |
	events := Gt4CloudflareWebhookEvents withAll: {
		Gt4CloudflareWebhookEvent
			fromJsonString: self webhookEventJson
			kvKey: 'evt:2025-04-10T14:30:00.000Z:a1b2c3d4'.
		Gt4CloudflareWebhookEvent
			fromJsonString: self webhookEventAnonymousJson
			kvKey: 'evt:2025-04-10T15:05:00.000Z:e5f6g7h8' }.
	self assert: events items size equals: 2.
	self assert: events items first sourceIp equals: '203.0.113.42'.
	self assert: events items second signatureHeader isNil.
	^ events
]

{ #category : 'examples - webhook worker' }
Gt4CloudflareWorkersExamples >> webhookWorker [
	<gtExample>
	"Creates a webhook worker configured but not deployed (no live API calls)."
	| worker |
	worker := Gt4CloudflareWebhookWorker
		client: self client
		scriptName: 'storylane-webhook'
		secret: 'my-test-secret'.
	worker kvNamespaceId: 'ns-abc-123'.
	self assert: worker scriptName equals: 'storylane-webhook'.
	self assert: worker secret equals: 'my-test-secret'.
	self assert: worker isDeployed not.
	^ worker
]

{ #category : 'examples - webhook worker' }
Gt4CloudflareWorkersExamples >> webhookWorkerScript [
	<gtExample>
	"Verifies the generated JS code contains key webhook handling features."
	| worker code |
	worker := self webhookWorker.
	code := worker webhookWorkerScript.
	self assert: (code includesSubstring: 'async fetch(request, env)').
	self assert: (code includesSubstring: 'handleWebhook').
	self assert: (code includesSubstring: 'listEvents').
	self assert: (code includesSubstring: 'verifySignature').
	self assert: (code includesSubstring: 'env.STORE.put').
	self assert: (code includesSubstring: 'x-storylane-signature').
	self assert: (code includesSubstring: 'WEBHOOK_SECRET').
	self assert: (code includesSubstring: 'expirationTtl').
	^ code
]

{ #category : 'examples - scripts' }
Gt4CloudflareWorkersExamples >> workerScript [
	<gtExample>
	| script |
	script := Gt4CloudflareWorkerScript fromDictionary: self workerScriptJson.
	self assert: script name equals: 'my-webhook-handler'.
	self assert: script etag equals: 'abc123def456'.
	self assert: script createdOn equals: '2025-01-15T10:30:00Z'.
	self assert: script hasKvBindings.
	^ script
]

{ #category : 'examples - fixtures' }
Gt4CloudflareWorkersExamples >> workerScriptJson [
	^ NeoJSONObject fromString: '{
		"id": "my-webhook-handler",
		"etag": "abc123def456",
		"created_on": "2025-01-15T10:30:00Z",
		"modified_on": "2025-04-10T14:22:00Z",
		"bindings": [
			{ "type": "kv_namespace", "name": "STORE", "namespace_id": "ns-abc-123" }
		]
	}'
]

{ #category : 'examples - scripts' }
Gt4CloudflareWorkersExamples >> workerScripts [
	<gtExample>
	| scripts |
	scripts := Gt4CloudflareWorkerScripts withAll: {
		Gt4CloudflareWorkerScript fromDictionary: self workerScriptJson.
		Gt4CloudflareWorkerScript fromDictionary: (NeoJSONObject fromString: '{
			"id": "another-worker",
			"etag": "xyz789",
			"created_on": "2025-03-01T08:00:00Z",
			"modified_on": "2025-03-01T08:00:00Z",
			"bindings": []
		}') }.
	self assert: scripts items size equals: 2.
	self assert: scripts items first name equals: 'my-webhook-handler'.
	self assert: scripts items second hasKvBindings not.
	^ scripts
]
