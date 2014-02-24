/**
 * User: booster
 * Date: 20/02/14
 * Time: 8:36
 */
package starling.tile {
import starling.display.Sprite;

public class MapSprite extends Sprite {
    private var _layers:Vector.<Layer>  = new <Layer>[];
    private var _layersDirty:Boolean    = true;

    public function MapSprite() {
        super();
    }

    public function get layerCount():int { return _layers.length; }

    public function addLayer(name:String):void {
        addLayerAt(name, layerCount);
    }

    public function addLayerAt(name:String, index:int):void {
        var count:int = _layers.length;

        if(index >= 0 && index <= count) {
            if(getLayerIndex(name) >= 0) {
                setLayerIndex(name, index);
            }
            else {
                if(index == count)  _layers[count] = new Layer(name);
                else                _layers.splice(index, 0, new Layer(name));

                _layersDirty = true;
            }
        }
        else {
            throw new RangeError("invalid layer index");
        }
    }

    public function removeLayer(name:String):void {
        var nodeIndex:int = getLayerIndex(name);

        if (nodeIndex != -1)
            removeLayerAt(nodeIndex);
    }

    public function removeLayerAt(index:int):void {
        if(index >= 0 && index < layerCount) {
            if(index == layerCount)     _layers.length -= 1;
            else                        _layers.splice(index, 1);

            _layersDirty = true;
        }
        else {
            throw new RangeError("invalid layer index");
        }
    }

    public function removeLayers(beginIndex:int = 0, endIndex:int = -1):void {
        if(endIndex < 0 || endIndex >= layerCount)
            endIndex = layerCount - 1;

        for(var i:int = beginIndex; i <= endIndex; ++i)
            removeLayerAt(beginIndex);
    }

    public function getLayerIndex(name:String):int {
        var count:int = _layers.length;
        for(var i:int = 0; i < count; i++)
            if(_layers[i].name == name)
                return i;

        return -1;
    }

    public function setLayerIndex(name:String, index:int):void {
        var oldIndex:int = getLayerIndex(name);

        if (oldIndex == index) return;
        if (oldIndex == -1) throw new ArgumentError("layer not added to this MapSprite");

        var l:Layer = _layers[oldIndex];
        _layers.splice(oldIndex, 1);
        _layers.splice(index, 0, l);

        _layersDirty = true;
    }

    public function swapLayers(nameA:String, nameB:String):void {
        var indexA:int = getLayerIndex(nameA);
        var indexB:int = getLayerIndex(nameB);

        if (indexA == -1 || indexB == -1) throw new ArgumentError("layer not added to this MapSprite");

        swapLayersAt(indexA, indexB);
    }

    public function swapLayersAt(indexA:int, indexB:int):void {
        if(indexA == indexB) return;

        var child1:Layer = _layers[indexA];
        var child2:Layer = _layers[indexB];

        _layers[indexA] = child2;
        _layers[indexB] = child1;

        _layersDirty = true;
    }

    public function getLayerAt(index:int):String { return _layers[index].name; }

    public function assignMapRenderer(renderer:MapRenderer, layerName:String, compileLayers:Boolean = true):void {
        var layer:Layer = getLayer(layerName);

        if(layer == null)
            throw new ArgumentError("layer + \'" + layerName + "\' does not exist");

        var count:int = layer.mapRenderers.length;
        layer.mapRenderers[count] = renderer;

        if(compileLayers)
            compile();
    }

    public function unassignMapRenderer(renderer:MapRenderer, layerName:String, compileLayers:Boolean = true):void {
        var layer:Layer = getLayer(layerName);

        if(layer == null)
            throw new ArgumentError("layer + \'" + layerName + "\' does not exist");

        var count:int = layer.mapRenderers.length;
        for(var i:int = 0; i < count; i++) {
            var r:MapRenderer = layer.mapRenderers[i];

            if(r != renderer)
                continue;

            if(i == count)  layer.mapRenderers.length -= 1;
            else            layer.mapRenderers.splice(i, 1);
            break;
        }

        if(compileLayers)
            compile();
    }

    public function compile():void {
        if(! _layersDirty) return;

        removeChildren();

        var count:int = _layers.length;
        for(var i:int = 0; i < count; i++) {
            var layer:Layer = _layers[i];

            var renderers:Vector.<MapRenderer> = layer.mapRenderers;
            var rendererCount:int = renderers.length;
            for(var j:int = 0; j < rendererCount; j++) {
                var renderer:MapRenderer = renderers[j];

                var sprites:Vector.<Sprite> = renderer.rowSprites;
                var spriteCount:int = sprites.length;
                for(var k:int = 0; k < spriteCount; k++) {
                    var sprite:Sprite = sprites[k];

                    addChild(sprite);
                    //trace("MapRenderer[" + k + "]: " + sprite.getBounds(this).toString());
                }
            }
        }

        //trace("MapSprite: " + this.getBounds(parent).toString());

        _layersDirty = false;
    }

    private function getLayer(name:String):Layer {
        var count:int = _layers.length;
        for(var i:int = 0; i < count; i++) {
            var layer:Layer = _layers[i];

            if(layer.name == name)
                return layer;
        }

        return null;
    }
}
}

import starling.tile.MapRenderer;

class Layer {
    public var name:String;
    public var mapRenderers:Vector.<MapRenderer> = new <MapRenderer>[];

    public function Layer(name:String) {
        this.name = name;
    }
}
