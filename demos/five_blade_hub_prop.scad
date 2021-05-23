include <BOSL2/std.scad>
use <bladegen/bladegen.scad>

difference() {
  union() {
    root_shape = [right(3, yflip(oval(r = [3, 8], $fn = 30))), 10];
    up(3) bladegen_mm(diameter = 200, inner_radius = 20, blades = 5, naca_n = 10, root_shape = root_shape);
    cyl(r = 15, h = 10); // note slight overlap due to curvature
  }
  cyl(d = 6, h = 99);
}


