const std = @import("std");
const expect = std.testing.expect;

fn pop(comptime T: type, value: u128) !void {
    var v = std.mem.bytesAsValue(T, @as(*[@sizeOf(T)]u8, @ptrCast(@constCast(std.mem.asBytes(&value)))));
    std.debug.print("\n{d} : {s}", .{ v.*, @typeName(@TypeOf(v.*)) });
    try expect(v.* == std.math.maxInt(T));
    try expect(@sizeOf(@TypeOf(v.*)) == @sizeOf(T));
}

test "dynamic writing" {
    var buf: [8]u8 = [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 };
    const u8_max = std.math.maxInt(u8);
    const u16_max = std.math.maxInt(u16);
    const u32_max = std.math.maxInt(u32);
    const u64_max = std.math.maxInt(u64);
    const u128_max = std.math.maxInt(u128);

    try expect(u8_max == 255);

    try pop(u8, u8_max);

    try pop(u16, u16_max);

    try pop(u32, u32_max);

    try pop(u64, u64_max);

    try pop(u128, u128_max);

    std.mem.writeIntSliceLittle(u8, &buf, u8_max);
    try expect(@as(u8, @bitCast(buf[0])) == std.math.maxInt(u8));
    for (buf[1..]) |byte| try expect(byte == 0);
}

const Poppers = error{
    Poppy,
    Poppie,
    Pop_pop,
};
fn makeMeAMilagroMan() !bool {
    return Poppers.Pop_pop;
}
test "Returning An Error" {
    // _ = try makeMeAMilagroMan();
}
