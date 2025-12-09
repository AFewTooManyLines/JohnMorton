extern number time;
extern float setting1 = 10.f;
extern float setting2 = 700.f;

vec4 effect( vec4 color, Image tex, vec2 tex_uv, vec2 pix_uv )
{  
  // per row offset
  float f  = sin( tex_uv.y * setting1 * 3.14f );
  
  // scale to per pixel
  float o  = f * (0.35f / setting2);
  
  // scale for subtle effect
  float s  = f * 0.02f + 0.90f;
  
  // scan line fading
  float l  = sin( time * 32.f )*.03f + 0.97f;
  
  float r = Texel( tex, vec2( tex_uv.x+o, tex_uv.y+o ) ).x;
  float g = Texel( tex, vec2( tex_uv.x-o, tex_uv.y+o ) ).y;
  float b = Texel( tex, vec2( tex_uv.x  , tex_uv.y-o ) ).z;
  
  return vec4( r*0.95f, g, b*0.95f, l ) * s;
}