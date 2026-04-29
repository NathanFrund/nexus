Class {
	#name : 'NxHazardResult',
	#superclass : 'Object',
	#instVars : [
		'occurred',
		'severity',
		'description'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'instance creation' }
NxHazardResult class >> none [
    "No hazard occurred."
    ^ self new
        occurred: false;
        yourself
]

{ #category : 'instance creation' }
NxHazardResult class >> withSeverity: aNumber description: aString [
    "Hazard occurred with given severity (0.0-1.0) and description."
    ^ self new
        occurred: true;
        severity: aNumber;
        description: aString;
        yourself
]

{ #category : 'accessing' }
NxHazardResult >> description [
    ^ description ifNil: [ 'Hazard' ]
]

{ #category : 'accessing' }
NxHazardResult >> description: aString [
    description := aString
]

{ #category : 'accessing' }
NxHazardResult >> occurred [
    ^ occurred ifNil: [ false ]
]

{ #category : 'accessing' }
NxHazardResult >> occurred: aBoolean [
    occurred := aBoolean
]

{ #category : 'accessing' }
NxHazardResult >> severity [
    ^ severity ifNil: [ 0.5 ]
]

{ #category : 'accessing' }
NxHazardResult >> severity: aNumber [
    severity := aNumber clampBetween: 0.0 and: 1.0
]
