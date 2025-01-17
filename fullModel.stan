// generated with brms 2.10.0
functions {
}
data {
  int<lower=1> N;  // number of observations
  vector[N] Y;  // response variable
  int<lower=1> K;  // number of population-level effects
  matrix[N, K] X;  // population-level design matrix
  // data for group-level effects of ID 1
  int<lower=1> N_1;  // number of grouping levels
  int<lower=1> M_1;  // number of coefficients per level
  int<lower=1> J_1[N];  // grouping indicator per observation
  // group-level predictor values
  vector[N] Z_1_1;
  int prior_only;  // should the likelihood be ignored?
}
transformed data {
  int Kc = K - 1;
  matrix[N, Kc] Xc;  // centered version of X without an intercept
  vector[Kc] means_X;  // column means of X before centering
  for (i in 2:K) {
    means_X[i - 1] = mean(X[, i]);
    Xc[, i - 1] = X[, i] - means_X[i - 1];
  }
}
parameters {
  vector[Kc] b;  // population-level effects
  // temporary intercept for centered predictors
  real Intercept;
  real<lower=0> sigma;  // residual SD
  vector<lower=0>[M_1] sd_1;  // group-level standard deviations
  // standardized group-level effects
  vector[N_1] z_1[M_1];
}
transformed parameters {
  // actual group-level effects
  vector[N_1] r_1_1 = (sd_1[1] * (z_1[1]));
}
model {
  // initialize linear predictor term
  vector[N] mu = Intercept + Xc * b;
  for (n in 1:N) {
    // add more terms to the linear predictor
    mu[n] += r_1_1[J_1[n]] * Z_1_1[n];
  }
  // priors including all constants
  target += normal_lpdf(b[1] | -3,1);
  target += normal_lpdf(b[2] | -3,1);
  target += normal_lpdf(b[3] | 1,1);
  target += normal_lpdf(Intercept | -5,1.5);
  target += student_t_lpdf(sigma | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10);
  target += cauchy_lpdf(sd_1 | 0,1)
    - 1 * cauchy_lccdf(0 | 0,1);
  target += normal_lpdf(z_1[1] | 0, 1);
  // likelihood including all constants
  if (!prior_only) {
    target += normal_lpdf(Y | mu, sigma);
  }
}
generated quantities {
  // actual population-level intercept
  real b_Intercept = Intercept - dot_product(means_X, b);
  // additionally draw samples from priors
  real prior_b_1 = normal_rng(-3,1);
  real prior_b_2 = normal_rng(-3,1);
  real prior_b_3 = normal_rng(1,1);
  real prior_Intercept = normal_rng(-5,1.5);
  real prior_sigma = student_t_rng(3,0,10);
  real prior_sd_1 = cauchy_rng(0,1);
  // use rejection sampling for truncated priors
  while (prior_sigma < 0) {
    prior_sigma = student_t_rng(3,0,10);
  }
  while (prior_sd_1 < 0) {
    prior_sd_1 = cauchy_rng(0,1);
  }
}

