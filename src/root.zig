const std = @import("std");
const print = std.debug.print;

const c = @import("c.zig"); const glfw = c.glfw;
const gl = c.glad;

const eh = @import("utils/simple_error_handling.zig");

// Global Variables
const WIDTH = 800;
const HEIGTH = 600;

pub fn run() !void {
    if (glfw.glfwInit() == 0) {
        print("GLFW Initializatin Failed", .{});
        return error.GLFWInitializationFailed;
    }
    defer glfw.glfwTerminate();

    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, 3);
    glfw.glfwWindowHint(glfw.GLFW_OPENGL_PROFILE, glfw.GLFW_OPENGL_CORE_PROFILE);

    const window = glfw.glfwCreateWindow(WIDTH, HEIGTH, "VoxelEngine", null, null);
    if (window == null) {
        print("Failed to create GLFW window\n", .{});
        glfw.glfwTerminate();
        return error.WindowCreationFailed;
    }
    defer glfw.glfwDestroyWindow(window);

    glfw.glfwMakeContextCurrent(window);
    glfw.glfwSwapInterval(1); // Vsync Basically
                             
    const loader: gl.GLADloadproc = @ptrCast(&glfw.glfwGetProcAddress);
    if (gl.gladLoadGLLoader(loader) == 0) {
        print("Failed To Initialize GLAD\n", .{});
        return error.GLADInitializationFailed;
    }
    _ = glfw.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    // -----------------------------------------------------------------
    var success: c_int = undefined; 
    var infolog: [512]u8 = undefined;


    const vertices = [_]f32 {
        0.5,  0.5, 0.0,  // top right
        0.5, -0.5, 0.0,  // bottom right
       -0.5, -0.5, 0.0,  // bottom left
       -0.5,  0.5, 0.0   // top left     
    };
    const indices  = [_]c_uint {
        0, 1, 3,
        1, 2, 3
    };

    var VBO: c_uint = undefined;
    var VAO: c_uint = undefined;
    var EBO: c_uint = undefined;

    gl.glGenBuffers(1, &VBO);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, VBO);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), vertices[0..].ptr, gl.GL_STATIC_DRAW);

    gl.glGenVertexArrays(1, &VAO);
    gl.glBindVertexArray(VAO);

    gl.glGenBuffers(1, &EBO);
    gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, EBO);
    gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, @sizeOf(@TypeOf(indices)), indices[0..].ptr, gl.GL_STATIC_DRAW);


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

    // Linking Vertex Attributes
    gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 3*@sizeOf(f32), null);
    gl.glEnableVertexAttribArray(0);

    // -----------------------------------------------------------------
    // Render Loop
    while (glfw.glfwWindowShouldClose(window) == 0) {
        // Input
        processInput(window);

        // Rendering commands
        gl.glClearColor(0.08, 0.08, 0.08, 1.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);

        gl.glUseProgram(shaderProgram);
        gl.glBindVertexArray(VAO);
        gl.glDrawElements(gl.GL_TRIANGLES, 6, gl.GL_UNSIGNED_INT, null);

        // Check and Call events and swap the buffers
        glfw.glfwSwapBuffers(window);
        glfw.glfwPollEvents();
    }
}

fn framebuffer_size_callback(window: c.window, width: c_int, height: c_int) callconv(.c) void {
    _ = window;
    gl.glViewport(0, 0, width, height);
}

fn processInput(window: c.window) void {
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) == glfw.GLFW_PRESS) {
        glfw.glfwSetWindowShouldClose(window, 1);
    }
}
