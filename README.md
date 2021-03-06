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

### screenSize

Set the viewport size. The default is 240 and will be integer scaled to the height of the actual screen.

#### Parameters

* size - the size in _pixels_; I like 240 (default), 120 and 420.

### viewport

Obtain information about the viewport position and window size.  
This function is useful to get info about the whereabouts in the real coordinate space of the device that *Löve2D* is being run on.  
The viewport is always square, but I allow for drawing outside it, such as that if you have a larger platformer for example, the buttons may hide some of the playfield but hopefully not the viewport.

#### Return value

A dict containing these keys:

* offsetX - start position of the top left corner of the screen (may be negative) (coordinate x)
* offsetY - start position of the top left corner of the screen (may be negative) (coordinate y)
* width - the full width of the window
* height - the full height of the window
* zoom - the scale factor

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
* sourceCellX - source cell to copy from (x coordinate)
* sourceCellY - source cell to copy from (y coordinate)
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
* alpha (default: `0` full transparency) - the amount of transparency to set
* colour (default: `{0, 0, 0}` full black) - the colour to set
* offsetX (default: `0`) - displacement (x coordinate)
* offsetY (default: `0`) - displacement (y coordinate)

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

