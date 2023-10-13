# net.bobbo.character

This plugin provides the ability to define a character and properties about them via a resource.

## Dependencies

This plugin is made for Godot 4.1. The following plugins must be installed:

- `net.bobbo.text-reader`

## Usage

### Creating a Character

1. Create a new CharacterDefinition resource
2. Edit it's name field to be something other than `UNNAMED`.
3. (OPTIONAL) Assign this character Text Reader Settings for custom talk sounds!

### Set / Get a Character's Position

CharacterDefinitions allow you to assign a character a position, or track a character to a node's position. Having this functionality be exposed via a resource is useful because it allows one to reference a potentially in-game character *outside* the context of the scene that they're in. Examples of why this is useful can be seen in dialog: it's nice to reference a character by referencing their CharacterDefinition, and then have some other node or system supply the actual physical position to that character on it's own.

You can set the position of a character by calling either `set_position()` or `set_tracked_node()` on a CharacterDefinition. If you set a character's tracked node, then whenever you call `get_position()` on that character, it will return the position of the tracked node. This is helpful if you just want a character's position to be defined by some object in-game.

### Phyiscal vs Non-Physical Characters

A character is considered physical if there is something currently representing them in the game world. In another way, a character is physical if they have an active position assigned to them. When `set_position()` or `set_tracked_node()` is called, a character is automatically set as physical.  
