/**
 * User: booster
 * Date: 19/02/14
 * Time: 14:15
 */
package stork.tile {
import stork.core.Node;

public class MapNode extends Node {
    private var _layers:Vector.<MapLayer> = new <MapLayer>[];

    public function MapNode(name:String = "MapNode") {
        super(name);
    }

    public function get layerCount():int { return _layers.length; }

    public function addLayer(layer:MapLayer):void {
        addLayerAt(layer, layerCount);
    }

    public function addLayerAt(layer:MapLayer, index:int):void {
        var count:int = _layers.length;

        if(index >= 0 && index <= count) {
            if(getLayerIndex(layer) >= 0) {
                setLayerIndex(layer, index);
            }
            else {
                if(index == count)  _layers[count] = layer;
                else                _layers.splice(index, 0, layer);
            }
        }
        else {
            throw new RangeError("invalid layer index");
        }
    }

    public function removeLayer(layer:MapLayer):void {
        var nodeIndex:int = getLayerIndex(layer);

        if (nodeIndex != -1)
            removeLayerAt(nodeIndex);
    }

    public function removeLayerAt(index:int):void {
        if(index >= 0 && index < layerCount) {
            if(index == layerCount)     _layers.length -= 1;
            else                        _layers.splice(index, 1);
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

    public function getLayerIndex(layer:MapLayer):int { return _layers.indexOf(layer); }
    public function setLayerIndex(layer:MapLayer, index:int):void {
        var oldIndex:int = getLayerIndex(layer);

        if (oldIndex == index) return;
        if (oldIndex == -1) throw new ArgumentError("not added to this MapNode");

        _layers.splice(oldIndex, 1);
        _layers.splice(index, 0, layer);
    }

    public function swapLayers(layerA:MapLayer, layerB:MapLayer):void {
        var indexA:int = getLayerIndex(layerA);
        var indexB:int = getLayerIndex(layerB);

        if (indexA == -1 || indexB == -1) throw new ArgumentError("not added to this MapNode");

        swapLayersAt(indexA, indexB);
    }

    public function swapLayersAt(indexA:int, indexB:int):void {
        var child1:MapLayer = getLayerAt(indexA);
        var child2:MapLayer = getLayerAt(indexB);

        _layers[indexA] = child2;
        _layers[indexB] = child1;
    }

    public function getLayerAt(index:int):MapLayer { return _layers[index]; }

    public function getLayerByName(name:String):MapLayer {
        var count:int = _layers.length;
        for(var i:int = 0; i < count; ++i)
            if(_layers[i].name == name)
                return _layers[i];

        return null;
    }

    public function getLayerByClass(layerClass:Class):MapLayer {
        var count:int = _layers.length;
        for(var i:int = 0; i < count; ++i)
            if(_layers[i] is layerClass)
                return _layers[i];

        return null;
    }

    public function getLayersByClass(layerClass:Class, layers:Vector.<MapLayer> = null):Vector.<MapLayer> {
        if(layers == null) layers = new <MapLayer>[];

        var count:int = _layers.length;
        for(var i:int = 0; i < count; ++i)
            var n:MapLayer = _layers[i];

        if(n is layerClass)
            layers[layers.length] = n;

        return layers;
    }
}
}
