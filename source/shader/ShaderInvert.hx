package shader;
import flixel.system.FlxAssets.FlxShader;

class ShaderInvert extends FlxShader {
	@:glFragmentSource("
        #pragma header
        varying vec2 openfl_TextureCoordv;
		uniform sampler2D openfl_Texture;

		uniform mat4 uMultipliers;
		uniform vec4 uOffsets;

		void main(void) {

			vec4 color = texture2D (openfl_Texture, openfl_TextureCoordv);

			if (color.a == 0.0) {

				gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);

			} else {

				color = vec4 (color.rgb / color.a, color.a);
				color = uOffsets + color * uMultipliers;

				gl_FragColor = vec4 (color.rgb * color.a, color.a);

			}

		}")
	public function new()
	{
		super();

		#if !macro
		uMultipliers.value = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
		uOffsets.value = [0, 0, 0, 0];
		#end
	}
}