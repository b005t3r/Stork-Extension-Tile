/**
 * User: booster
 * Date: 04/03/14
 * Time: 11:19
 */
package stork.tile.navigation {
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import medkit.collection.HashSet;
import medkit.collection.TreeSet;

use namespace flash_proxy;

public class NavigationPath extends Proxy {
    internal var _length:int                        = 0;
    internal var _nodes:Vector.<NavigationNode>     = new <NavigationNode>[];
    internal var _complete:Boolean                  = false;

    internal var _openNodes:TreeSet                 = new TreeSet();
    internal var _closedNodes:HashSet               = new HashSet();

    public function reset():void {
        for(var i:int = 0; i < _length; ++i)
            _nodes[i] = null;

        _length = 0;

        _openNodes.clear();
        _closedNodes.clear();

        _complete = false;
    }

    override flash_proxy function getProperty(name:*):* { return _nodes[name]; }
    override flash_proxy function nextNameIndex(index:int):int { return index < _length ? index + 1 : 0; }
    override flash_proxy function nextName(index:int):String { return (index - 1).toString(); }
    override flash_proxy function nextValue(index:int):* { return _nodes[index - 1]; }

    public function get length():int { return _length; }
    public function get complete():Boolean { return _complete; }

    internal function ensureCapacity(minCapacity:int):void {
        var oldCapacity:int = _nodes.length;

        if (minCapacity > oldCapacity) {
            var newCapacity:int = (oldCapacity * 5) / 4 + 10;

            if (newCapacity < minCapacity)
                newCapacity = minCapacity;

            _nodes.length = newCapacity;
        }
    }
}
}
