Class {
	#name : 'NxMovementSystem',
	#superclass : 'Object',
	#instVars : [
		'witnessSystem',
		'nodeIndex',
		'lastMoveTime',
		'announcer'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

{ #category : 'adding' }
NxMovementSystem >> addToIndex: anEntity atNode: aNodeName [
    (nodeIndex at: aNodeName ifAbsentPut: [ OrderedCollection new ]) add: anEntity
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> entitiesAtNode: aNodeName [
    ^ nodeIndex at: aNodeName ifAbsent: [ OrderedCollection new ]
]

{ #category : 'initialization' }
NxMovementSystem >> initialize [

	super initialize.
	witnessSystem := NxWitnessSystem new.
	nodeIndex := Dictionary new.
	announcer := Announcer new
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> moveEntity: anEntity toNode: targetNodeName inWorld: aWorld [

	| pos current edge hazard |
	pos := anEntity componentOfType: NxPosition.
	pos ifNil: [ ^ false ].
	current := pos nodeName.
	edge := (aWorld graph edgesFrom: current)
		        detect: [ :e | (e otherEndOf: current) = targetNodeName ]
		        ifNone: [ nil ].
	edge ifNil: [ ^ false ].
	(edge allowsTraversalFrom: current) ifFalse: [ ^ false ].

	"Update index"
	self removeFromIndex: anEntity atNode: current.

	"Departure witnesses"
	witnessSystem
		departEntity: anEntity
		fromNode: current
		inWorld: aWorld.

	"Hazard check"
	hazard := edge checkHazardTo: targetNodeName.
	hazard ifNotNil: [ aWorld pendingEvents add: hazard ].

	"Move entity"
	pos nodeName: targetNodeName.
	self addToIndex: anEntity atNode: targetNodeName.
	lastMoveTime := DateAndTime now.
	
	witnessSystem arriveEntity: anEntity atNode: targetNodeName inWorld: aWorld.

	announcer announce: (NxEntityMoved new
			 entity: anEntity;
			 targetNode: targetNodeName;
			 yourself).
	^ true
]

{ #category : 'removing' }
NxMovementSystem >> removeFromIndex: anEntity atNode: aNodeName [
    (nodeIndex at: aNodeName ifAbsent: [ ^ self ]) remove: anEntity ifAbsent: []
]

{ #category : 'enumerating' }
NxMovementSystem >> whenEntityMovedDo: aBlock [
    announcer when: NxEntityMoved do: aBlock for: self

]

{ #category : 'accessing' }
NxMovementSystem >> witnessSystem [
	^ witnessSystem 
]
