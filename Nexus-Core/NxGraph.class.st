"
I am a collection of NxNodes and NxEdges that together form a spatial graph.

I can be loaded from JSON files via my class‑side constructors.
I answer queries about nodes (by name, all names), edges from a given node,
and the neighbours reachable from a node (respecting edge direction).
"
Class {
	#name : 'NxGraph',
	#superclass : 'Object',
	#instVars : [
		'nodes',
		'edges'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'instance creation' }
NxGraph class >> fromJSON: aDictionary [
    | graph |
    graph := self new.   "self = NxGraph class, so 'graph' is now a fresh NxGraph instance"
    
    "Nodes"
    (aDictionary at: 'nodes') keysAndValuesDo: [ :nodeId :props |
        graph addNode: (NxNode new
            name: nodeId asString;
            label: (props at: 'label' ifAbsent: [ nodeId asString ]);
            terrain: (props at: 'terrain' ifAbsent: [ #unknown ]) asSymbol) ].

    "Edges (with optional direction)"
    (aDictionary at: 'edges') do: [ :edgeSpec |
        | from to attrs |
        from := edgeSpec first asString.
        to := edgeSpec second asString.
        attrs := edgeSpec third.
        graph addEdgeFrom: from to: to
            distance: (attrs at: 'distance' ifAbsent: [ 1 ])
            risk: (attrs at: 'risk' ifAbsent: [ 0.0 ])
            direction: (attrs at: 'direction' ifAbsent: [ 'both' ]) asSymbol ].
    ^ graph
]

{ #category : 'instance creation' }
NxGraph class >> fromJSONFile: aFileReference [
    | jsonString jsonDict |
    jsonString := aFileReference contents.
    jsonDict := STONJSON fromString: jsonString.
    ^ self fromJSON: jsonDict 
]

{ #category : 'as yet unclassified' }
NxGraph class >> loadWorldFromJSONFile: aFileReference [
    "Load a hypergraph world from a JSON file containing multiple named graphs.
     Flattens all nodes and edges into a single NxGraph.
     Edges are expected to be maps with 'from' and 'to' keys (as in the Clojure version)."

    | config graph |
    config := STONJSON fromString: aFileReference contents.
    graph := self new.

    (config at: 'graphs') keysAndValuesDo: [ :regionName :graphDict |
        "Nodes"
        (graphDict at: 'nodes') keysAndValuesDo: [ :nodeId :props |
            (graph nodeNames includes: nodeId asSymbol) ifFalse: [
                graph addNode: (NxNode new
                    name: nodeId asString;
                    label: (props at: 'label' ifAbsent: [ nodeId asString ]);
                    terrain: ((props at: 'terrain' ifAbsent: [ 'unknown' ]) asSymbol);
                    yourself) ] ].

        "Edges (now maps with 'from', 'to', etc.)"
        (graphDict at: 'edges') do: [ :edgeDict |
            graph
                addEdgeFrom: (edgeDict at: 'from')
                to: (edgeDict at: 'to')
                distance: (edgeDict at: 'distance' ifAbsent: [ 1 ])
                risk: (edgeDict at: 'risk' ifAbsent: [ 0.0 ])
                direction: ((edgeDict at: 'direction' ifAbsent: [ 'both' ]) asSymbol) ] ].

    ^ graph
]

{ #category : 'as yet unclassified' }
NxGraph class >> loadWorldFromJSONString: aString [
    | config graph |
    config := STONJSON fromString: aString.
    graph := self new.
    (config at: 'graphs') keysAndValuesDo: [ :regionName :graphDict |
        (graphDict at: 'nodes') keysAndValuesDo: [ :nodeId :props |
            (graph nodeNames includes: nodeId asSymbol) ifFalse: [
                graph addNode: (NxNode new
                    name: nodeId asString;
                    label: (props at: 'label' ifAbsent: [ nodeId asString ]);
                    terrain: ((props at: 'terrain' ifAbsent: [ 'unknown' ]) asSymbol);
                    yourself) ] ].
        (graphDict at: 'edges') do: [ :edgeDict |
            graph addEdgeFrom: (edgeDict at: 'from')
                  to: (edgeDict at: 'to')
                  distance: (edgeDict at: 'distance' ifAbsent: [ 1 ])
                  risk: (edgeDict at: 'risk' ifAbsent: [ 0.0 ])
                  direction: ((edgeDict at: 'direction' ifAbsent: [ 'both' ]) asSymbol) ] ].
    ^ graph
]

{ #category : 'adding' }
NxGraph >> addEdgeFrom: fromName to: toName
               distance: dist risk: riskValue [
    self addEdgeFrom: fromName to: toName distance: dist risk: riskValue direction: #both
]

{ #category : 'adding' }
NxGraph >> addEdgeFrom: fromName to: toName
               distance: dist risk: riskValue direction: dirSymbol [
    | edge |
    edge := NxEdge new
        node1: fromName;
        node2: toName;
        distance: dist;
        risk: riskValue;
        direction: dirSymbol;
        yourself.
    edges add: edge.
    ^ edge
]

{ #category : 'adding' }
NxGraph >> addNode: anNxNode [
    nodes at: anNxNode name put: anNxNode
]

{ #category : 'accessing' }
NxGraph >> edgesFrom: aNodeName [
    ^ edges select: [ :edge | edge connectsNode: aNodeName ]
]

{ #category : 'initialization' }
NxGraph >> initialize [
    super initialize.
    nodes := Dictionary new.
    edges := OrderedCollection new.
]

{ #category : 'graph queries' }
NxGraph >> neighborsOf: aNodeName [
    ^ (self edgesFrom: aNodeName) flatCollect: [ :edge |
        | other |
        other := edge otherEndOf: aNodeName.
        "Is this edge traversable from aNodeName?"
        (edge direction = #both or: [
            (edge direction = #forward   and: [ edge node1 = aNodeName ]) or:
            [ edge direction = #backward and: [ edge node2 = aNodeName ]]
        ])
            ifTrue: [ { other } ]
            ifFalse: [ #() ] ]
]

{ #category : 'accessing' }
NxGraph >> nodeNamed: aString [
    ^ nodes at: aString
]

{ #category : 'accessing' }
NxGraph >> nodeNames [
    ^ nodes keys
]
