float[] B; // brownian motion
float[] S; // simple moving average
float[] m; // running minimum
float[] M; // running maximum
float mPrev;
float MPrev; // the Prevs are to keep track of the min and max which would otherwise be forgotten about
float n = 30; // sma argument
float drift = 0;
float vol = 1;

float space_sf = 250; // scaling space by a factor of S will effectively scale time by a factor of sqrt(S)
float time_sf = sqrt(space_sf);
float hustart = 0;
float pace = 0.1;

// initialising togglables
boolean toggleBM = true;
boolean toggleSMA = false;
boolean toggleSMADiff = false;
boolean toggleMax = false;
boolean toggleMin = false;
boolean toggleBrownianHue = true;
boolean toggleSMAHue = true;
boolean toggleSMADiffHue = true;
boolean zumb = false;
boolean reset = false;

// zecret zumblezee mode graphic
PImage zumble;

void setup() {
  fullScreen();
  background(0);
  colorMode(HSB, 360, 100, 100, 100);
  //noSmooth();

  // initialise BM
  B = new float[width/2];
  B[0] = 0;
  for (int i = 1; i < width/2; i++) {
    B[i] = 0;
  }

  // initialise SMA
  S = new float[width/2];
  for (int i = 0; i < n; i++) {
    S[i] = B[i];
  }
  for (int i = (int)n; i < width/2; i++) {
    float tempsum = 0;
    for (int j = 0; j < n; j++) {
      tempsum += B[i - j];
    }
    tempsum /= n;
    S[i] = tempsum;
  }

  // initialise min and max (inequalities in the conditionals look due to flipped y-axis)
  m = new float[width/2];
  M = new float[width/2];
  m[0] = B[0];
  M[0] = B[0];
  for (int i = 1; i < width/2; i++) {
    if (B[i] > m[i-1]) {
      m[i] = B[i];
    } else {
      m[i] = m[i-1];
    }
    if (B[i] < M[i-1]) {
      M[i] = B[i];
    } else {
      M[i] = M[i-1];
    }
  }
  mPrev = B[0];
  MPrev = B[0]; // again, min <--> max due to flipped y-axis

  // initialise the zumblezee
  zumble = loadImage("zumblezee.png");
}

