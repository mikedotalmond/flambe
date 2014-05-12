package flambe.camera;

import flambe.animation.AnimatedFloat;
import flambe.camera.Camera;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.util.Signal0;
import flambe.util.SignalConnection;

/**
 * @author Mike Almond - https://github.com/mikedotalmond
 */
@:allow(flambe.camera)
@:final class CameraController extends Component {
	
	var camera							:Camera = null;	
	public var panX		(default, null)	:AnimatedFloat;
	public var panY		(default, null)	:AnimatedFloat;
	public var targetX	(default, null)	:AnimatedFloat;
	public var targetY	(default, null)	:AnimatedFloat;
	public var zoom		(default, null)	:AnimatedFloat;
	public var rotation	(default, null)	:AnimatedFloat;
	
	function new(camera:Camera) {
		this.camera = camera;
	}	
	
	override public function onAdded() {		
		panX 			= new AnimatedFloat(camera.panX);
		panY 			= new AnimatedFloat(camera.panY);
		targetX 		= new AnimatedFloat(camera.targetX);
		targetY	 		= new AnimatedFloat(camera.targetY);
		zoom 			= new AnimatedFloat(camera.zoom);
		rotation 		= new AnimatedFloat(camera.rotation);
	}	
	
	override public function onUpdate(dt:Float) {
		
		panX.update(dt);
		panY.update(dt);
		targetX.update(dt);
		targetY.update(dt);
		zoom.update(dt);
		rotation.update(dt);
		
		camera.panX 		= panX._;
		camera.panY 		= panY._;
		camera.targetX 		= targetX._;
		camera.targetY 		= targetY._;
		camera.zoom 		= zoom._;
		camera.rotation 	= rotation._;
	}
	
	
	override public function onRemoved() {		
		camera 	= null;
		panX = null;
		panY = null;
		targetX = null;
		targetY = null;
		zoom = null;
		rotation = null;
	}
	
	
	/**
	 * set values to the current camera settings
	 */
	function setToCurrent() {
		panX._		= camera.panX;
		panY._ 		= camera.panY;
		targetX._ 	= camera.targetX;
		targetY._ 	= camera.targetY;
		zoom ._		= camera.zoom;
		rotation._ 	= camera.rotation;
	}
}