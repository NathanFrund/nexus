"
I am a simple event record describing that an agent witnessed something at a location.

I hold the type of event, the observer, the source (if any), and the node where it happened.
"
Class {
	#name : 'NxWitnessedEvent',
	#superclass : 'Object',
	#instVars : [
		'eventType',
		'observer',
		'source',
		'location'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'accessing' }
NxWitnessedEvent >> eventType [

	^ eventType
]

{ #category : 'accessing' }
NxWitnessedEvent >> eventType: aSymbol [

	eventType := aSymbol
]

{ #category : 'accessing' }
NxWitnessedEvent >> location [

	^ location
]

{ #category : 'accessing' }
NxWitnessedEvent >> location: aString [

	location := aString
]

{ #category : 'accessing' }
NxWitnessedEvent >> observer [

	^ observer
]

{ #category : 'accessing' }
NxWitnessedEvent >> observer: anAgent [

	observer := anAgent
]

{ #category : 'accessing' }
NxWitnessedEvent >> source [

	^ source
]

{ #category : 'accessing' }
NxWitnessedEvent >> source: anObject [

	source := anObject
]
