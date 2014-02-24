/**
 * User: booster
 * Date: 20/02/14
 * Time: 10:04
 */
package starling.tile {
import medkit.object.Equalable;

import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;

public class TextureTile implements ITileDisplay {
    private var _texture:Texture;

    public function TextureTile(texture:Texture) {
        _texture = texture;
    }

    public function get texture():Texture { return _texture; }

    public function createDisplay():DisplayObject {
        var i:Image = new Image(_texture);

        return i;
    }

    public function equals(object:Equalable):Boolean {
        var textureTile:TextureTile = object as TextureTile;

        if(textureTile == null)
            return false;

        return textureTile._texture == _texture;
    }
}
}
