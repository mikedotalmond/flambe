package flambe.camera.behaviours;

import flambe.camera.Camera;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class ZoomLimitBehaviour extends CameraControlBehaviour {
	
	public var min:Float;
	public var max:Float;	

	public function new(camera:Camera, min:Float, max:Float) {
		this.min = min;
		this.max = max;
		super(camera);
	}
	
	override public function update(dt:Float):Void {
		if (_enabled) {
			var z = Math.min(Math.max(min, camera._zoom), max);
			if (camera._zoom != z) camera._zoom = controller.zoom._ = z;
		}		
	}
}