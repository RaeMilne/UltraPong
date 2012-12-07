class Ball {

  float r;   // radius
  float x,y; // location
  float xspeed,yspeed; // speed
  
  // Constructor
  Ball(float tempR) {
    r = tempR;
    x = random(1, width);
    y = random(1, height);
    xspeed = 10;
    yspeed = 10;
  }

  void reset() {
    x = width/2;
    y = height/2;
    
  }
  void bounceEdges() {
    
    x += xspeed; // Increment x
    y += yspeed; // Increment y
   
    if (y < r || y > (height - r)) {
      yspeed *= -1;
    }
  } 

  void bounceLeft(float pad_x, float pad_y, float pad_ht, float pad_d) {
  
    x += xspeed; // Increment x
    y += yspeed; // Increment y

    // Check paddle contact
    if (x < (pad_x + r + pad_d) && y > pad_y && y < (pad_y + pad_ht)) {
       if (xspeed < 0) {
          xspeed *= -1;
       }
      }
    } 
  
  void bounceRight(float pad_x, float pad_y, float pad_ht, float pad_d) {
  
    x += xspeed; // Increment x
    y += yspeed; // Increment y
  
    // Check paddle contact
    if (x > (pad_x - r) && y > pad_y && y < (pad_y + pad_ht)) {
       if (xspeed > 0) {
          xspeed *= -1;
        }
      } 
    }
  
  
  // Draw the ball
  void display() {
    noStroke();
    fill(255);
    ellipse(x, y, r*2, r*2);
    }
}
