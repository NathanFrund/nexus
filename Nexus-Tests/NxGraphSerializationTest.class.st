Class {
	#name : 'NxGraphSerializationTest',
	#superclass : 'TestCase',
	#category : 'Nexus-Tests',
	#package : 'Nexus-Tests'
}

{ #category : 'tests' }
NxGraphSerializationTest >> testEdgeNoProperties [
    | original dict restored |
    original := NxEdge new node1: 'X'; node2: 'Y'; yourself.
    dict := original asPropertyDictionary.
    restored := NxEdge fromPropertyDictionary: dict.
    self assert: restored node1 equals: 'X'.
    self assert: restored allProperties isEmpty.
]

{ #category : 'tests' }
NxGraphSerializationTest >> testEdgeRoundTrip [
    | original dict restored |
    original := NxEdge new
        node1: 'A'; node2: 'B';
        distance: 3; risk: 0.4; direction: #forward;
        yourself.
    original setProperty: #encounterType to: 'bandits'.
    original setProperty: 'name' to: 'Old Forest Road'.

    dict := original asPropertyDictionary.
    restored := NxEdge fromPropertyDictionary: dict.

    self assert: restored node1 equals: 'A'.
    self assert: restored node2 equals: 'B'.
    self assert: restored distance equals: 3.
    self assert: restored risk equals: 0.4.
    self assert: restored direction equals: #forward.
    self assert: (restored propertyAt: #encounterType) equals: 'bandits'.
    self assert: (restored propertyAt: 'name') equals: 'Old Forest Road'.
]

{ #category : 'tests' }
NxGraphSerializationTest >> testNodeNoProperties [
    | original dict restored |
    original := NxNode new name: 'plains'; yourself.
    dict := original asPropertyDictionary.
    restored := NxNode fromPropertyDictionary: dict.
    self assert: restored name equals: 'plains'.
    self assert: restored allProperties isEmpty.
]

{ #category : 'tests' }
NxGraphSerializationTest >> testNodeRoundTrip [
    | original dict restored |
    original := NxNode new name: 'forest'; label: 'Dark Forest'; yourself.
    original setProperty: #terrain to: 'woods'.
    original setProperty: #hazardLevel to: 'high'.

    dict := original asPropertyDictionary.
    restored := NxNode fromPropertyDictionary: dict.

    self assert: restored name equals: 'forest'.
    self assert: restored label equals: 'Dark Forest'.
    self assert: (restored propertyAt: #terrain) equals: 'woods'.
    self assert: (restored propertyAt: #hazardLevel) equals: 'high'.
]

{ #category : 'tests' }
NxGraphSerializationTest >> testReservedKeyBlocked [
    | edge |
    edge := NxEdge new.
    self should: [ edge setProperty: '~custom' to: 'bad' ] raise: Error.
    self should: [ edge setProperty: '~customSymbol' to: 'bad' ] raise: Error.
]
