# Nexus - A Minimal, Data-Driven Spatial Engine

**Nexus** is a lightweight, graph-based spatial engine for agent-based simulations,
roleplaying games, and interactive narratives. Written in Pharo Smalltalk, it models a directed graph of named nodes and edges, tracks entities moving through the graph, and fires hooks so that game logic (hazards, healing, traps, story encounters) can be added without touching the engine itself.

> For detailed guides, API reference, and customisation examples, see the [Nexus Wiki](https://github.com/NathanFrund/nexus/wiki).

## Philosophy

- **Graph‑first** — The world is a graph. Every location is a node; every path is an edge.
- **Data‑driven** — Nodes and edges carry arbitrary metadata (a property graph). Plugins read that metadata to make decisions.
- **Hook‑based extensibility** — Six named hooks cover every phase of movement. Game logic lives in plugins; the engine never changes.
- **Two approaches** — An simple path for lightweight agents, and a full Entity‑Component‑System pipeline for complex simulations.
- **Library, not a framework** — Nexus provides a world, movement, and hooks. You bring the agents, components, and rules.
- **Property‑graph native** — Every node and edge can be serialized to a portable dictionary, ready for JSON or graph databases (XTDB, SurrealDB, etc.).

## Features

- **Graph‑based spatial model** with bidirectional and one‑way (`#forward`/`#backward`) edges.
- **High‑performance spatial index** – O(1) lookups for finding “who is at this node?”
- **Property graph** — `NxNode` and `NxEdge` each hold a lazy properties dictionary for terrain, encounters, story metadata, etc.
- **Hook‑based plugin system** — extend every movement phase without modifying the engine: `#validate`, `#departure`, `#hazard`, `#spatialMove`, `#arrival`, `#announce`.
- **One‑way veto latch** — any plugin can block a move, and no later plugin can unlock it.
- **Witnessed events** — when an entity leaves or arrives, other agents at the same node witness it.
- **Event accumulation** — a world’s pendingEvents collects everything that happened during a move.
- **Serialization‑ready** — `asPropertyDictionary` / `fromPropertyDictionary:` on every node and edge, compatible with graph databases and JSON.
- **Two movement tiers** — simple agent path (moveAgent:toNode:) and full ECS pipeline (`NxMovementSystem`), both powered by the same hooks
- **Clear, testable Smalltalk core** — no external dependencies, no ABM framework required.
- **Hypergraph world loading from JSON** – multiple named graphs flattened into a single space.

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
thug location.   "→ 'elderHut'"
```

## village.json

Build a world from data.

```json
{
  "graphs": {
    "village": {
      "nodes": {
        "village": {
          "label": "Village Square"
        },
        "elderHut": {
          "label": "Elder's Hut",
          "properties": {
            "npc": "Elder"
          }
        },
        "forest": {
          "label": "Forest Path",
          "properties": {
            "hazardLevel": "high"
          }
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
| `Nexus-Core`  | `NxGraph`, `NxNode`, `NxEdge`, `NxWorld`, `NxWitnessedEvent`, `NxHazardEvent`, `NxSimpleAgent`, `NxPlugin`, `NxBlockPlugin`, `NxPluginHook`,`NxPluginRegistry` |
| `Nexus-ECS`   | Entity‑Component‑System layer (optional) – `NxEntity`, `NxMovementSystem`, `NxWitnessSystem`, `NxMovementContext`   |
| `Nexus-Tests` | `NxGraphTest`, `NxWorldTest`, `NxHazardPluginTests`, `NxHookWiringTest`, `NxGraphSerializationTest`                                                      |

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
- **System** – processes entities (e.g., `NxMovementSystem`). The movement pipeline automatically calls registered hook plugins at each step (`#validate`, `#departure`, `#hazard`, etc.).

**Quick example:**

```smalltalk
"Create an entity at 'square'"
explorer := world spawn: #explorer at: 'square'.

"Move it — hooks fire automatically"
world move: #explorer to: 'hut'.
```

Under the hood, `NxMovementSystem` runs a six‑step pipeline. Each step calls the corresponding hook on the global `NxPluginRegistry`. The transient `NxMovementContext` carries the entity, target node, edge, world reference, a **veto latch** (`moveAllowed`), and a data dictionary for inter‑hook communication.

Events: Subscribe to `NxArrivalEvent`, `NxDepartureEvent`, or `NxEntityMoved` via the movement or witness system’s `announcer`. You can also register a plugin for the `#announce` hook to react to every movement without a direct subscription.

## Plugin System (Hooks)

Nexus exposes **six named hooks** that fire during every movement. Plugin logic is registered as a block or a named `NxPlugin` subclass. The engine calls them automatically — no subclassing of the engine itself.

| Hook           | When it runs                           | Typical use                       |
|----------------|----------------------------------------|-----------------------------------|
| `#validate`    | Before any side effects                | Locked doors, zone of control     |
| `#departure`   | Before witnesses are notified           | Traps that spring when leaving    |
| `#hazard`      | Mid‑traversal (no built‑in logic)      | Risk rolls, bandit ambushes       |
| `#spatialMove` | After position updated                  | Terrain effects, token drops      |
| `#arrival`     | After witnesses are notified            | Healing shrines, quest triggers   |
| `#announce`    | After the movement announcement         | UI updates, sound effects         |

### Register a one-line plugin

```smalltalk
NxPluginRegistry default registerPluginFor: #hazard do: [ :ctx |
    ctx edge risk > 0 ifTrue: [
        ctx world pendingEvents add: (NxHazardEvent new
            target: ctx targetNode;
            severity: ctx edge risk;
            yourself) ] ].

```

### Create a named, introspectable plugin

```smalltalk
NxPlugin subclass: #HealingShrinePlugin
    instanceVariableNames: ''
    package: 'MyGame-Plugins'

HealingShrinePlugin >> execute: aContext
    aContext targetNode = #safeHouse ifTrue: [
        (aContext entity componentOfType: NxHealth) ifNotNil: [ :h |
            h current: h max ] ].

HealingShrinePlugin >> description
    ^ 'Restores full health at the safe house'
```

Register it:

```smalltalk
NxPluginRegistry default registerPluginFor: #arrival plugin: HealingShrinePlugin new.
```

### Introspect and control plugins at runtime

```smalltalk

(NxPluginRegistry default hooksFor: #validate) plugins do: [ :p | Transcript show: p description; cr ].
(NxPluginRegistry default hooksFor: #hazard) plugins first disable.

```

## Property Graph

Nodes and edges both carry a `properties` dictionary for arbitrary metadata. No more subclassing for every terrain or encounter type.

```smalltalk
edge := (world graph edgesFrom: 'village-square') first.
edge setProperty: #encounterType to: 'forestBandits'.
edge setProperty: #banditCrewName to: 'Blackwood Gang'.

"Later, a plugin reads it"
encounter := ctx edge propertyAt: #encounterType ifAbsent: nil.
```

## Serialization

Every node and edge can export itself as a flat dictionary, and be rebuilt from that dictionary. Structural attributes are prefixed with ~ to avoid collisions with custom properties.

```smalltalk
"Create an edge with metadata"
edge := NxEdge new
    node1: 'village-square'; node2: 'forest-path';
    distance: 2; risk: 0.3; yourself.
edge setProperty: #encounterType to: 'forestBandits'.
edge setProperty: #banditCrewName to: 'Blackwood Gang'.

"Export to a portable dictionary"
dict := edge asPropertyDictionary.
"dict keys → #('~from' '~to' '~distance' '~risk' '~direction' 'encounterType' 'banditCrewName')"

"Reconstruct it later (from a file, database, or network message)"
restored := NxEdge fromPropertyDictionary: dict.
restored propertyAt: #banditCrewName.  "→ 'Blackwood Gang'"
restored node1 = 'village-square'.     "→ true"
```

To save an entire world, iterate over `world graph nodes` and `world graph edges`, collect their dictionaries, and write them as JSON. Loading reverses the process.

The test class `NxGraphSerializationTest` guarantees that all structural and custom attributes survive a round‑trip without loss.

## License

MIT
