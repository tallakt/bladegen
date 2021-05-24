use <bladegen/bladegen.scad>

diameter = 200;
hub_r = 15;
hub_h = 12;
hole_d = 6;

nodes = blade_nodes(inner_radius = 0.3);
root = ellipse_root(r = [0.2, 0.08], rotate = 40.0, radius = 0.10);

difference() {
  union() {
    bladegen(diameter = 200, pitch = 150, nodes = nodes, root = root, blades = 5);
    translate([0, 0, -1]) cylinder(r = hub_r, h = hub_h, center = true);
  }
  cyl(d = hole_d, h = 99, center = true, $fn = 30);
}


