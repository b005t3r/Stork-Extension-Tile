/**
 * User: booster
 * Date: 03/03/14
 * Time: 13:43
 */
package stork.tile.navigation {
import medkit.object.Comparable;
import medkit.object.Equalable;
import medkit.object.Hashable;

public class NavigationNode implements Equalable, Comparable, Hashable {
    /** How much it currently costs to get from start to this node. */
    public var currentCostFromStart:Number = 0.0;

    /** How much we guess it's going yo cost to get from this node to the end. */
    public var estimatedCostToEnd:Number = 0.0;

    /** How much we guess it's going to cost to get from the start to the end through this node. */
    public var estimatedTotalCost:Number = 0.0;

    /** Grid coordinates. */
    public var column:int, row:int;

    /** How much traveling through this node costs. */
    public var travelCost:Number;

    /** Node used to travel to this node. */
    public var parent:NavigationNode;

    /**
     * Creates a new NavigationNode.
     * @param column        column in grid coordinates
     * @param row           row in grid coordinates
     * @param travelCost    cost of traveling through this node @default 1.0
     */
    public function NavigationNode(column:int, row:int, travelCost:Number = 1.0) {
        this.column = column;
        this.row = row;
        this.travelCost = travelCost;
    }

    public function equals(object:Equalable):Boolean {
        var node:NavigationNode = object as NavigationNode;

        if(node == null)
            return false;

        return node.column == column && node.row == row;
    }

    /** Compares two nodes using estimatedTotalCost. */
    public function compareTo(object:Comparable):int {
        var node:NavigationNode = object as NavigationNode;
        //var result:Number = estimatedTotalCost - node.estimatedTotalCost;
        var result:Number = estimatedTotalCost - node.estimatedTotalCost;

        if(result > 0.0)        return 1;
        else if(result < 0.0)   return -1;

        // from now on we just try not to remove nodes with the same cost, but describing different cells
        result = column - node.column;

        if(result > 0.0)        return 1;
        else if(result < 0.0)   return -1;

        result = row - node.row;

        if(result > 0.0)        return 1;
        else if(result < 0.0)   return -1;

        // column and row are the same, we can remove this node
        return 0;
    }

    public function hashCode():int {
        //return column + row * 31;
        //return column >= row ? column * column + column + row : column + row * row; // column & row >= 0
        return ((column << 16) | row);
    }
}
}
