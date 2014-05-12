package flambe.nape.util;

import haxe.Json;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.shape.Polygon;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class SerialiseBodyUtil {

	public static function serialiseBodies(bodies:Array<Body>) {
		var items:Array<String>=[];
		for (body in bodies) {
			var data = body.userData.serialised;
			var name = body.userData.serialisedName;
			items.push('{"name":"${name}", "data":${data}}');
		}
		return '[\n${items.join(",\n")}\n]';
	}

	/**
	 *
	 * @param	imageName
	 * @param	b
	 * @return
	 */
	public static function serialiseBody(body:Body) {

		var offset = body.userData.graphicOffset == null ? Vec2.get() : body.userData.graphicOffset;

		var out	=	'"graphicOffset":[${offset.x},${offset.y}],\n';
		out = out +	'${serialiseBodyPolygons(body)}';

		body.userData.serialised = '{\n${out}\n}';
	}


	static function serialiseBodyPolygons(b:Body):String {
		var polys = [];
		for (shape in b.shapes) {
			var vertices = [];
			for (vertex in shape.castPolygon.localVerts) vertices.push('[${vertex.x},${vertex.y}]');
			polys.push('${vertices}');
		}
		return '"polys":[${polys.join(",")}]';
	}


	/**
	 *
	 * @param	data
	 * @return
	 */
	public static function deserialiseStringToBody(data:String):Body {
		return deserialiseToBody(bodyPolyDataFromString(data));
	}

	public static function deserialiseToBody(bData:BodyPolyData):Body {

		var polys 	= bData.polys;
		var body	= new Body();

		for (poly in polys) {
			var vertices:Array<Vec2> = [];
			for (vtx in poly) vertices.push(Vec2.get(vtx[0], vtx[1]));
			body.shapes.add(new Polygon(vertices));
		}

		body.userData.graphicOffset = (bData.graphicOffset == null) ? Vec2.get() : Vec2.get(bData.graphicOffset[0], bData.graphicOffset[1]);

		return body;
	}


	public static inline function bodyPolyDataToString(data:BodyPolyData):String return Json.stringify(data);

	public static inline function bodyPolyDataFromString(data:String):BodyPolyData return cast Json.parse(data);
}


typedef BodyPolyData = {
	@:optional
	var graphicOffset	:Array<Float>;
	var polys			:Array<Array<Array<Float>>>;
}