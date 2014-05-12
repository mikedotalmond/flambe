package flambe.camera.behaviours;

import flambe.camera.CameraController;

/**
 * Base fora camera control behaviours
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class CameraControlBehaviour {
	
	var camera		:Camera;
	var controller	:CameraController;
	
	var _enabled	:Bool = false;
	public var enabled(get, set):Bool;
	
	// private - subclass and add a public constructor
	function new (camera:Camera) {
		this.camera 	= camera;
		this.controller = camera.controller;
	}
	
	
	/**
	 * Called from camera.update() prior to updating actual camera / container values
	 */ 
	public function update(dt:Float):Void {
		
	}
	
	
	/**
	 * Called from camera.update() after the controller has updated the camera, and the camera has updated the view (if it was invalidated)
	 * camera.visibleBounds has been updated by this time, so can be used here as needed (restrict movement or check stuff based on visible objects... etc...)
	 */
	public function postUpdate():Void {
		
	}
	
	
	/**
	 * 
	 */
	public function dispose():Void {
		enabled = false;
		controller = null;
		camera = null;
	}
	
	
	function get_enabled():Bool return _enabled;
	function set_enabled(value:Bool):Bool return _enabled = value;
}