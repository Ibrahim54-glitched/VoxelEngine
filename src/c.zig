pub const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});

pub const glad = @cImport({
    @cInclude("glad/glad.h");
});

pub const window = ?*glfw.GLFWwindow;
