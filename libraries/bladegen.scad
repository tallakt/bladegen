use <discrete.scad>;

// creates a propeller blade
// it has the correct pitch and a predefined pitch and aspect ratio
// pitch is specified in units per revolution
// the blade is one unit long


function naca_digits(digits) = 
  [floor(digits / 1000), floor(digits / 100) % 10, digits % 100];


function naca_mean_camber(digits, x) =
  let ( naca_digits = naca_digits(digits)
      , m = naca_digits[0] * 0.01
      , p = naca_digits[1] * 0.1
      , t = naca_digits[2] * 0.01
      , pp = (m == 0 || p == 0) ? 1 : p
      )
      (x <= p) ? m / pp^2 * (2 * p * x - x^2) : m / (1 - p)^2 * ((1 - 2 * p) + 2 * p * x - x^2);


function naca_thickness(digits, x) =
  let ( naca_digits = naca_digits(digits)
      , t = naca_digits[2] * 0.01
      )
      t / 0.2 * (0.2969 * sqrt(x) - 0.1260 * x - 0.3516 * x^2 + 0.2843 * x^3 - 0.1015 * x^4);
      

function cosine_spacing(x0) =
  (1 - cos(x0 * 180)) / 2.0;
  

function blade_cosine_spacing(radius0) =
  sin(radius0 * 90);


function dp_naca_top(digits, n = 30) =
  [
      for (i = [0:n])
        let ( x = cosine_spacing(i / n)
            , y_t = naca_thickness(digits, x)
            , y_c = naca_mean_camber(digits, x) 
            , delta_x = 0.001
            , y_c_plus = naca_mean_camber(digits, x + delta_x) 
            , theta = atan2((y_c_plus - y_c), delta_x)
            , x_u = x - y_t * sin(theta)
            , y_u = y_c + y_t * cos(theta)
            )
          [x_u, y_u]
  
  ];

function dp_naca_bottom(digits, n = 30) =
  [
      for (i = [1:(n - 1)])
        let ( x = cosine_spacing((n - i) / n)
            , y_t = naca_thickness(digits, x)
            , y_c = naca_mean_camber(digits, x) 
            , delta_x = 0.001
            , y_c_plus = naca_mean_camber(digits, x + delta_x) 
            , theta = atan2((y_c_plus - y_c), delta_x)
            , x_l = x + y_t * sin(theta)
            , y_l = y_c - y_t * cos(theta)
            )
          [x_l, y_l]
  
  ];

  
function dp_naca(digits, n = 50, center = 0.25, chord = 1.0) =
  [
    for (p = concat(dp_naca_top(digits, n = n), dp_naca_bottom(digits, n = n)))
      let ( x0 = p[0]
          , y0 = p[1]
          )
          [(x0 - center) * chord, y0 * chord]
  ];


function dp_mirror_y(points) =
  [
    for (p = points) [p[0], -p[1]]
  ];

function dp_mirror_x(points) =
  [
    for (p = points) [p[0], -p[1]]
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
            , chord1 = outline_chord(outline, radius1)
            , chord2 = outline_chord(outline, radius2)
            , angle1 = atan2(pitch, 2 * PI * radius1)
            , angle2 = atan2(pitch, 2 * PI * radius2)
            , profile1 = dp_naca(naca, chord = chord1 / aspect, n = naca_n)
            , profile2 = dp_naca(naca, chord = chord2 / aspect, n = naca_n)
            , profile1b = turbine ? dp_mirror_y(profile1) : profile1
            , profile2b = turbine ? dp_mirror_y(profile2) : profile2
            , profile1c = dp_rotate(profile1b, angle1 - 90)
            , profile2c = dp_rotate(profile2b, angle2 - 90)
            , profile1d = ccw ? profile1c : dp_mirror_x(profile1c)
            , profile2d = ccw ? profile2c : dp_mirror_x(profile2c)
            ) {
          translate([radius1, 0, 0]) rotate([0, 90, 0]) {
            dm_polyhedron(dm_extrude(
                profile1d,
                profile2d,
                1,
                delta_radius
                ));
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



