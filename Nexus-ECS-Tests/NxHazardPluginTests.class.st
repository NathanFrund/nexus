Class {
	#name : 'NxHazardPluginTests',
	#superclass : 'TestCase',
	#category : 'Nexus-ECS-Tests',
	#package : 'Nexus-ECS-Tests'
}

{ #category : 'running' }
NxHazardPluginTests >> setUp [
    super setUp.
    "Ensure a clean hook – no leftover plugins from other tests"
    (NxPluginRegistry default hooksFor: #hazard) initialize.
    "Register the classic risk‑based hazard plugin"
    NxPluginRegistry default registerPluginFor: #hazard do: [ :ctx |
        | edge risk |
        edge := ctx edge ifNil: [ ^ self ].
        risk := edge risk ifNil: 0.0.
        (risk > 0 and: [ Random new next <= risk ]) ifTrue: [
            ctx world pendingEvents add: (NxHazardEvent new
                target: ctx targetNode;
                severity: risk;
                description: 'Travel hazard encountered';
                yourself) ] ].
]

{ #category : 'running' }
NxHazardPluginTests >> tearDown [
    "Clean up to avoid cross‑test pollution"
    (NxPluginRegistry default hooksFor: #hazard) initialize.
    super tearDown.
]

{ #category : 'tests' }
NxHazardPluginTests >> testHazardOccurs [
    | world hero |
    world := NxWorld new.
    world graph: (NxGraph new
        addNode: (NxNode new name: 'A'; yourself);
        addNode: (NxNode new name: 'B'; yourself);
        addEdgeFrom: 'A' to: 'B' distance: 1 risk: 1.0;  "always triggers"
        yourself).
    hero := world spawn: #hero at: 'A'.
    world move: #hero to: 'B'.
    self assert: (world pendingEvents anySatisfy: [ :e | e isKindOf: NxHazardEvent ]).
]
