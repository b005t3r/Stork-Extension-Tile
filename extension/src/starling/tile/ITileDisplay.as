/**
 * User: booster
 * Date: 19/02/14
 * Time: 12:54
 */
package starling.tile {
import starling.display.DisplayObject;

import stork.tile.ITile;

public interface ITileDisplay extends ITile {
    function createDisplay():DisplayObject
}
}
