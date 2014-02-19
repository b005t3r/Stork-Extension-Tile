/**
 * User: booster
 * Date: 12/02/14
 * Time: 10:58
 */
package stork.tile {
import medkit.string.StringBuilder;

public class TilePattern implements ITilePattern {
    private var _map:Vector.<ITile>;
    private var _horizontalTileCount:int;
    private var _verticalTileCount:int;

    public function TilePattern(horizontalTileCount:int, verticalTileCount:int, initialTile:ITile = null) {
        _horizontalTileCount    = horizontalTileCount;
        _verticalTileCount      = verticalTileCount;
        _map                    = new Vector.<ITile>(horizontalTileCount * verticalTileCount, true);

        if(initialTile == null)
            return;

        var count:int = horizontalTileCount * verticalTileCount;
        for(var i:int = 0; i < count; i++)
            _map[i] = initialTile;
    }

    public function get horizontalTileCount():int { return _horizontalTileCount; }
    public function get verticalTileCount():int { return _verticalTileCount; }

    public function getTileAt(x:int, y:int):ITile {
        if(x < 0 || y < 0 || x >= _horizontalTileCount || y >= _verticalTileCount)
            throw new ArgumentError("x and/or y not in range; x: " + x + ", y: " + y + ", width: " + _horizontalTileCount + ", height: " + _verticalTileCount);

        return _map[y * _horizontalTileCount + x];
    }

    public function setTileAt(tile:ITile, x:int, y:int):void {
        if(x < 0 || y < 0 || x >= _horizontalTileCount || y >= _verticalTileCount)
            throw new ArgumentError("x and/or y not in range; x: " + x + ", y: " + y + ", width: " + _horizontalTileCount + ", height: " + _verticalTileCount);

        _map[y * _horizontalTileCount + x] = tile;
    }

    public function toString():String {
        var builder:StringBuilder = new StringBuilder(_horizontalTileCount * (_verticalTileCount + 1));

        for(var y:int = 0; y < _verticalTileCount; y++) {
            for(var x:int = 0; x < _horizontalTileCount; x++) {
                var tile:ITile = _map[y * _horizontalTileCount + x];
                builder.append(tile != null ? String(tile) : " ");
            }

            builder.append("\n");
        }

        return builder.toString();
    }
}
}
