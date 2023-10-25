const std = @import("std");

var bw = std.io.bufferedWriter(std.io.getStdOut().writer);
const stdout = bw.writer();

pub fn printRobj(in: std.fs.File) !void {
    _ = in;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var map = std.AutoHashMap(usize, f32 || u16).init(gpa.allocator()); 
    defer gpa.deinit();

    var slider: [100000]u8 = undefined;

    // split into kv & data
    var kv_ne_data =  std.mem.splitBackwardsSequence(u8, slider, "<KV>\n");

    // put kv into map
    var raw_kv = kv_ne_data.first();
    var size: usize = 0;
    var i: usize = 0;

    while (i < raw_kv.len) {
        size += if (std.mem.bytesToValue(isize, raw_kv[ i..i+size ]) == -1) 1 else 0;
        map.put( std.mem.bytesToValue(usize, raw_kv[ i..i+size ]) , std.mem.bytesToValue(f32||u16, raw_kv[ i+size..i+size+@sizeOf(f32)]) );
        i += size + 1;
    }

    // iterate for every \n & count each one
    var raw_data = kv_ne_data.next();
    var data_type: []u8 = undefined;
    var lines = std.mem.splitScalar([]u8, raw_data, '\n'); 
    for (lines) |line| {
        if (line.len == 1) { // TODO: check if the line includes \n when checking length
            data_type = line;
        } else {
            var vals = std.mem.splitScalar([]u8, line, ' ');
            
            // TODO: Handle in the Abstract-Syntax-Tree
            
            if ( data_type[0] == 'm' or data_type[0] == 'u' or data_type[0] == 'g') { 
                // TODO: Handle in the Abstract-Syntax-Tree
            } else {
            for (vals) |val|{
                const vType = switch(val.len) {
                    1 => u8,
                    2 => u16,
                    3 => u24,
                    4 => u32,
                    5 => u40,
                    6 => u48,
                    7 => u56,
                    8 => u64,
                };

                _ = map.get( std.mem.bytesToValue( vType, val ) );

                // TODO: Handle in the Abstract-Syntax-Tree
                swtich(data_type) {
                    "v" => {},
                    "vn" => {},
                    "vt" => {},
                    else => {},
                }
            }
            }
        }

    }
}
