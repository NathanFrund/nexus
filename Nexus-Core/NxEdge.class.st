"
I am a traversable connection between two nodes in the Nexus spatial graph.

I support three direction modes (#both, #forward, #backward), a distance value,
a risk factor for random hazards, and an optional list of scripted encounters.
I know how to tell whether I connect to a given node and to return the node at my other end.
"
Class {
	#name : 'NxEdge',
	#superclass : 'Object',
	#instVars : [
		'node1',
		'node2',
		'distance',
		'risk',
		'direction',
		'properties'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'instance creation' }
NxEdge class >> fromPropertyDictionary: dict [
    | edge |
    edge := self new
        node1: (dict at: '~from');
        node2: (dict at: '~to');
        distance: (dict at: '~distance' ifAbsent: [ 1 ]);
        risk: (dict at: '~risk' ifAbsent: [ 0.0 ]);
        direction: (dict at: '~direction' ifAbsent: [ #both ]);
        yourself.
    dict keysAndValuesDo: [ :key :value |
        (key asString beginsWith: '~') ifFalse: [
            edge setProperty: key to: value ] ].
    ^ edge
]

{ #category : 'property-graph' }
NxEdge >> allProperties [
    ^ self properties copy
]

{ #category : 'traversing' }
NxEdge >> allowsTraversalFrom: aNodeName [
    ^ (self direction = #both) or: [
        (self direction = #forward   and: [ self node1 = aNodeName ]) or:
        [ self direction = #backward and: [ self node2 = aNodeName ] ] ]
]

{ #category : 'property-graph' }
NxEdge >> asPropertyDictionary [
    | dict |
    dict := self properties copy.
    dict at: '~from' put: node1;
         at: '~to' put: node2;
         at: '~distance' put: (distance ifNil: [ 1 ]);
         at: '~risk' put: (risk ifNil: [ 0.0 ]);
         at: '~direction' put: (direction ifNil: [ #both ]).
    ^ dict
]

{ #category : 'movement' }
NxEdge >> checkHazardTo: targetNodeName [
	"Deprecated. Use hazard strategies instead."
    self risk <= 0.0 ifTrue: [ ^ nil ].
    (Random new next <= self risk) ifTrue: [
        Transcript show: 'Hazard! ', targetNodeName; cr.
        ^ NxHazardEvent new target: targetNodeName; risk: self risk; yourself ].
    ^ nil
]

{ #category : 'testing' }
NxEdge >> connectsNode: aNodeName [
	"Does this edge connect to aNodeName?"

	^ node1 = aNodeName or: [ node2 = aNodeName ]
]

{ #category : 'accessing' }
NxEdge >> direction [

	^ direction ifNil: [ #both ]
]

{ #category : 'accessing' }
NxEdge >> direction: aSymbol [

	(#(both forward backward) includes: aSymbol)
        ifFalse: [ self error: 'direction must be #both, #forward, or #backward' ].
    direction := aSymbol
]

{ #category : 'accessing' }
NxEdge >> distance [

	^ distance
]

{ #category : 'accessing' }
NxEdge >> distance: aNumber [

	distance := aNumber
]

{ #category : 'property-graph' }
NxEdge >> hasProperty: key [
    ^ self properties includesKey: key
]

{ #category : 'accessing' }
NxEdge >> node1 [

	^ node1
]

{ #category : 'accessing' }
NxEdge >> node1: aString [

	node1 := aString
]

{ #category : 'accessing' }
NxEdge >> node2 [

	^ node2
]

{ #category : 'accessing' }
NxEdge >> node2: aString [

	node2 := aString
]

{ #category : 'testing' }
NxEdge >> otherEndOf: aNodeName [
	"Return the node at the other end, assuming undirected.  
 For directed queries, use the traversal methods in NxGraph."

	node1 = aNodeName ifTrue: [ ^ node2 ].
	^ node1
]

{ #category : 'property-graph' }
NxEdge >> properties [
    ^ properties ifNil: [ properties := Dictionary new ]
]

{ #category : 'property-graph' }
NxEdge >> propertyAt: key [
    ^ self propertyAt: key ifAbsent: [ nil ]
]

{ #category : 'property-graph' }
NxEdge >> propertyAt: key ifAbsent: aBlock [
    ^ self properties at: key ifAbsent: aBlock
]

{ #category : 'property-graph' }
NxEdge >> removeProperty: key [
    self properties removeKey: key ifAbsent: []
]

{ #category : 'accessing' }
NxEdge >> risk [

	^ risk ifNil: [ 0.0 ]
]

{ #category : 'accessing' }
NxEdge >> risk: aNumber [

	risk := aNumber
]

{ #category : 'property-graph' }
NxEdge >> setProperty: key to: value [
    (key asString beginsWith: '~') ifTrue: [
        self error: 'Property key must not begin with ~' ].
    self properties at: key put: value
]
