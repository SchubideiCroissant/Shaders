# Shader Workshop: Unity (HLSL) & ModernGL (GLSL)

## Tools and Research
- [Geogebra](https://www.geogebra.org/u/schlachsahne76) – formulas i used to understand shader-logic
- [Free Unity Textures](https://ambientcg.com/list?sort=popular) – material and test textures  
- [Shader Distance Functions](https://iquilezles.org/articles/distfunctions2d/) – mathematical references  

---

## Shader Demos Unity
### Universal Shaders
#### Water Shader

**Shader:** `Waves.shader` 
<img src="gifs/waves.gif" alt="Wave-Shader" width="480">

##### Basic Concept

The water surface is displaced by combining several sine functions.  
Each sine controls an oscillation in a different spatial direction or pattern (radial, diagonal, noisy, etc.).  
The resulting value modifies the vertex position along the surface normal.


\[
W(x, z, t) = \sum_{i=1}^{N} A_i \cdot \sin\!\big( g_i(x, z)\cdot f_i  - \omega_i t + \varphi_i\big)
\]

- \(A_i\) amplitude controlling the wave height  
- \(g_i(x, z)\) spatial function such as a distance, a projection, or a simple axis 
- \(f_i\) spatial frequency controlling the number of waves (inverse of wavelength)  
- \(\omega_i\) temporal frequency controlling wave speed 
- \(t\) global time provided by Unity
- \(\varphi_i\) phase offset, optionally random for noise  

The displaced vertex is computed as

\[
p' = p + n \cdot W(x,z,t)
\]

- \(p'\) displaced world position of the vertex  
- \(p\) original world position of the vertex  
- \(n\) world-space normal of the vertex  
- \(W(x,z,t)\) wave function evaluated at the vertex position and global time  

On a flat plane mesh (with normals pointing upwards) this means a vertical displacement, while on curved meshes the displacement follows the local surface normals.
 

This formulation allows mixing multiple sine waves to create more natural and complex wave interference patterns.


---

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
### Fragement-Shaders
#### Screen-Position Shader
coming soon
**Shader:** `PositionShader.shader` 

---

#### Camera-Depth Shader
coming soon
**Shader:** `DepthShader.shader` 


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
