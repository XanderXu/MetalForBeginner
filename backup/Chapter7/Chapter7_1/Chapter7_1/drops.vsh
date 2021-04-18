attribute vec4 a_position;

varying vec2 uv;

void main() {
   
    gl_Position = a_position;
    //调整取值范围，从[-1，1]到[0，1]
    uv = (a_position.xy + 1.0) * 0.5;
}
