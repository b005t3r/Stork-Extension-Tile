/**
 * User: booster
 * Date: 19/02/14
 * Time: 12:57
 */
package starling.tile {
import starling.display.DisplayObject;
import starling.display.Sprite;

import stork.tile.ITile;
import stork.tile.ITilePattern;
import stork.tile.TilePattern;

public class MapRenderer implements ITilePattern {
    private var _tileWidth:Number;
    private var _tileHeight:Number;
    private var _tiles:TilePattern;
    private var _displayObjects:Vector.<DisplayObject>;

    private var _rowSprites:Vector.<Sprite>;

    public function MapRenderer(horizontalTileCount:int, verticalTileCount:int, tileWidth:Number, tileHeight:Number) {
        _tileWidth  = tileWidth;
        _tileHeight = tileHeight;

        _tiles      = new TilePattern(horizontalTileCount, verticalTileCount);

        _rowSprites = new Vector.<Sprite>(verticalTileCount, true);

        for(var i:int = 0; i < verticalTileCount; i++) {
            var sprite:TileRowSprite    = new TileRowSprite(this);
            sprite.y                    = i * tileHeight;

            _rowSprites[i] = sprite;
        }

        _displayObjects = new Vector.<DisplayObject>(horizontalTileCount * verticalTileCount, true);
    }

    public function get tileWidth():Number { return _tileWidth; }
    public function set tileWidth(value:Number):void { _tileWidth = value; }

    public function get tileHeight():Number { return _tileHeight; }
    public function set tileHeight(value:Number):void { _tileHeight = value; }

    public function get horizontalTileCount():int { return _tiles.horizontalTileCount; }
    public function get verticalTileCount():int { return _tiles.verticalTileCount; }

    public function get rowSprites():Vector.<Sprite> { return _rowSprites; }

    public function getTileAt(x:int, y:int):ITile { return _tiles.getTileAt(x, y); }
    public function setTileAt(tile:ITile, x:int, y:int):void {
        var oldDisplayObject:DisplayObject = _displayObjects[y * horizontalTileCount + x];

        if(oldDisplayObject != null)
            oldDisplayObject.removeFromParent();

        if(tile == null) {
            _displayObjects[y * horizontalTileCount + x] = null;
        }
        else {
            var tileDisplay:ITileDisplay = tile as ITileDisplay;

            if(tileDisplay == null)
                throw new ArgumentError("tile has to implement ITileDisplay");

            var displayObject:DisplayObject = tileDisplay.createDisplay();

            displayObject.x         = x * _tileWidth; // y has to be 0
            displayObject.y         = 0;
            displayObject.width     = _tileWidth;
            displayObject.height    = _tileHeight;

            _rowSprites[y].addChild(displayObject);
            _displayObjects[y * horizontalTileCount + x] = displayObject;
        }

        _tiles.setTileAt(tile, x, y);
    }

    public function toString():String {
        return _tiles.toString();
    }
}
}

import flash.geom.Point;
import flash.geom.Rectangle;

import starling.display.Sprite;
import starling.tile.MapRenderer;

class TileRowSprite extends Sprite {
    private static var _pointA:Point    = new Point();
    private static var _pointB:Point    = new Point();
    private static var _rect:Rectangle  = new Rectangle();

    private var renderer:MapRenderer;

    public function TileRowSprite(renderer:MapRenderer) {
        this.renderer = renderer;
    }

/*
    override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle {
        if (resultRect == null) resultRect = new Rectangle();

        var transformationMatrix:Matrix = getTransformationMatrix(targetSpace);

        MatrixUtil.transformCoords(transformationMatrix, 0, 0, _pointA);
        MatrixUtil.transformCoords(transformationMatrix, renderer.tileWidth * renderer.horizontalTileCount, renderer.tileHeight, _pointB);

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
*/
}
