Class {
	#name : 'NxECSWorldTest',
	#superclass : 'TestCase',
	#category : 'Nexus-ECS-Tests',
	#package : 'Nexus-ECS-Tests'
}

{ #category : 'tests' }
NxECSWorldTest >> testEntityMovementAndWitnessing [
    | graph world explorer villager moveSys depEvent |
    
    graph := NxGraph loadWorldFromJSONString: '{
        "graphs": {
            "village": {
                "nodes": {
                    "village-square": {"label": "Village Square"},
                    "elder-hut": {"label": "Elder''s Hut"}
                },
                "edges": [
                    {"from": "village-square", "to": "elder-hut", "distance": 1, "risk": 0.0}
                ]
            }
        }
    }'.
    
    world := NxWorld new graph: graph.
    
    "Create explorer entity"
    explorer := NxEntity new id: #explorer.
    explorer addComponent: (NxIdentity new id: #explorer; name: 'Explorer').
    explorer addComponent: (NxPosition new nodeName: 'village-square'; graph: graph).
    world addEntity: explorer.
    
    "Create villager entity"
    villager := NxEntity new id: #villager.
    villager addComponent: (NxIdentity new id: #villager; name: 'Villager').
    villager addComponent: (NxPosition new nodeName: 'village-square'; graph: graph).
    world addEntity: villager.
    
    "Subscribe to departure events so we can capture the announcement"
    depEvent := nil.
    moveSys := NxMovementSystem new.
    moveSys witnessSystem whenDepartureHappensDo: [ :ev | depEvent := ev ].
    
    "Move explorer"
    self assert: (moveSys moveEntity: explorer toNode: 'elder-hut' inWorld: world).
    
    "Explorer position updated"
    self assert: (explorer componentOfType: NxPosition) nodeName equals: 'elder-hut'.
    "Villager didn't move"
    self assert: (villager componentOfType: NxPosition) nodeName equals: 'village-square'.
    
    "A departure event was announced"
    self deny: depEvent isNil.
    self assert: depEvent observer id equals: #villager.
    self assert: depEvent source id equals: #explorer.
]
