Class {
	#name : 'NxPluginRegistry',
	#superclass : 'Object',
	#instVars : [
		'hooks'
	],
	#classVars : [
		'Default'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'accessing' }
NxPluginRegistry class >> default [
    ^ Default ifNil: [ Default := self new ]

]

{ #category : 'as yet unclassified' }
NxPluginRegistry >> hooksFor: hookName [
    ^ hooks at: hookName ifAbsentPut: [ NxPluginHook new ]

]

{ #category : 'initialization' }
NxPluginRegistry >> initialize [
    super initialize.
    hooks := Dictionary new.
]

{ #category : 'as yet unclassified' }
NxPluginRegistry >> registerPluginFor: hookName do: aBlock [
    (self hooksFor: hookName) addPlugin: aBlock

]

{ #category : 'as yet unclassified' }
NxPluginRegistry >> registerPluginFor: hookName plugin: anNxPlugin [
    (self hooksFor: hookName) addPlugin: anNxPlugin
]
