Class {
	#name : 'Gt4CloudflareWebhookWorker',
	#superclass : 'Object',
	#instVars : [
		'client',
		'scriptName',
		'kvNamespaceId',
		'secret',
		'publicUrl'
	],
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'instance creation' }
Gt4CloudflareWebhookWorker class >> client: aClient scriptName: aName [
	^ self new
		client: aClient;
		scriptName: aName
]

{ #category : 'instance creation' }
Gt4CloudflareWebhookWorker class >> client: aClient scriptName: aName secret: aSecret [
	^ self new
		client: aClient;
		scriptName: aName;
		secret: aSecret
]

{ #category : 'api' }
Gt4CloudflareWebhookWorker >> clearEvents [
	"Delete all stored webhook events from KV."
	| keysResponse keys |
	keysResponse := client kvListKeys: kvNamespaceId prefix: 'evt:' limit: nil.
	keys := (keysResponse at: 'result') collect: [ :each | each at: 'name' ].
	keys do: [ :aKey | client kvDelete: aKey namespace: kvNamespaceId ]
]

{ #category : 'accessing' }
Gt4CloudflareWebhookWorker >> client [
	^ client
]

{ #category : 'accessing' }
Gt4CloudflareWebhookWorker >> client: aClient [
	client := aClient
]

{ #category : 'api' }
Gt4CloudflareWebhookWorker >> deploy [
	"Create KV namespace, upload the webhook Worker with KV binding, enable subdomain.
	Returns self with publicUrl set."
	| kvNs bindings |
	kvNamespaceId ifNil: [
		kvNs := client createKvNamespace: scriptName , '-events'.
		kvNamespaceId := kvNs id ].
	bindings := OrderedCollection new.
	bindings add: {
		'type' -> 'kv_namespace'.
		'name' -> 'STORE'.
		'namespace_id' -> kvNamespaceId } asDictionary.
	secret ifNotNil: [
		bindings add: {
			'type' -> 'secret_text'.
			'name' -> 'WEBHOOK_SECRET'.
			'text' -> secret } asDictionary ].
	client
		uploadScript: scriptName
		code: self webhookWorkerScript
		bindings: bindings asArray.
	client enableSubdomain: scriptName.
	publicUrl := client scriptUrl: scriptName.
	^ self
]

{ #category : 'api' }
Gt4CloudflareWebhookWorker >> eventCount [
	"Return the number of stored webhook events."
	| keysResponse |
	keysResponse := client kvListKeys: kvNamespaceId prefix: 'evt:' limit: nil.
	^ (keysResponse at: 'result') size
]

{ #category : 'api' }
Gt4CloudflareWebhookWorker >> fetchEvent: aKvKey [
	"Retrieve a single webhook event from KV by its key."
	| json |
	json := client kvGet: aKvKey namespace: kvNamespaceId.
	^ Gt4CloudflareWebhookEvent fromJsonString: json kvKey: aKvKey
]

{ #category : 'api' }
Gt4CloudflareWebhookWorker >> fetchEvents [
	"Retrieve all stored webhook events from KV via the Workers API.
	Returns a Gt4CloudflareWebhookEvents group."
	| keysResponse keys events |
	keysResponse := client kvListKeys: kvNamespaceId prefix: 'evt:' limit: nil.
	keys := (keysResponse at: 'result') collect: [ :each | each at: 'name' ].
	events := keys collect: [ :aKey |
		| json |
		json := client kvGet: aKey namespace: kvNamespaceId.
		Gt4CloudflareWebhookEvent fromJsonString: json kvKey: aKey ].
	^ Gt4CloudflareWebhookEvents withAll: events
]

{ #category : 'gt - actions' }
Gt4CloudflareWebhookWorker >> gtDeployActionFor: anAction [
	<gtAction>
	self isDeployed ifTrue: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons play;
		tooltip: 'Deploy webhook Worker';
		priority: 1;
		action: [ :aButton :aTab |
			self deploy.
			aTab viewContentElement phlow update ]
]

{ #category : 'gt - views' }
Gt4CloudflareWebhookWorker >> gtEventsFor: aView [
	<gtView>
	(self isDeployed not or: [ kvNamespaceId isNil ]) ifTrue: [ ^ aView empty ].
	^ aView forward
		title: 'Events';
		priority: 2;
		object: [ self fetchEvents ];
		view: #gtEventsFor:
]

{ #category : 'gt - actions' }
Gt4CloudflareWebhookWorker >> gtRefreshEventsActionFor: anAction [
	<gtAction>
	self isDeployed ifFalse: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons refresh;
		tooltip: 'Refresh events';
		priority: 5;
		action: [ :aButton :aTab |
			aTab viewContentElement phlow update ]
]

{ #category : 'gt - views' }
Gt4CloudflareWebhookWorker >> gtScriptCodeFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Worker script';
		priority: 5;
		text: [ self webhookWorkerScript ]
]

{ #category : 'gt - views' }
Gt4CloudflareWebhookWorker >> gtStatusFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Status';
		priority: 1;
		items: [ {
			'Script name' -> (scriptName ifNil: [ '' ]).
			'Deployed?' -> self isDeployed.
			'Public URL' -> (publicUrl ifNil: [ '(not deployed)' ]).
			'KV namespace' -> (kvNamespaceId ifNil: [ '(not created)' ]).
			'Secret set?' -> secret notNil.
			'Account ID' -> (client ifNil: [ '' ] ifNotNil: [ client accountId ifNil: [ '' ] ]) } ];
		column: 'Property' text: #key weight: 1;
		column: 'Value' text: #value weight: 3
]

{ #category : 'gt - actions' }
Gt4CloudflareWebhookWorker >> gtTeardownActionFor: anAction [
	<gtAction>
	self isDeployed ifFalse: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons cancel;
		tooltip: 'Teardown webhook Worker';
		priority: 2;
		action: [ :aButton :aTab |
			self teardown.
			aTab viewContentElement phlow update ]
]

{ #category : 'testing' }
Gt4CloudflareWebhookWorker >> isDeployed [
	^ publicUrl notNil
]

{ #category : 'accessing' }
Gt4CloudflareWebhookWorker >> kvNamespaceId [
	^ kvNamespaceId
]

{ #category : 'accessing' }
Gt4CloudflareWebhookWorker >> kvNamespaceId: aString [
	kvNamespaceId := aString
]

{ #category : 'printing' }
Gt4CloudflareWebhookWorker >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: (scriptName ifNil: [ '?' ]).
	publicUrl ifNotNil: [
		aStream nextPutAll: ' · '; nextPutAll: publicUrl ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
Gt4CloudflareWebhookWorker >> publicUrl [
	^ publicUrl
]

{ #category : 'accessing' }
Gt4CloudflareWebhookWorker >> publicUrl: aString [
	publicUrl := aString
]

{ #category : 'accessing' }
Gt4CloudflareWebhookWorker >> scriptName [
	^ scriptName
]

{ #category : 'accessing' }
Gt4CloudflareWebhookWorker >> scriptName: aString [
	scriptName := aString
]

{ #category : 'accessing' }
Gt4CloudflareWebhookWorker >> secret [
	^ secret
]

{ #category : 'accessing' }
Gt4CloudflareWebhookWorker >> secret: aString [
	secret := aString
]

{ #category : 'api' }
Gt4CloudflareWebhookWorker >> teardown [
	"Delete the Worker script and its KV namespace."
	client deleteScript: scriptName.
	kvNamespaceId ifNotNil: [
		client deleteKvNamespace: kvNamespaceId ].
	publicUrl := nil
]

{ #category : 'code generation' }
Gt4CloudflareWebhookWorker >> webhookWorkerScript [
	"Generate the JavaScript ES module for a webhook-receiving Cloudflare Worker.
	The Worker:
	  - POST / : receives webhooks, stores in KV with 30-day TTL
	  - GET /events : lists stored events (newest first)
	  - GET /events/{key} : returns a single event
	  - Optional HMAC-SHA256 signature verification when secret is set"
	^ 'export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "POST") {
      return await handleWebhook(request, env);
    }

    if (request.method === "GET" && url.pathname === "/events") {
      return await listEvents(env);
    }

    if (request.method === "GET" && url.pathname.startsWith("/events/")) {
      const key = decodeURIComponent(url.pathname.slice(8));
      return await getEvent(env, key);
    }

    if (request.method === "GET" && url.pathname === "/health") {
      return new Response(JSON.stringify({ status: "ok", timestamp: new Date().toISOString() }), {
        headers: { "content-type": "application/json" }
      });
    }

    return new Response("Not found", { status: 404 });
  }
};

async function handleWebhook(request, env) {
  const body = await request.text();
  const secret = env.WEBHOOK_SECRET || null;

  if (secret) {
    const sigHeader =
      request.headers.get("x-storylane-signature") ||
      request.headers.get("x-hub-signature-256") ||
      request.headers.get("x-webhook-signature") ||
      null;
    if (!sigHeader) {
      return new Response("Missing signature", { status: 401 });
    }
    const valid = await verifySignature(body, sigHeader, secret);
    if (!valid) {
      return new Response("Invalid signature", { status: 401 });
    }
  }

  const headers = {};
  for (const [k, v] of request.headers.entries()) {
    headers[k] = v;
  }

  const event = {
    timestamp: new Date().toISOString(),
    method: request.method,
    url: request.url,
    path: new URL(request.url).pathname,
    headers: headers,
    body: body,
    sourceIp: request.headers.get("cf-connecting-ip") || null,
  };

  const key = "evt:" + event.timestamp + ":" + crypto.randomUUID().slice(0, 8);
  await env.STORE.put(key, JSON.stringify(event), { expirationTtl: 2592000 });

  return new Response(JSON.stringify({ ok: true, key: key }), {
    status: 200,
    headers: { "content-type": "application/json" }
  });
}

async function verifySignature(body, signature, secret) {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw", encoder.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]
  );
  const sig = await crypto.subtle.sign("HMAC", key, encoder.encode(body));
  const expected = btoa(String.fromCharCode(...new Uint8Array(sig)));
  return expected === signature;
}

async function listEvents(env) {
  const list = await env.STORE.list({ prefix: "evt:", limit: 100 });
  const events = [];
  for (const key of list.keys) {
    const val = await env.STORE.get(key.name);
    if (val) {
      events.push({ key: key.name, event: JSON.parse(val) });
    }
  }
  events.sort((a, b) => b.event.timestamp.localeCompare(a.event.timestamp));
  return new Response(JSON.stringify(events), {
    headers: { "content-type": "application/json" }
  });
}

async function getEvent(env, key) {
  const val = await env.STORE.get(key);
  if (!val) {
    return new Response("Not found", { status: 404 });
  }
  return new Response(val, {
    headers: { "content-type": "application/json" }
  });
}'
]
