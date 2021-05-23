include <BOSL2/std.scad>

// creates a propeller blade
// it has the correct pitch and a predefined pitch and aspect ratio
// pitch is specified in units per revolution
// the blade is one unit long


function naca_params(digits) = 
  [0.01 * floor(digits / 1000), 0.1 * (floor(digits / 100) % 10), 0.01 * (digits % 100)];


function naca_mean_camber(naca_params, x) =
  let ( m = naca_params[0]
      , p = naca_params[1]
      , t = naca_params[2]
      , pp = (m == 0 || p == 0) ? 1 : p
      )
      (x <= p) ? m / pp^2 * (2 * p * x - x^2) : m / (1 - p)^2 * ((1 - 2 * p) + 2 * p * x - x^2);


function naca_thickness(naca_params, x) =
  let (t = naca_params[2])
      t / 0.2 * (0.2969 * sqrt(x) - 0.1260 * x - 0.3516 * x^2 + 0.2843 * x^3 - 0.1015 * x^4);
      

function cosine_spacing(x0) =
  (1 - cos(x0 * 180)) / 2.0;
  

function blade_cosine_spacing(radius0) =
  sin(radius0 * 90);


function naca_top_coords(naca_params, n = 30) =
  [
      for (i = [0:n])
        let ( x = cosine_spacing(i / n)
            , y_t = naca_thickness(naca_params, x)
            , y_c = naca_mean_camber(naca_params, x) 
            , delta_x = 0.001
            , y_c_plus = naca_mean_camber(naca_params, x + delta_x) 
            , theta = atan2((y_c_plus - y_c), delta_x)
            , x_u = x - y_t * sin(theta)
            , y_u = y_c + y_t * cos(theta)
            )
          [x_u, y_u]
  
  ];

function naca_bottom_coords(naca_params, n = 30) =
  [
      for (i = [1:(n - 1)])
        let ( x = cosine_spacing((n - i) / n)
            , y_t = naca_thickness(naca_params, x)
            , y_c = naca_mean_camber(naca_params, x) 
            , delta_x = 0.001
            , y_c_plus = naca_mean_camber(naca_params, x + delta_x) 
            , theta = atan2((y_c_plus - y_c), delta_x)
            , x_l = x + y_t * sin(theta)
            , y_l = y_c - y_t * cos(theta)
            )
          [x_l, y_l]
  
  ];

  
function naca_coords(digits, n = 50, center = 0.25, chord = 1.0) =
  let (naca_params = naca_params(digits))
  [
    for (p = concat(naca_top_coords(naca_params, n = n), naca_bottom_coords(naca_params, n = n)))
      let ( x0 = p[0]
          , y0 = p[1]
          )
          [(x0 - center) * chord, y0 * chord]
  ];


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


module bladegen(aspect = 5, pitch = 1, segments = 20, naca = 2412, naca_n = 30, outline = ["elliptical"], blades = 1, inner_radius = 0, turbine = false, ccw = false) {
  for (blade = [1:blades]) {
    rotate([0, 0, 360 / blades * (blade - 1)]) {
      for (i = [1:segments]) {
        let ( radius_sweep = 1 - inner_radius
            , radius1 = inner_radius + radius_sweep * blade_cosine_spacing((i - 1) / segments)
            , radius2 = inner_radius + radius_sweep * blade_cosine_spacing(i / segments)
            , delta_radius = radius2 - radius1
            , chord1 = max(0.001, outline_chord(outline, radius1))
            , chord2 = max(0.001, outline_chord(outline, radius2))
            , angle1 = atan2(pitch, 2 * PI * radius1)
            , angle2 = atan2(pitch, 2 * PI * radius2)
            , profile1 = naca_coords(naca, chord = chord1 / aspect, n = naca_n)
            , profile2 = naca_coords(naca, chord = chord2 / aspect, n = naca_n)
            , profile1b = turbine ? yflip(profile1) : profile1
            , profile2b = turbine ? yflip(profile2) : profile2
            , profile1c = rot(90 - angle1, p = profile1b)
            , profile2c = rot(90 - angle2, p = profile2b)
            , profile1d = ccw ? profile1c : xflip(profile1c)
            , profile2d = ccw ? profile2c : xflip(profile2c)
            ) {
          yrot(90) {
            skin([profile1d, profile2d]
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



