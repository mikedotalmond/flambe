package flambe.nape;

import flambe.asset.AssetPack;
import flambe.camera.Camera;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.math.FMath;
import flambe.math.Rectangle;
import flambe.nape.util.NapeHelpers;
import flambe.System;
import nape.phys.Compound;
import nape.shape.Polygon;

import nape.constraint.AngleJoint;
import nape.constraint.DistanceJoint;
import nape.constraint.PivotJoint;
import nape.dynamics.InteractionFilter;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.space.Space;

import flambe.nape.util.IsoBody;


/**
 * Component that wraps a Nape physics simulation, provides helpers, etc...
 */
class SpaceComponent extends Component {

	static inline var FixedTimeStep					= 1.0 / 60.0;
	static inline var PositionIterationsPerTimeStep = 10;
	static inline var VelocityIterationsPerTimeStep = 10;

	//
	var world						:Entity;
	
    var _space 						:Space;
    var _pack 						:AssetPack;

	var cumalativeDt				:Float;
	
	public var space	(get, never):Space;
	function get_space	()			:Space return _space;

	public var bounds(default, null):Rectangle;
	
	public function new (pack:AssetPack, space:Space=null, bounds:Rectangle=null) {
        _pack  		= pack;
		_space 		= space == null ? new Space(Vec2.get(0, 0)) : space;
		this.bounds	= bounds;
		cumalativeDt = .0;
    }

	override public function onAdded() {
		world = owner;
		createPhisicalBounds();
	}
	
	function createPhisicalBounds() {
		if (bounds != null) {
			
			var c = new Compound();
			
			var makeBox = function(type, x, y, w, h) {
				var b = new Body(type, Vec2.weak(x,y));
				b.shapes.add(new Polygon(Polygon.rect(0, 0, w, h)));
				b.compound = c;
				return b;
			}
			
			var left  	= makeBox(BodyType.STATIC, bounds.left - 8, bounds.top, 8, 	bounds.height);
			var right 	= makeBox(BodyType.STATIC, bounds.right, bounds.top, 8, bounds.height);
			
			var top		= makeBox(BodyType.STATIC, bounds.left, 	bounds.top - 4, 	bounds.width, 8);
			var bottom	= makeBox(BodyType.STATIC, bounds.left, 	bounds.bottom + 4, 	bounds.width, 8);
			
			c.space = space;
		}
	}

		
		

	/**
	 *@inheritDoc
	 */
    override public function onUpdate(dt:Float) {
		cumalativeDt += dt;
		while (cumalativeDt >= FixedTimeStep) {
			_space.step(FixedTimeStep, VelocityIterationsPerTimeStep, PositionIterationsPerTimeStep);
			cumalativeDt -= dt;
		}
    }

    public function createBodySpriteEntity(body:Body, ?sprite:Sprite=null, ?ComponentType:Class<BodyComponent>=null, ?constructorArgs:Array<Dynamic>=null, ?target:Entity=null):Entity {
		var e = target == null ? new Entity() : target;

		if (sprite != null) {
			var offset:Vec2 = body.userData.graphicOffset;
			if (offset != null) sprite.setAnchor(-offset.x, -offset.y);
			e.add(sprite);
		}

		if (ComponentType == null) {
			ComponentType = BodyComponent;
			constructorArgs = [world, body];
		} else if (constructorArgs != null) {
		   constructorArgs.unshift(body);
		   constructorArgs.unshift(world);
		} else {
			constructorArgs = [world, body];
		}

		e.add(Type.createInstance(ComponentType, constructorArgs));

		return e;
    }
	
	public inline function createRootSprite():Entity {
		return new Entity().add(new Sprite());
	}

	public inline function addDistanceJoint(joint:DistanceJoint) :Entity {
        joint.space = _space;
        return new Entity().add(new DistanceJointComponent(joint));
    }

	public function createDistanceJointSpriteEntity(joint:DistanceJoint, sprite:Sprite):Entity {
		var entity = addDistanceJoint(joint);
		entity.add(sprite);
		sprite.setAnchor(sprite.getNaturalWidth() / 2, 0);
		return entity;
	}
}