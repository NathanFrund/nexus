Class {
	#name : 'NxPluginHook',
	#superclass : 'Object',
	#instVars : [
		'plugins'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'adding' }
NxPluginHook >> addPlugin: aPluginOrBlock [
    "Wrap a block in NxBlockPlugin automatically."
    | plugin |
    plugin := aPluginOrBlock isBlock 
        ifTrue: [ NxBlockPlugin new action: aPluginOrBlock ]
        ifFalse: [ aPluginOrBlock ].
    plugins add: plugin.
]

{ #category : 'initialization' }
NxPluginHook >> initialize [
    super initialize.
    plugins := OrderedCollection new.
]

{ #category : 'accessing' }
NxPluginHook >> plugins [
    ^ plugins
]

{ #category : 'running' }
NxPluginHook >> runWith: aContext [
    "Run only enabled plugins, in registration order."
    plugins do: [ :each |
        each enabled ifTrue: [ each execute: aContext ] ].

]
