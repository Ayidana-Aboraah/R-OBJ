const std = @import("std");
const cli = @import("cli");
const converter = @import("converter.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const params = comptime cli.parseParamsComptime(
        \\-h, --help    Display this and exit
        \\-c, --convert <str>...Converts the file(s) 
        \\-i, --individually Converts the files individually instead of through shared information (can only be used with -c)
        \\-m, --multithread Makes the conversion multithread and can only be used for reversion and or multiple individual conversions
        \\-r, --revert Reverts the file(s)
        \\-v, --version Output Version information
        \\<str>...
        \\
    );

    var diag = cli.Diagnostic{};

    var res = cli.parse(cli.Help, &params, cli.parsers.default, .{
        .diagnostic = &diag,
        .allocator = gpa.allocator(),
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return;
    };
    defer res.deinit();

    if (res.args.help != 0) try cli.usage(std.io.getStdErr().writer(), cli.Help, &params);
    if (res.args.number) |n| std.debug.print("--number = {}\n", .{n});
    for (res.args.string) |s| std.debug.print("--string = {s}\n", .{s});
    for (res.positionals) |pos| std.debug.print("{s}\n", .{pos});
}
