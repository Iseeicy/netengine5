# net.bobbo.dialog-graph

A Godot plugin made for BOBBO-NET's netengine5 framework.
This plugin provides Dialog Graphs - which store the state of some branching executable dialog tree.

## Dependencies

This plugin is made for Godot 4.1. The following plugins must be installed:

- `net.bobbo.character`
- `net.bobbo.knowledge`
- `net.bobbo.resource-field`
- `net.bobbo.state-machine`
- `net.bobbo.text-reader`
- `net.bobbo.text-window`

## Usage

### Creating a DialogGraph

New DialogGraphs can be created using Godot's New Resource menu.

1. Right click in the Godot filesystem and create a new resource. ![An image showing the Create New -> Resource dialog in the godot filesystem](docs/create_graph_1.png)
2. Select the DialogGraph type. ![An image showing Godot's "Create New Resource" dialog with the DialogGraph type highlighted](docs/create_graph_2.png)
3. Name the new graph appropriately. ![An image showing Godot's File Saving dialog, with the name of the new graph to be highlighted](docs/create_graph_3.png)
4. Double click on the new graph file to open it in the Dialog Graph editor. ![An image showing the new DialogGraph open in the main Godot screen, with the file highlighted in the godot filesystem](docs/create_graph_4.png)
