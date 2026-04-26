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
