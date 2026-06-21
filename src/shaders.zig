const std = @import("std");
const c = @import("c.zig");

const gl = c.glad;

pub const Shader = struct {
    ID: c_uint,

    pub fn init(self: *Shader, comptime vertexFilePath: []const u8, comptime fragmentFilePath: []const u8) !void {
        // debug
        var success: c_int = undefined; 
        var infolog: [512]u8 = undefined;

        // Shader
        const vertexShaderSource = @embedFile(vertexFilePath);
        const fragmentShaderSource = @embedFile(fragmentFilePath);

        var vertexShader: c_uint = undefined;
        var fragmentShader: c_uint = undefined;

        // vertex Shader
        vertexShader = gl.glCreateShader(gl.GL_VERTEX_SHADER); gl.glShaderSource(vertexShader, 1, @ptrCast(&vertexShaderSource), null);
        gl.glCompileShader(vertexShader);

        gl.glGetShaderiv(vertexShader, gl.GL_COMPILE_STATUS, &success);
        if (success == 0) {
            gl.glGetShaderInfoLog(vertexShader, 512, null, &infolog);
            std.debug.print("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n{s}\n", .{infolog});
            return error.VertexShaderCompilationFailed;
        }
        defer gl.glDeleteShader(vertexShader);

        // fragment Shader
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
        
        // ShaderProgram
        self.ID = gl.glCreateProgram();
        gl.glAttachShader(self.ID, vertexShader);
        gl.glAttachShader(self.ID, fragmentShader);
        gl.glLinkProgram(self.ID);

        gl.glGetProgramiv(self.ID, gl.GL_LINK_STATUS, &success);
        if (success == 0) {
            gl.glGetProgramInfoLog(self.ID, 512, null, &infolog);
            std.debug.print("ERROR::SHADER::LINKING::COMPILATION_FAILED\n{s}\n", .{infolog});
            return error.ShaderLinkingCompilationFailed;
        }
    }
    pub fn use(self: *Shader) void {
        gl.glUseProgram(self.ID);
    }
    pub fn deinit(self: *Shader) void {
        gl.glDeleteProgram(self.ID);
    }
    pub fn setFloat(self: *Shader, name: [*:0]const u8, value: f32) void {
        gl.glUniform1f(gl.glGetUniformLocation(self.ID, name), value);
    }
};
