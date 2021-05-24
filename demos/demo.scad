use <bladegen/bladegen.scad>

INCH_MM = 25.6;


translate([0, 0, 0])   bladegen(pitch = 4 * INCH_MM, diameter = 5 * INCH_MM);
translate([0, 25, 0])  bladegen(pitch = 4 * INCH_MM, diameter = 5 * INCH_MM, outline = rectangular_outline());
translate([0, 50, 0])  bladegen(pitch = 4 * INCH_MM, diameter = 5 * INCH_MM, outline = rectangular_outline(taper_tip = 0.5));
translate([0, 75, 0])  bladegen(pitch = 4 * INCH_MM, diameter = 5 * INCH_MM, outline = elliptical_outline(exponent = 2));
translate([0, 100, 0]) bladegen(pitch = 40, diameter = 100, outline = elliptical_outline(aspect_ratio = 3));
translate([0, 125, 0]) bladegen(pitch = 40, diameter = 100, nodes = blade_nodes(inner_radius = 0.10));
translate([0, 150, 0]) bladegen(pitch = 40, diameter = 100, ccw = true);
translate([0, 175, 0]) bladegen(pitch = 40, diameter = 100, nodes = blade_nodes(inner_radius = 0.30), root = ellipse_root(radius = 0.1));
translate([0, 200, 0]) bladegen(pitch = 40, diameter = 100, turbine = true);
translate([0, 225, 0]) bladegen(pitch = 40, diameter = 100, wing_sections = [[0.0, 2440], [0.5, 2420], [1.0, 0010]]);
translate([0, 300, 0]) bladegen(pitch = 40, diameter = 100, nodes = blade_nodes(inner_radius = 0.15), blades = 5);

