/**
 * User: booster
 * Date: 06/03/14
 * Time: 8:38
 */
package stork.game.navigation {
import flash.geom.Point;

import medkit.geom.GeomUtil;

import medkit.geom.GeomUtil;

import stork.game.GameActionNode;
import stork.tile.Entity;
import stork.tile.navigation.NavigationLayer;
import stork.tile.navigation.NavigationNode;
import stork.tile.navigation.NavigationPath;

public class FollowPathActionNode extends GameActionNode {
    private static var _pointA:Point = new Point();
    private static var _pointB:Point = new Point();

    private var _path:NavigationPath;
    private var _layer:NavigationLayer;
    private var _entity:Entity;
    private var _speed:Number; // pixels per second

    private var _nextSegmentIndex:int = 0;
    private var _tileWidth:Number;
    private var _tileHeight:Number;

    public function FollowPathActionNode(entity:Entity, speed:Number, path:NavigationPath, navigationLayer:NavigationLayer, name:String = "FollowPathActionNode") {
        super(name);

        _path   = path;
        _layer  = navigationLayer;
        _entity = entity;
        _speed  = speed;

        _tileWidth  = _layer.tileWidth;
        _tileHeight = _layer.tileHeight;
    }

    override protected function actionStarted():void {
        _entity.x = _path[0].column * _tileWidth + _tileWidth / 2;
        _entity.y = _path[0].row * _tileHeight + _tileHeight / 2;
    }

    override protected function stepStarted():void { ++_nextSegmentIndex; }

    override protected function actionUpdated(dt:Number):void {
        var prevNode:NavigationNode = _path[_nextSegmentIndex - 1];
        var nextNode:NavigationNode = _path[_nextSegmentIndex];

        var startX:Number   = prevNode.column * _tileWidth + _tileWidth / 2,    startY:Number = prevNode.row * _tileHeight + _tileHeight / 2;
        var endX:Number     = nextNode.column * _tileWidth + _tileWidth/ 2,     endY:Number   = nextNode.row * _tileHeight + _tileHeight / 2;

        _pointA.setTo(startX, startY);
        _pointB.setTo(_entity.x, _entity.y);

        var currDistance:Number = GeomUtil.distanceBetweenPoints(_pointA, _pointB);

        _pointB.setTo(endX, endY);

        var totalDistance:Number = GeomUtil.distanceBetweenPoints(_pointA, _pointB);
        var travelAngle:Number = GeomUtil.angleBetweenPoints(_pointA, _pointB);

        var timeNeeded:Number = timeToFinish(_speed, 0, currDistance, totalDistance);

        var travelDistance:Number;

        if(timeNeeded > dt) {
            travelDistance = nextValue(_speed, dt, 0, currDistance, totalDistance);

            _entity.x = startX + Math.sin(travelAngle) * travelDistance;
            _entity.y = startY + -Math.cos(travelAngle) * travelDistance; // y-axis is going down
        }
        else {
            _entity.x = endX;
            _entity.y = endY;

            if(_path.length > _nextSegmentIndex + 1)
                finishStep(timeNeeded);
            else
                finishAction();
        }
    }

    private function timeToFinish(ratio:Number, start:Number, value:Number, end:Number):Number {
        if(end <= value)
            return 0;

        var diff:Number = end - value;

        return diff / ratio;
    }

    private function nextValue(ratio:Number, dt:Number, start:Number, value:Number, end:Number):Number {
        return value + ratio * dt;
    }
}
}
