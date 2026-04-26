Class {
	#name : 'NxComponentAdded',
	#superclass : 'Announcement',
	#instVars : [
		'component',
		'entity'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

{ #category : 'accessing' }
NxComponentAdded >> component [

	^ component
]

{ #category : 'accessing' }
NxComponentAdded >> component: anObject [

	component := anObject
]

{ #category : 'accessing' }
NxComponentAdded >> entity [

	^ entity
]

{ #category : 'accessing' }
NxComponentAdded >> entity: anEntity [

	entity := anEntity
]
