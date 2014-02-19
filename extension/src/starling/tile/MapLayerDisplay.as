/**
 * User: booster
 * Date: 19/02/14
 * Time: 12:57
 */
package starling.tile {
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.utils.MatrixUtil;
import starling.utils.RectangleUtil;

import stork.tile.ITile;
import stork.tile.ITilePattern;
import stork.tile.TilePattern;

public class MapLayerDisplay extends Sprite implements ITilePattern {
    private static var _pointA:Point    = new Point();
    private static var _pointB:Point    = new Point();
    private static var _rect:Rectangle  = new Rectangle();

    private var _tileWidth:Number;
    private var _tileHeight:Number;
    private var _tiles:TilePattern;

    public function MapLayerDisplay(horizontalTileCount:int, verticalTileCount:int, tileWidth:Number, tileHeight:Number) {
        _tileWidth  = tileWidth;
        _tileHeight = tileHeight;

        _tiles      = new TilePattern(horizontalTileCount, verticalTileCount);
    }

    public function get horizontalTileCount():int { return _tileWidth; }
    public function get verticalTileCount():int { return _tileHeight; }

    public function getTileAt(x:int, y:int):ITile { return _tiles.getTileAt(x, y); }
    public function setTileAt(tile:ITile, x:int, y:int):void {
        var oldTile:ITile = _tiles.getTileAt(x, y);

        if(oldTile != null)
            DisplayObject(oldTile).removeFromParent();

        var tileDisplay:DisplayObject = tile as DisplayObject;

        if(tileDisplay == null || tile is ITileDisplay == false)
            throw new ArgumentError("tile has to implement ITileDisplay and subclass DisplayObject");

        tileDisplay.x       = x * _tileWidth;
        tileDisplay.y       = y * _tileHeight;
        tileDisplay.width   = _tileWidth;
        tileDisplay.height  = _tileHeight;

        addChild(tileDisplay);

        _tiles.setTileAt(tile, x, y);
    }

    override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle {
        if (resultRect == null) resultRect = new Rectangle();

        var transformationMatrix:Matrix = getTransformationMatrix(targetSpace);

        MatrixUtil.transformCoords(transformationMatrix, 0, 0, _pointA);
        MatrixUtil.transformCoords(transformationMatrix, _tileWidth * horizontalTileCount, _tileHeight * verticalTileCount, _pointB);

        var x1:Number = _pointA.x < _pointB.x ? _pointA.x : _pointB.x;
        var y1:Number = _pointA.y < _pointB.y ? _pointA.y : _pointB.y;
        var x2:Number = _pointA.x > _pointB.x ? _pointA.x : _pointB.x;
        var y2:Number = _pointA.y > _pointB.y ? _pointA.y : _pointB.y;

        resultRect.setTo(x1, y1, x2 - x1, y2 - y1);

        // if we have a scissor rect, intersect it with our bounds
        if(clipRect != null)
            RectangleUtil.intersect(resultRect, getClipRect(targetSpace, _rect), resultRect);

        return resultRect;
    }
}
}
