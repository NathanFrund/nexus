"
I am the spatial context that binds a Nexus graph to a collection of agents.

I answer queries about which agents are present at a given node,
generate ""witnessed"" events for agents who observe an action,
and handle agent movement with direction‑ and risk‑based hazard checks.
Agents I work with need only respond to #location.
"
Class {
	#name : 'NxWorld',
	#superclass : 'Object',
	#instVars : [
		'agents',
		'entities',
		'graph',
		'objects',
		'objectLocation',
		'pendingEvents',
		'spatialIndex'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'management' }
NxWorld >> addEntity: anObject [
    objects at: anObject id put: anObject.
    self entities at: anObject id put: anObject.   "keep legacy dict in sync"
    self registerObjectLocation: anObject.
]

{ #category : 'accessing' }
NxWorld >> agents [

	^ agents ifNil: [ Dictionary new ]
]

{ #category : 'accessing' }
NxWorld >> agents: aDictionary [

	agents := aDictionary 
]

{ #category : 'spatial queries' }
NxWorld >> agentsAtNode: aNodeName [
    ^ self agents values select: [ :agent | agent location = aNodeName ]
]

{ #category : 'accessing' }
NxWorld >> entities [

	^ entities ifNil: [ entities := Dictionary new ]
]

{ #category : 'accessing' }
NxWorld >> entities: anEntity [

	self entities at: anEntity id put: anEntity
]

{ #category : 'spatial-index' }
NxWorld >> entitiesAtNode: aNodeName [
    ^ self entities values select: [ :e |
        (e hasComponent: NxPosition) and: [
            (e componentOfType: NxPosition) nodeName = aNodeName ] ]
]

{ #category : 'accessing' }
NxWorld >> graph [

	^ graph
]

{ #category : 'accessing' }
NxWorld >> graph: anNxGraph [

	graph := anNxGraph 
]

{ #category : 'initialization' }
NxWorld >> initialize [

	super initialize.
	pendingEvents := OrderedCollection new.
	objects := Dictionary new. "id -> object"
	objectLocation := Dictionary new. "id -> nodeName"
	spatialIndex := Dictionary new "nodeName -> Set of ids"
]

{ #category : 'public' }
NxWorld >> move: entityId to: targetNodeName [
    | entity system |
    entity := self entities at: entityId ifAbsent: [ self error: 'Unknown entity: ', entityId ].
    system := NxMovementSystem new.
    ^ system moveEntity: entity toNode: targetNodeName inWorld: self
]

{ #category : 'movement' }
NxWorld >> moveAgent: anAgent toNode: targetNodeName [
    | currentLocation edge observers hazard events |
    currentLocation := anAgent location.
    edge := (self graph edgesFrom: currentLocation)
                detect: [ :e | (e otherEndOf: currentLocation) = targetNodeName ]
                ifNone: [ nil ].
    edge ifNil: [ ^ false ].
    
    "Check directionality"
    (edge direction = #both or: [
        (edge direction = #forward   and: [ edge node1 = currentLocation ]) or:
        [ edge direction = #backward and: [ edge node2 = currentLocation ]]
    ]) ifFalse: [ ^ false ].
    
    "Capture departure witnesses before moving"
    observers := self witnessedEventsFor: #agentDeparted atNode: currentLocation source: anAgent.
    
    "Check for travel hazard"
    hazard := edge checkHazardTo: targetNodeName.
    
    "Collect events into pendingEvents"
    events := OrderedCollection new.
    events addAll: observers.
    hazard ifNotNil: [ events add: hazard ].
    pendingEvents removeAll; addAll: events.
    
    "Move the agent"
    anAgent location: targetNodeName.
    ^ true
]

{ #category : 'accessing' }
NxWorld >> objects [
	^ objects 
]

{ #category : 'spatial-index' }
NxWorld >> objectsAtNode: aNodeName [
    "Return a collection of actual objects at the given node (copy to avoid mutation)."
    ^ (spatialIndex at: aNodeName ifAbsent: [ ^ #() ]) 
        collect: [ :eachId | objects at: eachId ]
]

{ #category : 'accessing' }
NxWorld >> pendingEvents [
	^ pendingEvents 
]

{ #category : 'spatial-index' }
NxWorld >> registerObjectLocation: anObject [
    "Determine initial location and add to spatial index."
    | location |
    location := self resolveLocationOf: anObject.
    location ifNotNil: [ self updateObjectLocation: anObject from: nil to: location ].
]

{ #category : 'management' }
NxWorld >> removeEntity: anObject [
    self removeObjectFromIndex: anObject.
    objects removeKey: anObject id ifAbsent: [].
    entities removeKey: anObject id ifAbsent: [].
]

{ #category : 'spatial-index' }
NxWorld >> removeObjectFromIndex: anObject [
    "Remove object from spatial index and location map."
    | nodeName |
    nodeName := objectLocation removeKey: anObject id ifAbsent: [ nil ].
    nodeName ifNotNil: [
        (spatialIndex at: nodeName ifAbsent: [ ^ self ]) 
            remove: anObject id ifAbsent: [].
        (spatialIndex at: nodeName) ifEmpty: [ spatialIndex removeKey: nodeName ] ]
]

{ #category : 'spatial-index' }
NxWorld >> resolveLocationOf: anObject [
    "Duck‑typed location: try ECS component first, else simple location accessor."
    (anObject respondsTo: #componentOfType:) ifTrue: [
        | pos |
        pos := anObject componentOfType: (Smalltalk at: #NxPosition ifAbsent: [ nil ]).
        pos ifNotNil: [ ^ pos nodeName ] ].
    (anObject respondsTo: #location) ifTrue: [ ^ anObject location ].
    ^ nil
]

{ #category : 'as yet unclassified' }
NxWorld >> spawn: entityId at: aNodeName [
    | entity |
    entity := NxEntity new id: entityId asSymbol.
    entity addComponent: (NxIdentity new id: entityId; name: entityId asString).
    entity addComponent: (NxPosition new 
        nodeName: aNodeName; 
        graph: self graph).   "critical: inject the graph"
    self addEntity: entity.
    ^ entity
]

{ #category : 'spatial-index' }
NxWorld >> updateObjectLocation: anObject from: oldNodeName to: newNodeName [
    "Move an object between buckets. oldNodeName may be nil."
    oldNodeName ifNotNil: [
        (spatialIndex at: oldNodeName ifAbsent: [ ^ self ]) 
            remove: anObject id ifAbsent: [] ].
    newNodeName ifNotNil: [
        (spatialIndex at: newNodeName ifAbsentPut: [ Set new ]) 
            add: anObject id.
        objectLocation at: anObject id put: newNodeName ].
    (oldNodeName = newNodeName) ifTrue: [ ^ self ].
    oldNodeName ifNotNil: [
        (spatialIndex at: oldNodeName) ifEmpty: [ spatialIndex removeKey: oldNodeName ] ]
]

{ #category : 'spatial queries' }
NxWorld >> witnessedEventsFor: anEventType atNode: aNodeName source: sourceAgent [
    | witnesses |
    witnesses := (self agentsAtNode: aNodeName) reject: [ :agent | agent == sourceAgent ].
    witnesses ifNotEmpty: [
        ^ witnesses collect: [ :observer |
            NxWitnessedEvent new
                eventType: anEventType;
                observer: observer;
                source: sourceAgent;
                location: aNodeName;
                yourself ] ].
    "No witnesses → still emit an event with nil observer"
    ^ Array with: (NxWitnessedEvent new
        eventType: anEventType;
        observer: nil;
        source: sourceAgent;
        location: aNodeName;
        yourself)
]
