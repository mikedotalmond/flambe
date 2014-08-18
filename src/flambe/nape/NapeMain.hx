package flambe.nape;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;

import flambe.camera.Camera;

import flambe.display.Sprite;

import flambe.Entity;

import flambe.input.Gesture;
import flambe.input.GestureControl;
import flambe.input.Key;
import flambe.input.KeyboardEvent;

import flambe.math.Rectangle;

import flambe.nape.MouseDragComponent;
import flambe.nape.SpaceComponent;

import flambe.System;

import flambe.util.Promise;

import nape.geom.Vec2;
import nape.space.Space;


class NapeMain {
	
	public var assets			(default, null):AssetPack;
	
	public var spaceComponent	(default, null):SpaceComponent;
	public var mouseDrag		(default, null):MouseDragComponent;
	
	public var ui				(default, null):Entity;
	public var uiContainer		(default, null):Sprite;
	
	public var world			(default, null):Entity;
	public var worldContainer	(default, null):Sprite;
	public var camera			(default, null):Camera;
	
	public var worldBounds		(default, null):Rectangle;
	public var worldSceneryLayer(default, null):Entity;
	public var worldNapeLayer	(default, null):Entity;
	public var worldUILayer		(default, null):Entity;
	
	public var gestureControl	(default, null):GestureControl;
	
	public var stageWidth		(default, null):Int;
	public var stageHeight		(default, null):Int;
	
	
	function new(worldBounds:Rectangle = null) {	
		this.worldBounds = worldBounds;
	}
	
	
	// Assets ready...
    function onSuccess(assetPack:AssetPack) {
		
		this.assets 	= assetPack;
		stageWidth 		= System.stage.width;
		stageHeight 	= System.stage.height;
		
		System.root.addChild(world = new Entity()); // game world with camera, physics, etc...
		
		System.root.addChild(ui = new Entity()); // non-game, no camera, on top of everything (HUD)
		ui.add(uiContainer = new Sprite());
		
		stageWidth  = System.stage.width;
		stageHeight = System.stage.height;
		
		// world display
		worldContainer 		= new Sprite();
		camera 				= new Camera();
		worldSceneryLayer	= new Entity();
		worldNapeLayer 		= new Entity();
		worldUILayer 		= new Entity();
		
		world
			// root container + camera
			.add(worldContainer).add(camera)			
			// in-camera 	bg/scenery
			.addChild(worldSceneryLayer)			
			// in-camera	nape-world for physics-y things
			.addChild(worldNapeLayer)			
			//  in-camera	fg/ui
			.addChild(worldUILayer);			
		
		//
		setupScenery();
		
		//
		setupNapeWorld();
			
		//
		setupCamera();
		
		//
		setupUI();
		
		//
		onResize();
		
		//
		System.stage.resize.connect(onResize); 	
		System.stage.orientation.changed.connect(function(a,b) {
			if(a != b) onResize();
		});
		
		//
		world.add(gestureControl = new GestureControl());
		gestureControl.gesture.connect(firstUserInteraction).once();
		gestureControl.gesture.connect(onGesture);
		
		#if !(firefox||android||ios)
		if (System.keyboard.supported) System.keyboard.down.connect(onKey);		
		#end
		
		#if (flash && debug)
		System.root.add(new flambe.nape.NapeDebugView(spaceComponent.napeSpace, camera));
		#end
    }
	
	
	
	// -----------------------------------------------------------------------------------------
	
	
	function setupScenery() {
		
	}
	
	
	function setupNapeWorld() {
		worldNapeLayer
			.add(spaceComponent = new SpaceComponent(assets, worldBounds))
			.add(mouseDrag 		= new MouseDragComponent(280000, spaceComponent, worldContainer));
	}
	
	
	function setupCamera() {
		// initialise camera settings
	}	
	
	
	function setupUI() {
		
	}	
	
	
	// -----------------------------------------------------------------------------------------
	
		
	function onResize() {
		stageWidth  = System.stage.width;
		stageHeight = System.stage.height;
	}
	
	/**
	 * Triggered once at the start of the first (mouse/touch) user input...
	 * @param	g
	 */
	function firstUserInteraction(g:Gesture) {
		
	}
	
	
	function onGesture(g:Gesture) {
		
	}
	
	
	#if !(firefox||android||ios)
	function onKey(e:KeyboardEvent) {
		
		switch(e.key) {
			
			case Key.Escape	 		: System.stage.requestFullscreen(false);
			case Key.F, Key.F11		: System.stage.requestFullscreen();
			
			case Key.NumpadAdd		: camera.controller.zoom.animateBy(.2, .25, Ease.quadOut);
			case Key.NumpadSubtract	: camera.controller.zoom.animateBy(-.2, .25, Ease.quadOut);
			
			
			case Key.R				: if (System.keyboard.isDown(Key.Control)){
				#if html 
				js.Browser.document.location.reload();
				#elseif flash
				flash.external.ExternalInterface.call('document.location.reload');
				#end
			}
			
			default:
				trace(e.key);
		}
	}
	#end
}