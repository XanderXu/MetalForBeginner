attribute vec4 a_position;
attribute vec3 a_normal;
uniform mat4 mvp;
uniform mat4 u_m;
uniform mat4 u_p;


varying vec3 normal;

void main() {
    gl_Position = mvp * a_position;
    normal = a_normal * 0.5 + 0.5;
}