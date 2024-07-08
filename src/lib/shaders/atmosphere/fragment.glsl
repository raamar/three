varying vec3 vNormal;


uniform float uIntencity;
uniform float uIntencityX;
uniform float uIntencityY;
uniform float uIntencityZ; 
uniform float uIntencityPow; 
uniform float uIntencityR; 
uniform float uIntencityG; 
uniform float uIntencityB; 
uniform float uIntencityA; 

void main() {
  float intensity = pow( uIntencity - dot( vNormal, vec3( uIntencityX, uIntencityY, uIntencityZ ) ), uIntencityPow );
  gl_FragColor = vec4( uIntencityR, uIntencityG, uIntencityB, uIntencityA ) * intensity;
}