const std = @import("std");

pub const vertex = struct {
    position: @Vector(3, f32),
    normal: @Vector(3, f32),
    texture: @Vector(2, f32),
};

pub const material = struct {
    name: [:0]u8,
    ambient_colour: @Vector(3, f32),
    diffuse_colour: @Vector(3, f32),
    specular_colour: @Vector(3, f32),
    specular_exponent: f32,
    optical_density: f32,
    disolve: f32,
    illumination: i32,
    // NOTE: may want to see if we can use indexes or a faster way of mapping these names to a finite list
    ambient_colour_map: [:0]u8,
    diffuse_colour_map: [:0]u8,
    specular_colour_map: [:0]u8,
    alpha_texture_map: [:0]u8,
    bump_map: [:0]u8,
};

pub const mesh = struct {
    name: [:0]u8,
    veticies: std.ArrayList(vertex), // NOTE: may replace with []vertex if necessary
    indicies: std.ArrayList(usize), // NOTE: may replace with []u32 if necessary
    material: material,
    pub fn init(alloc: std.mem.Allocator) !mesh{
        return {.veticies = std.ArrayList(vertex).init(alloc);
        };
    }
};

pub fn loadFile() !mesh{

}
