const std = @import("std");
const types = @import("../loader.zig");

pub const f32Context = struct {
    pub fn hash(self: f32Context, s: f32) u32 {
        _ = self;

        return @as(u32, @bitCast(s));
    }

    pub fn eql(self: f32Context, a: f32, b: f32, b_index: usize) bool {
        _ = self;
        _ = b_index;
        return a == b;
    }
};

fn IntSize(count: usize) type {
    const max = std.math.maxInt;
    return if (count < max(u8)) u8 else if (count < max(u16)) u16 else if (count < max(u24)) u24 else if (count < max(u32)) u32 else if (count < max(u40)) u40 else if (count < max(u48)) u48 else if (count < max(u56)) u56 else u64;
}

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const nl = []u8{10}; // newline
const n = []u8{0}; // null
const terminator = []u8{ 0, 10 };

// TODO: remember to defer the deinit of the gpa allocator & map
pub fn initWriteMap(map: *std.ArrayHashMap(f32, usize, f32Context, false)) !void {
    map.* = std.ArrayHashMap(f32, usize, f32Context, false).init(allocator);
    try map.put(0.0, 1);
}

pub fn initReadMap(map: *std.AutoHashMap(usize, f32)) !void {
    map = std.AutoHashMap(usize, f32, false).init(allocator);
    try map.put(1, 0.0);
}

pub fn writeMap(map: std.AutoHashMap(f32, usize)) !void {
    var out: std.fs.File = try std.fs.createFileAbsoluteZ("kv.rkv", .{});
    for (map.keyIterator().next()) |val| {
        out.write(std.mem.toBytes(val));
        out.write(terminator); // This might be a cause for bugs later
    }
}

pub fn fillMap(path: [:0]u8, map: *std.AutoHashMap(usize, f32)) void {
    const in: std.fs.File = std.fs.openFileAbsoluteZ(path, .{});
    var reader = std.io.bufferedReader(in).reader();
    const buffer = std.io.FixedBufferStream(u8);
    var count = 1;

    for (reader.streamUntilDelimiter(buffer, 0, null)) |line| {
        try map.put(count, try std.fmt.parseFloat(f32, line));
        count += 1;
    }
}

pub fn convertOBJ(path: [:0]u8, map: *std.ArrayHashMap(f32, usize, f32Context, false)) !void {
    const in = try std.fs.createFileAbsoluteZ(path, .{}); //TODO: Proper error handling
    var out = try std.fs.createFileAbsoluteZ("out.robj", .{});

    var reader = std.io.bufferedReader(in).reader();
    const buffer = std.io.FixedBufferStream(u8);

    // line the whole line
    // sections are the pieces of the line
    // indicies are the pieces of a section

    for (reader.streamUntilDelimiter(buffer, '\n', null)) |line| {
        var sections = std.mem.splitScalar(u8, line, ' ');
        sectLoop: for (sections.next()) |sect| {
            switch (line[0]) {
                'v' => {
                    const idx = try map.getOrPut(try std.fmt.parseFloat(f32, sect), map.count() + 1); // TODO: check this out

                    const vIdx = if (idx.found_existing) idx.value_ptr.* else map.count();
                    const uType = IntSize(vIdx);

                    out.write(std.mem.toBytes(@as(uType, @truncate(vIdx))));
                    out.write(n);
                },
                'f' => {
                    var indicies = std.mem.splitScalar(u8, sect, '/');

                    for (indicies.next()) |indice| {
                        const val: usize = std.fmt.parseUnsigned(usize, indice, 10);
                        const uType = IntSize(val);

                        out.write(std.mem.toBytes(@as(uType, @truncate(val))));
                        if (indicies.index + 1 != indicies.buffer.len) out.write("/");
                    }
                    out.write(n);
                },
                'l', 'p' => {
                    const val: usize = std.fmt.parseUnsigned(usize, sect, 10);
                    const uType = IntSize(val);

                    out.write(std.mem.toBytes(@as(uType, @truncate(val))));
                    out.write(n);
                },
                'u', 'm', 'g' => {
                    out.write(line);
                    break :sectLoop;
                },
                '#' => continue :sectLoop,
            }
        }

        _ = try out.write(nl);
    }
}

// pub fn read(path: [:0]const u8, map: std.AutoHashMap(usize, f32), mesh_alloc: std.mem.Allocator) !types.mesh { // TODO: replace void with mesh data type once that's completevar
//    const in: std.fs.File = std.fs.openFileAbsoluteZ(path, .{});
//    var reader = std.io.bufferedReader(in).reader();
//    const buffer = std.io.FixedBufferStream(u8);
//
//
//     var mesh:types.mesh = types.mesh.init(mesh_alloc);
//     var mode = 'v';
//
//     // mode used for something else here
//     for (reader.streamUntilDelimiter(buffer, '\n', null)) |line| {
//         if (line[0] == 0) break;
//         if (line[line.len - 2] == 0) { // all normal data lines like vertices should end witha  \0\n
//             switch (mode) {
//                 'v' => {}, // TODO: Load into a verticies on mesh object
//                 'f', 'p', 'l' => {}, // TODO: Load into faces, points, or lines on mesh object
//             }
//         } else {} // TODO: figure out how to handle materials & groups
//
//     }
// }
