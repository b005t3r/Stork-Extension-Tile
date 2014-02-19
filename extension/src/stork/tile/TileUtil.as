/**
 * User: booster
 * Date: 13/02/14
 * Time: 14:43
 */
package stork.tile {
import stork.tile.ITile;

public class TileUtil {
    public static function matches(tileA:ITile, tileB:ITile):Boolean {
        if(tileA == null || tileB == null)
            return true;

        return tileA.equals(tileB);
    }
}
}
