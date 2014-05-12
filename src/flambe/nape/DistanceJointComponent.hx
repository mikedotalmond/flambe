package flambe.nape;

import flambe.Component;
import flambe.display.Sprite;
import flambe.math.FMath;

import nape.constraint.DistanceJoint;
import nape.geom.Vec2;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
@:final class DistanceJointComponent extends Component {

    static inline var PI2 :Float = FMath.PI / 2;

	var sprite:Sprite;
    var joint :DistanceJoint;


	public function new (joint:DistanceJoint) {
        this.joint = joint;
    }

	override public function onAdded() {
		sprite = owner.get(Sprite);
	}


    override public function onUpdate (dt :Float) {

		if(joint.active) {
            var pos1 	= joint.body1.localPointToWorld(joint.anchor1);
            var pos2 	= joint.body2.localPointToWorld(joint.anchor2);
			var length 	= Vec2.distance(pos1, pos2);
			var angle 	= Math.atan2(pos1.y - pos2.y, pos1.x - pos2.x) + PI2;

			if (sprite == null) sprite = owner.get(Sprite);
            sprite.x._ 			= pos1.x;
            sprite.y._ 			= pos1.y;
            sprite.scaleY._ 	= length / sprite.getNaturalHeight();
            sprite.rotation._ 	= FMath.toDegrees(angle);
        }
    }

    override public function onRemoved () {
        // Remove from the space
        joint.space = null;
    }
}
