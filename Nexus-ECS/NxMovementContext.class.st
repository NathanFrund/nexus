"
I am a transient data holder (parameter object) that carries state through the movement
pipeline of `NxMovementSystem`.

During a movement, I hold:
- The entity that is moving
- The target node name
- The world in which the movement occurs
- A back‑reference to the movement system (for access to its services)
- The edge being traversed (discovered during validation)
- An optional `data` dictionary for ad‑hoc information (e.g., custom step parameters)

I am created at the start of `moveEntity:toNode:inWorld:` and passed to each pipeline
step. Steps can read and write to me, ensuring that all relevant information is
available without polluting the movement system with temporary instance variables.

I also provide convenient accessors for the common values.

Example usage in a custom step:

    stepLog: aContext
        | msg |
        msg := 'Moving ', aContext entity id, ' from ',
               (aContext entity componentOfType: NxPosition) nodeName,
               ' to ', aContext targetNode.
        Transcript show: msg; cr.
        ^ true
"
Class {
	#name : 'NxMovementContext',
	#superclass : 'Object',
	#instVars : [
		'entity',
		'targetNode',
		'world',
		'movementSystem',
		'edge',
		'hazardStrategy',
		'data'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

{ #category : 'accessing' }
NxMovementContext >> data: anObject [

	data := anObject
]

{ #category : 'data dictionary' }
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
NxMovementContext >> hazardStrategy [
    "Return the hazard strategy, defaulting to NxSimpleRiskStrategy if not set."
    ^ hazardStrategy ifNil: [ hazardStrategy := NxSimpleRiskStrategy new ]
]

{ #category : 'accessing' }
NxMovementContext >> hazardStrategy: aStrategy [
    hazardStrategy := aStrategy
]

{ #category : 'accessing' }
NxMovementContext >> movementSystem [
    ^ movementSystem

]

{ #category : 'accessing' }
NxMovementContext >> movementSystem: anObject [
    movementSystem := anObject
]

{ #category : 'data dictionary' }
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
