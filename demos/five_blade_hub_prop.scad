use <bladegen/bladegen.scad>

bladegen_metric(diameter = 0.20, inner_radius = 0.010, blades = 5, naca_n = 10);
difference() {
  translate([0, 0, -3]) cylinder(r = 15, h = 14, center = true); // note slight overlap due to curvature
  cylinder(d = 6, h = 99, center = true);
}


