Class {
	#name : 'NxHazardStrategy',
	#superclass : 'Object',
	#category : 'Nexus-Core',
	#package : 'Nexus-Core'
}

{ #category : 'evaluating' }
NxHazardStrategy >> evaluateFor: anEntity onEdge: anEdge [
    "Return an NxHazardResult indicating whether a hazard occurs."
    ^ self subclassResponsibility
]
