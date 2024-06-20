const std = @import("std");
const converter = @import("converter.zig");

test "pop" {
    try converter.convert("../test_data/lamp.obj");
}
