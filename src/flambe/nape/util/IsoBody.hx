package flambe.nape.util;

import flambe.display.SubTexture;
import haxe.io.Bytes;
import nape.geom.AABB;
import nape.geom.IsoFunction.IsoFunctionDef;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.shape.Polygon;

import haxe.io.Bytes;
import haxe.io.BytesData;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
@:final class IsoBody {

	public static function bodiesFromSpriteSheet(atlas:Map<String, SubTexture>):Map<String,Body> {

		var bodies = new Map<String,Body>();

		for (key in atlas.keys()) {
			var data = atlas.get(key);
			var body = bodyFromTexture(data);
			bodies.set(key, body);
		}

		return bodies;
	}


	static function bodyFromTexture(texture:SubTexture, alphaThreshold:Int=0x80) {
		var bytes 	= texture.readPixels(Std.int(texture.x), Std.int(texture.y), Std.int(texture.width), Std.int(texture.height)); // slow...
		var iso		= new BytesDataIso(bytes, Std.int(texture.width), Std.int(texture.height), alphaThreshold);
        var body 	= IsoBody.run(
			#if flash
			iso,
			#else
			iso.iso,
			#end
			iso.bounds, Vec2.weak(4, 4), 4, 1.5);

		return body;
	}


	/**
	 * @param	iso
	 * @param	bounds
	 * @param	granularity
	 * @param	quality
	 * @param	simplification
	 *
	 * For more info, see: http://napephys.com/help/manual.html ~~ 9. Geometric Utilities
	 */
    static function run(iso:IsoFunctionDef, bounds:AABB, granularity:Vec2=null, quality:Int=2, simplification:Float=1.5) {
        var body = new Body();
        if (granularity==null) granularity = Vec2.weak(8, 8);
        var polys = MarchingSquares.run(iso,bounds, granularity, quality);
        for (p in polys) {
            var qolys = p.simplify(simplification).convexDecomposition(true);
            for (q in qolys) {
                body.shapes.add(new Polygon(q));
                // Recycle GeomPoly and its vertices
                q.dispose();
            }
            // Recycle list nodes
            qolys.clear();
            // Recycle GeomPoly and its vertices
            p.dispose();
        }
        // Recycle list nodes
        polys.clear();
        // Align body with its centre of mass.
        // Keeping track of our required graphic offset.
        var pivot = body.localCOM.mul(-1);
        body.translateShapes(pivot);
        body.userData.graphicOffset = pivot;
        return body;
    }
}



@:final class BytesDataIso
#if flash
implements IsoFunctionDef
#end
{
	public var bytes:Bytes;
    public var width:Int;
    public var height:Int;
    public var threshold:Int;
    public var bounds:AABB;

    public function new(bytes:Bytes, width, height, threshold:Int = 0x80) {
        this.bytes = bytes;
        this.width = width;
        this.height = height;
        this.threshold = threshold;
        bounds = new AABB(0, 0, width, height);
    }

    public function iso(x:Float, y:Float) {

		var ix = Std.int(x); var iy = Std.int(y);
        // clamp in-case of numerical inaccuracies
        if (ix < 0) ix = 0; if (iy < 0) iy = 0;
        if (ix >= width)  ix = width - 1;
        if (iy >= height) iy = height - 1;

		var pos = ((ix + width * iy) << 2);

		#if html
		var v = bytes.get(pos + 3); // alpha
		return v > threshold ? -1 : 1;

		#else
		// Work around FlashPlayer issue when reading from a texture with alpha on the GPU
		// Expect full red - 0xFF0000 - to be the background, and everything else is content
		var r = bytes.get(pos);
		var g = bytes.get(pos + 1);
		var b = bytes.get(pos + 2);
		return (r == 255 && g == 0 && b == 0) ? 1 : -1;
		#end
    }
}