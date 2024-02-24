const std = @import("std");

const f32Context = struct {
    pub fn hash(self: f32Context, s: f32) u32 {
        _ = self;
        var x: u32 = 0;
        return x | s;
    }

    pub fn eql(self: f32Context, a: f32, b: f32, b_index: usize) bool {
        _ = self;
        _ = b_index;
        return a == b;
    }
};

fn IntSize(count: usize) type {
    const max = std.math.maxInt;
    return if (count < max(u8)) u8 else if (count < max(u16)) u16 else if (count < max(u24)) u24 else if (count < max(u32)) u32 else if (count < max(u40)) u40 else if (count < max(u48)) u48 else if (count < max(u56)) u56 else if (count < max(u64)) u64 else u128;
}

pub fn convert(path: [:0]const u8) !void {
    var in: std.fs.File = try std.fs.openFileAbsoluteZ(path, .{});
    var out: std.fs.File = try std.fs.createFileAbsoluteZ("out", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit(); // NOTE: maybe check for leaks at some point
    var map = std.ArrayHashMap(f32, usize, f32Context, false).init(allocator);
    map.put(0.0, 1);

    var reader = std.io.bufferedReader(in).reader();
    var buffer = std.io.FixedBufferStream(u8);
    const nl = []u8{10}; // newline
    const n = []u8{0}; // null

    for (reader.streamUntilDelimiter(buffer, '\n', null)) |line| {
        var section = std.mem.splitScalar(u8, line, ' ');
        switch (line[0]) {
            'v' => {
                for (section.next()) |raw| {
                    if (raw == '\n') {
                        _ = try out.write(nl);
                    } else {
                        var val: f32 = try std.fmt.parseFloat(f32, raw);
                        var res = try map.getOrPut(val, map.count() + 1); // TODO: check this out

                        var count = if (res.found_existing) res.value_ptr.* else map.count();
                        const ty = IntSize(count);

                        out.write(std.mem.toBytes(@as(ty, @truncate(count))));
                        out.write(n);
                    }
                }
            },
            'f', 'l', 'p' => {
                for (section.next()) |raw| {
                    if (raw == '\n') {
                        _ = try out.write(nl);
                    } else {
                        var val: usize = std.fmt.parseUnsigned(usize, raw, 10);
                        const ty = IntSize(val);

                        out.write(std.mem.toBytes(@as(ty, @truncate(val))));
                        out.write(n);
                    }
                }
            },
            'u', 'm', 'g' => out.write(line),
            '#' => continue,
        }
    }

    out.write(n); // 0 at the beginning signifies it's the kv section

    const terminator = []u8{ 0, 10 };

    var vals: []f32 = map.keys(); // TODO: Check if they're in order

    for (vals) |val| {
        out.write(std.mem.toBytes(val));
        out.write(terminator);
    }
}

pub fn read(path: [:0]const u8) !void { // TODO: replace void with mesh data type once that's completevar
    var in: std.fs.File = std.fs.openFileAbsoluteZ(path, .{});
    var reader = std.io.bufferedReader(in).reader();
    var buffer = std.io.FixedBufferStream(u8);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit(); // NOTE: maybe check for leaks at some point
    var map = std.AutoHashMap(usize, f32).init(allocator);

    map.put(1, 0.0);

    var count = 2;
    var mode: u8 = 1; // 0 kv, rest are different types of data

    // fill map first
    for (reader.streamUntilDelimiter(buffer, 0, null)) |line| {
        if (mode == 1 and line[0] == 0) {
            mode = 0;
        } else if (mode == 0) { // kv
            var v = try std.fmt.parseFloat(f32, line);
            try map.put(count, v);
            count += 1;
        }
    }

    // mode used for something else here
    for (reader.streamUntilDelimiter(buffer, '\n', null)) |line| {
        if (line[0] == 0) break;
        if (line[line.len - 2] == 0) { // all normal data lines like vertices should end witha  \0\n
            switch (mode) {
                'v' => {}, // TODO: Load into a verticies on mesh object
                'f', 'p', 'l' => {}, // TODO: Load into faces, points, or lines on mesh object
            }
        } else {} // TODO: figure out how to handle materials & groups

    }
}
