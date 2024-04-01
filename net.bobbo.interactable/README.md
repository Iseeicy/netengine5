# net.bobbo.interactable

A Godot plugin made for BOBBO-NET's netengine5 framework.
This plugin provides the ability to create objects in the world that the player can interact with.

## Dependencies

This plugin is made for Godot 4.1.

## Usage

### `Interactable` Nodes

This plugin implents the `Interactable` node. This can be added as a child to any `CollisionObject` node (such as a `RigidBody` or `StaticBody`). You can implement custom interactions by either using `Interactable`'s signals, or directly extending `Interactable` and overriding following virtual functions:

- `interactable_use_start()`
- `interactable_use_stop()`
- `interactable_hover_start()`
- `interactable_hover_stop()`

### `InteractorRay3D` Nodes

This plugin also implements the `InteractorRay3D` node. This acts like a `RayCast3D`, but specializes in hovering over & selecting interactable nodes. This is why `Interactables` expect to be underneath a `CollisionObject` node: so this node can properly located them.
