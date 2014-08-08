package flambe.input;

@:final enum GestureType {
	GESTURE_TAP;
	GESTURE_LONG_PRESS;
	GESTURE_PAN;
	GESTURE_SWIPE;
	GESTURE_BEGIN;
	GESTURE_END;
	GESTURE_PINCH;
	GESTURE_ROTATION;
	//GESTURE_TWO_FINGER_PAN; //TODO:GESTURE_TWO_FINGER_PAN
}

@:allow(flambe.input)
@:final class Gesture {
	
	public var type	(default, null):GestureType;	
    public var x	(default, null):Float;
    public var y	(default, null):Float;
    public var extra(default, null):Dynamic;
	
	function new(type:GestureType, x:Float, y:Float, ?extra:Dynamic = null) {
		this.type 			= type;
		this.x 				= x;
        this.y 				= y;
        this.extra 			= extra;
    }
	
	public function clone():Gesture return new Gesture(type, x, y, extra);
	
    public function toString():String return '${type} x:${x}, y:${y}, extra=${extra}';
	
	inline function setTo(x:Float, y:Float, ?extra:Dynamic = null):Gesture {
		this.x = x; this.y = y;
		this.extra = extra;
		return this;
	}
}

