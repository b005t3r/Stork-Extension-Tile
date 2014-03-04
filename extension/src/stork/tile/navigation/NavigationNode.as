/**
 * User: booster
 * Date: 03/03/14
 * Time: 13:43
 */
package stork.tile.navigation {

public class NavigationNode {
    /** How much we guess it's going to cost to get from the start to the end through this node. */
    public var estimatedTotalCost:Number = 0.0;

    /** How much it currently costs to get from start to this node. */
    public var currentCost:Number = 0.0;

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
}
}
