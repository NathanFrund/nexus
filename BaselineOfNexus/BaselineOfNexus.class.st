Class {
	#name : 'BaselineOfNexus',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfNexus',
	#package : 'BaselineOfNexus'
}

{ #category : 'baselines' }
BaselineOfNexus >> baseline: spec [
    <baseline>
    spec for: #common do: [
        spec
            package: 'Nexus-Core';
            package: 'Nexus-Tests' with: [ spec requires: #('Nexus-Core') ];
            package: 'Nexus-ECS' with: [ spec requires: #('Nexus-Core') ];
            package: 'Nexus-ECS-Tests' with: [ spec requires: #('Nexus-ECS' 'Nexus-Tests') ] ]
]
