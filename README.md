# Nexus - A Minimal, Data-Driven Spatial Engine

**Nexus** is a lightweight, graph-based spatial system for agent-based simulations,
roleplaying games, and interactive narratives. It models space as a network of
meaningful **nodes** connected by traversable **edges** -- a pointcrawl architecture
that puts presence, witnessing, and path hazards front and center.

> For detailed guides, API reference, and customisation examples, see the [Nexus Wiki](https://github.com/NathanFrund/nexus/wiki).

## Philosophy

- Nodes are places that matter. A village square, a blacksmith, a forest clearing.
- Edges are paths. Roads, trails, rivers, one‑way cliffs, secret tunnels.
- Agents are always at a node. Movement means following an edge.
- Events happen at nodes. Everyone there can witness them.
- Everything is driven by plain JSON maps. No hard‑coded coordinates, no framework lock‑in.

## Features

- Graph‑based spatial model with **bidirectional and one‑way** edges
- **High‑performance spatial index** – O(1) lookups for “who is at this node?”
- **Configurable movement pipeline** – validate, witness, hazard, move, announce
- Witness‑event generation for social diffusion (always emits an event, even when alone)
- Movement with direction checks and random path hazards
- Event accumulation (`pendingEvents`) for every move – includes departure witnesses and travel hazards
- Stable agent identifiers (`id`) for reliable identity tracking
- Hypergraph world loading from JSON – multiple named graphs flattened into a single space
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
| `Nexus-ECS`   | Entity‑Component‑System layer (optional) – `NxEntity`, `NxMovementSystem`, `NxWitnessSystem`   |
| `Nexus-Tests` | `NxGraphTest`, `NxWorldTest`, ECS tests                                                        |

## Design

Nexus is intentionally decoupled from any specific agent‑based model. It doesn’t know
about personality traits, conversion rules, or game mechanics. It just produces spatial
events (witnessing, path hazards) that any simulation engine can consume.

## Entity‑Component‑System (ECS) Layer

Nexus includes an optional **ECS layer** (`Nexus-ECS` package) that provides a flexible,
data‑driven way to model agents. For a complete walkthrough, see the **Wiki**.

**Key concepts:**

- **Entity** – container with a unique `id` and components.
- **Component** – plain data object (e.g., `NxPosition`).
- **System** – processes entities (e.g., `NxMovementSystem`).

**Quick example:**

```smalltalk
"Create entity with position at 'square'"
explorer := NxEntity new id: #explorer.
explorer addComponent: (NxPosition new nodeName: 'square'; graph: graph).
world addEntity: explorer.

"Move it"
moveSys := NxMovementSystem new.
moveSys moveEntity: explorer toNode: 'hut' inWorld: world.
```

**Events:** Subscribe to `NxArrivalEvent`, `NxDepartureEvent`, `NxEntityMoved` via the movement or witness system’s `announcer`.

## License

MIT
