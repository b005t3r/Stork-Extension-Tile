/**
 * User: booster
 * Date: 01/03/14
 * Time: 15:20
 */
package starling.tile.layer {
import starling.display.Sprite;
import starling.events.Event;

public class EntitySprite extends Sprite {
    private var _staticEntity:Boolean;

    public function EntitySprite(staticEntity:Boolean = false) {
        _staticEntity = staticEntity;
    }

    /** LayerSprite can use this property and "pre-render" (i.e. flatten along with tiles) this sprite when true. */
    public function get staticEntity():Boolean { return _staticEntity; }
    public function set staticEntity(value:Boolean):void {
        if(value == _staticEntity) return;

        _staticEntity = value;

        // let the parent know this has changed
        dispatchEventWith(Event.CHANGE);
    }
}
}
