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
		'agents'
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

{ #category : 'movement' }
NxWorld >> moveAgent: anAgent toNode: targetNodeName [
    | currentLocation edge |
    currentLocation := anAgent location.

    "Find the edge from current location to target"
    edge := (self graph edgesFrom: currentLocation)
                detect: [ :e | (e otherEndOf: currentLocation) = targetNodeName ]
                ifNone: [ nil ].
    edge ifNil: [ ^ false ].

    "Check directionality of the edge"
    (edge direction = #both or: [
        (edge direction = #forward   and: [ edge node1 = currentLocation ]) or:
        [ edge direction = #backward and: [ edge node2 = currentLocation ]]
    ]) ifFalse: [ ^ false ].

    "Move the agent"
    anAgent location: targetNodeName.

    "Random hazard check"
    (edge risk > 0.0 and: [ edge risk > 1.0 atRandom ]) ifTrue: [
        Transcript show: 'Hazard! ', targetNodeName; cr ].
    ^ true
]

{ #category : 'spatial queries' }
NxWorld >> witnessedEventsFor: anEventType atNode: aNodeName source: sourceAgent [

	^ (self agentsAtNode: aNodeName)
		  reject: [ :agent | agent == sourceAgent ]
		  thenCollect: [ :observer |
				  NxWitnessedEvent new
					  eventType: anEventType;
					  observer: observer;
					  source: sourceAgent;
					  location: aNodeName;
					  yourself ]
]
