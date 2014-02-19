/**
 * User: booster
 * Date: 19/02/14
 * Time: 12:49
 */
package stork.tile.navigation {
import stork.tile.MapLayer;

public class NavigationLayer extends MapLayer {
    public function NavigationLayer(name:String, horizontalTileCount:int, verticalTileCount:int, tileWidth:int, tileHeight:int, horizontalOffset:int = 0, verticalOffset:int = 0) {
        super(name, horizontalTileCount, verticalTileCount, tileWidth, tileHeight, horizontalOffset, verticalOffset);
    }
}
}
