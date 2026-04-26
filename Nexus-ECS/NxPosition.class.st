Class {
	#name : 'NxPosition',
	#superclass : 'Object',
	#instVars : [
		'nodeName',
		'graph'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

{ #category : 'testing' }
NxPosition >> canReachNodes [
    ^ (graph edgesFrom: nodeName) collect: [ :edge | edge otherEndOf: nodeName ]
]

{ #category : 'accessing' }
NxPosition >> graph [

	^ graph
]

{ #category : 'accessing' }
NxPosition >> graph: aGraph [

	graph := aGraph
]

{ #category : 'accessing' }
NxPosition >> nodeName [

	^ nodeName
]

{ #category : 'accessing' }
NxPosition >> nodeName: aNode [

	nodeName := aNode
]
