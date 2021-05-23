# bladegen

Generate propeller blades in OpenSCAD.

![Demo script output](images/demo.png)

Note the propellers and turbine blades generated by this code is not at all
tested in real life scenarios and may be totally wrong.


## Installation

To use bladegen, you should put the `bladegen.scad` in the OpenSCAD library
folder that you will find in the `File` menu of OpenSCAD. Additionally you will
need to install the DiscreteOpenSCAD library
[BOSL2](https://github.com/revarbat/BOSL2) also in the library folder.



## Usage

```openscad
use <bladegen.scad>
  
translate([0, 0, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["rectangular"]);
translate([0, 25, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["trapez", 0.5]);
translate([0, 50, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["elliptical"]);
translate([0, 75, 0]) bladegen_inch(pitch = 4, diameter = 5, outline = ["squarish"]);
translate([0, 100, 0]) bladegen_metric(pitch = 0.10, diameter = 0.10, outline = ["rectangular"], aspect = 3);
translate([0, 125, 0]) bladegen_metric(diameter = 0.10, outline = ["rectangular"], inner_radius = 0.01);
translate([0, 150, 0]) bladegen_metric(ccw = true, diameter = 0.10, outline = ["rectangular"], inner_radius = 0.01);
translate([0, 175, 0]) bladegen_metric(turbine = true, diameter = 0.10, outline = ["rectangular"], inner_radius = 0.01);
translate([0, 250, 0]) bladegen_metric(diameter = 0.10, outline = ["elliptical"], inner_radius = 0.01, blades = 5);
```

If you prefer, open the file `demo.scad` to run the above commands.

All inch lengths and pitch are specified in inces, while the metric version
expects meters.

To make a hub, it must be done manually by a code something like

```openscad
use <bladegen.scad>

bladegen_metric(diameter = 0.20, inner_radius = 0.010, blades = 5, naca_n = 10);
difference() {
  translate([0, 0, -3]) cylinder(r = 15, h = 14, center = true); // note slight overlap due to curvature
  cylinder(d = 6, h = 99, center = true);
}
```




