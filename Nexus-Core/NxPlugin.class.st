Class {
	#name : 'NxPlugin',
	#superclass : 'Object',
	#instVars : [
		'name',
		'enabled'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'accessing' }
NxPlugin >> description [
    ^ 'Plugin: ', name
]

{ #category : 'protocol' }
NxPlugin >> disable [
    enabled := false
]

{ #category : 'protocol' }
NxPlugin >> enable [
    enabled := true
]

{ #category : 'accessing' }
NxPlugin >> enabled [
    ^ enabled ifNil: [ true ]
]

{ #category : 'execution' }
NxPlugin >> execute: aContext [
    ^ self subclassResponsibility
]

{ #category : 'initialization' }
NxPlugin >> initialize [
    super initialize.
    enabled := true.
    name := self class name.
]
