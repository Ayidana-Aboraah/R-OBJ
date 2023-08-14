const std = @import("std");

const errors = error{
    Model_Vertex_Overflow,
};

pub fn read(in: std.fs.File, out: std.fs.File) !void {
    var br = std.io.bufferedReader(in.reader());
    var in_reader = br.reader();

    // May allocate on the heap, currently unknown
    const fileSize = (try in.stat()).size;
    var stream: []u8 = [fileSize]u8;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var map = std.AutoHashMap(f32 || u16, usize).init(gpa.allocator());
    defer gpa.deinit();

    while (in_reader.readUntilDelimiterOrEof(stream, '\n')) {
        var split = std.mem.splitScalar(u8, stream, ' ');
        var mode = split.first();

        for (split.next()) |v| {
            switch (mode) {
                'v' => {
                    var f = try std.fmt.parseFloat(f32, v);
                    var entry = try map.getOrPutValue(f, map.count());
                    _ = try out.write(std.mem.asBytes(entry.value_ptr)); //TODO: see if we can use only the active bytes
                },

                'f',
                'p',
                'l',
                => {
                    var i = try std.fmt.parseUnsigned(u16, v, 10);
                    var entry = try map.getOrPutValue(i, map.count());
                    _ = try out.write(std.mem.asBytes(entry.value_ptr));
                },

                else => {
                    out.write(v);
                },
            }

            out.write("<KV>\n"); // Seperator for KV & Data
            // Write KV with V first K second (since the Keys are actually the value in the original one)
            for (map.iterator().next()) |entry| {
                const tType = if (entry.value_ptr.* <= std.math.maxInt(u8)) u8 // write 1 byte
                else if (entry.value_ptr.* <= std.math.MaxInt(u16)) u16 //write 2 bytes
                else if (entry.value_ptr.* <= std.math.MaxInt(u32)) u32 //write 4 bytes
                else if (entry.value_ptr.* <= std.math.MaxInt(u64)) u64 //write 8 bytes
                else if (entry.value_ptr.* <= std.math.MaxInt(u128)) u128 //write 16 bytes
                else return errors.Model_Vertex_Overflow;

                out.write(std.mem.asBytes(@as(tType, @truncate(entry.value_ptr))));
            }
        }
    }
}
