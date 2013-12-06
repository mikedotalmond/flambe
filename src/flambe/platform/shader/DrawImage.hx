//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.shader;

import hxsl.Shader;

/**
 * Shader that draws textured triangles with a given alpha.
 * Requries 5 Floats/Vertex
 */
@:final class DrawImage extends Shader
{
    static var SRC = {
        var input :{
            pos :Float2,
            uv :Float2,
            alpha :Float,
		};

        var _uv :Float2;
        var _alpha :Float;
		
		function vertex () {
            _uv = input.uv;
            _alpha = input.alpha;
            out = input.pos.xyzw;
        }

        function fragment (texture :Texture) {
            out = texture.get(_uv, clamp) * _alpha;
        }
    }
}



/**
 * Shader that draws textured triangles with a given alpha and rgb tint (multipliers)
 * Requries 8 Floats/Vertex
 */
@:final class DrawImageWithTint extends Shader {
	
    static var SRC = {
		
        var input: {
            pos 	:Float2,
            uv 		:Float2,
            alpha 	:Float,
			tint	:Float3,
        };

        var _uv 	:Float2;
        var _alpha 	:Float;
        var _tint	:Float3;

        function vertex () {
            _uv 	= input.uv;
            _alpha 	= input.alpha;
            _tint	= input.tint;
            out 	= input.pos.xyzw;
        }
		
        function fragment (texture :Texture) {
			
			var temp 	= texture.get(_uv, clamp);
			temp.xyz 	*= _tint;
			
            out 		= temp * _alpha;
        }
    }
}
