/**
 * User: booster
 * Date: 19/02/14
 * Time: 12:24
 */
package stork.tile {
public interface ITilePattern {
    function get horizontalTileCount():int;
    function get verticalTileCount():int;

    function getTileAt(column:int, row:int):ITile;
    function setTileAt(tile:ITile, column:int, row:int):void;
}
}
