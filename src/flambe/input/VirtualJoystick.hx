package flambe.input;

import flambe.Component;
import flambe.math.FMath;
import flambe.math.Point;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class VirtualJoystick extends Component {
	
	var origin				:Point;
	var position			:Point;
	var dx					:Float;
	var dy					:Float;
	var minDistanceSquared	:Float;
	var maxDistanceSquared	:Float;
	var lengthSquared		:Float;
	
	
	public var inRange			(default, null):Bool;
	public var inDeadZone		(default, null):Bool;
	
	public var normalisedLength	(default, null):Float; // normalised length within the min/max distance range
	public var angle			(default, null):Float; //
	
	public var minDistance(get, set):Float; // dead-zone for pointer delta
	public var maxDistance(get, set):Float; // max range for pointer delta - for distances beyond this range, the delta is zeroed
	
	
	public function new() {		
		origin				= new Point();
		position 			= new Point();
	}
	
	
	override public function onAdded() {
		dx = dy 			= 0.0;
		minDistance 		= 2;
		maxDistance			= 32;		
		centre();
	}
	
	
	public function setOrigin(x:Float, y:Float) {
		origin.set(x, y);
		return this;
	}
	
	
	public function setPosition(x:Float, y:Float) {
		
		position.x 	= x;
		position.y 	= y;
		
		dx 				= origin.x - position.x;
		dy 				= origin.y - position.y;
		
		lengthSquared 	= dx * dx + dy * dy;
		angle			= Math.atan2(dy, dx) + FMath.PI;
		
		inDeadZone		= lengthSquared <= minDistanceSquared;
		inRange 		= inDeadZone && (lengthSquared <= maxDistanceSquared);
		
		if (inDeadZone) {
			normalisedLength = 0;
		} else if(inRange) {
			normalisedLength = (lengthSquared - minDistanceSquared) / (maxDistanceSquared - minDistanceSquared);
		} else {
			normalisedLength = 1;
		}
		
		return this;
	}
	
	
	/**
	 * reset stick position to the origin
	 */
	public function centre() {
		setPosition(origin.x, origin.y);
		return this;
	}	
	
	
	//
	
	
	var _minDistance:Float;
	inline function get_minDistance():Float return _minDistance;
	function set_minDistance(value:Float):Float {
		minDistanceSquared = value * value;
		return _minDistance = value;
	}
	
	var _maxDistance:Float;
	inline function get_maxDistance():Float return _maxDistance;
	function set_maxDistance(value:Float):Float {
		maxDistanceSquared = value * value;
		return _maxDistance = value;
	}
}