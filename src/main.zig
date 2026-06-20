const std = @import("std");

const VoxelEngine = @import("VoxelEngine");

pub fn main() !void {
    try VoxelEngine.run();
}
