package flambe.nape.util;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class NapeHelpers {


	/**
	 * Random number from +/- size
	 * @param	size
	 * @return
	 */
	inline public static function rRange(size:Float):Float {
		return (Math.random() - .5) * (size + size);
	}
	
	/**
	 * 
	 * @param	a
	 * @param	b
	 * @param	f
	 * @return
	 */
	public static inline function lerp(a:Float, b:Float, f:Float):Float {
		return b + (a - b) * f;
	}

	/**
	 * Rotate the components of a Vec2 through theta degrees
	 * @param	vIn
	 * @param	theta
	 * @param	vOut
	 */
	public static inline function rotate2DV(input:Vec2, theta:Float):Vec2 {
		var x = input.x * Math.cos(theta) - input.y * Math.sin(theta);
		var y = input.x * Math.sin(theta) + input.y * Math.cos(theta);
		return input.setxy(x, y);
	}


	/**
	 * Rotate the y-component of a Vec2 through theta degrees
	 * rotate just the Y position (of a vector) by a theta radians
	 * @param	yIn
	 * @param	theta
	 * @param	vOut
	 */
	public static inline function rotate2DYOnly(yIn:Float, theta:Float, vOut:Vec2):Vec2 {
		vOut.x = -yIn * Math.sin(theta);
		vOut.y = yIn * Math.cos(theta);
		return vOut;
	}



	/**
	 *
	 * @param	x
	 * @param	y
	 * @param	w
	 * @param	h
	 */
	public static function createBox(type:BodyType, x:Float, y:Float, w:Float, h:Float):Body {
		var b = new Body(type);
        b.shapes.add(new Polygon(Polygon.rect(0, 0, w, h)));

        var pivot:Vec2 = b.localCOM.mul(-1);
        b.translateShapes(pivot);
        b.userData.graphicOffset = pivot;
		
		b.position.setxy(x, y);
		return b;
	}


	/**
	 *
	 * @param	x
	 * @param	y
	 * @param	r
	 */
	public static function createCircle(type:BodyType, x:Float, y:Float, r:Float):Body {
		var b = new Body(type);
        b.shapes.add(new Circle(r));

        var pivot:Vec2 = b.localCOM.mul(-1);
        b.translateShapes(pivot);
        b.userData.graphicOffset = pivot;

		b.position.setxy(x, y);
		return b;
	}
}