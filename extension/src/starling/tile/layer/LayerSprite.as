/**
 * User: booster
 * Date: 28/02/14
 * Time: 13:24
 */
package starling.tile.layer {
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.tile.ITileDisplay;
import starling.utils.MatrixUtil;

import stork.tile.ITile;
import stork.tile.ITilePattern;
import stork.tile.TilePattern;

public class LayerSprite extends Sprite implements ITilePattern {
    private static var _point:Point     = new Point();
    private static var _matrix:Matrix   = new Matrix();

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

            onDisplayAdded(tile, displayObject, column, row);
            _displayObjects[row * horizontalTileCount + column] = displayObject;
        }

        _tiles.setTileAt(tile, column, row);
    }

    public function toString():String {
        return _tiles.toString();
    }

    override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle {
        if(! resultRect)
            resultRect = new Rectangle();

        var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
        var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
        var actualWidth:Number  = tileWidth * horizontalTileCount;
        var actualHeight:Number = tileHeight * verticalTileCount;

        // optimization
        if (targetSpace == this) {
            minX = 0;
            minY = 0;
            maxX = actualWidth;
            maxY = actualHeight;
        }
        else {
            this.getTransformationMatrix(targetSpace, _matrix);

            MatrixUtil.transformCoords(_matrix, 0, 0, _point);
            minX = minX < _point.x ? minX : _point.x;
            maxX = maxX > _point.x ? maxX : _point.x;
            minY = minY < _point.y ? minY : _point.y;
            maxY = maxY > _point.y ? maxY : _point.y;

            MatrixUtil.transformCoords(_matrix, 0, actualHeight, _point);
            minX = minX < _point.x ? minX : _point.x;
            maxX = maxX > _point.x ? maxX : _point.x;
            minY = minY < _point.y ? minY : _point.y;
            maxY = maxY > _point.y ? maxY : _point.y;

            MatrixUtil.transformCoords(_matrix, actualWidth, 0, _point);
            minX = minX < _point.x ? minX : _point.x;
            maxX = maxX > _point.x ? maxX : _point.x;
            minY = minY < _point.y ? minY : _point.y;
            maxY = maxY > _point.y ? maxY : _point.y;

            MatrixUtil.transformCoords(_matrix, actualWidth, actualHeight, _point);
            minX = minX < _point.x ? minX : _point.x;
            maxX = maxX > _point.x ? maxX : _point.x;
            minY = minY < _point.y ? minY : _point.y;
            maxY = maxY > _point.y ? maxY : _point.y;
        }

        resultRect.x = minX;
        resultRect.y = minY;
        resultRect.width  = maxX - minX;
        resultRect.height = maxY - minY;

        return resultRect;
    }

    protected function getTileDisplayObject(column:int, row:int):DisplayObject {
        return _displayObjects[row * horizontalTileCount + column];
    }

    protected function onDisplayAdded(tile:ITile, displayObject:DisplayObject, column:int, row:int):void {
        throw new Error("abstract method call");
    }
}
}
