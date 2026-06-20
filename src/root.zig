const std = @import("std");

const c = @import("c.zig");
const eh = @import("utils/simple_error_handling.zig");
const w = @import("window.zig");
const glf = @import("glad.zig");
const input = @import("input.zig");

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
    var success: c_int = undefined; 
    var infolog: [512]u8 = undefined;


    const vertices = [_]f32 {
        -0.5, -0.5, 0.0,  // left 
         0.5, -0.5, 0.0,  // right
         0.0,  0.5, 0.0,  // top 
    };

    var VBO: c_uint = undefined;
    var VAO: c_uint = undefined;

    gl.glGenBuffers(1, &VBO);
    gl.glGenVertexArrays(1, &VAO);

    gl.glBindVertexArray(VAO);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, VBO);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), vertices[0..].ptr, gl.GL_STATIC_DRAW);
    gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 3*@sizeOf(f32), null);
    gl.glEnableVertexAttribArray(0);

    // Vertex Shader
    var vertexShader: c_uint = undefined;
    const vertextShaderSource = @embedFile("shaders/vertexshader.glsl");
    vertexShader = gl.glCreateShader(gl.GL_VERTEX_SHADER);
    gl.glShaderSource(vertexShader, 1, @ptrCast(&vertextShaderSource), null);
    gl.glCompileShader(vertexShader);

    gl.glGetShaderiv(vertexShader, gl.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        gl.glGetShaderInfoLog(vertexShader, 512, null, &infolog);
        std.debug.print("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n{s}\n", .{infolog});
        return error.VertexShaderCompilationFailed;
    }
    defer gl.glDeleteShader(vertexShader);

    // Fragment Shader
    var fragmentShader: c_uint = undefined;
    const fragmentShaderSource = @embedFile("shaders/fragmentshader.glsl");
    fragmentShader = gl.glCreateShader(gl.GL_FRAGMENT_SHADER);
    gl.glShaderSource(fragmentShader, 1, @ptrCast(&fragmentShaderSource), null);
    gl.glCompileShader(fragmentShader);

    gl.glGetShaderiv(fragmentShader, gl.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        gl.glGetShaderInfoLog(fragmentShader, 512, null, &infolog);
        std.debug.print("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n{s}\n", .{infolog});
        return error.FragmentShaderCompilationFailed;
    }
    defer gl.glDeleteShader(fragmentShader);

    // Linking Shader
    var shaderProgram: c_uint = undefined;
    shaderProgram = gl.glCreateProgram();
    gl.glAttachShader(shaderProgram, vertexShader);
    gl.glAttachShader(shaderProgram, fragmentShader);
    gl.glLinkProgram(shaderProgram);

    gl.glGetProgramiv(shaderProgram, gl.GL_LINK_STATUS, &success);
    if (success == 0) {
        gl.glGetProgramInfoLog(shaderProgram, 512, null, &infolog);
        std.debug.print("ERROR::SHADER::LINKING::COMPILATION_FAILED\n{s}\n", .{infolog});
        return error.ShaderLinkingCompilationFailed;
    }
    defer gl.glDeleteProgram(shaderProgram);

    // -----------------------------------------------------------------
    // Render Loop
    while (glfw.glfwWindowShouldClose(window) == 0) {
        // Input
        input.processInput(window);

        // Rendering commands
        gl.glClearColor(0.08, 0.08, 0.08, 1.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);

        gl.glUseProgram(shaderProgram);
        gl.glBindVertexArray(VAO);
        gl.glDrawArrays(gl.GL_TRIANGLES, 0, 3);

        // Check and Call events and swap the buffers
        glfw.glfwSwapBuffers(window);
        glfw.glfwPollEvents();
    }
}
