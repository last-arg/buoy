const std = @import("std");
const Builder = std.build.Builder;
const Allocator = std.mem.Allocator;
const BufMap = std.BufMap;

pub fn build(b: *Builder) void {

    const mode = b.standardReleaseOptions();
    b.addCIncludePath("/nix/store/hy2kzwsn2q5qa5sdbq95vx9dp9cs26q3-xcb-util-0.4.0-dev/include");

    const exe = b.addExecutable("buoy", "src/main.zig");

    exe.addCompileFlags([][]const u8 {
        "-std=c99",
    //     "-nostdlib",
    });


    exe.setBuildMode(mode);
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("X11");
    exe.linkSystemLibrary("Xrandr");
    // exe.linkSystemLibrary("Xinerama");
    //
    // Need support for struct (and union) return values
    // https://github.com/ziglang/zig/issues/1481
    //
    exe.linkSystemLibrary("xcb");
    // exe.linkSystemLibrary("xcb-util");
    exe.linkSystemLibrary("xcb-keysyms");
    exe.linkSystemLibrary("xcb-randr");

    // exe.addSourceFile("wrappers/xcb.c");

    const c_obj = b.addCObject("xcb-wrapper.c", "xcb-wrapper.c");
    exe.addObject(c_obj);


    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);

    _ = b.env_map.set("DISPLAY", ":1");
    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addCommand(".", b.env_map, [][]const u8{
        exe.getOutputPath(),
    });
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(&exe.step);

}
