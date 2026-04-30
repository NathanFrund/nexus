"
I am a node in the Nexus spatial graph. 

I hold a name, a human‑readable label, and a terrain symbol.
Nodes are the places that agents occupy, events happen at, and edges connect.
"
Class {
	#name : 'NxNode',
	#superclass : 'Object',
	#instVars : [
		'name',
		'label',
		'properties'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'instance creation' }
NxNode class >> fromPropertyDictionary: dict [
    | node |
    node := self new
        name: (dict at: '~id');
        label: (dict at: '~label' ifAbsent: [ dict at: '~id' ]);
        yourself.
    dict keysAndValuesDo: [ :key :value |
        (key asString beginsWith: '~') ifFalse: [
            node setProperty: key to: value ] ].
    ^ node
]

{ #category : 'property-graph' }
NxNode >> allProperties [
    ^ self properties copy

]

{ #category : 'converting' }
NxNode >> asPropertyDictionary [
    | dict |
    dict := self properties copy.
    dict at: '~id' put: name;
         at: '~label' put: (label ifNil: [ name ]).
    ^ dict
]

{ #category : 'property-graph' }
NxNode >> hasProperty: key [
    ^ self properties includesKey: key
]

{ #category : 'accessing' }
NxNode >> label [

	^ label
]

{ #category : 'accessing' }
NxNode >> label: aString [

	label := aString
]

{ #category : 'accessing' }
NxNode >> name [

	^ name
]

{ #category : 'accessing' }
NxNode >> name: aString [

	name := aString
]

{ #category : 'property-graph' }
NxNode >> properties [
    ^ properties ifNil: [ properties := Dictionary new ]
]

{ #category : 'property-graph' }
NxNode >> propertyAt: key [
    ^ self propertyAt: key ifAbsent: [ nil ]
]

{ #category : 'property-graph' }
NxNode >> propertyAt: key ifAbsent: aBlock [
    ^ self properties at: key ifAbsent: aBlock
]

{ #category : 'property-graph' }
NxNode >> removeProperty: key [
    self properties removeKey: key ifAbsent: []
]

{ #category : 'property-graph' }
NxNode >> setProperty: key to: value [
    (key asString beginsWith: '~') ifTrue: [
        self error: 'Property key must not begin with ~' ].
    self properties at: key put: value
]
