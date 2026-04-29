Class {
	#name : 'NxDefaultRiskStrategy',
	#superclass : 'NxHazardStrategy',
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'evaluating' }
NxDefaultRiskStrategy >> evaluateFor: anEntity onEdge: anEdge [
    | risk |
    risk := anEdge risk ifNil: [ 0.0 ].
    risk <= 0.0 ifTrue: [ ^ NxHazardResult none ].
    (Random new next <= risk) ifTrue: [
        ^ NxHazardResult withSeverity: risk description: 'Travel hazard encountered' ].
    ^ NxHazardResult none
]
