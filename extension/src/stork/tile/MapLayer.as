/**
 * User: booster
 * Date: 19/02/14
 * Time: 12:37
 */
package stork.tile {

public class MapLayer extends TilePattern {
    private var _name:String;
    private var _tileWidth:Number;
    private var _tileHeight:Number;
    private var _horizontalOffset:Number;
    private var _verticalOffset:Number;

    private var _entities:Vector.<Entity> = new <Entity>[];

    public function MapLayer(name:String, horizontalTileCount:int, verticalTileCount:int, tileWidth:Number, tileHeight:Number, horizontalOffset:Number = 0, verticalOffset:Number = 0, initialTile:ITile = null) {
        super(horizontalTileCount, verticalTileCount, initialTile);

        _name               = name;
        _tileWidth          = tileWidth;
        _tileHeight         = tileHeight;
        _horizontalOffset   = horizontalOffset;
        _verticalOffset     = verticalOffset;
    }

    public function get name():String { return _name; }
    public function set name(value:String):void { _name = value; }

    public function get tileWidth():Number { return _tileWidth; }
    public function set tileWidth(value:Number):void { _tileWidth = value; }

    public function get tileHeight():Number { return _tileHeight; }
    public function set tileHeight(value:Number):void { _tileHeight = value; }

    public function get horizontalOffset():Number { return _horizontalOffset; }
    public function set horizontalOffset(value:Number):void { _horizontalOffset = value; }

    public function get verticalOffset():Number { return _verticalOffset; }
    public function set verticalOffset(value:Number):void { _verticalOffset = value; }

    public function get entityCount():int { return _entities.length; }

    public function addEntity(entity:Entity):void {
        addEntityAt(entity, entityCount);
    }

    public function addEntityAt(entity:Entity, index:int):void {
        var count:int = _entities.length;

        if(index >= 0 && index <= count) {
            if(getEntityIndex(entity) >= 0) {
                setEntityIndex(entity, index);
            }
            else {
                if(index == count)  _entities[count] = entity;
                else                _entities.splice(index, 0, entity);
            }
        }
        else {
            throw new RangeError("invalid entity index");
        }
    }

    public function removeEntity(entity:Entity):void {
        var nodeIndex:int = getEntityIndex(entity);

        if (nodeIndex != -1)
            removeEntityAt(nodeIndex);
    }

    public function removeEntityAt(index:int):void {
        if(index >= 0 && index < entityCount) {
            if(index == entityCount)     _entities.length -= 1;
            else                        _entities.splice(index, 1);
        }
        else {
            throw new RangeError("invalid entity index");
        }
    }

    public function removeEntities(beginIndex:int = 0, endIndex:int = -1):void {
        if(endIndex < 0 || endIndex >= entityCount)
            endIndex = entityCount - 1;

        for(var i:int = beginIndex; i <= endIndex; ++i)
            removeEntityAt(beginIndex);
    }

    public function getEntityIndex(entity:Entity):int { return _entities.indexOf(entity); }
    public function setEntityIndex(entity:Entity, index:int):void {
        var oldIndex:int = getEntityIndex(entity);

        if (oldIndex == index) return;
        if (oldIndex == -1) throw new ArgumentError("not added to this MapNode");

        _entities.splice(oldIndex, 1);
        _entities.splice(index, 0, entity);
    }

    public function swapEntities(entityA:Entity, entityB:Entity):void {
        var indexA:int = getEntityIndex(entityA);
        var indexB:int = getEntityIndex(entityB);

        if (indexA == -1 || indexB == -1) throw new ArgumentError("not added to this MapNode");

        swapEntitiesAt(indexA, indexB);
    }

    public function swapEntitiesAt(indexA:int, indexB:int):void {
        var child1:Entity = getEntityAt(indexA);
        var child2:Entity = getEntityAt(indexB);

        _entities[indexA] = child2;
        _entities[indexB] = child1;
    }

    public function getEntityAt(index:int):Entity { return _entities[index]; }

    public function getEntityByClass(entityClass:Class):Entity {
        var count:int = _entities.length;
        for(var i:int = 0; i < count; ++i)
            if(_entities[i] is entityClass)
                return _entities[i];

        return null;
    }

    public function getEntitiesByClass(entityClass:Class, entities:Vector.<Entity> = null):Vector.<Entity> {
        if(entities == null) entities = new <Entity>[];

        var count:int = _entities.length;
        for(var i:int = 0; i < count; ++i)
            var n:Entity = _entities[i];

        if(n is entityClass)
            entities[entities.length] = n;

        return entities;
    }
}
}
