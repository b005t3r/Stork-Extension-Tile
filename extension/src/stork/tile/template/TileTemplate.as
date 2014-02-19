/**
 * User: booster
 * Date: 12/02/14
 * Time: 11:17
 */
package stork.tile.template {
import flash.errors.IllegalOperationError;

import stork.tile.*;

public class TileTemplate {
    private var _matchingPattern:ITilePattern;
    private var _notMatchingPattern:ITilePattern;
    private var _outputPattern:ITilePattern;

    private var _xOffset:int;
    private var _yOffset:int;

    public function TileTemplate(matching:ITilePattern, notMatching:ITilePattern = null, output:ITilePattern = null, xOffset:int = 0, yOffset:int = 0) {
        _matchingPattern    = matching;
        _notMatchingPattern = notMatching;
        _outputPattern      = output;
        _xOffset            = xOffset;
        _yOffset            = yOffset;
    }

    public function findMatches(pattern:ITilePattern, resultMatches:Vector.<TemplateMatch> = null):Vector.<TemplateMatch> {
        if(resultMatches == null)
            resultMatches = new <TemplateMatch>[];

        for(var x:int = 0; x < pattern.horizontalTileCount - _matchingPattern.horizontalTileCount + 1; x++) {
            for(var y:int = 0; y < pattern.verticalTileCount - _matchingPattern.verticalTileCount + 1; y++) {
                if(matchesAt(pattern, x, y))
                    resultMatches[resultMatches.length] = new TemplateMatch(x, y);


            }
        }

        return resultMatches;
    }

    public function matchesAt(pattern:ITilePattern, x:int, y:int):Boolean {
        for(var ix:int = 0; ix < _matchingPattern.horizontalTileCount; ix++) {
            for(var iy:int = 0; iy < _matchingPattern.verticalTileCount; iy++) {
                var patternTile:ITile = pattern.getTileAt(x + ix, y + iy);
                var matchingTile:ITile = _matchingPattern.getTileAt(ix, iy);

                if(! TileUtil.matches(patternTile, matchingTile))
                    return false;

                var notMatchingTile:ITile = _notMatchingPattern != null ? _notMatchingPattern.getTileAt(ix, iy) : null;

                if(notMatchingTile != null && TileUtil.matches(patternTile, notMatchingTile))
                    return false;
            }
        }

        return true;
    }

    public function applyMatches(pattern:ITilePattern, matches:Vector.<TemplateMatch>):void {
        var matchesCount:int = matches.length;
        for(var i:int = 0; i < matchesCount; i++) {
            var match:TemplateMatch = matches[i];

            applyAt(pattern, match.x, match.y);
        }
    }

    public function applyAt(pattern:ITilePattern, x:int, y:int):void {
        if(_outputPattern == null)
            throw new IllegalOperationError("can't call applyAt() when an output pattern is not set");

        for(var ix:int = 0; ix < _outputPattern.horizontalTileCount; ix++) {
            for(var iy:int = 0; iy < _outputPattern.verticalTileCount; iy++) {
                var tile:ITile = _outputPattern.getTileAt(ix, iy);

                if(tile == null)
                    continue;

                pattern.setTileAt(tile, x + ix + _xOffset, y + iy + _yOffset);
            }
        }
    }
}
}
