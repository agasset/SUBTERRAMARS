shader_type canvas_item;
render_mode unshaded;
uniform sampler2D scene: hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D revealed: repeat_disable, filter_linear;
uniform sampler2D previous_revealed: repeat_disable, filter_linear;
uniform float reveal_progress = 1.0;
uniform vec2 reveal_origin;
uniform float reveal_radius = 1.0;
uniform vec2 screen_origin;
uniform float zoom = 1.0;
uniform vec2 grid_size;
uniform vec2 mask_offset;
uniform float cell_size = 10.0;
uniform vec2 helmet;
uniform vec2 facing;
uniform float beam_radius;
uniform bool beam_on = false;
uniform bool hostile_on = false;
uniform vec2 hostile;
uniform int light_count = 0;
uniform vec2 lamps[32];
uniform float radii[32];
uniform vec4 inks[32];
uniform int blocker_count = 0;
uniform vec3 blockers[8];
varying vec2 canvas_position;
float transmission(vec2 source, vec2 pixel) {
 vec2 ray=(pixel-source)/vec2(1.0,0.5);
 float squared=max(dot(ray,ray),0.001);
 float visibility=1.0;
 for(int j=0;j<8;j++) {
  if(j>=blocker_count) break;
  vec2 offset=(blockers[j].xy-source)/vec2(1.0,0.5);
  float t=dot(offset,ray)/squared;
  if(t>0.02 && t<0.97) {
   float distance_to_ray=length(offset-ray*t);
   visibility*=mix(0.22,1.0,smoothstep(blockers[j].z*0.65,blockers[j].z*1.25,distance_to_ray));
  }
 }
 return visibility;
}
void vertex() { canvas_position = VERTEX; }
void fragment() {
 // Keep the mask in the same logical coordinates as the game canvas,
 // including stretched windows and high-DPI displays.
 vec2 p = canvas_position;
 vec2 world = (p-screen_origin)/zoom; world.y *= 2.0;
 vec2 uv = (world+mask_offset)/(grid_size*cell_size);
 float known = texture(revealed, uv).r;
 float scan_wave=0.0;
 if(reveal_progress<1.0) {
  float distance_from_origin=length(world-reveal_origin);
  float front=reveal_progress*(reveal_radius+24.0);
  float dissolve=1.0-smoothstep(front-24.0,front+8.0,distance_from_origin);
  float old_known=texture(previous_revealed,uv).r;
  known=mix(old_known,known,dissolve);
  scan_wave=(1.0-smoothstep(0.0,5.0,abs(distance_from_origin-front)))*(1.0-reveal_progress)*0.18;
 }
 if (uv.x<0.0 || uv.y<0.0 || uv.x>1.0 || uv.y>1.0) known=0.0;
 float fog = smoothstep(0.51,0.94,known);
 vec3 col = texture(scene,SCREEN_UV).rgb+vec3(0.1,0.8,0.9)*scan_wave;
 float illumination=0.72;
 vec3 tint=vec3(0.0);
 for(int i=0;i<32;i++) {
  if(i>=light_count) break;
  vec2 d=(p-lamps[i])/vec2(radii[i],radii[i]*0.55);
  float strength=pow(max(0.0,1.0-length(d)),1.5);
  strength*=0.97+0.03*sin(TIME*2.1+float(i)*1.7);
  if(strength>0.005) strength*=transmission(lamps[i],p);
  illumination+=strength*0.68;
  tint+=inks[i].rgb*strength*0.065;
 }
 float beam=0.0;
 if(beam_on) {
  vec2 delta=p-helmet;
  float dist=length(delta);
  float angle=dot(normalize(delta+vec2(0.0001)),normalize(facing));
  beam=smoothstep(0.80,0.96,angle)*(1.0-smoothstep(beam_radius*0.60,beam_radius,dist));
  if(beam>0.005) beam*=transmission(helmet,p);
  illumination+=beam*0.86;
 }
 // The beam clears visual mist on every rendered surface, including elevated
 // walls whose screen pixels do not map back onto a revealed floor cell.
 fog=max(fog,smoothstep(0.02,0.60,beam));
 vec3 lit=col*clamp(illumination,0.0,1.22)+tint+vec3(0.02,0.35,0.40)*beam*0.32;
 lit=mix(lit,vec3(0.08,0.68,0.76),beam*0.15);
 // The explorer is already known: fog must not crop its elevated helmet.
 float explorer=1.0-smoothstep(0.75,1.0,length((p-helmet)/vec2(6.0*zoom,9.0*zoom)));
 fog=max(fog,explorer);
 if(hostile_on) {
  float attacker=1.0-smoothstep(0.7,1.0,length((p-hostile)/vec2(14.0*zoom,11.0*zoom)));
  fog=max(fog,attacker);
 }
 float cloud=0.5+0.5*sin(world.x*0.095+sin(world.y*0.13)+TIME*0.18);
 vec3 mist=vec3(0.025,0.037,0.043)*(0.8+cloud*0.35);
 COLOR=vec4(mix(mist,lit,fog),1.0);
}
