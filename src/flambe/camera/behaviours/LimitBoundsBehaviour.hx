package flambe.camera.behaviours;
import flambe.math.Rectangle;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class LimitBoundsBehaviour extends CameraControlBehaviour {

	public var bounds:Rectangle;
	
	public function new(camera:Camera, bounds:Rectangle) {
		super(camera);
		this.bounds = bounds;
	}
	
	
	// after all animation updates, clamp to visible area as needed
	override public function postUpdate() {
		if (_enabled) {
			var c = camera;
			var b = bounds;
			var vb = c.visibleBounds;
			var spr = c.rootSprite;
			var z = c.zoom;
			
			// x
			if (vb.width >= b.width) { 	// centre align X if width<visible height
				spr.anchorX._ = b.x + c.stageCentreX / z - ((vb.width - b.width) / 2);
			} else if (vb.x < b.x) {
				spr.anchorX._ = b.x + c.stageCentreX / z;
			} else if (vb.right > b.right) {
				spr.anchorX._ = b.right - c.stageCentreX / z;
			}
			
			// y
			if (vb.height > b.height) {	// centre align Y if height<visible height
				spr.anchorY._ = b.y + c.stageCentreY / z - ((vb.height - b.height) / 2);				
			} else if (vb.y < b.y) { // limit y top
				spr.anchorY._ = b.y + c.stageCentreY / z;
			} else if (vb.bottom > b.bottom) { // limit y bottom
				spr.anchorY._ = b.bottom - c.stageCentreY / z;
			}
		}
	}
	
	
	override public function dispose() {
		super.dispose();
		bounds = null;
	}
}