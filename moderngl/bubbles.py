import moderngl
import moderngl_window as mglw
import numpy as np
import random
import time as pytime

# --- Shader ---
VERTEX_SHADER = """
#version 330
in vec2 in_vert;
out vec2 uv;
void main() {
    gl_Position = vec4(in_vert, 0.0, 1.0);
    uv = in_vert * 0.5 + 0.5;  // [-1,1] → [0,1]  Normalisierung
}
"""

FRAGMENT_SHADER = """
#version 330           
uniform float iTime;
//uniform vec2 iResolution;
uniform vec3 iPositions[10]; // radius, x, y
in vec2 uv; 
out vec4 fragColor;
void main() {

    float mask = 0.0; // Startwert
    vec3 color = vec3(0.0,1.0,0.8);
    for (int i = 0; i < 10; i++) {
        float r = iPositions[i].x + iTime*0.0001;
        vec2 center = iPositions[i].yz;

        float abstand = length(uv - center);
        //float mask = 1.0 - step(r, abstand); // 0 wenn abstand < r , sonst 1, harter Übergang

        float m = 1.0 - smoothstep(r, r + 0.03, abstand);
        mask = max(mask,m);

    }

    fragColor = vec4(vec3(mask)*color, 1.0);
}
"""

class App(mglw.WindowConfig):
    window_size = (800, 800)
    gl_version = (3, 3)
    title = "ModernGL"
    vsync = False


    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # Shader-Programm
        self.prog = self.ctx.program(
            vertex_shader=VERTEX_SHADER,
            fragment_shader=FRAGMENT_SHADER,
        )
        self.FPS = 5

        # Vollbild-Quad
        vertices = np.array([ 
            -1.0, -1.0,  # unten links
             1.0, -1.0,  # unten rechts
            -1.0,  1.0,  # oben links
             1.0,  1.0,  # oben rechts
        ])
        vbo = self.ctx.buffer(vertices.astype("f4").tobytes())
        self.quad = self.ctx.simple_vertex_array(self.prog, vbo, "in_vert")

    def on_render(self, time: float, frame_time: float):
        self.ctx.clear(0.0, 0.0, 0.0, 1.0)
        self.prog['iTime'].value = time  # Zeit an Shader übergeben
        self.prog["iPositions"].value = create_positions()
        #self.prog['iResolution'].value = self.window_size  # Fenstergröße an Shader übergeben
        # Hintergrund zeichnen
        pytime.sleep(max(0, 1/self.FPS - frame_time)) # Frameratebegrenzung
        self.quad.render(moderngl.TRIANGLE_STRIP)

def create_positions():
    circ_data = []
    for i in range(10):
        r = 0.1 * random.random()
        x = random.random()
        y = random.random()
        circ_data.append((r, x, y))   # Tupel (r, x, y)
    return circ_data

if __name__ == "__main__":
   
    mglw.run_window_config(App)
    