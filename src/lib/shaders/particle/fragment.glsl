uniform vec3 uColor;
varying float vAlpha;

varying float vIntersections;
uniform sampler2D uTexture;

void main() {
  // if (vIntersections > 0.0) {

  // gl_FragColor = vec4( vec3(1, 0, 0), vAlpha );
  // } else {

  // gl_FragColor = vec4( uColor, vAlpha );
  // }



  gl_FragColor = vec4( uColor, vAlpha );
	gl_FragColor = gl_FragColor;
}