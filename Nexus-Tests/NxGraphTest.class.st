Class {
	#name : 'NxGraphTest',
	#superclass : 'TestCase',
	#instVars : [
		'graph'
	],
	#category : 'Nexus-Tests',
	#package : 'Nexus-Tests'
}

{ #category : 'running' }
NxGraphTest >> setUp [
    graph := NxGraph new.
    graph addNode: (NxNode new name: 'village'; label: 'Village Square').
    graph addNode: (NxNode new name: 'hut'; label: 'Elders Hut').
    graph addEdgeFrom: 'village' to: 'hut' distance: 1 risk: 0.1.
    "One-way edge: from 'village' to 'cliff' only forward"
    graph addNode: (NxNode new name: 'cliff'; label: 'Cliff Bottom').
    graph addEdgeFrom: 'village' to: 'cliff' distance: 1 risk: 0.0 direction: #forward.
]

{ #category : 'tests' }
NxGraphTest >> testNeighborsBasic [
    self assert: (graph neighborsOf: 'village') asSet equals: #('hut' 'cliff') asSet.
    self assert: (graph neighborsOf: 'hut') asSet equals: #('village') asSet.
]

{ #category : 'tests' }
NxGraphTest >> testNodeLookup [
    self assert: (graph nodeNamed: 'village') name equals: 'village'.
]

{ #category : 'tests' }
NxGraphTest >> testOneWayNeighbor [
    "From cliff, you cannot go back to village because edge is forward only"
    self assert: (graph neighborsOf: 'cliff') isEmpty.
]
