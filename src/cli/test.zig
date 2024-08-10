const std = @import("std");
const converter = @import("converter.zig");

test "bang" {
    var map: std.ArrayHashMap(f32, usize, converter.f32Context, false) = undefined;
    try converter.initWriteMap(&map);
    try converter.convertOBJ(@constCast("../../test_data/lamp.obj"), &map);
}
