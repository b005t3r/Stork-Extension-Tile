/**
 * User: booster
 * Date: 19/02/14
 * Time: 12:50
 */
package stork.tile.navigation {
import medkit.enum.Enum;

import stork.tile.ITile;

public class NavigationTile extends Enum implements ITile {
    { initEnums(NavigationTile); }

    public static const PASSABLE_TILE:NavigationTile = new NavigationTile();
    public static const OBSTACLE_TILE:NavigationTile = new NavigationTile();

    override public function toString():String {
        if(this == PASSABLE_TILE)   return ".";
        else                        return "X";
    }
}
}
