package flambe.camera;

import flambe.camera.behaviours.CameraControlBehaviour;
import flambe.camera.behaviours.MouseControlBehaviour;

import flambe.math.Rectangle;
import flambe.util.SignalConnection;

import flambe.camera.CameraController;

import flambe.Component;

import flambe.display.Sprite;

import flambe.Entity;

import flambe.math.Point;

import flambe.System;

import flambe.util.Signal0;



/**
 * Flambe Camera Component
 * @author Mike Almond - https://github.com/mikedotalmond
 */

@:allow(flambe.camera)
class Camera extends Component {
	
	var invalidated							:Bool;
	var stageResized						:SignalConnection;
	
	public var zoom			(get, set)		:Float;
	var _zoom								:Float;
	
	public var targetX		(get, set)		:Float;
	var _targetX							:Float;
	
	public var targetY		(get, set)		:Float;
	var _targetY							:Float;
	
	public var panX			(get, set)		:Float;
	var _panX								:Float;
	
	public var panY			(get, set)		:Float;
	var _panY								:Float;
	
	public var rotation		(get, set)		:Float;
	var _rotation							:Float;
	
	
	public var stageWidth	(default, null)	:Int;
	public var stageHeight	(default, null)	:Int;
	public var stageCentreX	(default, null)	:Float;
	public var stageCentreY	(default, null)	:Float;
	
	public var change		(default, null)	:Signal0;
    public var container	(default, null)	:Entity;
	public var rootSprite	(default, null)	:Sprite;
	
	public var controller	(default, null)	:CameraController;
	public var behaviours	(default, null)	:Array<CameraControlBehaviour>;
	
	public var visibleBounds(default, null)	:Rectangle;
	
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- *
	 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
	
    public function new(?container:Entity) {
		
        this.container 	= container;
		behaviours 		= new Array<CameraControlBehaviour>();
		change 			= new Signal0();
		visibleBounds	= new Rectangle();
		_targetX 		= .0;
		_targetY 		= .0;
		_panX 			= .0;
		_panY 			= .0;
		_rotation 		= .0; 
		_zoom 			= 1.0;
		invalidated 	= true;
	}
	
	
	override public function onAdded() {
		
		container 	= owner;
		rootSprite 	= container.get(Sprite);
		if (rootSprite == null) throw 'Uh-oh! No Sprite found in the container Entity ${container}';
		
		// animatable parameter controller
		owner.add(controller = new CameraController(this));
		
		stageResized = System.stage.resize.connect(onStageResized, true);
		onStageResized();
	}
	
	
	override public function onRemoved() {
		
		reset();
		
		for (b in behaviours) b.dispose();
		behaviours = null;
		
		if (controller != null) {
			controller.dispose();
			controller = null;
		}
		
		if (stageResized != null) {
			stageResized.dispose();
			stageResized = null;
		}
		
		rootSprite 		= null;
		container 		= null;
	}
	
	
	override public function onUpdate(dt:Float) {

		var w = stageCentreX;
		var h = stageCentreY;
		
		for (behaviour in behaviours) behaviour.update(dt);
		
		if (invalidated) {
			
			rootSprite.anchorX._ = _targetX - _panX;
			rootSprite.anchorY._ = _targetY - _panY;
			
			// rotate
			rootSprite.rotation._ = _rotation;
			
			// scale
			rootSprite.setScale(_zoom);
			
			// position (centre)
			rootSprite.x._ = w;
			rootSprite.y._ = h;	
			
			// update visible bounds
			var left = rootSprite.anchorX._ - w / _zoom;
			var top  = rootSprite.anchorY._ - h / _zoom;
			visibleBounds.set(left, top, stageWidth / _zoom, stageHeight / _zoom);
			
			for (behaviour in behaviours) behaviour.postUpdate();
			
			invalidated = false;
			change.emit();
		}
	}
	
	
	function onStageResized() {
		stageWidth 		= System.stage.width;
		stageHeight 	= System.stage.height;
		stageCentreX 	= stageWidth / 2;
		stageCentreY 	= stageHeight / 2;
		invalidated 	= true;
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- *
	 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
	
	/**
	 * 
	 * @param	pX
	 * @param	pY
	 * @return
	 */
	public function screenPointToWorld(pX:Float, pY:Float, ?target:Point=null):Point {
		
		var out = (target == null) ? new Point(pX,pY) : target;
		if (rootSprite == null) return out;
		
		var spr 	= rootSprite;
		var scale 	= spr.scaleX._;
		
		var ax 		= (spr.anchorX._ * scale);
		var ay 		= (spr.anchorY._ * scale);
		
		var x 		= (pX - (spr.x._ - ax)) / scale;
		var y 		= (pY - (spr.y._ - ay)) / scale;
		
		out.set(x, y);
		return out;
	}
		
	 
	public function reset():Camera {
		zoom = 1;
		targetX = 0; targetY = 0;
		panX = panY = rotation = 0.0;
		invalidated = true;
		controller.setToCurrent();
		return this;
	}
	
	
	/**
	  *
	  * @param	offset x
	  * @param	offset y
	  * @return this Camera instance
	  */
	public function setPan(x:Float, y:Float):Camera {
		panX = x; panY = y;
		return this;
    }
	
	
	/**
	 * 
	 * @param	degrees
	 * @return
	 */
	public function setRotation(degrees:Float):Camera {
		rotation = degrees;
		return this;
    }
	
	
	/**
	 * 
	 * @param value
	 * @return this Camera instance
	 */
	public function setZoom(value:Float):Camera {
		zoom = value;
		return this;
    }
	
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- *
	 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
		
	
	/**
	 * zoom
	 * @return
	 */
	inline function get_zoom():Float return _zoom;
	inline function set_zoom(value:Float):Float {
		invalidated = invalidated || (value != _zoom);
		return _zoom = value;
	}
	
	inline function get_rotation():Float return _rotation;
	inline function set_rotation(value:Float):Float {
		invalidated = invalidated || (value != _rotation);
		return _rotation = value;
	}
	
	inline function get_targetX():Float return _targetX;
	inline function set_targetX(value:Float):Float {
		invalidated = invalidated || (value != _targetX);
		return _targetX = value;
	}
	
	inline function get_targetY():Float return _targetY;
	inline function set_targetY(value:Float):Float {
		invalidated = invalidated || (value != _targetY);
		return _targetY = value;
	}
	
	inline function get_panX():Float return _panX;
	inline function set_panX(value:Float):Float {
		invalidated = invalidated || (value != _panX);
		return _panX = value;
	}
	
	inline function get_panY():Float return _panY;
	inline function set_panY(value:Float):Float {
		invalidated = invalidated || (value != _panY);
		return _panY = value;
	}	
}