Class {
	#name : 'NxIdentity',
	#superclass : 'Object',
	#instVars : [
		'id',
		'name'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

{ #category : 'accessing' }
NxIdentity >> id [

	^ id
]

{ #category : 'accessing' }
NxIdentity >> id: anObject [

	id := anObject
]

{ #category : 'accessing' }
NxIdentity >> name [

	^ name
]

{ #category : 'accessing' }
NxIdentity >> name: aString [

	name := aString
]
