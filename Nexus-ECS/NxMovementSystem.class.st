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

{ #category : 'pipeline' }
NxMovementSystem >> buildContextFor: anEntity toNode: targetNodeName inWorld: aWorld [
    ^ NxMovementContext new
        entity: anEntity;
        targetNode: targetNodeName;
        world: aWorld;
        movementSystem: self;
        hazardStrategy: NxDefaultRiskStrategy new;
        yourself
]

{ #category : 'pipeline' }
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

{ #category : 'pipeline' }
NxMovementSystem >> moveEntity: anEntity toNode: targetNodeName inWorld: aWorld [
    | context |
    context := self buildContextFor: anEntity toNode: targetNodeName inWorld: aWorld.
    ^ self executePipelineOn: context
]

{ #category : 'steps' }
NxMovementSystem >> stepAnnounce: aContext [
    announcer announce: (NxEntityMoved new
        entity: aContext entity;
        targetNode: aContext targetNode;
        yourself).
    (aContext registry hooksFor: #announce) runWith: aContext.
    ^ true
]

{ #category : 'steps' }
NxMovementSystem >> stepArrival: aContext [
    witnessSystem arriveEntity: aContext entity atNode: aContext targetNode inWorld: aContext world.
    (aContext registry hooksFor: #arrival) runWith: aContext.
    ^ true
]

{ #category : 'steps' }
NxMovementSystem >> stepDeparture: aContext [
    | current |
    current := (aContext entity componentOfType: NxPosition) nodeName.
    (aContext registry hooksFor: #departure) runWith: aContext.
    witnessSystem departEntity: aContext entity fromNode: current inWorld: aContext world.
    ^ true
]

{ #category : 'steps' }
NxMovementSystem >> stepHazard: aContext [
    (aContext registry hooksFor: #hazard) runWith: aContext.
    ^ true
]

{ #category : 'steps' }
NxMovementSystem >> stepSpatialMove: aContext [
    | pos oldNode newNode |
    pos := aContext entity componentOfType: NxPosition.
    oldNode := pos nodeName.
    newNode := aContext targetNode.
    aContext world updateObjectLocation: aContext entity from: oldNode to: newNode.
    pos nodeName: newNode.
    lastMoveTime := DateAndTime now.
    (aContext registry hooksFor: #spatialMove) runWith: aContext.
    ^ true
]

{ #category : 'steps' }
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
    
    "Allow hooks to veto the move"
    aContext moveAllowed: true.   "reset (fresh context, but harmless)"
    (aContext registry hooksFor: #validate) runWith: aContext.
    ^ aContext moveAllowed
]

{ #category : 'enumerating' }
NxMovementSystem >> whenEntityMovedDo: aBlock [
    announcer when: NxEntityMoved do: aBlock for: self

]

{ #category : 'accessing' }
NxMovementSystem >> witnessSystem [
	^ witnessSystem 
]
