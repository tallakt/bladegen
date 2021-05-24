include <BOSL2/std.scad>
include <BOSL2/fnliterals.scad>
use <naca.scad>

function blade_cosine_spacing(radius0) =
  sin(radius0 * 90);


function blade_nodes(n = 20, inner_radius = 0) =
  assert(inner_radius >= 0.0 && inner_radius <= 1.0, "Inner radius must be between 0 and 1")
  let (remainder = 1.0 - inner_radius)
  [ for (i = [0:n]) inner_radius + remainder * blade_cosine_spacing(i / n) ];


function rectangular_outline(nodes = blade_nodes(), aspect_ratio = 5, taper_tip = 1.0) =
  assert(taper_tip >= 0.0, "Taper tip must be greater than zero")
  [ for (r = nodes) (2 - 2 * r * (1 - taper_tip) - taper_tip) / aspect_ratio ];


function elliptical_outline(nodes = blade_nodes(), aspect_ratio = 5, exponent = 2) =
  let ( area_factors = [1.0, 0.6666666667, 0.7853981635, 0.8413092632, 0.8740191848, 0.8955218748, 0.9107439932]
      , area_factor = area_factors[floor(exponent - 1)],
      , chord_factor = 1 / aspect_ratio / area_factor
      )
    [ for (r = nodes) chord_factor * sqrt(1 - r^exponent) ];


function naca_digits_ensure_list(digits) =
  let ( digits_list = is_num(digits) ? [[0.0, digits], [1.0, digits]] : digits
      , _dummy0 = map(function (x) assert(is_num(x[0]) && x[0] >= 0.0 && x[0] <= 1.0, "Radius must be 0..1"), digits_list)
      , _dummy1 = map(function (x) assert(is_num(x[1]) && x[1] >= 0 && x[1] <= 10000 && x[1] == floor(x[1]), "NACA profiles must be four digit numers"), digits_list)
      )
  assert(is_list(digits_list), "Please supply either a single NACA digit or a list of [blade %, NACA digits]")
  digits_list;


function clamp(x, low, hi) =
  min(max(x, low), hi);


function interpolate_naca_sections(section1, section2, factor) =
  let( factor1 = clamp(factor, 0, 1)
     , n = len(section1) - 1
     , section1s = scale(1 - factor1, section1)
     , section2s = scale(factor1, section2)
     , add_fun = function (pair) [pair[0][0] + pair[1][0], pair[0][1] + pair[1][1]]
     )
  map(add_fun, zip(section1s, section2s));



function wing_sections_interpolated_to_nodes(wing_sections, nodes = blade_nodes(), n = 20) =
  let ( radii = map(function (x) x[0], wing_sections)
      , wing_sections_coords = map(function (x) naca_coords(x[1], n = n, chord = 1.0), wing_sections)
      , n = len(nodes) - 1
      , m = len(wing_sections) - 1
      )
  [
    for (i = [0:n])
      let( radius = nodes[i]
         , idx = find_first(radius, radii, func = function (a, b) b >= a)
         , idx2 = idx ? min(m, idx) : m
         , idx1 = max(idx2 - 1, 0)
         , delta = radii[idx2] - radii[idx1]
         , delta1 = delta <= 0 ? 1.0 : delta
         )
         interpolate_naca_sections(wing_sections_coords[idx1], wing_sections_coords[idx2], (radius - radii[idx1]) / delta1)
  ];


// note radius given at % blade length, radius % of chord
function ellipse_root(r = [.4, .2], radius = 0.0, $fn = 40, rotate = 0) =
  assert(radius >= 0.0 && radius <= 1.0, "Radius must be between 0 and 1")
  [zrot(rotate, oval(r = r, $fn = $fn)), radius];


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
      bladegen_helper(nodes[i], outline[i], wing_sections[i], pitch, turbine, ccw)
  ];



module bladegen( diameter = 1
               , pitch = 1
               , nodes = blade_nodes()
               , outline = undef
               , wing_sections = undef
               , blades = 1
               , turbine = false
               , ccw = false
               , root = undef
               , naca_n = 20
               ) {
  assert(!outline || (len(outline) == len(nodes)), "Length of outline and nodes differ")
  let ( root_poly = root ? root[0] : undef
      , root_radius = root ? root[1] : undef
      , radius = diameter / 2,
      , normalized_pitch = pitch / radius 
      , n = len(nodes) - 1
      , outline1 = outline ? outline : elliptical_outline(nodes, exponent = 5)
      , wing_sections1 = wing_sections ? wing_sections : naca_digits_ensure_list(digits = 2412)
      , node_wing_sections = wing_sections_interpolated_to_nodes(wing_sections1, nodes = nodes, n = naca_n)
      , profiles = bladegen_profiles_helper(nodes, outline1, node_wing_sections, normalized_pitch, turbine, ccw)
      ) {
    for (blade = [1:blades]) {
      zrot(360 / blades * (blade - 1)) scale(radius) {

        // ending of root with morphing profile to shape
        if (root_radius != undef && nodes[0] > root_radius) {
          yrot(90) {
            skin([profiles[0], zrot(90, scale(outline1[0], ccw_polygon(root_poly)))]
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



