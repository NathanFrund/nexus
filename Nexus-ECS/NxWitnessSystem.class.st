Class {
	#name : 'NxWitnessSystem',
	#superclass : 'Object',
	#instVars : [
		'announcer'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

{ #category : 'witness' }
NxWitnessSystem >> arriveEntity: anEntity atNode: aNodeName inWorld: aWorld [
    | others events |
    others := (aWorld objectsAtNode: aNodeName) reject: [ :obj | obj id = anEntity id ].
    events := others ifEmpty: [
        { NxArrivalEvent new
            observer: nil;
            source: anEntity;
            location: aNodeName;
            yourself } ]
        ifNotEmpty: [
            others collect: [ :observer |
                NxArrivalEvent new
                    observer: observer;
                    source: anEntity;
                    location: aNodeName;
                    yourself ] ].
    events do: [ :event | announcer announce: event ].
    aWorld pendingEvents addAll: events

]

{ #category : 'witness' }
NxWitnessSystem >> departEntity: anEntity fromNode: aNodeName inWorld: aWorld [

	| others events |
	others := (aWorld objectsAtNode: aNodeName) reject: [ :obj | obj id = anEntity id ].
	events := others
		          ifEmpty: [
				          { (NxDepartureEvent new
					           observer: nil;
					           source: anEntity;
					           location: aNodeName;
					           yourself) } ]
		          ifNotEmpty: [
				          others collect: [ :observer |
						          NxDepartureEvent new
							          observer: observer;
							          source: anEntity;
							          location: aNodeName;
							          yourself ] ].
	events do: [ :event | announcer announce: event ].

	"Also add to world's pendingEvents for backward compatibility during transition"
	aWorld pendingEvents addAll: events
]

{ #category : 'initialization' }
NxWitnessSystem >> initialize [
    super initialize.
    announcer := Announcer new.
]

{ #category : 'subscriptions' }
NxWitnessSystem >> whenArrivalHappensDo: aBlock [
    announcer when: NxArrivalEvent do: aBlock for: self
]

{ #category : 'subscriptions' }
NxWitnessSystem >> whenDepartureHappensDo: aBlock [
    announcer when: NxDepartureEvent do: aBlock for: self
]
