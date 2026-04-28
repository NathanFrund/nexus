"
I am an announcement fired when an entity arrives at a node in the Nexus‑ECS system.

I am used by the witness system to notify other systems (e.g., UI, AI, combat) that
an entity has entered a location. My `observer` is the entity that witnessed the arrival
(usually another entity already present at the node), and my `source` is the entity that
arrived. If no witnesses are present, `observer` is nil.

I am a subclass of `Announcement` so that subscribers can register via
`when:do:` on the witness system's announcer.

Example:

    witnessSystem whenArrivalHappensDo: [ :event |
        Transcript show: event source name, ' arrived at ', event location ].
"
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
