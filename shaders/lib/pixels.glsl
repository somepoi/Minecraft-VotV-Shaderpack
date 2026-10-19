#ifndef VT_PIXELS
#define VT_PIXELS
#include "/lib/settings.glsl"
// Surface-space cells remain attached to the world when the camera moves.
float vtWaterDensity(vec2 halfSpan,vec2 atlasSize,bool horizontal) {
    vec2 radius=halfSpan*atlasSize;
    // A square's corner radius is invariant under rotation of flowing UVs.
    float span=horizontal ? sqrt(2.0)*length(radius) : 2.0*max(radius.x,radius.y);
    return max(1.0,floor(span+0.5));
}
vec2 vtWaterCell(vec2 plane,float spriteTexels) {
#if WATER_PIXELATED == 1
    float density = WATER_PIXEL_DENSITY == 0 ? spriteTexels : float(WATER_PIXEL_DENSITY);
    density = max(floor(density+0.5),1.0);
    return (floor(plane*density)+0.5)/density;
#else
    return plane;
#endif
}
vec3 vtShadowCell(vec3 world,vec3 normal) {
#if SHADOW_PIXELATED == 1
    float size=SHADOW_PIXEL_SIZE;
    vec3 n=normal*inversesqrt(max(dot(normal,normal),1e-8));
    vec3 a=abs(n);
    vec3 snapped=(floor(world/size)+0.5)*size;
    // Quantize the two receiver-plane axes, leaving depth on the surface.
    if(a.y>=max(a.x,a.z))snapped.y=world.y;
    else if(a.x>a.z)snapped.x=world.x;
    else snapped.z=world.z;
    // Solve only the dominant coordinate. Orthogonal projection would change
    // the already-quantized free axes and make a slope cell vary internally.
    float residual=dot(snapped-world,n);
    if(a.y>=max(a.x,a.z) && a.y>1e-6)snapped.y-=residual/n.y;
    else if(a.x>a.z && a.x>1e-6)snapped.x-=residual/n.x;
    else if(a.z>1e-6)snapped.z-=residual/n.z;
    return snapped;
#else
    return world;
#endif
}
#endif
