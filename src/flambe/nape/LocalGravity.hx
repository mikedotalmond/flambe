package flambe.nape;

import flambe.Component;
import flambe.input.Acceleration;
import flambe.System;
import nape.geom.Vec2;
import nape.space.Space;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class LocalGravity extends Component {
	
	var fx:Float;
	var fy:Float;

	public function new(fx, fy) {
		this.fx = fx;
		this.fy = fy;
	}
	
	override public function onAdded() {
		
		var space:Space = owner.get(SpaceComponent).napeSpace;
		
		if(System.motion.accelerationSupported){
			System.motion.accelerationIncludingGravity.connect(function(acc:Acceleration) {
				if (fx != 0) space.gravity.x = acc.x * fx;
				if (fy != 0) space.gravity.y = acc.y * fy;
			});
		}
	}	
}