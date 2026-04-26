# Nexus - A Minimal, Data-Driven Spatial Engine

**Nexus** is a lightweight, graph-based spatial system for agent-based simulations,
roleplaying games, and interactive narratives. It models space as a network of
meaningful **nodes** connected by traversable **edges** -- a pointcrawl architecture
that puts presence, witnessing, and path hazards front and center.

## Philosophy

- Nodes are places that matter. A village square, a blacksmith, a forest clearing.
- Edges are paths. Roads, trails, rivers, one‑way cliffs, secret tunnels.
- Agents are always at a node. Movement means following an edge.
- Events happen at nodes. Everyone there can witness them.
- Everything is driven by plain JSON maps. No hard‑coded coordinates, no framework lock‑in.

## Features

- Graph‑based spatial model with **bidirectional and one‑way** edges
- Presence queries: “Who is at this location?”
- Witness‑event generation for social diffusion (always emits an event, even when nobody else is present)
- Movement with direction checks and random path hazards
- Event accumulation (`pendingEvents`) for every move – includes departure witnesses and travel hazards
- Stable agent identifiers (`id`) for reliable identity tracking
- Hypergraph world loading from JSON – multiple named graphs are flattened into a single navigable space
- Map‑based edge representation for clarity and extensibility
- Clean, testable Smalltalk core – no ABM framework required

## Installation

In a Pharo Playground, execute:

```smalltalk
Metacello new
    baseline: 'Nexus';
    repository: 'github://NathanFrund/nexus';
    load.
```

## Getting Started (Pharo)

1. Load the code into a fresh **Pharo 13** image (Pharo 12 should also work).
2. Create a JSON map (see the example below) or use the included `village.json`.
3. Run the following snippet in a Playground:

```smalltalk
| graph world agents elder thug |
graph := NxGraph loadWorldFromJSONFile: 'village.json' asFileReference.

elder := NxSimpleAgent new id: #elder; name: 'Elder'; location: 'elderHut'; yourself.
thug  := NxSimpleAgent new id: #thug; name: 'Thug';  location: 'village'; yourself.
agents := Dictionary new
    at: 'elder' put: elder;
    at: 'thug'  put: thug;
    yourself.
world := NxWorld new graph: graph; agents: agents.

"Who is at the village?"
(world agentsAtNode: 'village') collect: #name.   "→ #('Thug')"

"Move Thug to the Elder's Hut"
world moveAgent: thug toNode: 'elderHut'.
thug location.
```

## village.json

```json
{
  "graphs": {
    "village": {
      "nodes": {
        "village": {
          "label": "Village Square",
          "terrain": "open"
        },
        "elderHut": {
          "label": "Elder's Hut",
          "terrain": "building"
        },
        "forest": {
          "label": "Forest Path",
          "terrain": "woods"
        }
      },
      "edges": [
        {
          "from": "village",
          "to": "elderHut",
          "distance": 1,
          "risk": 0.0
        },
        {
          "from": "village",
          "to": "forest",
          "distance": 2,
          "risk": 0.3,
          "direction": "backward"
        }
      ]
    }
  }
}
```

A world can contain multiple named graphs—edges between nodes in different graphs are automatically merged into a single navigable space.

## Package Structure

| Package       | Contents                                                                                       |
| ------------- | ---------------------------------------------------------------------------------------------- |
| `Nexus-Core`  | `NxGraph`, `NxNode`, `NxEdge`, `NxWorld`, `NxWitnessedEvent`, `NxHazardEvent`, `NxSimpleAgent` |
| `Nexus-Tests` | `NxGraphTest`, `NxWorldTest`                                                                   |

## Design

Nexus is intentionally decoupled from any specific agent‑based model. It doesn’t know
about personality traits, conversion rules, or game mechanics. It just produces spatial
events (witnessing, path hazards) that any simulation engine can consume.

## Entity‑Component‑System (ECS) Layer

Nexus includes an optional **ECS layer** (`Nexus-ECS` package) that provides an alternative
way to model agents. Instead of using a single agent class, you compose entities from
small, reusable **components** and let dedicated **systems** process them. This makes
agents more flexible and easier to extend without touching existing code.

### Concepts

| Concept       | Meaning                                                                                                                      |
| :------------ | :--------------------------------------------------------------------------------------------------------------------------- |
| **Entity**    | A lightweight object with a unique `id` and a collection of components.                                                      |
| **Component** | A plain data object that holds one specific attribute (position, identity, etc.).                                            |
| **System**    | An object that queries entities for specific components and performs logic. Systems communicate via Pharo **Announcements**. |

### Core Components

| Component    | Fields              | Purpose                                            |
| :----------- | :------------------ | :------------------------------------------------- |
| `NxIdentity` | `id`, `name`        | Unique identifier and display name.                |
| `NxPosition` | `nodeName`, `graph` | Current location and reference to the world graph. |

### Systems

| System             | Role                                                                   |
| :----------------- | :--------------------------------------------------------------------- |
| `NxMovementSystem` | Validates and executes entity movement (direction, hazards, events).   |
| `NxWitnessSystem`  | Generates departure events that other agents at the same node observe. |

### Quick Start (ECS)

```smalltalk
"Create a small graph and world"
graph := NxGraph new.
graph addNode: (NxNode new name: 'square'; label: 'Town Square').
graph addNode: (NxNode new name: 'hut'; label: 'Elder''s Hut').
graph addEdgeFrom: 'square' to: 'hut' distance: 1 risk: 0.0.

world := NxWorld new graph: graph.

"Create two entities"
explorer := NxEntity new id: #explorer.
explorer addComponent: (NxIdentity new id: #explorer; name: 'Explorer').
explorer addComponent: (NxPosition new nodeName: 'square'; graph: graph).
world addEntity: explorer.

villager := NxEntity new id: #villager.
villager addComponent: (NxIdentity new id: #villager; name: 'Villager').
villager addComponent: (NxPosition new nodeName: 'square'; graph: graph).
world addEntity: villager.

"Move the explorer and listen for departure events"
moveSys := NxMovementSystem new.
moveSys witnessSystem whenDepartureHappensDo: [ :ev |
    Transcript show: ev observer name, ' watched ', ev source name, ' leave the ', ev location; cr ].

moveSys moveEntity: explorer toNode: 'hut' inWorld: world.
```

### Announcements

The ECS layer uses Pharo's `Announcer` for all inter‑system communication.
You can subscribe to any of these events:

| Announcement       | Raised when…                                                |
| :----------------- | :---------------------------------------------------------- |
| `NxComponentAdded` | A component is added to an entity.                          |
| `NxDepartureEvent` | An entity leaves a node (emitted by `NxWitnessSystem`).     |
| `NxEntityMoved`    | An entity completes a move (emitted by `NxMovementSystem`). |

### Coexistence with Agents

The ECS layer lives alongside the traditional `NxSimpleAgent` model in `Nexus-Core`.
You can use both in the same world, or gradually migrate to entities as your needs grow.

This section is self‑contained, documents the public API, and shows a working example without any forward‑looking references to other projects. It can be placed after the “Design” section in your main README.

## License

MIT
