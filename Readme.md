# HLSL Shader Workshop with Unity & Shadertoy

## Tools and Research
- [Geogebra](https://www.geogebra.org/u/schlachsahne76) – formulas i used to understand shader-logic
- [Free Unity Textures](https://ambientcg.com/list?sort=popular) – material and test textures  
- [Shader Distance Functions](https://iquilezles.org/articles/distfunctions2d/) – mathematical references  

---

## Shader Demos

### Object-Space Ripple  
<img src="gifs/OS_sphere.gif" alt="Object-Space Ripple Shader" width="480">

**Shader:** `SphereRipple.hlsl`  
Waves are calculated in **object space**, making the ripple effect stick to the object itself. Useful for spherical effects such as ripples on a small planet or sphere.  

---

### World-Space Ripple  
<img src="gifs/WS_ripple.gif" alt="World-Space Ripple Shader" width="480">

**Shader:** `UniversalRipple.hlsl`  
Waves are calculated in **world space** with a fixed wave center. The effect is independent of object movement, suitable for environmental or global ripple effects.  

---
