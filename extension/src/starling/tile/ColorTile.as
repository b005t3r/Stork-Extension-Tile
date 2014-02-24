/**
 * User: booster
 * Date: 20/02/14
 * Time: 10:03
 */
package starling.tile {
import medkit.object.Equalable;

import starling.display.DisplayObject;
import starling.display.Quad;

public class ColorTile implements ITileDisplay {
    private var _color:uint;
    private var _alpha:Number;

    public function ColorTile(color:uint, alpha:Number) {
        _color = color;
        _alpha = alpha;
    }

    public function get color():uint { return _color; }
    public function get alpha():Number { return _alpha; }

    public function createDisplay():DisplayObject {
        var q:Quad = new Quad(1, 1, _color);
        q.alpha = _alpha;

        return q;
    }

    public function equals(object:Equalable):Boolean {
        var colorTile:ColorTile = object as ColorTile;

        if(colorTile == null)
            return false;

        return colorTile._color == _color && colorTile._alpha == _alpha;
    }
}
}
