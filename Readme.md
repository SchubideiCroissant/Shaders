# Shader Workshop: Unity (HLSL) & ModernGL (GLSL)

## Tools and Research
- [Geogebra](https://www.geogebra.org/u/schlachsahne76) – formulas i used to understand shader-logic
- [Free Unity Textures](https://ambientcg.com/list?sort=popular) – material and test textures  
- [Shader Distance Functions](https://iquilezles.org/articles/distfunctions2d/) – mathematical references  

---

## Shader Demos Unity
### Vertex-Shaders
#### Object-Space Ripple  


<img src="gifs/OS_sphere.gif" alt="Object-Space Ripple Shader" width="480">

**Shader:** `SphereRipple.hlsl`  
Waves are calculated in **object space**, making the ripple effect stick to the object itself. Useful for spherical effects such as ripples on a small planet or sphere.  

---

#### World-Space Ripple  
<img src="gifs/WS_ripple.gif" alt="World-Space Ripple Shader" width="480">

**Shader:** `UniversalRipple.hlsl`  
Waves are calculated in **world space** with a fixed wave center. The effect is independent of object movement, suitable for environmental or global ripple effects.  

---

## Shader Demos ModernGL
### Fragment Shaders
<img src="gifs/bubbles.gif" alt="Simple Fragment Shader" width="480">

**Shader:** `moderngl/bubbles.py`  
Bubble sizes and positions are calculated by the CPU and then drawn onto the screen.

---

##### Generating Gifs from mp4/mkv...
```bash
ffmpeg -i input.mp4-vf "fps=15,scale=400:-1:flags=lanczos,palettegen" palette.png
ffmpeg -ss 0 -t 5 -i input.mp4 -i palette.png -filter_complex "fps=15,scale=400:-1:flags=lanczos[x];[x][1:v]paletteuse" output.gif
```
