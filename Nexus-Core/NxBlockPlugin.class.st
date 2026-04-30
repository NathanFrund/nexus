Class {
	#name : 'NxBlockPlugin',
	#superclass : 'NxPlugin',
	#instVars : [
		'action'
	],
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'accessing' }
NxBlockPlugin >> action: aBlock [
    action := aBlock.
    name := 'BlockPlugin (', aBlock hash asString, ')'.
]

{ #category : 'execution' }
NxBlockPlugin >> execute: aContext [
    ^ action value: aContext
]
