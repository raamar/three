uniform vec3 uColor;
varying float vAlpha;

uniform sampler2D uTexture;

void main() {
  gl_FragColor = vec4( uColor, vAlpha );

	gl_FragColor = gl_FragColor;
}