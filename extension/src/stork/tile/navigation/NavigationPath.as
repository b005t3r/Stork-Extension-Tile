/**
 * User: booster
 * Date: 04/03/14
 * Time: 11:19
 */
package stork.tile.navigation {
import medkit.collection.HashSet;
import medkit.collection.TreeSet;

public class NavigationPath {
    public var length:int                       = 0;
    public var nodes:Vector.<NavigationNode>    = new <NavigationNode>[];
    public var complete:Boolean                 = false;

    internal var openNodes:TreeSet              = new TreeSet();
    internal var closedNodes:HashSet            = new HashSet();

    public function reset():void {
        for(var i:int = 0; i < length; ++i)
            nodes[i] = null;

        length = 0;

        openNodes.clear();
        closedNodes.clear();

        complete = false;
    }
}
}
