package flambe.nape;

import flambe.asset.AssetPack;

import flambe.Component;

import flambe.display.Sprite;

import flambe.Entity;

import flambe.math.Rectangle;

import nape.constraint.DistanceJoint;

import nape.geom.Vec2;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Compound;

import nape.shape.Polygon;
import nape.space.Space;



/**
 * Component that wraps a Nape physics simulation, provides helpers, etc...
 */
class SpaceComponent extends Component {
	
	
	static inline var FixedTimeStep					:Float	= 1.0 / 60.0;
	static inline var PositionIterationsPerTimeStep	:Int 	= 10;
	static inline var VelocityIterationsPerTimeStep	:Int 	= 10;
	
	var cumalativeDt						:Float;
	
	public var assetPack	(default, null)	:AssetPack;	
	public var napeSpace	(default, null)	:Space;	
	public var bounds		(default, null)	:Rectangle;
	
	
	public function new (assetPack:AssetPack, bounds:Rectangle = null, napeSpace:Space = null) {
        this.assetPack  = assetPack;
		this.napeSpace	= napeSpace == null ? new Space(Vec2.get(0, 0)) : napeSpace;
		this.bounds		= bounds;
		cumalativeDt 	= .0;
    }

	
	override public function onAdded() {
		createPhisicalBounds();
	}
	
	
    override public function onUpdate(dt:Float) {
		cumalativeDt += dt;
		while (cumalativeDt >= FixedTimeStep) {
			napeSpace.step(FixedTimeStep, VelocityIterationsPerTimeStep, PositionIterationsPerTimeStep);
			cumalativeDt -= dt;
		}
    }
	
	
	// ------------------------------------------------------------------------------------------------------
	
	
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
			
			c.space 	= napeSpace;
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
			constructorArgs = [owner, body];
		} else if (constructorArgs != null) {
		   constructorArgs.unshift(body);
		   constructorArgs.unshift(owner);
		} else {
			constructorArgs = [owner, body];
		}
		
		e.add(Type.createInstance(ComponentType, constructorArgs));
		
		return e;
    }
	
	
	public inline function createRootSprite():Entity return new Entity().add(new Sprite());

	
	public inline function addDistanceJoint(joint:DistanceJoint) :Entity {
        joint.space = napeSpace;
        return new Entity().add(new DistanceJointComponent(joint));
    }
	
	
	public inline function createDistanceJointSpriteEntity(joint:DistanceJoint, sprite:Sprite):Entity {
		return addDistanceJoint(joint).add(
			sprite.setAnchor(sprite.getNaturalWidth() / 2, 0)
		);
	}
}