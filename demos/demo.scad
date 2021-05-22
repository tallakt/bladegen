use <bladegen.scad>

module bladegen_demo() {
  translate([0, 0, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["rectangular"]);
  translate([0, 25, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["trapez", 0.5]);
  translate([0, 50, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["elliptical"]);
  translate([0, 75, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["squarish"]);
  translate([0, 100, 0]) bladegen_metric(pitch = 0.10, diameter = 0.10, outline = ["rectangular"], aspect = 3);
  translate([0, 125, 0]) bladegen_metric(diameter = 0.10, outline = ["rectangular"], inner_radius = 0.01);
  translate([0, 150, 0]) bladegen_metric(ccw = true, diameter = 0.10, outline = ["rectangular"], inner_radius = 0.01);
  translate([0, 175, 0]) bladegen_metric(turbine = true, diameter = 0.10, outline = ["rectangular"], inner_radius = 0.01);
  translate([0, 250, 0]) bladegen_metric(diameter = 0.10, outline = ["elliptical"], inner_radius = 0.01, blades = 5);
}

bladegen_demo();

