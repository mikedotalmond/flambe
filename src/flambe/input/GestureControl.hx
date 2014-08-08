package flambe.input;

import flambe.Component;
import flambe.input.Gesture.GestureType;
import flambe.input.PointerEvent;
import flambe.input.TouchPoint;
import flambe.math.Point;
import flambe.util.Signal1;
import flambe.util.SignalConnection;
import haxe.Timer;


@:final enum TouchType {
	TOUCH_BEGIN;
	TOUCH_MOVE;
	TOUCH_END;
}

@:final typedef TouchData = {
	var x:Float;
	var y:Float;
	var time:Float;
	var id:Int;
}

@:final enum GestureState {
	READY;
	BEGIN;
	TWO_FINGER_MOVE;
	MOVE;
}



@:final class GestureControl extends Component {

	static var mouseSupported				(get, null):Bool;
    public static var multitouchSupported	(get, null):Bool;
    public static var pointerSupported		(get, null):Bool;
	
    static var moveToleSqr		:Float = 1.0;
	
    public var longPressDelay	:Float = 1; // seconds
    public var swipeTimeout		:Float = .25; // can be zero, means no timeout
	
	public var preferPointer	:Bool = true; // user Pointer over Touch if(multitouchSupported && mouseSupported)
	
	public var gesture	(default, null):Signal1<Gesture>;
	
	var state			:GestureState;
    var gestures		:Map<GestureType,Gesture>;
	var touch0			:TouchData;
    var touch1			:TouchData;
	
    var touchList		:List<TouchData>;
    var longPressTimer	:Timer;
	
	var upConn			:SignalConnection;
	var downConn		:SignalConnection;
	var moveConn		:SignalConnection;
	var resizeConn		:SignalConnection;
	
	var touchTimes		:Map<Int,Float>;
	var tempPoint		:Point;
	
    public function new() {	
		
		tempPoint 	= new Point();
		gesture 	= new Signal1<Gesture>();
        touchList	= new List<TouchData>();
		touchTimes	= new Map<Int,Float>();
		gestures 	= createGestures();
    }
	
	
	override function onAdded() {
		
		if ((multitouchSupported && mouseSupported && preferPointer) || (!multitouchSupported && pointerSupported)) {
			System.pointer.down.connect(onPointerDown).once();
		} else if (multitouchSupported) {
			upConn 		= System.touch.up.connect(onTouchUp);
			downConn 	= System.touch.down.connect(onTouchDown);
			moveConn 	= System.touch.move.connect(onTouchMove);
		} else {
			throw "No Pointer or (multi)Touch inputs available?"; // can it happen?
		}
		
		resizeConn = System.stage.resize.connect(stageResized);
		stageResized();
		
		setReady();
	}
	 
	function onPointerDown(e:PointerEvent) {
		if (upConn != null) upConn.dispose();
		upConn = System.pointer.up.connect(onPointerUp);			
		
		if (moveConn != null) moveConn.dispose();
		moveConn = System.pointer.move.connect(onPointerMove);
		
		onTouch(TouchType.TOUCH_BEGIN, -1, e.viewX, e.viewY);
	}
	
	function onPointerMove(e:PointerEvent) onTouch(TouchType.TOUCH_MOVE, -1, e.viewX, e.viewY);
	
	function onPointerUp(e:PointerEvent) {
		moveConn.dispose(); moveConn = null;
		upConn.dispose(); upConn = null;
		
		onTouch(TouchType.TOUCH_END, -1, e.viewX, e.viewY);
		
		System.pointer.down.connect(onPointerDown).once();
	}
	
    
    function onTouchDown(e:TouchPoint) onTouch(TouchType.TOUCH_BEGIN, e.id, e.viewX, e.viewY);	
    function onTouchMove(e:TouchPoint) onTouch(TouchType.TOUCH_MOVE, e.id, e.viewX, e.viewY);
    function onTouchUp(e:TouchPoint) onTouch(TouchType.TOUCH_END, e.id, e.viewX, e.viewY);
	
	
	function stageResized() {
		var s = System.stage;
		moveToleSqr = Math.sqrt(s.width * s.width + s.height * s.height) * 0.008;
		moveToleSqr *= moveToleSqr;
    }
	
	
	override public function onRemoved() {
		if (resizeConn != null) resizeConn.dispose();
		if (upConn != null) upConn.dispose();
		if (downConn != null) downConn.dispose();
		if (moveConn != null) moveConn.dispose();
        setReady();
	}
	
	
    function setReady() {
        state = GestureState.READY;
        touch0 = touch1 = null;
        touchList.clear();
        cancelLongPress();
    }
	
	
    function onTouch(type:TouchType, id:Int, x:Float, y:Float) {
        var primary = (touch0 == null || touch0.id == id);
        if (primary || (touch1 != null && touch1.id == id) || (touch0 != null && touch1 == null && touch0.id != id)) {
			var tData = cast { time:Timer.stamp(), id:id, x:x, y:y };
			handleTouch(type, tData, primary);
        }
    }
	
	//get, set, and trigger a gesture
	inline function trigger(type:GestureType, x:Float, y:Float, ?extra:Dynamic=null) {
		gesture.emit(gestures.get(type).setTo(x, y, extra));
	}
	

    function handleTouch(type:TouchType, tData:TouchData , primary:Bool) : Bool {
       
		var now 	= tData.time;
		var x 		= tData.x;
		var y 		= tData.y;
		var tp 		= primary ? touch0 : touch1;
		
        if (type == TouchType.TOUCH_MOVE && tp != null && distSqr(tData, tp) < moveToleSqr) return false; // NO MOVE -> skip
        var handled = true;
		
		var g:Gesture;
		
		switch (state) {
			
			case GestureState.READY:
				
				if (primary && type == TouchType.TOUCH_BEGIN) {
					state = BEGIN;
					touch0 = tData;
					touchTimes.set(tData.id, now);
					longPressTimer = Timer.delay(sendLongPress.bind(tData), Std.int(longPressDelay * 1000));
				} else {
					handled = false;
				}
				
			case GestureState.BEGIN:
				if (primary && type == TouchType.TOUCH_END) {
					trigger(GestureType.GESTURE_TAP, x, y);
					setReady();
				} else if (primary && type == TouchType.TOUCH_MOVE) {
					tempPoint.set(x - touch0.x, y - touch0.y);
					trigger(GestureType.GESTURE_PAN, x, y, tempPoint);
					setMove(tData);
				} else if (!primary && type == TouchType.TOUCH_BEGIN) {
					setTwoFingerMove(tData);
				} else {
					handled = false;
				}
				
			case GestureState.MOVE:
				if (primary && type == TouchType.TOUCH_MOVE) {
					tempPoint.set(x - touch0.x, y - touch0.y);
					trigger(GestureType.GESTURE_PAN, x, y, tempPoint);
					setMove(tData);
				} else if (primary && (type == TouchType.TOUCH_END)) {
					
					var dt = now - touchTimes.get(touch0.id);
					
					if (swipeTimeout <= 0 || dt < swipeTimeout) {
						
						var beginpt 	= touchList.pop();
						var beginTime 	= touchTimes.get(beginpt.id);
						touchTimes.remove(beginpt.id);
						
						var dx = beginpt.x - tp.x;
						var	dy = beginpt.y - tp.y;
						var angle = Math.atan2(dy, dx);
						var len   = Math.sqrt(dx * dx + dy * dy);
						
						polar(tempPoint, len / -dt, angle);
						trigger(GestureType.GESTURE_SWIPE, x, y, tempPoint);
					}
					setReady();
				} else if (!primary && type == TouchType.TOUCH_BEGIN) {
					trigger(GestureType.GESTURE_BEGIN, x, y);
					setTwoFingerMove(tData);
				} else {
					handled = false;
				}
				
			case GestureState.TWO_FINGER_MOVE:
				
				if (type == TouchType.TOUCH_END) {
					trigger(GestureType.GESTURE_END, x, y);
					setReady();
				} else if (type == TouchType.TOUCH_MOVE) {
					var pt1 	= primary ? touch1 : touch0;
					var pt2		= primary ? touch0 : touch1;
					var scale	= distSqr(tData, pt1) / distSqr(pt2, pt1);
					var angle 	= Math.atan2(y - pt1.y, x - pt1.x) - Math.atan2(pt2.y - pt1.y, pt2.x - pt1.x);
					var midX 	= lerp(pt1.x, pt2.x, 0.5);
					var midY 	= lerp(pt1.y, pt2.y, 0.5);
					if (scale != 1) trigger(GestureType.GESTURE_PINCH, midX, midY, scale);
					if (angle != 0) trigger(GestureType.GESTURE_ROTATION, midX, midY, angle);
					//TODO:2-finger pan
					if (primary) touch0 = tData; else touch1 = tData;
				} else {
					handled = false;
				}
			}
			
        return handled;
    }
	
	
    inline function sendLongPress(t:TouchData) {
        trigger(GestureType.GESTURE_LONG_PRESS, t.x, t.y);
		setReady();
    }

	
    inline function setMove(t:TouchData) {
        state = GestureState.MOVE;
        if (touch0 != null) touchList.push(touch0);
        touch0 = t;
        cancelLongPress();
    }
	
	
    inline function setTwoFingerMove(t:TouchData) {
        state = GestureState.TWO_FINGER_MOVE;
        touch1 = t;
        cancelLongPress();
    }
	
	
    inline function cancelLongPress() {
        if (longPressTimer != null) {
            longPressTimer.stop();
            longPressTimer = null;
        }
    }
	
	
	inline static function polar(pt:Point, len:Float, angle:Float) {
		pt.set(len * Math.cos(angle), len * Math.sin(angle));
	}
	
	
	inline static function lerp(a:Float, b:Float, f:Float):Float {
		return b + f * (a - b);
	}
	
	
    inline function distSqr(a:TouchData, b:TouchData):Float {
		var dx = b.x - a.x;
		var	dy = b.y - a.y;
        return dx * dx + dy * dy;
    }
	
	
	inline static function get_mouseSupported():Bool return System.mouse.supported;	
	inline static function get_pointerSupported():Bool return System.pointer.supported;	
	inline static function get_multitouchSupported():Bool return System.touch.supported && System.touch.maxPoints > 1;	
	
	// create map of GestureType to Gesture instances for the given enum types, or all of them if null
	function createGestures(?types:Array<GestureType>=null):Map<GestureType,Gesture> {
		if (types == null) types = Type.allEnums(GestureType);
		var map = new Map<GestureType,Gesture>();
		for (type in types) map.set(type, new Gesture(type, Math.NaN, Math.NaN));
		return map;
	}
}