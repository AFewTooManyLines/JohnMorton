extern number shift = 0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
    vec2 tc = texture_coords;
    vec2 scale = vec2(1.0 / 800.0, 1.0 / 600.0);

    vec4 shiftedTexel = Texel(texture, vec2(
        tc.x + shift * scale.x, 
        tc.y + shift * scale.y
    ));

    return shiftedTexel;
}
