package flambe.camera.view;

import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.Sprite;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.Component;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class CameraInfoDisplay extends Component {
	
	var container	:Entity;
	var camera		:Camera;
	var needsUpdate	:Bool;
	
	var view		:CameraInfoDisplayView;
	var font		:Font;
	
	public function new(ui:Entity, font:Font) {
		ui.addChild(container = new Entity());
		this.font = font;
	}
	
	override public function onAdded() {
		view 	= new CameraInfoDisplayView(container, font);
		camera 	= owner.get(Camera);
		camera.change.connect(onCameraChange);
	}
	
	function onCameraChange() needsUpdate = true;
	
	override public function onUpdate(dt:Float) {
		if (needsUpdate) {
			needsUpdate			= false;			
			view.pan.text 		= 'Pan [${roundForDisplay(camera.panX)},${roundForDisplay(camera.panY)}]';
			view.target.text 	= 'Target [${roundForDisplay(camera.targetX)},${roundForDisplay(camera.targetY)}]';
			view.zoom.text		= 'Zoom [${roundForDisplay(camera.zoom)}]';
		}
	}
	
	
	inline function roundForDisplay(value:Float):String {
		return '${Math.fround(value * 100) / 100}';
	}
}

@:allow(flambe.camera.view.CameraInfoDisplay)
@:final class CameraInfoDisplayView {
	
	var title		:TextSprite;
	var pan			:TextSprite;
	var target		:TextSprite;
	var zoom		:TextSprite;
	
	var root		:Sprite;
	
	function new(container:Entity, font:Font) {
		
		container.add(root = new FillSprite(0, 160, 136));
		root.alpha._ = .7;
		root.x._ 	= 8;
		root.y._ 	= 8;
		
		title 		= cast new TextSprite(font, 'Camera').setXY(8, 4);
		pan		 	= cast new TextSprite(font, '').setXY(8, 40);
		target		= cast new TextSprite(font, '').setXY(8, 40 + 32);
		zoom 		= cast new TextSprite(font, '').setXY(8, 40 + 64);
		
		container.addChild(new Entity().add(title));
		container.addChild(new Entity().add(pan));
		container.addChild(new Entity().add(target));
		container.addChild(new Entity().add(zoom));
	}
}