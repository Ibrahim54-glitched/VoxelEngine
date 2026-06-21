const std = @import("std");

const c = @import("c.zig");
const eh = @import("utils/simple_error_handling.zig");
const w = @import("window.zig");
const glf = @import("glad.zig");
const input = @import("input.zig");
const Shader = @import("shaders.zig").Shader;

const glfw = c.glfw;
const gl = c.glad;
const print = std.debug.print;


// Global Variables
const WIDTH = 800;
const HEIGTH = 600;

pub fn run() !void {

    const window = try w.createWindow();
    defer w.deleteWindow(window);
    
    try glf.loadGlad(window);

    // -----------------------------------------------------------------
    var shader: Shader = undefined;


    const vertices = [_]f32 {
        // positions         // colors
        0.5, -0.5, 0.0,  1.0, 0.0, 0.0,   // bottom right
       -0.5, -0.5, 0.0,  0.0, 1.0, 0.0,   // bottom left
        0.0,  0.5, 0.0,  0.0, 0.0, 1.0    // top 
    };

    var VBO: c_uint = undefined;
    var VAO: c_uint = undefined;

    gl.glGenBuffers(1, &VBO);
    gl.glGenVertexArrays(1, &VAO);

    gl.glBindVertexArray(VAO);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, VBO);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), vertices[0..].ptr, gl.GL_STATIC_DRAW);
    // Positions attributes
    gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 6*@sizeOf(f32), null);
    gl.glEnableVertexAttribArray(0);
    // Color Attributes
    gl.glVertexAttribPointer(1, 3, gl.GL_FLOAT, gl.GL_FALSE, 6*@sizeOf(f32), @ptrFromInt(3*@sizeOf(f32)));
    gl.glEnableVertexAttribArray(1);

    try shader.init("shaders/vertexshader.glsl", "shaders/fragmentshader.glsl");
    defer shader.deinit();


    // -----------------------------------------------------------------
    // Render Loop
    while (glfw.glfwWindowShouldClose(window) == 0) {
        // Input
        input.processInput(window);

        // Rendering commands
        gl.glClearColor(0.08, 0.08, 0.08, 1.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);

        shader.use();
        gl.glBindVertexArray(VAO);
        gl.glDrawArrays(gl.GL_TRIANGLES, 0, 3);

        // Check and Call events and swap the buffers
        glfw.glfwSwapBuffers(window);
        glfw.glfwPollEvents();
    }
}
