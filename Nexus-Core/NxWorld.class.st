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
		'graph',
		'agents',
		'pendingEvents'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

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
NxWorld >> pendingEvents [
	^ pendingEvents 
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
