uniform float uIntencity;
uniform float uIntencityX;
uniform float uIntencityY;
uniform float uIntencityZ;

uniform float uAtmosphereR;
uniform float uAtmosphereG;
uniform float uAtmosphereB;
uniform float uAtmospherePow;

uniform float uFragColorA;

uniform vec3 uColor;

varying vec3 vNormal;
varying vec2 vUv;

void main() {
  float intensity = uIntencity - dot( vNormal, vec3(uIntencityX, uIntencityY, uIntencityZ ));
  vec3 atmosphere = vec3( uAtmosphereR, uAtmosphereG, uAtmosphereB ) * pow(intensity, uAtmospherePow);

  gl_FragColor = vec4( (atmosphere + uColor), uFragColorA );
}