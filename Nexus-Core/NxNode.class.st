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
		'terrain',
		'properties'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'as yet unclassified' }
NxNode >> allProperties [
    ^ self properties copy

]

{ #category : 'testing' }
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

{ #category : 'accessing' }
NxNode >> properties [
    ^ properties ifNil: [ properties := Dictionary new ]
]

{ #category : 'accessing' }
NxNode >> propertyAt: key [
    ^ self propertyAt: key ifAbsent: [ nil ]
]

{ #category : 'accessing' }
NxNode >> propertyAt: key ifAbsent: aBlock [
    ^ self properties at: key ifAbsent: aBlock
]

{ #category : 'removing' }
NxNode >> removeProperty: key [
    self properties removeKey: key ifAbsent: []
]

{ #category : 'initialization' }
NxNode >> setProperty: key to: value [
    self properties at: key put: value
]

{ #category : 'accessing' }
NxNode >> terrain [

	^ terrain
]

{ #category : 'accessing' }
NxNode >> terrain: anObject [

	terrain := anObject
]
