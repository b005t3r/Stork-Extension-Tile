/**
 * User: booster
 * Date: 28/02/14
 * Time: 13:37
 */
package starling.tile.layer {
import flash.geom.Rectangle;

import starling.core.RenderSupport;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;
import starling.filters.FragmentFilter;

import stork.tile.ITile;

public class FrontTopViewLayerSprite extends MapLayerSprite {
    private static var _rect:Rectangle  = new Rectangle();

    private var _rows:Vector.<Sprite>;

    private var _renderList:RenderList = new RenderList();

    public function FrontTopViewLayerSprite(horizontalTileCount:int, verticalTileCount:int, tileWidth:Number, tileHeight:Number) {
        super(horizontalTileCount, verticalTileCount, tileWidth, tileHeight);

        _rows = new Vector.<Sprite>(verticalTileCount, true);

        for(var i:int = 0; i < verticalTileCount; i++) {
            var sprite:TileRowSprite    = new TileRowSprite(this);
            sprite.y                    = i * tileHeight;

            _rows[i] = sprite; // already sorted by Y
            addChild(sprite);
        }

        addEventListener(Event.ADDED, onChildAdded);
        addEventListener(Event.REMOVED, onChildRemoved);
    }

    private function onChildRemoved(event:Event):void {
        var child:DisplayObject = event.target as DisplayObject;

        if(child.parent != this || child is TileRowSprite)
            return;

        _renderList.remove(child);
    }

    private function onChildAdded(event:Event):void {
        var child:DisplayObject = event.target as DisplayObject;

        if(child.parent != this || child is TileRowSprite)
            return;

        _renderList.add(child);
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

        if(isFlattened || _rows.length == this.numChildren) {
            super.render(support, parentAlpha);
        }
        else {
            var alpha:Number = parentAlpha * this.alpha;
            var blendMode:String = support.blendMode;

            _renderList.sort();

            var i:int, j:int, child:DisplayObject;
            var rowCount:int = _rows.length, listSize:int = _renderList.length;

            var list:Vector.<DisplayObject> = _renderList.displayObjects;

            var row:DisplayObject   = rowCount > 0 ? _rows[0] : null;
            var other:DisplayObject = listSize > 0 ? list[0] : null;

            for(i = 0, j = 0; i < rowCount || j < listSize;) {
                if(other == null || (row != null && row.y + tileHeight < other.y)) {
                    child = row;
                    ++i;

                    if(i < rowCount)
                        row = _rows[i];
                    else
                        row = null;
                }
                else {
                    child = other;
                    ++j;

                    if(j < listSize)
                        other = list[j];
                    else
                        other = null;
                }

                if(child.hasVisibleArea) {
                    var filter:FragmentFilter = child.filter;

                    support.pushMatrix();
                    support.transformMatrix(child);
                    support.blendMode = child.blendMode;

                    if(filter)  filter.render(child, support, alpha);
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
        displayObject.x         = column * tileWidth; // y has to be 0
        displayObject.y         = 0;
        displayObject.width     = tileWidth;
        displayObject.height    = tileHeight;

        _rows[row].addChild(displayObject);
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

            unflatten();

            if(numChildren == 0)    visible = false;
            else                    flatten();
        }

        super.render(support, parentAlpha);
    }
}

class RenderList {
    private var _listA:Vector.<DisplayObject> = new <DisplayObject>[];
    private var _listB:Vector.<DisplayObject> = new <DisplayObject>[];
    private var _size:int;

    public function get displayObjects():Vector.<DisplayObject> { return _listA; }
    public function get length():int { return _size; }

    public function add(o:DisplayObject):void {
        if(_size == _listA.length) {
            var newSize:int = _size * 2 + 10;

            _listA.length = newSize;
            _listB.length = newSize;
        }

        _listA[_size++] = o;
    }

    public function remove(o:DisplayObject):void {
        var index:int = _listA.indexOf(o);

        if(index < 0) return;

        for(; index < _size - 1; ++index)
            _listA[index] = _listA[int(index + 1)];

        _listA[_size] = null;
        _listB[_size] = null;
        --_size;
    }

    public function sort():void {
        var tmp:Vector.<DisplayObject> = _listA;
        _listA = _listB;
        _listB = tmp;

        for(var i:int = 0; i < _size; ++i) {
            var o:DisplayObject = _listB[i];

            addSorted(o, _listA, i);
        }
    }

    private function addSorted(o:DisplayObject, list:Vector.<DisplayObject>, listSize:int):void {
        if(listSize == 0) {
            list[0] = o;
            return;
        }

        var left:int, right:int, middle:int;

        // optimization for adding elements in the right order
        if(o.y >= list[int(listSize - 1)].y) {
            list[listSize] = o;
        }
        else {
            left = 0; right = listSize; middle = (left + right) / 2;
            var middleChild:DisplayObject;

            while(middle > left) {
                middleChild = list[middle];

                if(o.y > middleChild.y) left = middle;
                else                    right = middle;

                middle = (left + right) / 2;
            }

            middleChild = list[middle];

            if(o.y > middleChild.y)
                ++middle;

            for(right = listSize; right > middle; --right)
                list[right] = list[int(right - 1)];

            list[middle] = o;
        }
    }
}
