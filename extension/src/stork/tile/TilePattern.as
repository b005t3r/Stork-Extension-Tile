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

    public function getTileAt(column:int, row:int):ITile {
        if(column < 0 || row < 0 || column >= _horizontalTileCount || row >= _verticalTileCount)
            throw new ArgumentError("x and/or y not in range; x: " + column + ", y: " + row + ", width: " + _horizontalTileCount + ", height: " + _verticalTileCount);

        return _map[row * _horizontalTileCount + column];
    }

    public function setTileAt(tile:ITile, column:int, row:int):void {
        if(column < 0 || row < 0 || column >= _horizontalTileCount || row >= _verticalTileCount)
            throw new ArgumentError("x and/or y not in range; x: " + column + ", y: " + row + ", width: " + _horizontalTileCount + ", height: " + _verticalTileCount);

        _map[row * _horizontalTileCount + column] = tile;
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
