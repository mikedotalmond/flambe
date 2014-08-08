//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.shader;

import js.html.*;
import js.html.webgl.*;
import js.html.webgl.RenderingContext;

import flambe.platform.html.WebGLTexture;

class DrawTextureGL extends ShaderGL
{
    public function new (gl :RenderingContext)
    {
        super(gl,
        [ // Vertex shader
            "attribute highp vec2 a_pos;",
            "attribute mediump vec2 a_uv;",
            "attribute lowp float a_alpha;",

            "varying mediump vec2 v_uv;",
            "varying lowp float v_alpha;",

            "void main (void) {",
                "v_uv = a_uv;",
                "v_alpha = a_alpha;",
                "gl_Position = vec4(a_pos, 0, 1);",
            "}",
        ].join("\n"),

        [ // Fragment shader
            "varying mediump vec2 v_uv;",
            "varying lowp float v_alpha;",

            "uniform lowp sampler2D u_texture;",

            "void main (void) {",
                "gl_FragColor = texture2D(u_texture, v_uv) * v_alpha;",
            "}",
        ].join("\n"));

        a_pos = getAttribLocation("a_pos");
        a_uv = getAttribLocation("a_uv");
        a_alpha = getAttribLocation("a_alpha");

        u_texture = getUniformLocation("u_texture");
        setTexture(0);
    }

    public function setTexture (unit :Int)
    {
        _gl.uniform1i(u_texture, unit);
    }

    override public function prepare ()
    {
        _gl.enableVertexAttribArray(a_pos);
        _gl.enableVertexAttribArray(a_uv);
        _gl.enableVertexAttribArray(a_alpha);

        var bytesPerFloat = Float32Array.BYTES_PER_ELEMENT;
        var stride = 5*bytesPerFloat;
        _gl.vertexAttribPointer(a_pos, 2, GL.FLOAT, false, stride, 0*bytesPerFloat);
        _gl.vertexAttribPointer(a_uv, 2, GL.FLOAT, false, stride, 2*bytesPerFloat);
        _gl.vertexAttribPointer(a_alpha, 1, GL.FLOAT, false, stride, 4*bytesPerFloat);
    }

    private var a_pos :Int;
    private var a_uv :Int;
    private var a_alpha :Int;

    private var u_texture :UniformLocation;
}



#if flambe_enable_tint
class DrawTextureWithTintGL extends ShaderGL
{
    public function new (gl :RenderingContext)
    {
        super(gl,
        [ // Vertex shader
            "attribute highp vec2 a_pos;",
            "attribute mediump vec2 a_uv;",
            "attribute lowp float a_alpha;",
            "attribute lowp vec3 a_tint;",

            "varying mediump vec2 v_uv;",
            "varying lowp float v_alpha;",
            "varying lowp vec3 v_tint;",

            "void main (void) {",
                "v_uv = a_uv;",
                "v_alpha = a_alpha;",
                "v_tint = a_tint;",
                "gl_Position = vec4(a_pos, 0, 1);",
            "}",
        ].join("\n"),

        [ // Fragment shader
            "varying mediump vec2 v_uv;",
            "varying lowp float v_alpha;",
            "varying lowp vec3 v_tint;",

            "uniform lowp sampler2D u_texture;",

            "void main (void) {",
				"vec4 temp = texture2D(u_texture, v_uv);",
				"temp.xyz *= v_tint;",
                "gl_FragColor = temp * v_alpha;",
            "}",
        ].join("\n"));

        a_pos = getAttribLocation("a_pos");
        a_uv = getAttribLocation("a_uv");
        a_alpha = getAttribLocation("a_alpha");
        a_tint = getAttribLocation("a_tint");
		
        u_texture = getUniformLocation("u_texture");
        setTexture(0);
    }

    public function setTexture (unit :Int)
    {
        _gl.uniform1i(u_texture, unit);
    }

    override public function prepare ()
    {
        _gl.enableVertexAttribArray(a_pos);
        _gl.enableVertexAttribArray(a_uv);
        _gl.enableVertexAttribArray(a_alpha);
        _gl.enableVertexAttribArray(a_tint);

        var bytesPerFloat = Float32Array.BYTES_PER_ELEMENT;
        var stride = bytesPerFloat<<3; // * 8
        _gl.vertexAttribPointer(a_pos, 2, GL.FLOAT, false, stride, 0 * bytesPerFloat);
        _gl.vertexAttribPointer(a_uv, 2, GL.FLOAT, false, stride, bytesPerFloat * 2);
        _gl.vertexAttribPointer(a_alpha, 1, GL.FLOAT, false, stride, bytesPerFloat * 4);
        _gl.vertexAttribPointer(a_tint, 3, GL.FLOAT, false, stride, bytesPerFloat * 5);
    }

    private var a_pos :Int;
    private var a_uv :Int;
    private var a_alpha :Int;
    private var a_tint :Int;

    var u_texture :UniformLocation;
}
#end
