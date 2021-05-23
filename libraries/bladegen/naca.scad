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


module naca2d(digits, n = 50, center = 0.25, chord = 1.0) {
  polygon(naca_coords(digits, n = n, center = center, chord = chord));
}

