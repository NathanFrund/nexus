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
NxWorldTest >> testWitnessedEvents [
    | events |
    events := world witnessedEventsFor: #heroicAct atNode: 'market' source: elder.
    self assert: events size equals: 1.
    self assert: events anyOne observer equals: thug.
    self assert: events anyOne source equals: elder.

]
