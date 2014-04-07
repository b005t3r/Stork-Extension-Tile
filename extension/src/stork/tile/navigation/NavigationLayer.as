/**
 * User: booster
 * Date: 19/02/14
 * Time: 12:49
 */
package stork.tile.navigation {
import medkit.collection.HashSet;
import medkit.collection.TreeSet;

import stork.tile.MapLayer;

public class NavigationLayer extends MapLayer {
    public static function manhattanTravelCost(startNode:NavigationNode, destinationNode:NavigationNode, commonCost:Number = 1.0, commonDiagonalCost:Number = 1.0):Number {
        return Math.abs(startNode.column - destinationNode.column) * commonCost + Math.abs(startNode.row + destinationNode.row) * commonCost;
    }

    public static function euclidianTravelCost(node:NavigationNode, destinationNode:NavigationNode, commonCost:Number = 1.0, commonDiagonalCost:Number = 1.0):Number {
        var dx:Number = node.column - destinationNode.column;
        var dy:Number = node.row - destinationNode.row;

        return Math.sqrt(dx * dx + dy * dy) * commonCost;
    }

    public static function diagonalTravelCost(node:NavigationNode, destinationNode:NavigationNode, commonCost:Number = 1.0, commonDiagonalCost:Number = 1.0):Number {
        var dx:Number = Math.abs(node.column - destinationNode.column);
        var dy:Number = Math.abs(node.row - destinationNode.row);

        var diagonal:Number = dx < dy ? dx : dy;
        var straight:Number = dx + dy;

        return commonDiagonalCost * diagonal + commonCost * (straight - 2 * diagonal);
    }

    public static function nonDiagonalConnectedNodes(node:NavigationNode, navigationLayer:NavigationLayer, result:Vector.<NavigationNode>):void {
        var c:int, r:int, cost:Number, adjacentTile:INavigationTile, currentTile:INavigationTile = navigationLayer.getTileAt(node.column, node.row) as INavigationTile;

        if(currentTile == null) {
            result[0] = result[1] = result[2] = result[3] = null;
            return;
        }

        // left
        c = node.column - 1; r = node.row;

        if(c >= 0) {
            adjacentTile = navigationLayer.getTileAt(c, r) as INavigationTile;
            cost = adjacentTile != null ? currentTile.leaveCost(-1, 0) + adjacentTile.enterCost(1, 0) : Infinity;

            result[0] = isFinite(cost) ? new NavigationNode(c, r, cost) : null;
        }
        else {
            result[0] = null;
        }

        // right
        c = node.column + 1; r = node.row;

        if(c < navigationLayer.horizontalTileCount) {
            adjacentTile = navigationLayer.getTileAt(c, r) as INavigationTile;
            cost = adjacentTile != null ? currentTile.leaveCost(1, 0) + adjacentTile.enterCost(-1, 0) : Infinity;

            result[1] = isFinite(cost) ? new NavigationNode(c, r, cost) : null;
        }
        else {
            result[1] = null;
        }

        // up
        c = node.column; r = node.row - 1;

        if(r >= 0) {
            adjacentTile = navigationLayer.getTileAt(c, r) as INavigationTile;
            cost = adjacentTile != null ? currentTile.leaveCost(0, -1) + adjacentTile.enterCost(0, 1) : Infinity;

            result[2] = isFinite(cost) ? new NavigationNode(c, r, cost) : null;
        }
        else {
            result[2] = null;
        }

        // down
        c = node.column; r = node.row + 1;

        if(r >= 0) {
            adjacentTile = navigationLayer.getTileAt(c, r) as INavigationTile;
            cost = adjacentTile != null ? currentTile.leaveCost(0, 1) + adjacentTile.enterCost(0, -1) : Infinity;

            result[3] = isFinite(cost) ? new NavigationNode(c, r, cost) : null;
        }
        else {
            result[3] = null;
        }
    }

    private var _alpha:Number                       = 0.5;
    private var _commonTravelCost:Number            = 1.0;
    private var _commonDiagonalTravelCost:Number    = 1.0;

    private var _heuristicCostFunction:Function     = euclidianTravelCost;
    private var _connectedNodesFunction:Function    = nonDiagonalConnectedNodes;

    public function NavigationLayer(name:String, horizontalTileCount:int, verticalTileCount:int, tileWidth:Number, tileHeight:Number, horizontalOffset:Number = 0, verticalOffset:Number = 0) {
        super(name, horizontalTileCount, verticalTileCount, tileWidth, tileHeight, horizontalOffset, verticalOffset);
    }

    public function get alpha():Number { return _alpha; }
    public function set alpha(value:Number):void { _alpha = value; }

    public function get commonTravelCost():Number { return _commonTravelCost; }
    public function set commonTravelCost(value:Number):void { _commonTravelCost = value; }

    public function get commonDiagonalTravelCost():Number { return _commonDiagonalTravelCost; }
    public function set commonDiagonalTravelCost(value:Number):void { _commonDiagonalTravelCost = value; }

    public function get heuristicCostFunction():Function { return _heuristicCostFunction; }
    public function set heuristicCostFunction(value:Function):void { _heuristicCostFunction = value; }

    public function get connectedNodesFunction():Function { return _connectedNodesFunction; }
    public function set connectedNodesFunction(value:Function):void { _connectedNodesFunction = value; }

    public function findPath(startX:int, startY:int, endX:int, endY:int, maxIterations:int = int.MAX_VALUE, path:NavigationPath = null):NavigationPath {
        if(path == null)            path = new NavigationPath();
        else if(path._length > 0)    path.reset();

        var startNode:NavigationNode = new NavigationNode(startX, startY, 0);

        path._length = 1;
        path._nodes[0] = startNode;

        continueSearch(endX, endY, path, maxIterations);

        return path;
    }

    public function continueSearch(endX:int, endY:int, path:NavigationPath, maxIterations:int = int.MAX_VALUE):Boolean {
        if(path._length == 0)
            throw new ArgumentError("path must contain at least one node");

        // this path is already complete
        if(path.complete)
            return false;

        var startNode:NavigationNode = path._nodes[path._length - 1];
        path._length -= 1;

        var destinationNode:NavigationNode = new NavigationNode(endX, endY);

        var connectedNodes:Vector.<NavigationNode> = new Vector.<NavigationNode>(4, true);

        var oneMinusAlpha:Number = 1.0 - _alpha;

        var openNodes:TreeSet = path._openNodes;
        var closedNodes:HashSet = path._closedNodes;

        openNodes.clear(); // reset open nodes - continuing the search is the same as starting a new search really
        //closedNodes.clear(); // don't reset closed nodes, so we won't be going back and forth each call

        // let's assume we can find the path on one go
        path._complete = true;

        openNodes.add(startNode);

        var currentNode:NavigationNode = startNode;

        while(currentNode.column != endX || currentNode.row != endY) {
            if(openNodes.size() == 0 || maxIterations == 0) {
                path._complete = false; // path still incomplete
                break;
            }

            currentNode = openNodes.pollFirst();

            _connectedNodesFunction(currentNode, this, connectedNodes);

            var connectedCount:int = connectedNodes.length;
            for(var i:int = 0; i < connectedCount; ++i) {
                var testNode:NavigationNode = connectedNodes[i];
                connectedNodes[i] = null;

                if(testNode == null || testNode == currentNode || closedNodes.contains(testNode))
                    continue;

                var costFromStart:Number        = currentNode.currentCostFromStart + testNode.travelCost;
                var estimatedCostToEnd:Number   = _heuristicCostFunction(testNode, destinationNode, _commonTravelCost, _commonDiagonalTravelCost);
                var estimatedTotalCost:Number   = _alpha * costFromStart + oneMinusAlpha * estimatedCostToEnd;

                testNode.currentCostFromStart   = costFromStart;
                testNode.estimatedCostToEnd     = estimatedCostToEnd;
                testNode.estimatedTotalCost     = estimatedTotalCost;
                testNode.parent                 = currentNode;

                if(openNodes.contains(testNode))
                    continue;

                openNodes.add(testNode);
            }

            closedNodes.add(currentNode);
            --maxIterations;
        }

        var count:int = 0, nodes:Vector.<NavigationNode> = path._nodes;
        while(currentNode != null) {
            if(count == path._nodes.length)
                path.ensureCapacity(count + 1);

            nodes[count++]  = currentNode;
            currentNode     = currentNode.parent;
        }

        // reverse result
        for(var left:int = 0, right:int = count - 1; left < right; ++left, --right) {
            var tmp:NavigationNode  = nodes[left];
            nodes[left]             = nodes[right];
            nodes[right]            = tmp;
        }

        path._length = count;

        // if there still is a chance and need to complete this path, return true; false otherwise
        return ! path.complete && openNodes.size() > 0;
    }
}
}
