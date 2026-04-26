"
I am a minimal agent implementation for testing and simple scenarios.

I have a name and a location, and I can be placed in an NxWorld.
"
Class {
	#name : 'NxSimpleAgent',
	#superclass : 'Object',
	#instVars : [
		'id',
		'name',
		'location'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'accessing' }
NxSimpleAgent >> id [

	^ id
]

{ #category : 'accessing' }
NxSimpleAgent >> id: aSymbol [

	id := aSymbol
]

{ #category : 'accessing' }
NxSimpleAgent >> location [

	^ location
]

{ #category : 'accessing' }
NxSimpleAgent >> location: aString [

	location := aString
]

{ #category : 'accessing' }
NxSimpleAgent >> name [

	^ name
]

{ #category : 'accessing' }
NxSimpleAgent >> name: aString [

	name := aString
]
