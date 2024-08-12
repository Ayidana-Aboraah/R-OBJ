const std = @import("std");
const cli = @import("cli");
const converter = @import("converter.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const params = comptime cli.parseParamsComptime(
        \\-h, --help    Display this and exit
        \\-n, --number <usize> BBUB
        \\-s, --string <str>... ABABA
        \\<str>...
        \\
    );

    var diag = cli.Diagnostic{};

    var res = cli.parse(cli.Help, &params, cli.parsers.default, .{
        .diagnostic = &diag,
        .allocator = gpa.allocator(),
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0) std.debug.print("--help\n", .{});
    if (res.args.number) |n| std.debug.print("--number = {}\n", .{n});
    for (res.args.string) |s| std.debug.print("--string = {s}\n", .{s});
    for (res.positionals) |pos| std.debug.print("{s}\n", .{pos});
}
