Class {
	#name : 'NxEntity',
	#superclass : 'Object',
	#instVars : [
		'id',
		'components',
		'announcer'
	],
	#category : 'Nexus-ECS',
	#package : 'Nexus-ECS'
}

{ #category : 'adding' }
NxEntity >> addComponent: aComponent [
    components at: aComponent class put: aComponent.
    announcer announce: (NxComponentAdded new component: aComponent; entity: self).
]

{ #category : 'accessing' }
NxEntity >> announcer [

	^ announcer
]

{ #category : 'accessing' }
NxEntity >> announcer: anObject [

	announcer := anObject
]

{ #category : 'as yet unclassified' }
NxEntity >> componentOfType: aClass [
    ^ components at: aClass ifAbsent: [ nil ]
]

{ #category : 'accessing' }
NxEntity >> components [

	^ components
]

{ #category : 'accessing' }
NxEntity >> components: anObject [

	components := anObject
]

{ #category : 'testing' }
NxEntity >> hasComponent: aClass [
    ^ components includesKey: aClass
]

{ #category : 'accessing' }
NxEntity >> id [

	^ id
]

{ #category : 'accessing' }
NxEntity >> id: anObject [

	id := anObject
]

{ #category : 'initialization' }
NxEntity >> initialize [
    components := Dictionary new.
    announcer := Announcer new.
]

{ #category : 'enumerating' }
NxEntity >> whenComponentAddedDo: aBlock [
    announcer when: NxComponentAdded do: aBlock for: self
]
