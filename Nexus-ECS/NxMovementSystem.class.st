Class {
	#name : 'NxMovementSystem',
	#superclass : 'Object',
	#instVars : [
		'witnessSystem',
		'lastMoveTime',
		'announcer',
		'steps'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

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
NxMovementSystem >> executePipelineOn: aContext [
    steps do: [ :selector |
        (self perform: selector with: aContext) ifFalse: [ ^ false ] ].
    ^ true
]

{ #category : 'initialization' }
NxMovementSystem >> initialize [

	super initialize.
	witnessSystem := NxWitnessSystem new.
	announcer := Announcer new.
	steps := #( 
        #stepValidate: 
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
NxMovementSystem >> stepSpatialMove: aContext [
    | pos oldNode newNode |
    pos := aContext entity componentOfType: NxPosition.
    oldNode := pos nodeName.
    newNode := aContext targetNode.
    "Update the world's authoritative spatial index"
    aContext world updateObjectLocation: aContext entity from: oldNode to: newNode.
    "Update the component's node name"
    pos nodeName: newNode.
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
