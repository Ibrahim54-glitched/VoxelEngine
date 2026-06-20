const std = @import("std");
const c = @import("c.zig");

const glfw = c.glfw;
const print = std.debug.print;

const WIDTH = 800;
const HEIGTH = 600;
const TITLE = "VoxelEngine";

pub fn createWindow() !c.window {
    if (glfw.glfwInit() == 0) {
        print("GLFW Initializatin Failed", .{});
        return error.GLFWInitializationFailed;
    }
    // defer glfw.glfwTerminate();

    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, 3);
    glfw.glfwWindowHint(glfw.GLFW_OPENGL_PROFILE, glfw.GLFW_OPENGL_CORE_PROFILE);

    const window = glfw.glfwCreateWindow(WIDTH, HEIGTH, @ptrCast(&TITLE), null, null);
    if (window == null) {
        print("Failed to create GLFW window\n", .{});
        glfw.glfwTerminate();
        return error.WindowCreationFailed;
    }

    glfw.glfwMakeContextCurrent(window);
    glfw.glfwSwapInterval(1); // Vsync Basically
     
    return window;
}
pub fn deleteWindow(window: c.window) void {
    glfw.glfwTerminate();
    glfw.glfwDestroyWindow(window);
}
