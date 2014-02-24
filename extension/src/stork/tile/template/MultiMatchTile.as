/**
 * User: booster
 * Date: 24/02/14
 * Time: 12:39
 */
package stork.tile.template {
import medkit.object.Equalable;

import stork.tile.ITile;

public class MultiMatchTile implements ITile {
    public static const MATCHES_ANY:String = "any";
    public static const MATCHES_ALL:String = "all";

    private var _tiles:Vector.<ITile> = new <ITile>[];

    private var _matchesAll:Boolean;

    public function MultiMatchTile(type:String) {
        _matchesAll = (type == MATCHES_ALL);
    }

    public function append(tile:ITile):MultiMatchTile {
        _tiles[_tiles.length] = tile;

        return this;
    }

    public function equals(object:Equalable):Boolean {
        var i:int, count:int,tile:ITile;

        if(_matchesAll) {
            count = _tiles.length;
            for(i = 0; i < count; i++) {
                tile = _tiles[i];

                if(! tile.equals(object))
                    return false;
            }

            return true;
        }
        else {
            count = _tiles.length;
            for(i = 0; i < count; i++) {
                tile = _tiles[i];

                if(tile.equals(object))
                    return true;
            }

            return false;
        }
    }
}
}
