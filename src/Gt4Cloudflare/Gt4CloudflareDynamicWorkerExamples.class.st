Class {
	#name : 'Gt4CloudflareDynamicWorkerExamples',
	#superclass : 'Object',
	#category : 'Gt4Cloudflare',
	#package : 'Gt4Cloudflare'
}

{ #category : 'examples' }
Gt4CloudflareDynamicWorkerExamples >> client [
	<gtExample>
	| aClient |
	aClient := Gt4CloudflareDynamicWorkerClient new
		hostUrl: 'https://dynamic-worker-host.your-subdomain.workers.dev';
		authToken: 'test-token'.
	self assert: aClient history isEmpty.
	^ aClient
]

{ #category : 'examples' }
Gt4CloudflareDynamicWorkerExamples >> pythonFilesystemExplorationCode [
	<gtExample>
	^ 'from workers import Response
import json
import os

async def on_fetch(request, env):
    result = {"files": [], "dirs": [], "packages": []}

    # Walk the entire virtual filesystem
    for root, dirs, files in os.walk("/"):
        for d in dirs:
            path = os.path.join(root, d)
            result["dirs"].append(path)
        for f in files:
            path = os.path.join(root, f)
            try:
                size = os.path.getsize(path)
            except:
                size = -1
            result["files"].append({"path": path, "size": size})

    # Try importing a package and see what it adds
    try:
        import micropip
        await micropip.install("requests")
        import requests
        result["packages"].append({"name": "requests", "version": requests.__version__, "file": requests.__file__})

        # Re-walk to find new files after install
        new_files = []
        for root, dirs, files in os.walk("/"):
            for f in files:
                path = os.path.join(root, f)
                existing = [e["path"] for e in result["files"]]
                if path not in existing:
                    try:
                        size = os.path.getsize(path)
                    except:
                        size = -1
                    new_files.append({"path": path, "size": size})
        result["new_files_after_install"] = new_files
    except Exception as e:
        result["package_error"] = str(e)

    # Log everything for observability capture
    print("FILESYSTEM_SCAN_COMPLETE")
    print(f"Total dirs: {len(result[''dirs''])}")
    print(f"Total files: {len(result[''files''])}")
    if "new_files_after_install" in result:
        print(f"New files after package install: {len(result[''new_files_after_install''])}")

    return Response(json.dumps(result, indent=2), headers={"Content-Type": "application/json"})'
]

{ #category : 'examples' }
Gt4CloudflareDynamicWorkerExamples >> pythonHelloWorldCode [
	<gtExample>
	^ 'from workers import Response

async def on_fetch(request, env):
    return Response("Hello from a Python Dynamic Worker!")'
]

{ #category : 'examples' }
Gt4CloudflareDynamicWorkerExamples >> resultFromFilesystemScan [
	<gtExample>
	"Simulated result from a Python filesystem scan Dynamic Worker"
	| sampleData |
	sampleData := Dictionary new.
	sampleData at: 'success' put: true.
	sampleData at: 'status' put: 200.
	sampleData at: 'language' put: 'python'.
	sampleData at: 'body' put: '{
  "files": [
    {"path": "/lib/python3.12/os.py", "size": 38834},
    {"path": "/lib/python3.12/json/__init__.py", "size": 13952},
    {"path": "/lib/python3.12/site-packages/requests/__init__.py", "size": 4845}
  ],
  "dirs": ["/lib", "/lib/python3.12", "/lib/python3.12/site-packages"],
  "packages": [{"name": "requests", "version": "2.31.0", "file": "/lib/python3.12/site-packages/requests/__init__.py"}],
  "new_files_after_install": [
    {"path": "/lib/python3.12/site-packages/requests/__init__.py", "size": 4845},
    {"path": "/lib/python3.12/site-packages/requests/api.py", "size": 3025},
    {"path": "/lib/python3.12/site-packages/requests/sessions.py", "size": 29853}
  ]
}'.
	sampleData at: 'logs' put: {
		(Dictionary newFromPairs: { 'level'. 'log'. 'message'. 'FILESYSTEM_SCAN_COMPLETE' }).
		(Dictionary newFromPairs: { 'level'. 'log'. 'message'. 'Total dirs: 3' }).
		(Dictionary newFromPairs: { 'level'. 'log'. 'message'. 'Total files: 3' }).
		(Dictionary newFromPairs: { 'level'. 'log'. 'message'. 'New files after package install: 3' }).
	}.
	^ Gt4CloudflareDynamicWorkerResult fromDictionary: sampleData
]
