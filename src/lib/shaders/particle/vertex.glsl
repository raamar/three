attribute float alpha;
varying float vAlpha;
uniform float uSize;
uniform float uHeight;
attribute float intersections;
varying float vIntersections;


void main() {
  // vec4 mvPosition = modelViewMatrix * vec4( position + vec3(intersections * 0.03, intersections * 0.03, intersections * 0.03 ), uHeight + intersections * -0.3 );
  vec4 mvPosition = modelViewMatrix * vec4( position, uHeight);
  gl_PointSize = uSize * (10.0 / -mvPosition.z);
  gl_Position = projectionMatrix * mvPosition;
  vAlpha = alpha;
  vIntersections = intersections;
}