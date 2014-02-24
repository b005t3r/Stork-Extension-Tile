/**
 * User: booster
 * Date: 24/02/14
 * Time: 9:17
 */
package starling.tile {
import flash.utils.Dictionary;

import starling.textures.Texture;
import starling.textures.TextureAtlas;

public class TileDisplayAtlas {
    private var _verbose:Boolean;

    private var _tiles:Dictionary = new Dictionary();

    public function TileDisplayAtlas(verbose:Boolean = false) {
        _verbose = verbose;
    }

    public function addTile(name:String, tile:ITileDisplay):void {
        if(_verbose) {
            if(_tiles[name] != null)
                trace("[TileDisplayAtlas] Overwriting tile for name: \"" + name + "\"");
        }

        _tiles[name] = tile;
    }

    public function addTileFromColor(name:String, color:uint, alpha:Number):void {
        var tile:ColorTile = new ColorTile(color, alpha);

        addTile(name, tile);
    }

    public function addTileFromTexture(name:String, texture:Texture):void {
        var tile:TextureTile = new TextureTile(texture);

        addTile(name, tile);
    }

    public function addTileFromTextureAtlas(name:String, textureName:String, atlas:TextureAtlas):void {
        var texture:Texture = atlas.getTexture(textureName);

        addTileFromTexture(name, texture);
    }

    public function addTilesFromTextureAtlas(mappings:XML, atlas:TextureAtlas):void {
        for each (var mapping:XML in mappings.Mapping)
            addTileFromTextureAtlas(mapping.@name, mapping.@textureName, atlas);
    }

    public function getTile(name:String):ITileDisplay {
        return _tiles[name];
    }
}
}
