#ifndef GS_SETTINGS
#define GS_SETTINGS
// Point sampling keeps the selected texel crisp.
#define FILTER_MODE 5 // [5]
// Point sample at base mip; no bilinear/trilinear texture smoothing.
#define ATLAS_MIP_LEVELS 4
#define MODEL_FILTER 2 // [2] Point-sampled model textures
#define WATER_STYLE 2 // [0 2]
#define WATER_PIXELATED 1 // [0 1]
#define WATER_PIXEL_DENSITY 0 // [0 8 16 32 64 128]
#define NORMAL_STRENGTH 1.0 // [0.0 0.5 0.75 1.0 1.5 2.0]
#define WATER_SCALE 1.0 // [0.5 1.0 2.0 4.0]
#define FLOW_SPEED 1.0 // [0.0 0.25 0.5 1.0 1.5 2.0]
#define REFRACTION_STRENGTH 0.015 // [0.0 0.005 0.01 0.015 0.025 0.04]
#define WATER_ABSORPTION 0.32 // [0.0 0.08 0.16 0.32 0.5 0.8]
#define REFLECTION_STRENGTH 0.8 // [0.0 0.35 0.65 0.8 1.0]
#define RETRO_COLOUR 1 // [0 1]
#define COLOUR_LEVELS 16 // [4 8 16 32 64]
#define DITHERING 1 // [0 1]
#define DITHER_STRENGTH 1.0 // [0.0 0.25 0.5 0.75 1.0]
#define EXPOSURE 1.0 // [0.75 1.0 1.25 1.5]
#define UNDERWATER_DISTORTION 0.35 // [0.0 0.15 0.35 0.65 1.0]
#define RIPPLE_DROPS 1 // [0 1]
#define DROP_EVERY_TICKS 4 // [2 4 8 16]
#define WATER_AMPLITUDE 8.0 // [0.0 2.0 4.0 6.0 8.0 12.0]
#define WATER_TEXELS 16.0 // [8.0 16.0 32.0]
#endif
