Breadboard
==========

Löve2D library to aid in even faster prototyping.

Example usage
-------------

The following code should display an 8x8 tile from the `some-image.png` image onto the screen at coordinates (0, 0).

    local BB = require("breadboard")

    local img = BB.makeTileset("some-image.png")

    BB.tile(img, 0, 0, 0)
    function BB.frame(dt)
      BB.draw(0, 0)
    end

API
---

### clearScreen

Clear the screen with a given colour. (black default)

#### Parameters

* colour (default: `{1, 1, 1}`) - the colour to use while clearing the screen

### draw

Draw from the tilemap to the screen.

#### Parameters

* sourceCellX - source tile to start the copy from (x coordinate)
* sourceCellY - source tile to start the copy from (y coordinate)
* spanCellX (default: `1`) - number of tiles to copy (x coordinate)
* spanCellY (default: `1`) - number of tiles to copy (y coordinate)
* offsetX (default: `0`) - displacement (x coordinate)
* offsetY (default: `0`) - displacement (y coordinate)
* rotationAngle (default: `0`) - rotation to apply when copying
* scale (default: `1`) - scale to apply when copying
* alpha (default: `1` full opacity) - the amount of transparency to copy the tile with
* colour (default: `{1, 1, 1}` full white) - the colour multiplier (basically love.graphics.setColor)

### tile

Draw to the tilemap.

#### Parameters

* tilesetID - ID of the loaded tileset (use makeTileset)
* tileID - ID of the first tile from the tileset to start copying from
* destCellX - destination cell to copy to on the tilemap (x coordinate)
* destCellY - destination cell to copy to on the tilemap (y coordinate)
* spanCellX (default: `1`) - number of tiles to copy (x coordinate)
* spanCellY (default: `1`) - number of tiles to copy (y coordinate)
* alpha (default: `1` full opacity) - the amount of transparency to copy the tile with
* colour (default: `{1, 1, 1}` full white) - the colour multiplier (basically love.graphics.setColor)
* offsetX (default: `0`) - displacement (x coordinate)
* offsetY (default: `0`) - displacement (y coordinate)
* flipX (default: `false`) - do a horizontal flip
* flipY (default: `false`) - do a vertical flip

### tileClear

Clear a tile on the tilemap.

#### Parameters

* destCellX - position of the first tile to clear (x coordinate)
* destCellY - position of the first tile to clear (y coordinate)
* spanCellX (default: `1`) - number of tiles to clear (x coordinate)
* spanCellY (default: `1`) - number of tiles to clear (y coordinate)
* offsetX (default: `0`) - displacement (x coordinate)
* offsetY (default: `0`) - displacement (y coordinate)
* alpha (default: `0` full transparency) - the amount of transparency to set
* colour (default: `{0, 0, 0}` full black) - the colour to set

### makeTileset

Load a tileset from file. If the file has already been loaded, this returns a cached version.
Use `removeTileset` if needed.

#### Parameters

* fileName - the path/filename to load the data from

#### Return value

A tileset ID.

### listTilesets 
List all loaded tilesets.

#### Return value

A list with all the loaded tileset IDs.

### removeTileset

Remove a tileset given its ID.

#### Parameters

* tilesetID - ID of the tileset to remove

### button

Get the status of a button. The buttons are:

* `l` - Left
  * KB: `Left`, `S`
* `u` - Up
  * KB: `Up`, `E`
* `r` - Right
  * KB: `Right`, `F`
* `d` - Down
  * KB: `Down`, `D`
* `a` - A button
  * KB: `Space`, `z`, `j`
* `b` - B button
  * KB: `Ctrl`, `x`, `k`
* `c` - C button
  * KB: `Alt`, `c`, `l`
* `s` - Start button
  * KB: `Enter`

The library also makes a touchscreen virtual joystick for Android and uses default mappings for a joystick.

#### Parameters

* butID - button ID, one of the ones above

#### Return value

Boolean representing the state of the button.

### buttonPressed

Return if a button has been pressed in the current frame.

#### Parameters

* butID - button ID, check `button` for IDs

#### Return value

Boolean whether the button has been pressed in the current frame.

