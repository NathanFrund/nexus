Class {
	#name : 'NxMovementContext',
	#superclass : 'Object',
	#instVars : [
		'entity',
		'targetNode',
		'world',
		'movementSystem',
		'edge',
		'data'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

{ #category : 'accessing' }
NxMovementContext >> data: anObject [

	data := anObject
]

{ #category : 'accessing' }
NxMovementContext >> dataAt: key [
    ^ data at: key ifAbsent: [ nil ]
]

{ #category : 'accessing' }
NxMovementContext >> edge [

	^ edge
]

{ #category : 'accessing' }
NxMovementContext >> edge: anEdge [

	edge := anEdge
]

{ #category : 'accessing' }
NxMovementContext >> entity [

	^ entity
]

{ #category : 'accessing' }
NxMovementContext >> entity: anObject [

	entity := anObject
]

{ #category : 'accessing' }
NxMovementContext >> movementSystem [

	^ movementSystem
]

{ #category : 'accessing' }
NxMovementContext >> movementSystem: anObject [

	movementSystem := anObject
]

{ #category : 'initialization' }
NxMovementContext >> setData: key to: value [
    data at: key put: value
]

{ #category : 'accessing' }
NxMovementContext >> targetNode [

	^ targetNode
]

{ #category : 'accessing' }
NxMovementContext >> targetNode: anObject [

	targetNode := anObject
]

{ #category : 'accessing' }
NxMovementContext >> world [

	^ world
]

{ #category : 'accessing' }
NxMovementContext >> world: anObject [

	world := anObject
]
