Class {
	#name : 'NxECSWorldTest',
	#superclass : 'TestCase',
	#category : 'Nexus-ECS-Tests',
	#package : 'Nexus-ECS-Tests'
}

{ #category : 'tests' }
NxECSWorldTest >> testArrivalEvent [
    | graph world explorer villager moveSys arrivedEvent |

    "Create graph"
    graph := NxGraph new.
    graph addNode: (NxNode new name: 'square'; label: 'Square').
    graph addNode: (NxNode new name: 'hut'; label: 'Hut').
    graph addEdgeFrom: 'square' to: 'hut' distance: 1 risk: 0.0.

    "Create world"
    world := NxWorld new.
    world graph: graph.

    "Create explorer at square"
    explorer := NxEntity new id: #explorer.
    explorer addComponent: (NxPosition new nodeName: 'square'; graph: graph).
    world addEntity: explorer.

    "Create villager at hut"
    villager := NxEntity new id: #villager.
    villager addComponent: (NxPosition new nodeName: 'hut'; graph: graph).
    world addEntity: villager.

    "Set up arrival subscription"
    arrivedEvent := nil.
    moveSys := NxMovementSystem new.
    moveSys witnessSystem whenArrivalHappensDo: [ :event |
        arrivedEvent := event ].

    "Perform move"
    self assert: (moveSys moveEntity: explorer toNode: 'hut' inWorld: world).

    "Verify arrival event"
    self deny: arrivedEvent isNil.
    self assert: arrivedEvent observer equals: villager.
    self assert: arrivedEvent source equals: explorer.
    self assert: arrivedEvent location equals: 'hut'.
]

{ #category : 'tests' }
NxECSWorldTest >> testDepartureEvent [
    | graph world witness mover moveSys departedEvent |

    "Create graph"
    graph := NxGraph new.
    graph addNode: (NxNode new name: 'square'; label: 'Square').
    graph addNode: (NxNode new name: 'hut'; label: 'Hut').
    graph addEdgeFrom: 'square' to: 'hut' distance: 1 risk: 0.0.

    "Create world"
    world := NxWorld new.
    world graph: graph.

    "Create mover at square"
    mover := NxEntity new id: #mover.
    mover addComponent: (NxPosition new nodeName: 'square'; graph: graph).
    world addEntity: mover.

    "Create witness also at square (same node as mover)"
    witness := NxEntity new id: #witness.
    witness addComponent: (NxPosition new nodeName: 'square'; graph: graph).
    world addEntity: witness.

    "Set up departure subscription"
    departedEvent := nil.
    moveSys := NxMovementSystem new.
    moveSys witnessSystem whenDepartureHappensDo: [ :event |
        departedEvent := event ].

    "Perform move – mover leaves square to hut"
    self assert: (moveSys moveEntity: mover toNode: 'hut' inWorld: world).

    "Verify departure event"
    self deny: departedEvent isNil.
    self assert: departedEvent observer equals: witness.
    self assert: departedEvent source equals: mover.
    self assert: departedEvent location equals: 'square'.
]

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

{ #category : 'tests' }
NxECSWorldTest >> testHazardOccurs [
    | graph world explorer moveSys hazardEvent |

    graph := NxGraph new.
    graph addNode: (NxNode new name: 'square'; label: 'Square').
    graph addNode: (NxNode new name: 'hut'; label: 'Hut').
    graph addEdgeFrom: 'square' to: 'hut' distance: 1 risk: 1.0.

    world := NxWorld new.
    world graph: graph.

    explorer := NxEntity new id: #explorer.
    explorer addComponent: (NxPosition new nodeName: 'square'; graph: graph).
    world addEntity: explorer.

    moveSys := NxMovementSystem new.
    self assert: (moveSys moveEntity: explorer toNode: 'hut' inWorld: world).

    hazardEvent := world pendingEvents detect: [ :e | e isKindOf: NxHazardEvent ] ifNone: [ nil ].
    self deny: hazardEvent isNil.
    self assert: hazardEvent target equals: 'hut'.
    self assert: hazardEvent severity equals: 1.0.
]

{ #category : 'tests' }
NxECSWorldTest >> testNoHazard [
    | graph world explorer moveSys hazardEvent |

    graph := NxGraph new.
    graph addNode: (NxNode new name: 'square'; label: 'Square').
    graph addNode: (NxNode new name: 'hut'; label: 'Hut').
    graph addEdgeFrom: 'square' to: 'hut' distance: 1 risk: 0.0.

    world := NxWorld new.
    world graph: graph.

    explorer := NxEntity new id: #explorer.
    explorer addComponent: (NxPosition new nodeName: 'square'; graph: graph).
    world addEntity: explorer.

    moveSys := NxMovementSystem new.
    self assert: (moveSys moveEntity: explorer toNode: 'hut' inWorld: world).

    hazardEvent := world pendingEvents detect: [ :e | e isKindOf: NxHazardEvent ] ifNone: [ nil ].
    self assert: hazardEvent isNil.
]