void draw() {
  if (reset == true) {
    for (int i = 0; i < width/2; i++) {
      B[i] = 0;
      S[i] = 0;
      m[i] = 0;
      M[i] = 0;
      hustart = 0;
      drift = 0;
      vol = 1;

      toggleBM = true;
      toggleSMA = false;
      toggleSMADiff = false;
      toggleMax = false;
      toggleMin = false;
      toggleBrownianHue = true;
      toggleSMAHue = true;
      toggleSMADiffHue = true;
      zumb = false;
      reset = false;
    }
  }

  background(0, 0, 15);
  strokeWeight(2.7);

  translate(width/2, height/2);

  // DRAW
  stroke(0, 0, 100);
  float hu = hustart;
  for (int i = 0; i < width/2 - 1; i++) {
    hu += pace;
    hu = hu % 360;
    // draw BM:
    if (toggleBM == true) {
      if (toggleBrownianHue == true) {
        stroke(hu, 70, 100);
      } else {
        stroke(0, 0, 100);
      }
      line(i - width/2, B[i], i + 1 - width/2, B[i+1]);
    }
    // draw SMA:
    stroke(0, 0, 100);
    if (toggleSMAHue == true) {
      stroke((hu + 120) % 360, 70, 100);
    }
    if (toggleSMA == true) {
      line(i - width/2, S[i], i + 1 - width/2, S[i+1]);
    }
    // draw difference:
    stroke(0, 0, 100);
    if (toggleSMADiffHue == true) {
      stroke((hu + 240) % 360, 70, 100);
    }
    if (toggleSMADiff == true) {
      line(i - width/2, B[i]-S[i], i + 1 - width/2, B[i+1]-S[i+1]);
    }
    // draw min:
    stroke(0, 0, 100);
    if (toggleMin == true) {
      line(i - width/2, m[i], i + 1 - width/2, m[i+1]);
    }
    // draw max:
    if (toggleMax == true) {
      line(i - width/2, M[i], i + 1 - width/2, M[i+1]);
    }

    // draw axes scale:
    //line(10, 0, 10 + time_sf, 0);
    //line(10, 0, 10, space_sf);

    // UMBLE EE
    if (zumb == true) {
      image(zumble, -20, -20 + B[width/2 - 1]);
    }
  }

  hustart += pace; // hustart is to ensure colours move across the screen

  // UPDATE
  // compute the next brownian motion point:
  float nuB = B[width/2 - 1] + vol * sqrt(space_sf) * randomGaussian() + drift;
  // compute the next sma point:
  float tempsum = 0;
  for (int j = 0; j < n; j++) {
    tempsum += B[width/2 - 1 - j];
  }
  tempsum /= n;
  float nuS = tempsum;
  // I'm sure there's a more efficient way to update the sma. however, this does the job for my purposes.

  // compute the running min and running max point:
  for (int i = 1; i < width/2; i++) {
    if (B[i] > m[i-1]) {
      m[i] = B[i];
    } else {
      m[i] = m[i-1];
    }
    if (B[i] < M[i-1]) {
      M[i] = B[i];
    } else {
      M[i] = M[i-1];
    }
  }
  m[0] = max(m[1], B[1]);
  M[0] = min(M[0], B[1]);

  // propagate:
  for (int i = 0; i < width/2 - 1; i++) {
    B[i] = B[i+1];
    S[i] = S[i+1];
  }
  B[width/2 - 1] = nuB;
  S[width/2 - 1] = nuS;

  // check for out of bounds:
  if (B[width/2 - 1] > height/2 - 10) {
    for (int i = 0; i < width/2; i++) {
      B[i] -= 10;
      S[i] -= 10;
      m[i] -= 10;
      M[i] -= 10;
    }
  }
  if (B[width/2 - 1] < -height/2 + 10) {
    for (int i = 0; i < width/2; i++) {
      B[i] += 10;
      S[i] += 10;
      m[i] += 10;
      M[i] += 10;
    }
  }

  // BUTTONS
  stroke(0, 0, 85);
  strokeWeight(1);
  textSize(18);

  // first column
  fill(0, 0, 85);
  rect(width/2 - 490, -height/2 + 50, 200, 40, 7);
  fill(0, 0, 15);
  text("Reset", width/2 - 470, -height/2 + 77);

  fill(0, 0, 85);
  rect(width/2 - 490, -height/2 + 110, 90, 40, 7);
  fill(0, 0, 15);
  text("SMA n-", width/2 - 470, -height/2 + 137);

  fill(0, 0, 85);
  rect(width/2 - 380, -height/2 + 110, 90, 40, 7);
  fill(0, 0, 15);
  text("SMA n+", width/2 - 360, -height/2 + 137);

  fill(0, 0, 85);
  rect(width/2 - 490, -height/2 + 170, 200, 40, 7);
  fill(0, 0, 15);
  text("Reset drift", width/2 - 470, -height/2 + 197);

  fill(0, 0, 85);
  rect(width/2 - 490, -height/2 + 230, 90, 40, 7);
  fill(0, 0, 15);
  text("Drift-", width/2 - 470, -height/2 + 257);

  fill(0, 0, 85);
  rect(width/2 - 380, -height/2 + 230, 90, 40, 7);
  fill(0, 0, 15);
  text("Drift+", width/2 - 360, -height/2 + 257);

  fill(0, 0, 85);
  rect(width/2 - 490, -height/2 + 290, 200, 40, 7);
  fill(0, 0, 15);
  text("Reset volatility", width/2 - 470, -height/2 + 317);

  fill(0, 0, 85);
  rect(width/2 - 490, -height/2 + 350, 90, 40, 7);
  fill(0, 0, 15);
  text("Vol-", width/2 - 470, -height/2 + 377);

  fill(0, 0, 85);
  rect(width/2 - 380, -height/2 + 350, 90, 40, 7);
  fill(0, 0, 15);
  text("Vol+", width/2 - 360, -height/2 + 377);

  // second column
  fill(0, 0, 85);
  rect(width/2 - 250, -height/2 + 50, 200, 40, 7);
  fill(0, 0, 15);
  text("Toggle BM", width/2 - 230, -height/2 + 77);

  fill(0, 0, 85);
  rect(width/2 - 250, -height/2 + 110, 200, 40, 7);
  fill(0, 0, 15);
  text("Toggle BM Colours", width/2 - 230, -height/2 + 137);

  fill(0, 0, 85);
  rect(width/2 - 250, -height/2 + 170, 200, 40, 7);
  fill(0, 0, 15);
  text("Toggle SMA", width/2 - 230, -height/2 + 197);

  fill(0, 0, 85);
  rect(width/2 - 250, -height/2 + 230, 200, 40, 7);
  fill(0, 0, 15);
  text("Toggle SMA Colours", width/2 - 230, -height/2 + 257);

  fill(0, 0, 85);
  rect(width/2 - 250, -height/2 + 290, 200, 40, 7);
  fill(0, 0, 15);
  text("Toggle SMA Diff.", width/2 - 230, -height/2 + 317);

  fill(0, 0, 85);
  rect(width/2 - 250, -height/2 + 350, 200, 40, 7);
  fill(0, 0, 15);
  text("Toggle SMA Df. Col.", width/2 - 230, -height/2 + 377);

  fill(0, 0, 85);
  rect(width/2 - 250, -height/2 + 410, 200, 40, 7);
  fill(0, 0, 15);
  text("Toggle running min.", width/2 - 230, -height/2 + 437);

  fill(0, 0, 85);
  rect(width/2 - 250, -height/2 + 470, 200, 40, 7);
  fill(0, 0, 15);
  text("Toggle running max.", width/2 - 230, -height/2 + 497);
}

