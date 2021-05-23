include <BOSL2/std.scad>
use <naca.scad>

function blade_cosine_spacing(radius0) =
  sin(radius0 * 90);


function outline_chord(outline = ["rectangular"], radius) =
  (outline[0] == "rectangular")
    ? 1.0 
    : (outline[0] == "trapez")
      ? 1.0 - radius * outline[1]
      : (outline[0] == "elliptical")
        ? sqrt(1 - radius^2)
        : (outline[0] == "squarish")
          ? sqrt(1 - radius^5)
          : 1.0;


function bladegen_helper(radius, outline, pitch, naca, aspect, naca_n, turbine, ccw) = 
  let ( chord = max(0.001, outline_chord(outline, radius))
      , angle = atan2(pitch, 2 * PI * radius)
      , profilea = naca_coords(naca, chord = chord / aspect, n = naca_n)
      , profileb = turbine ? yflip(profilea) : profilea
      , profilec = rot(270 - angle, p = profileb)
      , profiled = ccw ? profilec : xflip(profilec)
      ) 
    profiled;


module bladegen(aspect = 5, pitch = 1, segments = 20, naca = 2412, naca_n = 30, outline = ["elliptical"], blades = 1, inner_radius = 0, turbine = false, ccw = false) {
  for (blade = [1:blades]) {
    rotate([0, 0, 360 / blades * (blade - 1)]) {
      for (i = [1:segments]) {
        let ( radius_sweep = 1 - inner_radius
            , radius1 = inner_radius + radius_sweep * blade_cosine_spacing((i - 1) / segments)
            , radius2 = inner_radius + radius_sweep * blade_cosine_spacing(i / segments)
            , profile1 = bladegen_helper(radius1, outline, pitch, naca, aspect, naca_n, turbine, ccw)
            , profile2 = bladegen_helper(radius2, outline, pitch, naca, aspect, naca_n, turbine, ccw)
            ) {
          yrot(90) {
            skin([profile1, profile2]
                , slices = 0
                , z = [radius1, radius2]
                );
          }
        }
      }
    }
  }
}

module bladegen_inch(aspect = 5, pitch = 4.0, segments = 20, diameter = 5.0, naca = 2412, naca_n = 30, outline = ["elliptical"], blades = 1, inner_radius = 0, turbine = false, ccw = false) {
  scale(diameter / 2 * 25.6) bladegen(aspect = aspect, pitch = pitch / diameter, segments = segments, naca_n = naca_n, naca = naca, outline = outline, blades = blades, inner_radius = inner_radius / (diameter / 2), turbine = turbine, ccw = ccw);
}

module bladegen_metric(aspect = 5, pitch = 0.1, segments = 20, diameter = 0.10, naca = 2412, naca_n = 30, outline = ["elliptical"], blades = 1, inner_radius = 0, turbine = false, ccw = false) {
  scale(diameter * 1000 / 2) bladegen(aspect = aspect, pitch = pitch / diameter, segments = segments, naca_n = naca_n, naca = naca, outline = outline, blades = blades, inner_radius = inner_radius / (diameter / 2), turbine = turbine, ccw = ccw);
}



