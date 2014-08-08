package flambe.camera.behaviours;
import flambe.animation.Ease;

import flambe.display.Sprite;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
@:final class SpriteFollowBehaviour extends CameraControlBehaviour {
	
	var resetX									:Float = 0;
	var resetY									:Float = 0;
	var resetRotation							:Float = 0;
	
	var _target									:Entity = null;	
	var _targetSprite							:Sprite = null;	
	
	public var target			(get, set)		:Entity;	
	public var targetSprite		(get, never)	:Sprite;
	public var canFollowTarget	(get, never)	:Bool;
	
	public var xEaseTime						:Float = .25;
	public var yEaseTime						:Float = .25;
	public var rotationEaseTime					:Float = 0;
	
	public var easeX							:Float->Float;
	public var easeY							:Float->Float;
	public var easeRotation						:Float->Float;
	
	public var followTargetX					:Bool = true;
	public var followTargetY					:Bool = true;
	public var followTargetRotation				:Bool = false;
	
	
	public function new(camera:Camera, xEaseTime:Float=.25, yEaseTime:Float=.25) {
		super(camera);
		
		this.xEaseTime 	= xEaseTime;
		this.yEaseTime 	= yEaseTime;
		
		followTargetX 	= xEaseTime >= 0;
		followTargetY 	= yEaseTime >= 0;
		
		easeX 			= Ease.quadInOut;
		easeY 			= Ease.quadInOut;
		easeRotation	= Ease.quadInOut;
	}
	
	
	override public function update(dt:Float) {
		if (enabled && canFollowTarget) {
			if (followTargetX) camera.controller.targetX.animateTo(targetSprite.x._, xEaseTime, easeX);
			if (followTargetY) camera.controller.targetY.animateTo(targetSprite.y._, yEaseTime, easeY);
			if (followTargetRotation) camera.controller.rotation.animateTo(-targetSprite.rotation._, rotationEaseTime, easeRotation);
		}
	}
	
	
	override public function dispose() {
		super.dispose();
		_targetSprite = null;
		_target = null;
	}
	
	
	override function set_enabled(value:Bool) {
		if (_enabled && !value) {
			if (followTargetX) camera.controller.targetX.animateTo(resetX, xEaseTime, easeX);
			if (followTargetY) camera.controller.targetY.animateTo(resetY, yEaseTime, easeY);
			if (followTargetRotation) camera.controller.rotation.animateTo(resetRotation, rotationEaseTime, easeRotation);
		} else if (!_enabled && value) {
			resetX = camera.targetX;
			resetY = camera.targetY;
			resetRotation = camera.rotation;
		}
		return _enabled = value;
	}
	
	
	inline function get_target():Entity return _target;
	function set_target(value:Entity):Entity {
		
		if (value == null) {
			_targetSprite = null;
			enabled = false;
		} else {
				
			var spr = value.get(Sprite);
			
			if (spr == null) throw 'Uh-oh! No Sprite found in that Entity ${value}';
			if (spr == camera.rootSprite) throw 'Can\'t set the camera-target to be the main container!';
			
			_targetSprite = spr;
		}
		
		return _target = value;
	}
	
	inline function get_targetSprite():Sprite return _targetSprite;
	
	inline function get_canFollowTarget():Bool return _target != null && _targetSprite != null;
}