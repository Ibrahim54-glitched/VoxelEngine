const c = @import("c.zig");

const glfw = c.glfw;
const gl = c.glad;

pub fn processInput(window: c.window) void {
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) == glfw.GLFW_PRESS) {
        glfw.glfwSetWindowShouldClose(window, 1);
    }
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_EQUAL) == glfw.GLFW_PRESS) {
        gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_LINE);
    }
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_MINUS) == glfw.GLFW_PRESS) {
        gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
    }
}
