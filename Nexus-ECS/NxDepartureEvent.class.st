Class {
	#name : 'NxDepartureEvent',
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
NxDepartureEvent >> location [

	^ location
]

{ #category : 'accessing' }
NxDepartureEvent >> location: aString [

	location := aString
]

{ #category : 'accessing' }
NxDepartureEvent >> observer [

	^ observer
]

{ #category : 'accessing' }
NxDepartureEvent >> observer: anEntity [

	observer := anEntity
]

{ #category : 'accessing' }
NxDepartureEvent >> source [

	^ source
]

{ #category : 'accessing' }
NxDepartureEvent >> source: anEntity [

	source := anEntity
]
