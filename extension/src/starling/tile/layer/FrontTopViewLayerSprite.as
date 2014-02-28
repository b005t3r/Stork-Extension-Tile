/**
 * User: booster
 * Date: 28/02/14
 * Time: 13:37
 */
package starling.tile.layer {
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.core.RenderSupport;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.filters.FragmentFilter;
import starling.utils.MatrixUtil;

import stork.tile.ITile;

public class FrontTopViewLayerSprite extends LayerSprite {
    private static var _point:Point     = new Point();
    private static var _matrix:Matrix   = new Matrix();
    private static var _rect:Rectangle  = new Rectangle();

    private var _rowSprites:Vector.<Sprite>;

    private var _renderList:Vector.<DisplayObject> = new <DisplayObject>[];

    public function FrontTopViewLayerSprite(horizontalTileCount:int, verticalTileCount:int, tileWidth:Number, tileHeight:Number) {
        super(horizontalTileCount, verticalTileCount, tileWidth, tileHeight);

        _rowSprites = new Vector.<Sprite>(verticalTileCount, true);

        for(var i:int = 0; i < verticalTileCount; i++) {
            var sprite:TileRowSprite    = new TileRowSprite(this);
            sprite.y                    = i * tileHeight;

            _rowSprites[i] = sprite; // already sorted by Y
            addChild(sprite);
        }
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

    override public function render(support:RenderSupport, parentAlpha:Number):void {
        if(this.clipRect != null) {
            var clipRect:Rectangle = support.pushClipRect(getClipRect(stage, _rect));
            if(clipRect.isEmpty()) {

                // empty clipping bounds - no need to render children.
                support.popClipRect();
                return;
            }
        }

        if(isFlattened || _rowSprites.length == this.numChildren) {
            super.render(support, parentAlpha);
        }
        else {
            var i:int, child:DisplayObject, childCount:int = this.numChildren;

            var renderListSize:int = 0;

            for(i = 0; i < childCount; ++i) {
                child = getChildAt(i);

                // we've got these in an already sorted list
                if(child is TileRowSprite)
                    continue;

                addToRenderList(child, _renderList, renderListSize++);
            }

            var alpha:Number = parentAlpha * this.alpha;
            var blendMode:String = support.blendMode;

            var j:int, rowCount:int = _rowSprites.length;

            var row:DisplayObject = rowCount > 0 ? _rowSprites[0] : null;
            var other:DisplayObject = _renderList[0];

            _renderList[0] = null;

            for(i = 0, j = 0; i < rowCount || j < renderListSize;) {
                if(other == null || (row != null && row.y + tileHeight < other.y)) {
                    child = row;
                    ++i;

                    if(i < rowCount)
                        row = _rowSprites[i];
                    else
                        row = null;
                }
                else {
                    child = other;
                    ++j;

                    if(j < renderListSize) {
                        other = _renderList[j];
                        _renderList[j] = null;
                    }
                    else {
                        other = null;
                    }
                }

                if(child.hasVisibleArea) {
                    var filter:FragmentFilter = child.filter;

                    support.pushMatrix();
                    support.transformMatrix(child);
                    support.blendMode = child.blendMode;

                    if(filter) filter.render(child, support, alpha);
                    else        child.render(support, alpha);

                    support.blendMode = blendMode;
                    support.popMatrix();
                }
            }
        }

        if(this.clipRect != null)
            support.popClipRect();
    }

    override protected function onDisplayAdded(tile:ITile, displayObject:DisplayObject, column:int, row:int):void {
        _rowSprites[row].addChild(displayObject);
    }

    private function addToRenderList(child:DisplayObject, list:Vector.<DisplayObject>, listSize:int):void {
        if(listSize == list.length)
            list.length = listSize * 2 + 10;

        if(listSize == 0) {
            list[0] = child;
            return;
        }

        var left:int = 0, right:int = listSize;
        var middle:int = (left + right) / 2, middleChild:DisplayObject;

        while(middle > left) {
            middleChild = list[middle];

            if(child.y > middleChild.y) left = middle;
            else                        right = middle;

            middle = (left + right) / 2;
        }

        middleChild = list[middle];

        if(child.y > middleChild.y)
            ++middle;

        for(right = listSize; right > middle; --right)
            list[right] = list[int(right - 1)];

        list[middle] = child;
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
import starling.tile.layer.FrontTopViewLayerSprite;
import starling.utils.MatrixUtil;

class TileRowSprite extends Sprite {
    private static var _point:Point     = new Point();
    private static var _matrix:Matrix   = new Matrix();

    private var _layerSprite:FrontTopViewLayerSprite;

    private var _needsValidation:Boolean = true;

    public function TileRowSprite(layerSprite:FrontTopViewLayerSprite) {
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
        var actualHeight:Number = _layerSprite.tileHeight;

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

            if(numChildren == 0)    visible = false;
            else                    flatten();
        }

        super.render(support, parentAlpha);
    }
}
