/**
 * User: booster
 * Date: 19/02/14
 * Time: 12:49
 */
package stork.tile.navigation {
import stork.tile.MapLayer;

public class NavigationLayer extends MapLayer {
    public static function manhattanTravelCost(startNode:NavigationNode, destinationNode:NavigationNode, commonCost:Number = 1.0, commonDiagonalCost:Number = 1.0):Number {
        return Math.abs(startNode.column - destinationNode.column) * commonCost + Math.abs(startNode.row + destinationNode.row) * commonCost;
    }

    public static function euclidianTravelCost(node:NavigationNode, destinationNode:NavigationNode, cost:Number = 1.0, commonDiagonalCost:Number = 1.0):Number {
        var dx:Number = node.column - destinationNode.column;
        var dy:Number = node.row - destinationNode.row;

        return Math.sqrt(dx * dx + dy * dy) * cost;
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

        // left
        c = node.column - 1; r = node.row;

        if(c >= 0) {
            adjacentTile = navigationLayer.getTileAt(c, r) as INavigationTile;
            cost = currentTile.leaveCost(-1, 0) + adjacentTile.enterCost(1, 0);

            result[0] = isFinite(cost) ? new NavigationNode(c, r, cost) : null;
        }
        else {
            result[0] = null;
        }

        // right
        c = node.column + 1; r = node.row;

        if(c < navigationLayer.horizontalTileCount) {
            adjacentTile = navigationLayer.getTileAt(c, r) as INavigationTile;
            cost = currentTile.leaveCost(1, 0) + adjacentTile.enterCost(-1, 0);

            result[1] = isFinite(cost) ? new NavigationNode(c, r, cost) : null;
        }
        else {
            result[1] = null;
        }

        // up
        c = node.column; r = node.row - 1;

        if(r >= 0) {
            adjacentTile = navigationLayer.getTileAt(c, r) as INavigationTile;
            cost = currentTile.leaveCost(0, -1) + adjacentTile.enterCost(0, 1);

            result[2] = isFinite(cost) ? new NavigationNode(c, r, cost) : null;
        }
        else {
            result[2] = null;
        }

        // down
        c = node.column; r = node.row + 1;

        if(r >= 0) {
            adjacentTile = navigationLayer.getTileAt(c, r) as INavigationTile;
            cost = currentTile.leaveCost(0, 1) + adjacentTile.enterCost(0, -1);

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

    public function findPath(startX:int, startY:int, endX:int, endY:int, result:Vector.<NavigationNode> = null):Vector.<NavigationNode> {
        var destinationNode:NavigationNode = new NavigationNode(endX, endY);

        var currentNode:NavigationNode = new NavigationNode(startX, startY, 0);
        var connectedNodes:Vector.<NavigationNode> = new Vector.<NavigationNode>(4, true);

        var oneMinusAlpha:Number = 1.0 - _alpha;
        var commonDivider:Number = _alpha >= oneMinusAlpha ? _alpha : oneMinusAlpha;

        var openNodes:Vector.<NavigationNode> = new <NavigationNode>[currentNode];
        var closedNodes:Vector.<NavigationNode> = new <NavigationNode>[];

        while(currentNode.column != endX || currentNode.row != endY) {
            if(openNodes[0] == null)
                return null;

            currentNode         = openNodes[openNodes.length - 1];
            openNodes.length   -= 1;

            _connectedNodesFunction(currentNode, this, connectedNodes);

            var connectedCount:int = connectedNodes.length;
            for(var i:int = 0; i < connectedCount; ++i) {
                var testNode:NavigationNode = connectedNodes[i];

                if(testNode == null || testNode == currentNode /*|| testNode.travesable == false*/)
                    continue;

                connectedNodes[i] = null;

                var costFromStart:Number        = currentNode.currentCost + testNode.travelCost;
                var estimatedCostToEnd:Number   = _heuristicCostFunction(testNode, destinationNode, _commonTravelCost, _commonDiagonalTravelCost);
                var estimatedTotalCost:Number   = (_alpha * costFromStart + oneMinusAlpha * estimatedCostToEnd) / commonDivider;

                testNode.currentCost        = costFromStart;
                testNode.estimatedTotalCost = estimatedTotalCost;
                testNode.parent             = currentNode;

                // TODO: change openNodes to TreeSet and closedNodes to HashSet
                if(! contains(testNode, openNodes) && ! contains(testNode, closedNodes))
                    openNodes[openNodes.length] = testNode;
            }

            closedNodes[closedNodes.length] = currentNode;

            openNodes.sort(function(nodeA:NavigationNode, nodeB:NavigationNode):Number {
                return nodeB.estimatedTotalCost - nodeA.estimatedTotalCost
            });
        }

        if(result == null)
            result = new <NavigationNode>[];

        var count:int = 0;
        while(currentNode != null) {
            result[count++] = currentNode;
            currentNode = currentNode.parent;
        }

        // reverse result
        for(var left:int = 0, right:int = count - 1; left < right; ++left, --right) {
            var tmp:NavigationNode  = result[left];
            result[left]            = result[right];
            result[right]           = tmp;
        }

        return result;
    }

    private function contains(node:NavigationNode, nodes:Vector.<NavigationNode>):Boolean {
        var count:int = nodes.length;
        for(var i:int = 0; i < count; i++) {
            var n:NavigationNode = nodes[i];

            if(n == null)
                continue;

            if(n.column == node.column && n.row == node.row)
                return true;
        }

        return false;
    }
}
}

