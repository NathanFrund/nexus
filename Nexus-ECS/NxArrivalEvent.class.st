Class {
	#name : 'NxArrivalEvent',
	#superclass : 'Announcement',
	#instVars : [
		'observer',
		'source',
		'location'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

{ #category : 'accessing' }
NxArrivalEvent >> location [

	^ location
]

{ #category : 'accessing' }
NxArrivalEvent >> location: aString [

	location := aString
]

{ #category : 'accessing' }
NxArrivalEvent >> observer [

	^ observer
]

{ #category : 'accessing' }
NxArrivalEvent >> observer: anEntity [

	observer := anEntity
]

{ #category : 'accessing' }
NxArrivalEvent >> source [

	^ source
]

{ #category : 'accessing' }
NxArrivalEvent >> source: anEntity [

	source := anEntity
]
