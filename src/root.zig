const std = @import("std");

const c = @import("c.zig");
const glfw = c.glfw;
const gl = c.glad;

const eh = @import("utils/simple_error_handling.zig");

// Global Variables
const WIDTH = 800;
const HEIGTH = 600;

pub fn run() void {
    if (glfw.glfwInit() == 0) {
        eh.reportError_Simple("Failed to Initialize");
        return;
    }
    defer glfw.glfwTerminate();

    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, 3);
    glfw.glfwWindowHint(glfw.GLFW_OPENGL_PROFILE, glfw.GLFW_OPENGL_CORE_PROFILE);

    const window = glfw.glfwCreateWindow(WIDTH, HEIGTH, "VoxelEngine", null, null);
    if (window == null) {
        eh.reportError_Simple("Failed to create GLFW window");
        glfw.glfwTerminate();
        return;
    }
    defer glfw.glfwDestroyWindow(window);

    glfw.glfwMakeContextCurrent(window);
    glfw.glfwSwapInterval(1); // Vsync Basically
                             
    const loader: gl.GLADloadproc = @ptrCast(&glfw.glfwGetProcAddress);
    if (gl.gladLoadGLLoader(loader) == 0) {
        eh.reportError_Simple("Failed To Initialize GLAD");
        return;
    }
    _ = glfw.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    // Render Loop
    while (glfw.glfwWindowShouldClose(window) == 0) {
        // Input
        processInput(window);

        // Rendering commands
        gl.glClearColor(0.08, 0.08, 0.08, 1.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);

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
