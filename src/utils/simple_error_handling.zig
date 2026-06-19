const std = @import("std");

pub fn reportError_Simple(Error: []const u8) void {
    std.debug.print("{s}", .{Error});
}
