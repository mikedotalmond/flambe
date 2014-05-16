package flambe.nape;

import flambe.Component;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.math.FMath;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;


/**
 * Tracks a Nape phyiscs body, and updates the placement of the entity's Sprite.
 *
 * @author Mike Almond - https://github.com/mikedotalmond
 */

@:keep
class BodyComponent extends Component {

	var space:Space;
	var world:Entity;

    public var body(default, null):Body;
	public var bounds(default, null):AABB;

	/**
	 * Reference to the sprite associated with this BodyComponent
	 */
    public var sprite(default, null):Sprite;
	
	/**
	 * 
	 * @param	target
	 */
	public function setTargetSprite(target:Sprite) sprite = target;

	/**
	 *
	 * @param	body
	 * @param	?bounds - optional - bodies will be removed from the Space if/when they exit the supplied bounds
	 */
    public function new (world:Entity, body:Body, ?bounds:AABB=null) {
        this.world 	= world;
        this.body 	= body;
		this.bounds = bounds;
    }

	override public function onAdded() {
		space		= world.get(SpaceComponent).napeSpace;
		sprite 		= owner.get(Sprite);
		body.space 	= space;
	}

	var scaleX:Float = 1;
	var scaleY:Float = 1;
	public function setScale(x, y) {
		body.scaleShapes(1 / scaleX, 1 / scaleY);
		sprite.scaleX._ = scaleX = x;
		sprite.scaleY._ = scaleY = y;
		body.scaleShapes(x,y);
	}
	
    override public function onUpdate (dt :Float) {
        var pos = body.position;

        if (bounds != null && (pos.x <  bounds.min.x || pos.y <  bounds.min.y || pos.x >  bounds.max.x || pos.y >  bounds.max.y)) {
			owner.dispose();
		} else {
			sprite.x._ = pos.x;
            sprite.y._ = pos.y;
            sprite.rotation._ = FMath.toDegrees(body.rotation);
		}
    }

    override public function onRemoved () {
        // Remove this body from the space
        body.space = null;
    }
}

