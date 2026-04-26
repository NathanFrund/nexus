Class {
	#name : 'NxEntityMoved',
	#superclass : 'Announcement',
	#instVars : [
		'entity',
		'targetNode'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

{ #category : 'accessing' }
NxEntityMoved >> entity [

	^ entity
]

{ #category : 'accessing' }
NxEntityMoved >> entity: anEntity [

	entity := anEntity
]

{ #category : 'accessing' }
NxEntityMoved >> targetNode [

	^ targetNode
]

{ #category : 'accessing' }
NxEntityMoved >> targetNode: aString [

	targetNode := aString
]