// BUTTON FUNCTIONALITY AND GRAPHICS
void mouseClicked() {
  if ((mouseX > width - 250) && (mouseX < width - 50) && (mouseY > 50) && (mouseY < 90)) {             // second column
    toggleBM = !toggleBM;

    fill(0, 0, 50);
    rect(width/2 - 250, -height/2 + 50, 200, 40, 7);
    fill(0, 0, 15);
    text("Toggle BM", width/2 - 230, -height/2 + 77);
  } else if ((mouseX > width - 250) && (mouseX < width - 50) && (mouseY > 110) && (mouseY < 150)) {
    toggleBrownianHue = !toggleBrownianHue;

    fill(0, 0, 50);
    rect(width/2 - 250, -height/2 + 110, 200, 40, 7);
    fill(0, 0, 15);
    text("Toggle BM Colours", width/2 - 230, -height/2 + 137);
  } else if ((mouseX > width - 250) && (mouseX < width - 50) && (mouseY > 170) && (mouseY < 210)) {
    toggleSMA = !toggleSMA;

    fill(0, 0, 50);
    rect(width/2 - 250, -height/2 + 170, 200, 40, 7);
    fill(0, 0, 15);
    text("Toggle SMA", width/2 - 230, -height/2 + 197);
  } else if ((mouseX > width - 250) && (mouseX < width - 50) && (mouseY > 230) && (mouseY < 270)) {
    toggleSMAHue = !toggleSMAHue;

    fill(0, 0, 50);
    rect(width/2 - 250, -height/2 + 230, 200, 40, 7);
    fill(0, 0, 15);
    text("Toggle SMA Colours", width/2 - 230, -height/2 + 257);
  } else if ((mouseX > width - 250) && (mouseX < width - 50) && (mouseY > 290) && (mouseY < 330)) {
    toggleSMADiff = !toggleSMADiff;

    fill(0, 0, 50);
    rect(width/2 - 250, -height/2 + 290, 200, 40, 7);
    fill(0, 0, 15);
    text("Toggle SMA Diff.", width/2 - 230, -height/2 + 317);
  } else if ((mouseX > width - 250) && (mouseX < width - 50) && (mouseY > 350) && (mouseY < 390)) {
    toggleSMADiffHue = !toggleSMADiffHue;

    fill(0, 0, 50);
    rect(width/2 - 250, -height/2 + 350, 200, 40, 7);
    fill(0, 0, 15);
    text("Toggle SMA Df. Col.", width/2 - 230, -height/2 + 377);
  } else if ((mouseX > width - 250) && (mouseX < width - 50) && (mouseY > 410) && (mouseY < 450)) {
    toggleMin = !toggleMin;

    fill(0, 0, 50);
    rect(width/2 - 250, -height/2 + 410, 200, 40, 7);
    fill(0, 0, 15);
    text("Toggle running min.", width/2 - 230, -height/2 + 437);
  } else if ((mouseX > width - 250) && (mouseX < width - 50) && (mouseY > 470) && (mouseY < 510)) {
    toggleMax = !toggleMax;

    fill(0, 0, 50);
    rect(width/2 - 250, -height/2 + 470, 200, 40, 7);
    fill(0, 0, 15);
    text("Toggle running max.", width/2 - 230, -height/2 + 497);
  } else if ((mouseX > width - 490) && (mouseX < width - 290) && (mouseY > 50) && (mouseY < 90)) {     // first column
    reset = true;

    fill(0, 0, 50);
    rect(width/2 - 490, -height/2 + 50, 200, 40, 7);
    fill(0, 0, 15);
    text("Reset", width/2 - 470, -height/2 + 77);
  } else if ((mouseX > width - 380) && (mouseX < width - 290) && (mouseY > 110) && (mouseY < 150)) {
    n += 4;

    fill(0, 0, 50);
    rect(width/2 - 380, -height/2 + 110, 90, 40, 7);
    fill(0, 0, 15);
    text("SMA n+", width/2 - 360, -height/2 + 137);
  } else if ((mouseX > width - 490) && (mouseX < width - 400) && (mouseY > 110) && (mouseY < 150)) {
    if (n > 4) {
      n -= 4;
    }

    fill(0, 0, 50);
    rect(width/2 - 490, -height/2 + 110, 90, 40, 7);
    fill(0, 0, 15);
    text("SMA n-", width/2 - 470, -height/2 + 137);
  } else if ((mouseX > width - 490) && (mouseX < width - 290) && (mouseY > 170) && (mouseY < 210)) {
    drift = 0;

    fill(0, 0, 50);
    rect(width/2 - 490, -height/2 + 170, 200, 40, 7);
    fill(0, 0, 15);
    text("Reset drift", width/2 - 470, -height/2 + 197);
  } else if ((mouseX > width - 380) && (mouseX < width - 290) && (mouseY > 230) && (mouseY < 270)) {
    if (drift > -5) {
      drift -= 0.2;
    }

    fill(0, 0, 50);
    rect(width/2 - 380, -height/2 + 230, 90, 40, 7);
    fill(0, 0, 15);
    text("Drift+", width/2 - 360, -height/2 + 257);
  } else if ((mouseX > width - 490) && (mouseX < width - 400) && (mouseY > 230) && (mouseY < 270)) {
    if (drift < 5) {
      drift += 0.2;
    }

    fill(0, 0, 50);
    rect(width/2 - 490, -height/2 + 230, 90, 40, 7);
    fill(0, 0, 15);
    text("Drift-", width/2 - 470, -height/2 + 257);
  } else if ((mouseX > width - 490) && (mouseX < width - 290) && (mouseY > 290) && (mouseY < 330)) {
    vol = 1;

    fill(0, 0, 50);
    rect(width/2 - 490, -height/2 + 290, 200, 40, 7);
    fill(0, 0, 15);
    text("Reset volatility", width/2 - 470, -height/2 + 317);
  } else if ((mouseX > width - 380) && (mouseX < width - 290) && (mouseY > 350) && (mouseY < 390)) {
    if (vol < 10) {
      vol += 0.2;
    }

    fill(0, 0, 50);
    rect(width/2 - 380, -height/2 + 350, 90, 40, 7);
    fill(0, 0, 15);
    text("Vol+", width/2 - 360, -height/2 + 377);
  } else if ((mouseX > width - 490) && (mouseX < width - 400) && (mouseY > 350) && (mouseY < 390)) {
    if (vol > 0.2) {
      vol -= 0.2;
    }

    fill(0, 0, 50);
    rect(width/2 - 490, -height/2 + 350, 90, 40, 7);
    fill(0, 0, 15);
    text("Vol-", width/2 - 470, -height/2 + 377);
  }
}

void keyPressed() {
  if (key == 'b') {
    zumb = !zumb;
  }
}
