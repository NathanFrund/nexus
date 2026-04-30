Class {
	#name : 'NxHookWiringTest',
	#superclass : 'TestCase',
	#instVars : [
		'hookLog'
	],
	#category : 'Nexus-Tests',
	#package : 'Nexus-Tests'
}

{ #category : 'running' }
NxHookWiringTest >> setUp [
	super setUp.
	hookLog := OrderedCollection new.
	"Clean each hook"
	#( validate departure hazard spatialMove arrival announce ) do: [ :hn |
		(NxPluginRegistry default hooksFor: hn) initialize ].
	"Register one plugin per hook that records itself"
	NxPluginRegistry default registerPluginFor: #validate do: [ :ctx | hookLog add: #validate ].
	NxPluginRegistry default registerPluginFor: #departure do: [ :ctx | hookLog add: #departure ].
	NxPluginRegistry default registerPluginFor: #hazard do: [ :ctx | hookLog add: #hazard ].
	NxPluginRegistry default registerPluginFor: #spatialMove do: [ :ctx | hookLog add: #spatialMove ].
	NxPluginRegistry default registerPluginFor: #arrival do: [ :ctx | hookLog add: #arrival ].
	NxPluginRegistry default registerPluginFor: #announce do: [ :ctx | hookLog add: #announce ].
]

{ #category : 'running' }
NxHookWiringTest >> tearDown [
	#( validate departure hazard spatialMove arrival announce ) do: [ :hn |
		(NxPluginRegistry default hooksFor: hn) initialize ].
	super tearDown.
]

{ #category : 'tests' }
NxHookWiringTest >> testAllHooksExecuteInOrder [
	| world hero expectedOrder |
	world := NxWorld new.
	world graph: (NxGraph new
		addNode: (NxNode new name: 'A'; yourself);
		addNode: (NxNode new name: 'B'; yourself);
		addEdgeFrom: 'A' to: 'B' distance: 1 risk: 0.0;
		yourself).
	hero := world spawn: #hero at: 'A'.
	world move: #hero to: 'B'.

	"Assert every hook ran"
	#( validate departure hazard spatialMove arrival announce ) do: [ :hookName |
		self assert: (hookLog includes: hookName) description: hookName, ' should have run' ].

	"Assert execution order"
	expectedOrder := #( validate departure hazard spatialMove arrival announce ).
	self assert: hookLog asArray equals: expectedOrder.
]
