package flambe.nape;

import flambe.camera.Camera;
import flambe.math.Point;
import flambe.System;
import flambe.Component;
import flambe.display.Sprite;
import flambe.input.PointerEvent;
import flambe.util.SignalConnection;

import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.space.Space;


/**
 * TODO: make a more general DragComponent (BodyDragger?) that can take pointer or multitouch input (detect and assign source automatically), so allowing multiple drag actions at once.
 * @author Mike Almond - https://github.com/mikedotalmond
 */
@:final class MouseDragComponent extends Component {

	var space			:Space;
	var rootSprite		:Sprite;
	var mousePoint		:Point;	 	

	var handJoint		:PivotJoint;
	var maxForce		:Float;

	var downConnection	:SignalConnection;
	var upConnection	:SignalConnection;
	
	var spaceComponent	:SpaceComponent;
	var camera			:Camera;
	
	
	public function new (maxForce:Float=4000.0, spaceComponent:SpaceComponent=null, rootSprite:Sprite=null) {
		this.maxForce 		= maxForce;
		this.spaceComponent	= spaceComponent;
		this.rootSprite 	= rootSprite;
		mousePoint 			= new Point();
    }
	
	
	override public function onAdded() {
		
		if (spaceComponent 	== null) spaceComponent = owner.get(SpaceComponent);
		if (space 			== null) space 			= spaceComponent.napeSpace;
		if (rootSprite 		== null) rootSprite 	= owner.get(Sprite);
		
		this.camera 			= (rootSprite == null) ? null : rootSprite.owner.get(Camera);
		
		if (System.pointer.supported) {
			// TODO: multitouch support
			setupJoint();
			downConnection 	= System.pointer.down.connect(onPointerDown);
			upConnection	= System.pointer.up.connect(onPointerUp);
		} else {
			// no pointer?
		}
	}


	function setupJoint() {		
		handJoint 			= new PivotJoint(space.world, null, Vec2.weak(), Vec2.weak());
        handJoint.space 	= space;
        handJoint.active 	= false;
		handJoint.stiff 	= false;
		
		handJoint.maxForce 	= maxForce;
		handJoint.damping 	= 10;
		handJoint.frequency = 10;
	}
	
	
	function onPointerDown(e:PointerEvent) {
		
		camera.screenPointToWorld(e.viewX, e.viewY, mousePoint);
		var vec = Vec2.get(mousePoint.x,mousePoint.y);
		
		for (body in space.bodiesUnderPoint(vec)) {
			if (!body.isDynamic()) continue;
			handJoint.body2 = body;
			handJoint.anchor2.set(body.worldPointToLocal(vec, true));
			handJoint.active = true;
			break;
		}
		
		vec.dispose();
	}
	
	
	function onPointerUp(e:PointerEvent) {
		handJoint.active = false;
	}
	
	
    override public function onUpdate (dt :Float) {
		if (handJoint.active) {
			camera.screenPointToWorld(System.pointer.x, System.pointer.y, mousePoint);
			handJoint.anchor1.setxy(mousePoint.x, mousePoint.y);
		}
    }

    override public function onRemoved () {
        upConnection.dispose();
		downConnection.dispose();
        handJoint.space = null;
		handJoint = null;
    }
}