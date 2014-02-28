/**
 * User: booster
 * Date: 28/02/14
 * Time: 9:14
 */
package stork.tile {
import flash.geom.Rectangle;

public class Entity {
    private var _x:Number;
    private var _y:Number;
    private var _width:Number;
    private var _height:Number;
    private var _anchorX:Number;
    private var _anchorY:Number;

    private var _bounds:Rectangle       = new Rectangle();
    private var _boundsDirty:Boolean    = true;

    public function Entity(width:Number, height:Number) {
        _width  = width;
        _height = height;
    }

    public function get x():Number { return _x; }
    public function set x(value:Number):void {
        if(value == _x) return;

        _boundsDirty = true;

        _x = value;
    }

    public function get y():Number { return _y; }
    public function set y(value:Number):void {
        if(value == _y) return;

        _boundsDirty = true;

        _y = value;
    }

    public function get width():Number { return _width; }
    public function set width(value:Number):void {
        if(value == _width) return;

        _boundsDirty = true;

        _width = value;
    }

    public function get height():Number { return _height; }
    public function set height(value:Number):void {
        if(value == _height) return;

        _boundsDirty = true;

        _height = value;
    }

    public function get anchorX():Number { return _anchorX; }
    public function set anchorX(value:Number):void {
        if(value == _anchorX) return;

        _boundsDirty = true;

        _anchorX = value;
    }

    public function get anchorY():Number { return _anchorY; }
    public function set anchorY(value:Number):void {
        if(value == _anchorY) return;

        _boundsDirty = true;

        _anchorY = value;
    }

    public function get bounds():Rectangle {
        if(_boundsDirty) {
            _boundsDirty = false;

            _bounds.setTo(_x - _anchorX, _y - _anchorY, _width, _height);
        }

        return _bounds;
    }
}
}
