Class {
	#name : 'NxMovementSystem',
	#superclass : 'Object',
	#instVars : [
		'witnessSystem',
		'nodeIndex',
		'lastMoveTime',
		'announcer',
		'steps'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

{ #category : 'adding' }
NxMovementSystem >> addToIndex: anEntity atNode: aNodeName [
    (nodeIndex at: aNodeName ifAbsentPut: [ OrderedCollection new ]) add: anEntity
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> buildContextFor: anEntity toNode: targetNodeName inWorld: aWorld [
    ^ NxMovementContext new
        entity: anEntity;
        targetNode: targetNodeName;
        world: aWorld;
        movementSystem: self;
        yourself
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> entitiesAtNode: aNodeName [
    ^ nodeIndex at: aNodeName ifAbsent: [ OrderedCollection new ]
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> executePipelineOn: aContext [
    steps do: [ :selector |
        (self perform: selector with: aContext) ifFalse: [ ^ false ] ].
    ^ true
]

{ #category : 'initialization' }
NxMovementSystem >> initialize [

	super initialize.
	witnessSystem := NxWitnessSystem new.
	nodeIndex := Dictionary new.
	announcer := Announcer new.
	steps := #( 
        #stepValidate: 
        #stepRemoveFromIndex: 
        #stepDeparture: 
        #stepHazard: 
        #stepSpatialMove: 
        #stepArrival: 
        #stepAnnounce: 
    )
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> moveEntity: anEntity toNode: targetNodeName inWorld: aWorld [
    | context |
    context := self buildContextFor: anEntity toNode: targetNodeName inWorld: aWorld.
    ^ self executePipelineOn: context
]

{ #category : 'removing' }
NxMovementSystem >> removeFromIndex: anEntity atNode: aNodeName [
    (nodeIndex at: aNodeName ifAbsent: [ ^ self ]) remove: anEntity ifAbsent: []
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> stepAnnounce: aContext [
    announcer announce: (NxEntityMoved new
        entity: aContext entity;
        targetNode: aContext targetNode;
        yourself).
    ^ true
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> stepArrival: aContext [
    witnessSystem arriveEntity: aContext entity atNode: aContext targetNode inWorld: aContext world.
    ^ true
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> stepDeparture: aContext [
    | current |
    current := (aContext entity componentOfType: NxPosition) nodeName.
    witnessSystem departEntity: aContext entity fromNode: current inWorld: aContext world.
    ^ true
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> stepHazard: aContext [
    | hazard |
    hazard := aContext edge checkHazardTo: aContext targetNode.
    hazard ifNotNil: [ aContext world pendingEvents add: hazard ].
    ^ true
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> stepRemoveFromIndex: aContext [
    | current |
    current := (aContext entity componentOfType: NxPosition) nodeName.
    self removeFromIndex: aContext entity atNode: current.
    ^ true
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> stepSpatialMove: aContext [
    | pos |
    pos := aContext entity componentOfType: NxPosition.
    pos nodeName: aContext targetNode.
    self addToIndex: aContext entity atNode: aContext targetNode.
    lastMoveTime := DateAndTime now.
    ^ true
]

{ #category : 'as yet unclassified' }
NxMovementSystem >> stepValidate: aContext [
    | pos current edge |
    pos := aContext entity componentOfType: NxPosition.
    pos ifNil: [ ^ false ].
    current := pos nodeName.
    edge := (aContext world graph edgesFrom: current)
            detect: [ :e | (e otherEndOf: current) = aContext targetNode ]
            ifNone: [ nil ].
    edge ifNil: [ ^ false ].
    (edge allowsTraversalFrom: current) ifFalse: [ ^ false ].
    aContext edge: edge.
    ^ true
]

{ #category : 'enumerating' }
NxMovementSystem >> whenEntityMovedDo: aBlock [
    announcer when: NxEntityMoved do: aBlock for: self

]

{ #category : 'accessing' }
NxMovementSystem >> witnessSystem [
	^ witnessSystem 
]
