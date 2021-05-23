use <bladegen/bladegen.scad>

// To make a circle using BOSL2, use:
// echo(yflip(oval(d = 6, $fn = 8)));
CIRCLE = [[3, 0], [2.42705, 1.76336], [0.927051, 2.85317], [-0.927051, 2.85317], [-2.42705, 1.76336], [-3, 0], [-2.42705, -1.76336], [-0.927051, -2.85317], [0.927051, -2.85317], [2.42705, -1.76336]];


translate([0, 0, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["rectangular"]);
translate([0, 25, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["trapez", 0.5]);
translate([0, 50, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["elliptical"]);
translate([0, 75, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["squarish"]);
translate([0, 100, 0]) bladegen_mm(pitch = 100, diameter = 100, outline = ["rectangular"], aspect = 3);
translate([0, 125, 0]) bladegen_mm(diameter = 100, outline = ["rectangular"], inner_radius = 10);
translate([0, 150, 0]) bladegen_mm(ccw = true, diameter = 100, outline = ["rectangular"], inner_radius = 10);
translate([0, 175, 0]) bladegen_mm(diameter = 100, outline = ["rectangular"], inner_radius = 20, root_shape = [CIRCLE, 10]);
translate([0, 200, 0]) bladegen_mm(turbine = true, diameter = 100, outline = ["rectangular"], inner_radius = 10);
translate([0, 275, 0]) bladegen_mm(diameter = 100, outline = ["elliptical"], inner_radius = 10, blades = 5);

