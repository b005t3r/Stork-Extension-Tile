/**
 * User: booster
 * Date: 03/03/14
 * Time: 8:43
 */
package starling.tile.layer {
import starling.display.DisplayObject;

import stork.tile.ITile;

public class SimpleLayerSprite extends LayerSprite {
    private var _tileLayerSprite:TileLayerSprite;

    public function SimpleLayerSprite(horizontalTileCount:int, verticalTileCount:int, tileWidth:Number, tileHeight:Number) {
        super(horizontalTileCount, verticalTileCount, tileWidth, tileHeight);

        _tileLayerSprite = new TileLayerSprite(this);
        addChild(_tileLayerSprite);
    }

    override protected function onDisplayAdded(tile:ITile, displayObject:DisplayObject, column:int, row:int):void {
        displayObject.x         = column * tileWidth;
        displayObject.y         = row * tileHeight;
        displayObject.width     = tileWidth;
        displayObject.height    = tileHeight;

        _tileLayerSprite.addChild(displayObject);
    }
}
}

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.core.RenderSupport;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;
import starling.tile.layer.SimpleLayerSprite;
import starling.utils.MatrixUtil;

class TileLayerSprite extends Sprite {
    private static var _point:Point     = new Point();
    private static var _matrix:Matrix   = new Matrix();

    private var _layerSprite:SimpleLayerSprite;

    private var _needsValidation:Boolean = true;

    public function TileLayerSprite(layerSprite:SimpleLayerSprite) {
        this._layerSprite = layerSprite;

        addEventListener(Event.ADDED, onInvalidate);
        addEventListener(Event.REMOVED, onInvalidate);
    }

    private function onInvalidate(event:Event):void {
        var child:DisplayObject = event.target as DisplayObject;

        if(child.parent != this) return;

        _needsValidation = true;
    }

    override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle {
        if(! resultRect)
            resultRect = new Rectangle();

        var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
        var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
        var actualWidth:Number  = _layerSprite.tileWidth * _layerSprite.horizontalTileCount;
        var actualHeight:Number = _layerSprite.tileHeight * _layerSprite.verticalTileCount;

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

    override public function render(support:RenderSupport, parentAlpha:Number):void {
        if(_needsValidation) {
            _needsValidation = false;

            unflatten();

            if(numChildren == 0)    visible = false;
            else                    flatten();
        }

        super.render(support, parentAlpha);
    }
}