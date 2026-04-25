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
		'terrain'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

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
NxNode >> terrain [

	^ terrain
]

{ #category : 'accessing' }
NxNode >> terrain: anObject [

	terrain := anObject
]
