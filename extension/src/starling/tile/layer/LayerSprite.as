/**
 * User: booster
 * Date: 28/02/14
 * Time: 13:24
 */
package starling.tile.layer {
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.tile.ITileDisplay;

import stork.tile.ITile;
import stork.tile.ITilePattern;
import stork.tile.TilePattern;

public class LayerSprite extends Sprite implements ITilePattern {
    private var _tileWidth:Number;
    private var _tileHeight:Number;
    private var _tiles:TilePattern;
    private var _displayObjects:Vector.<DisplayObject>;

    public function LayerSprite(horizontalTileCount:int, verticalTileCount:int, tileWidth:Number, tileHeight:Number) {
        _tileWidth  = tileWidth;
        _tileHeight = tileHeight;

        _tiles = new TilePattern(horizontalTileCount, verticalTileCount);

        _displayObjects = new Vector.<DisplayObject>(horizontalTileCount * verticalTileCount, true);
    }

    public function get tileWidth():Number { return _tileWidth; }
    public function set tileWidth(value:Number):void { _tileWidth = value; }

    public function get tileHeight():Number { return _tileHeight; }
    public function set tileHeight(value:Number):void { _tileHeight = value; }

    public function get horizontalTileCount():int { return _tiles.horizontalTileCount; }
    public function get verticalTileCount():int { return _tiles.verticalTileCount; }

    public function getTileAt(column:int, row:int):ITile { return _tiles.getTileAt(column, row); }
    public function setTileAt(tile:ITile, column:int, row:int):void {
        var oldDisplayObject:DisplayObject = _displayObjects[row * horizontalTileCount + column];

        if(oldDisplayObject != null)
            oldDisplayObject.removeFromParent();

        if(tile == null) {
            _displayObjects[row * horizontalTileCount + column] = null;
        }
        else {
            var tileDisplay:ITileDisplay = tile as ITileDisplay;

            if(tileDisplay == null)
                throw new ArgumentError("tile has to implement ITileDisplay");

            var displayObject:DisplayObject = tileDisplay.createDisplay();

            displayObject.x         = column * _tileWidth; // y has to be 0
            displayObject.y         = 0;
            displayObject.width     = _tileWidth;
            displayObject.height    = _tileHeight;

            onDisplayAdded(tile, displayObject, column, row);
            _displayObjects[row * horizontalTileCount + column] = displayObject;
        }

        _tiles.setTileAt(tile, column, row);
    }

    public function toString():String {
        return _tiles.toString();
    }

    protected function getTileDisplayObject(column:int, row:int):DisplayObject {
        return _displayObjects[row * horizontalTileCount + column];
    }

    protected function onDisplayAdded(tile:ITile, displayObject:DisplayObject, column:int, row:int):void {
        throw new Error("abstract method call");
    }
}
}
