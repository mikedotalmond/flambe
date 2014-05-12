package flambe.nape;

import flambe.camera.Camera;
import nape.space.Space;

/**
 * @author Mark Knol [blog.stroep.nl]
 *
 * 
 * 
 * Added support for flambe.camera 
 * @author Mike Almond - https://github.com/mikedotalmond
 */
@:final class NapeDebugView extends Component {

	var space	:Space;
	var camera	:Camera = null;

	#if flash
	var debugView:nape.util.ShapeDebug;
	public var display(get, never):flash.display.DisplayObject;
	inline function get_display() return debugView != null ? debugView.display : null;
	#end

	public function new(space:Space, ?camera:Camera=null) {
		this.space = space;
		this.camera = camera;
		#if flash
		var width  = camera == null ? System.stage.width	: camera.stageWidth;
		var height = camera == null ? System.stage.height	: camera.stageHeight;
		debugView = new nape.util.ShapeDebug(width, height);
		flash.Lib.current.stage.addChild(debugView.display);
		#end
	}
	
	override public function onAdded() {
		#if flash
		if (camera != null) debugView.display.scrollRect = null;
		#end
	}

	override public function onUpdate(dt:Float) {
		#if flash
		debugView.clear();
		debugView.draw(space);
		
		if (camera != null) { 
			var zoom = camera.zoom;
			// NOTE: Does not handle camera rotation
			debugView.display.x = (-camera.targetX * zoom) + (camera.stageCentreX + camera.panX * zoom);
			debugView.display.y = (-camera.targetY * zoom) + (camera.stageCentreY + camera.panY * zoom);
			debugView.display.scaleX = debugView.display.scaleY = zoom;
		}
		#end
	}

	override public function dispose() {
		#if flash
		flash.Lib.current.stage.removeChild(debugView.display);
		debugView = null;
		#end
		super.dispose();
	}
}