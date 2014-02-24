/**
 * User: booster
 * Date: 19/02/14
 * Time: 12:37
 */
package stork.tile {

public class MapLayer extends TilePattern {
    private var _name:String;
    private var _tileWidth:int;
    private var _tileHeight:int;
    private var _horizontalOffset:int;
    private var _verticalOffset:int;

    public function MapLayer(name:String, horizontalTileCount:int, verticalTileCount:int, tileWidth:int, tileHeight:int, horizontalOffset:int = 0, verticalOffset:int = 0, initialTile:ITile = null) {
        super(horizontalTileCount, verticalTileCount, initialTile);

        _name               = name;
        _tileWidth          = tileWidth;
        _tileHeight         = tileHeight;
        _horizontalOffset   = horizontalOffset;
        _verticalOffset     = verticalOffset;
    }

    public function get name():String { return _name; }
    public function set name(value:String):void { _name = value; }

    public function get tileWidth():int { return _tileWidth; }
    public function set tileWidth(value:int):void { _tileWidth = value; }

    public function get tileHeight():int { return _tileHeight; }
    public function set tileHeight(value:int):void { _tileHeight = value; }

    public function get horizontalOffset():int { return _horizontalOffset; }
    public function set horizontalOffset(value:int):void { _horizontalOffset = value; }

    public function get verticalOffset():int { return _verticalOffset; }
    public function set verticalOffset(value:int):void { _verticalOffset = value; }
}
}
