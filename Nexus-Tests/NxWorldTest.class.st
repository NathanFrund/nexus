Class {
	#name : 'NxWorldTest',
	#superclass : 'TestCase',
	#instVars : [
		'world',
		'elder',
		'thug'
	],
	#category : 'Nexus-Tests',
	#package : 'Nexus-Tests'
}

{ #category : 'running' }
NxWorldTest >> setUp [
    | graph |
    graph := NxGraph new.
    graph addNode: (NxNode new name: 'market'; label: 'Market'; terrain: #open).
    graph addNode: (NxNode new name: 'tavern'; label: 'Tavern'; terrain: #building).
    graph addEdgeFrom: 'market' to: 'tavern' distance: 1 risk: 0.0.

    elder := NxSimpleAgent new name: 'Elder'; location: 'tavern'; yourself.
    thug  := NxSimpleAgent new name: 'Thug';  location: 'market'; yourself.

    world := NxWorld new
        graph: graph;
        agents: (Dictionary with: 'elder'->elder with: 'thug'->thug);
        yourself.
]

{ #category : 'tests' }
NxWorldTest >> testAgentsAtNode [
    self assert: (world agentsAtNode: 'tavern') size equals: 1.
    self assert: (world agentsAtNode: 'market') size equals: 1.
]

{ #category : 'tests' }
NxWorldTest >> testMoveBetweenGraphs [
    | jsonString graph explorer villager testWorld firstEvents secondEvents |

    jsonString := '{
        "graphs": {
            "village": {
                "nodes": {
                    "village-square": {"label": "Village Square"}
                },
                "edges": [
                    {"from": "village-square", "to": "dungeon-entrance", "distance": 1, "risk": 0.0}
                ]
            },
            "dungeon": {
                "nodes": {
                    "dungeon-entrance": {"label": "Dungeon Entrance"},
                    "dungeon-hall": {"label": "Dungeon Hall"}
                },
                "edges": [
                    {"from": "dungeon-entrance", "to": "dungeon-hall", "distance": 1, "risk": 0.0}
                ]
            }
        }
    }'.

    graph := NxGraph loadWorldFromJSONString: jsonString.

    explorer := NxSimpleAgent new id: #explorer; name: 'Explorer'; location: 'village-square'; yourself.
    villager := NxSimpleAgent new id: #villager; name: 'Villager'; location: 'village-square'; yourself.

    testWorld := NxWorld new graph: graph; agents: (Dictionary new
        at: 'explorer' put: explorer;
        at: 'villager' put: villager; yourself).

    "--- First move: explorer leaves village-square ---"
    self assert: (testWorld moveAgent: explorer toNode: 'dungeon-entrance').
    self assert: explorer location equals: 'dungeon-entrance'.
    self assert: villager location equals: 'village-square'.

    "Capture events immediately after the first move"
    firstEvents := testWorld pendingEvents select: [:ev | ev isKindOf: NxWitnessedEvent].
    self assert: firstEvents size equals: 1.
    self assert: firstEvents anyOne observer id equals: #villager.
    self assert: firstEvents anyOne source id equals: #explorer.

    "--- Second move: explorer continues alone in dungeon ---"
    self assert: (testWorld moveAgent: explorer toNode: 'dungeon-hall').
    self assert: explorer location equals: 'dungeon-hall'.

    "Verify that the second move produced a lonely-agent event (observer nil)"
    secondEvents := testWorld pendingEvents select: [:ev | ev isKindOf: NxWitnessedEvent].
    self assert: secondEvents size equals: 1.
    self assert: secondEvents anyOne observer isNil.
    self assert: secondEvents anyOne source id equals: #explorer.
]

{ #category : 'tests' }
NxWorldTest >> testWitnessedEvents [
    | events |
    events := world witnessedEventsFor: #heroicAct atNode: 'market' source: elder.
    self assert: events size equals: 1.
    self assert: events anyOne observer equals: thug.
    self assert: events anyOne source equals: elder.

]
