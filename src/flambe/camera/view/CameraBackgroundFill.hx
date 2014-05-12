package flambe.camera.view;

import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.Sprite;
import flambe.util.SignalConnection;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
@:final class CameraBackgroundFill extends FillSprite {
	
	var camera			:Camera;
	var updateConnection:SignalConnection;
	var resizeConnection:SignalConnection;
	
	var stageWidth		:Int;
	var stageHeight		:Int;
	var stageCentreX	:Float;
	var stageCentreY	:Float;
	var needsUpdate		:Bool;

	public function new(color:Int, camera:Camera) {
		super(color, 1, 1);		
		this.camera = camera;
		onStageResize();
	}
	
	override public function onAdded() {
		centerAnchor();
		updateConnection = camera.change.connect(updateBackground);		
		resizeConnection = System.stage.resize.connect(onStageResize);
		onStageResize();
	}
	
	override public function onUpdate(dt:Float) {
		
		if (needsUpdate) {
			// update bg position and scale to always fill the visible stage
			
			var z	= camera.zoom;
			var pad = Math.min(32 / z, 512); // extra pad to cover edges when zooming in/out
			
			setScaleXY((stageWidth + pad) / z, (stageHeight + pad) / z);
			
			var x, y;
			
			var rs = camera.rootSprite;
			x = rs.anchorX._ - rs.x._ + stageCentreX;
			y = rs.anchorY._ - rs.y._ + stageCentreY;				
			
			setXY(x, y);
			needsUpdate = false;
		}
	}
	
	
	function onStageResize() {
		stageWidth  = System.stage.width;
		stageHeight = System.stage.height;
		stageCentreX = stageWidth / 2;
		stageCentreY = stageHeight / 2;
		updateBackground();
	}
	
	inline function updateBackground() needsUpdate = true;
	
	
	override public function onRemoved() {
		if (camera != null) camera = null;
		if (updateConnection != null) {
			updateConnection.dispose();
			updateConnection = null;
		}
		if (resizeConnection != null) {
			resizeConnection.dispose();
			resizeConnection = null;
		}		
		super.onRemoved();
	}
}