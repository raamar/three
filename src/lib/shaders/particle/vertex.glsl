attribute float alpha;
varying float vAlpha;
uniform float uSize;
uniform float uHeight;


void main() {
  vec4 mvPosition = modelViewMatrix * vec4( position, uHeight );
  gl_PointSize = uSize * (10.0 / -mvPosition.z);
  gl_Position = projectionMatrix * mvPosition;
  vAlpha = alpha;
}