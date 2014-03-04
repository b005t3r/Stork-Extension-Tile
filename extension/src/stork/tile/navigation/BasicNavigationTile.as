/**
 * User: booster
 * Date: 19/02/14
 * Time: 12:50
 */
package stork.tile.navigation {
import medkit.enum.Enum;

public class BasicNavigationTile extends Enum implements INavigationTile {
    { initEnums(BasicNavigationTile); }

    public static const PASSABLE_TILE:BasicNavigationTile = new BasicNavigationTile();
    public static const OBSTACLE_TILE:BasicNavigationTile = new BasicNavigationTile();

    public function enterCost(horizontalDirection:int, verticalDirection:int):Number {
        if(this == PASSABLE_TILE)   return 0.5;
        else                        return Infinity;
    }

    public function leaveCost(horizontalDirection:int, verticalDirection:int):Number {
        if(this == PASSABLE_TILE)   return 0.5;
        else                        return Infinity;
    }

    override public function toString():String {
        if(this == PASSABLE_TILE)   return ".";
        else                        return "X";
    }
}
}
