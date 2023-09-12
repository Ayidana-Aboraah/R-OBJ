const std = @import("std");

var bw = std.io.bufferedWriter(std.io.getStdOut().writer);
const stdout = bw.writer();

pub fn printRobj(in: std.fs.File) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var map = std.AutoHashMap(usize, f32 || u16).init(gpa.allocator());
    defer gpa.deinit();

    var slider: [10000000000]u8 = undefined;
    
    // split into kv & data
    var kv_ne_data =  std.mem.splitBackwardsSequence(u8, slider, "<KV>\n");
    
    // put kv into map
    var raw_kv = kv_ne_data.first();
    // iterate for every \n & count each one
    // if the number of \n is greater than the possible size of a int than, you expand the expect amount of bytes by 1 (might also want to add a byte everytime you get oveer the total size)

    // iterate through data with kv
}
