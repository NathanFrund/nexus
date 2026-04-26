"
I am a simple event record describing a travel hazard that occurred
while an agent moved between nodes.

I hold the target node where the hazard was triggered and the risk
value of the edge that caused it.
"
Class {
	#name : 'NxHazardEvent',
	#superclass : 'Object',
	#instVars : [
		'target',
		'risk'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'accessing' }
NxHazardEvent >> risk [

	^ risk
]

{ #category : 'accessing' }
NxHazardEvent >> risk: aNumber [

	risk := aNumber
]

{ #category : 'accessing' }
NxHazardEvent >> target [

	^ target
]

{ #category : 'accessing' }
NxHazardEvent >> target: aString [

	target := aString
]
