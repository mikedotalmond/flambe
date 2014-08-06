package flambe.camera.behaviours;
import flambe.animation.Ease;

import flambe.display.Sprite;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
@:final class SpriteFollowBehaviour extends CameraControlBehaviour {
	
	var _target			:Entity = null;	
	var _targetSprite	:Sprite = null;	
	
	public var xEaseTime		:Float = .25;
	public var yEaseTime		:Float = .25;
	
	public var target			(get, set)		:Entity;	
	public var targetSprite		(get, never)	:Sprite;
	
	public var canFollowTarget	(get, never)	:Bool;
	public var followTargetRotation				:Bool = false;
	
	
	public function new(camera:Camera) {
		super(camera);
	}
	
	
	override public function update(dt:Float) {
		if (enabled && canFollowTarget) {
			camera.controller.targetX.animateTo(targetSprite.x._, xEaseTime);
			camera.controller.targetY.animateTo(targetSprite.y._, yEaseTime);
			if (followTargetRotation) camera.controller.rotation._ = -targetSprite.rotation._;
		}
	}
	
	
	override public function dispose() {
		super.dispose();
		_targetSprite = null;
		_target = null;
	}
	
	var resetX:Float = 0;
	var resetY:Float = 0;
	
	override function set_enabled(value:Bool) {
		if (_enabled && !value) {
			camera.controller.targetX.animateTo(resetX, xEaseTime, Ease.quadInOut);
			camera.controller.targetY.animateTo(resetY, yEaseTime, Ease.quadInOut);
		} else if (!_enabled && value) {
			resetX = camera.targetX;
			resetY = camera.targetY;
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