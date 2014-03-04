/**
 * User: booster
 * Date: 03/03/14
 * Time: 16:49
 */
package stork.tile.navigation {
import stork.tile.ITile;

public interface INavigationTile extends ITile {
    function enterCost(horizontalDirection:int, verticalDirection:int):Number
    function leaveCost(horizontalDirection:int, verticalDirection:int):Number
}
}
