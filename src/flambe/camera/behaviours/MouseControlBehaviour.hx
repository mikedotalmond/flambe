package flambe.camera.behaviours;

import flambe.animation.Ease;
import flambe.camera.behaviours.CameraControlBehaviour;
import flambe.camera.Camera;
import flambe.camera.CameraController;
import flambe.input.Key;
import flambe.input.MouseButton;
import flambe.math.Point;
import flambe.math.Rectangle;

import flambe.input.MouseEvent;
import flambe.util.SignalConnection;

/**
 * Basic Mouse based controls for the camera, probably just useful for dev/test
 * 
 * @author Mike Almond - https://github.com/mikedotalmond
 */
@:final class MouseControlBehaviour extends CameraControlBehaviour {
	
	var lastX					:Float = .0; 
	var lastY					:Float = .0;
	var x						:Float = .0; 
	var y						:Float = .0;
	var mouseMoved				:Bool = false;
	
	var mouseMoveConnection		:SignalConnection;
	var mouseDownConnection		:SignalConnection;
	var mouseUpConnection		:SignalConnection;
	var mouseScrollConnection	:SignalConnection;

	var bounds					:Rectangle;
	
	/**
	 * 
	 * @param	camera
	 * */
	public function new(camera:Camera, ?bounds:Rectangle=null) {
		this.bounds = bounds;
		super(camera);
	}
	
	
	/**
	 * preprocess pan delta-x to be applied; clamp to bounds and return 
	 * @param	dx
	 * @return
	 */
	function validatePanX(dx:Float):Float {
		if(_enabled && bounds!=null){
			if (dx < 0) { // moving right
				if (camera.visibleBounds.right - bounds.right > 0) return 0;
			} else if (dx > 0) { // moving left
				if (camera.visibleBounds.left - bounds.left < 0) return 0;
			}
		}
		return dx;
	}
	
	
	/**
	 *  preprocess pan delta-y to be applied; clamp to bounds and return
	 * @param	dy
	 * @return
	 */
	function validatePanY(dy:Float):Float {
		if(_enabled && bounds!=null){
			if (dy < 0) { // moving down
				if (camera.visibleBounds.bottom - bounds.bottom > 0) return 0;
			} else if (dy > 0) { // moving up
				if (camera.visibleBounds.top - bounds.top < 0) return 0;
			}
		}
		return dy;
	}

	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- *
	 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
	override public function update(dt:Float):Void {
		if (mouseMoved) {
			mouseMoved = false;
			
			var c = controller;
			var z = c.zoom._;
			
			var dx 	= (x - lastX) / z;
			var dy 	= (y - lastY) / z;
			
			lastX = x;
			lastY = y;
			
			c.panX._ += validatePanX(dx);
			c.panY._ += validatePanY(dy);
		}
	}
	
	
	function onMouseDown(e:MouseEvent) {
		if(_enabled){
			var m = System.mouse;
			if (e.button == MouseButton.Right || e.button == MouseButton.Left && System.keyboard.isDown(Key.Space)) {	
				lastX = e.viewX; lastY = e.viewY;
				mouseDownConnection.dispose(); mouseDownConnection = null;
				mouseMoveConnection = m.move.connect(onMouseMove);
				mouseUpConnection = m.up.connect(onMouseUp);
			}	
		}
	}
	
	
	function onMouseUp(e:MouseEvent) {
		//@TODO: release speed/velocity for throwing
		mouseUpConnection.dispose(); mouseUpConnection = null;
		mouseMoveConnection.dispose(); mouseMoveConnection = null;
		if (_enabled) mouseDownConnection = System.mouse.down.connect(onMouseDown);
	}
	
	
	function onMouseMove(e:MouseEvent) {
		if (_enabled) {
			mouseMoved = true;
			x = e.viewX; y = e.viewY;
		}
	}
	
	
	static inline var zoomStepAmount:Float = .2;
	static inline var zoomTime		:Float = .25;
	
	static inline var zoomUp		:Float = 1.0 + zoomStepAmount;
	static inline var zoomDown		:Float = 1.0 - zoomStepAmount;
	
	static inline var rotateStep	:Float = 22.5;
	
	function onMouseScroll(direction:Float) {
		if (_enabled) {
			var c = controller;
			if(System.keyboard.isDown(Key.Shift)) {
				c.rotation.animateBy(((direction > 0)? -rotateStep:rotateStep), zoomTime, Ease.quadOut);
			} else {
				var z = c.zoom._ * ((direction > 0) ? zoomUp : zoomDown);
				if (z != c.zoom._) c.zoom.animateTo(z, zoomTime, Ease.quadOut);
			}
		}
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- *
	 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
	
	
	function setupControl() {
		var m = System.mouse;
		mouseDownConnection = m.down.connect(onMouseDown);
		mouseScrollConnection = m.scroll.connect(onMouseScroll);
	}
	
	
	function removeControl() {
		if (mouseMoveConnection != null) {
			mouseMoveConnection.dispose();
			mouseMoveConnection = null;
		}
		if (mouseScrollConnection != null) {
			mouseScrollConnection.dispose(); 
			mouseScrollConnection = null;
		}
		if (mouseDownConnection != null) {
			mouseDownConnection.dispose(); 
			mouseDownConnection = null;
		}
		if (mouseUpConnection != null) {
			mouseUpConnection.dispose(); 
			mouseUpConnection = null;
		}
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- *
	 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
	override function set_enabled(value:Bool):Bool {
		if (!value && _enabled) {
			removeControl();
			_enabled = false;
		} else if (System.mouse.supported && value && !_enabled) {
			setupControl();			
			_enabled = true;
		}
		return _enabled;
	}
}