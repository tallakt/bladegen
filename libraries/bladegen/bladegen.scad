include <BOSL2/std.scad>
include <BOSL2/fnliterals.scad>
use <naca.scad>

function blade_cosine_spacing(radius0) =
  sin(radius0 * 90);


function blade_nodes(n = 20, inner_radius = 0) =
  assert(inner_radius >= 0.0 && inner_radius <= 1.0, "Inner radius must be between 0 and 1")
  let (remainder = 1.0 - inner_radius)
  [ for (i = [0:n]) inner_radius + remainder * blade_cosine_spacing(i / n) ];


function rectangular_outline(aspect_ratio = 5, taper_tip = 1.0) =
  assert(taper_tip >= 0.0, "Taper tip must be greater than zero")
  function (radius) (2 - 2 * clamp(radius, 0, 1) * (1 - taper_tip) - taper_tip) / aspect_ratio;


function elliptical_outline(aspect_ratio = 5, exponent = 2) =
  let ( area_factors = [1.0, 0.6666666667, 0.7853981635, 0.8413092632, 0.8740191848, 0.8955218748, 0.9107439932]
      , area_factor = area_factors[clamp(floor(exponent - 1), 0, len(area_factors) - 1)],
      , chord_factor = 1 / aspect_ratio / area_factor
      )
    function (radius) chord_factor * sqrt(1 - clamp(radius, 0, 1)^exponent);


function naca_wing(digits = 6320, n = 15, angle_of_attack = 0.0) =
  let (coords = zrot(-angle_of_attack, naca_coords(digits, n = n, chord = 1.0)))
    function (radius) coords;


function naca_wing_sections(wing_sections, n = 15) =
  let ( _dummy0 = map(function (x) assert(is_num(x[0]) && x[0] >= 0.0 && x[0] <= 1.0, "Radius must be 0..1"), wing_sections)
      , _dummy1 = map(function (x) assert(is_num(x[1]) && x[1] >= 0 && x[1] <= 10000 && x[1] == floor(x[1]), "NACA profiles must be four digit numers"), wing_sections)
      , radii = map(function (sect) sect[0], wing_sections)
      , aoas = map(function (sect) len(sect) >= 3 ? sect[2] : 0.0, wing_sections)
      , _dummy3 = assert(max(radii) >= 1.0, "Radius must be defined until 1.0")
      , _dummy4 = assert(min(radii) <= 0.0, "Radius must be defined from 0.0")
      , wing_sections_coords = map(function (sect) zrot(-sect[1], naca_coords(sect[0][1], n = n, chord = 1.0)), zip(wing_sections, aoas))
      , n = len(radii) - 1
      )
    function (radius)
      let( idx = find_first(radius, radii, func = function (a, b) b >= a)
         , idx2 = idx ? min(n, idx) : n
         , idx1 = max(idx2 - 1, 0)
         , delta = radii[idx2] - radii[idx1]
         , delta1 = delta <= 0 ? 1.0 : delta
         )
         interpolate_naca_sections(wing_sections_coords[idx1], wing_sections_coords[idx2], (radius - radii[idx1]) / delta1);


function interpolate_naca_sections(section1, section2, factor) =
  let( factor1 = clamp(factor, 0, 1)
     , n = len(section1) - 1
     , section1s = scale(1 - factor1, section1)
     , section2s = scale(factor1, section2)
     , add_fun = function (pair) [pair[0][0] + pair[1][0], pair[0][1] + pair[1][1]]
     )
  map(add_fun, zip(section1s, section2s));


function clamp(x, low, hi) =
  min(max(x, low), hi);


// note radius given at % blade length, radius % of chord
function ellipse_root(r = [.4, .2], radius = 0.0, $fn = 40, rotate = 0) =
  assert(radius >= 0.0 && radius <= 1.0, "Radius must be between 0 and 1")
  [zrot(rotate, ellipse(r = r, $fn = $fn)), radius];


function bladegen_helper(radius, chord, wing_section, pitch, turbine, ccw) = 
  let ( chord1 = max(0.001, chord)
      , angle = atan2(pitch, 2 * PI * radius)
      , profile0 = scale(chord1, wing_section)
      , profile1 = turbine ? yflip(profile0) : profile0
      , profile2 = rot(270 - angle, p = profile1)
      , profile3 = ccw ? yflip(xflip(profile2)) : xflip(profile2)
      ) 
    profile3;


function bladegen_profiles_helper(nodes, outline, wing_sections, pitch, turbine, ccw) =
  let (n = len(nodes) - 1)
  [
    for (i = [0:n])
      bladegen_helper(nodes[i], outline(nodes[i]), wing_sections(nodes[i]), pitch, turbine, ccw)
  ];


module bladegen( diameter = 1
               , pitch = 1
               , blade_n = 20,
               , inner_radius = 0.0,
               , outline = undef
               , wing_sections = undef
               , blades = 1
               , turbine = false
               , ccw = false
               , root = undef
               ) {
  let ( root_poly = root ? root[0] : undef
      , root_radius = root ? root[1] : undef
      , nodes = blade_nodes(n = blade_n, inner_radius = inner_radius)
      , radius = diameter / 2,
      , normalized_pitch = pitch / radius 
      , n = len(nodes) - 1
      , outline1 = outline ? outline : elliptical_outline()
      , wing_sections1 = wing_sections ? wing_sections : naca_wing()
      , profiles = bladegen_profiles_helper(nodes, outline1, wing_sections1, normalized_pitch, turbine, ccw)
      ) {
    for (blade = [1:blades]) {
      zrot(360 / blades * (blade - 1)) scale(radius) {

        // ending of root with morphing profile to shape
        if (root_radius != undef && nodes[0] > root_radius) {
          yrot(90) {
            skin([profiles[0], zrot(90, scale(outline1(root_radius), ccw_polygon(root_poly)))]
                , slices = 3
                , z = [nodes[0], root_radius]
                , method = "distance"
                );
          };
        }

        // the blade itself
        for (i = [0:(n - 1)]) {
          yrot(90) {
            skin([profiles[i], profiles[i + 1]]
                , slices = 0
                , z = [nodes[i], nodes[i + 1]]
                );
          }
        }
      }
    }
  }
}



