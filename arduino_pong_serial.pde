/*
Rae Milne
 Arduino Pong
 V3.1
 
 2 Dec 2012
 Physical Computing
 
 includes Serial Code from
 Making Things Talk
 by Tom Igoe
 
 */

import processing.serial.*;
import ddf.minim.*;

Minim minim;
AudioPlayer player;

Serial myPort;
int vals[] = new int[2];

final int STATE_START = 0;
final int STATE_PLAY = 1;
final int STATE_SCORE = 2;
final int STATE_WIN = 3;

int state = STATE_START;

//Ping Pong Variables
int rad = 15; //radius
Ball pingPong;   //declare Ball

//Left Paddle Position
float LPx = 0; // x-position 
float LPy = 0; // y-position

//Right Paddle Position
float RPx = 0; // x-position 
float RPy = 0; // y-position
float prevRPy = 0;//previous y-position
float rightMax = 100;
float rightMin = 5;

//Control Variables
int pad_d = 20; //depth of the paddle
int pad_ht = 120; //height of the paddle
//float speed;
int btnVal = 1;

//Score Variables
int p1Score = 0;
int p2Score = 0;
int winScore = 10;



//Background and Image Values
int bgCol = 50;
PShape startImage;

void setup() {

  size(displayWidth, displayHeight);
  shapeMode(CENTER);
  startImage = loadShape("startImage.svg");

  smooth();
  background(bgCol);


  vals[0] = 0;
  vals[1] = 1;

  int portId = 0;
  String portName = Serial.list()[portId];
  myPort = new Serial(this, portName, 9600);

  pingPong = new Ball(rad);

  PFont score;
  score = loadFont("MuseoSans-900-96.vlw");
  textFont(score, 72);
  textAlign(CENTER);

  minim = new Minim(this);
  player = minim.loadFile("pong.mp3", 2048);
}

void draw() {

  switch(state) {
  case STATE_START: 
    drawState_Start();
    break;
  case STATE_PLAY:
    drawState_Play(); 
    break;
  case STATE_SCORE:
    drawState_Score();
    break;  
  case STATE_WIN:
    drawState_Win();
    break;
  }
}

void drawState_Start() {

  background(bgCol);
  shape(startImage, width/2, height/2-100);

  if (btnVal == 0) 
  {
    state = STATE_PLAY;
  }
}

void drawState_Play() {

  player.play();

  background(bgCol);
  drawDividingLine();
  noStroke();

  drawLeftPaddle(); 
  drawRightPaddle(); 
  drawBouncingBall();
  displayScores();

  prevRPy = RPy;
}

void drawState_Score() {

  pingPong.reset();

  if (p1Score == winScore || p2Score == winScore) {
    state = STATE_WIN;
  } 
  else {
    state = STATE_PLAY;
  }
}

void drawLeftPaddle() {  
  LPx = 10;
  LPy = pingPong.y - pad_ht/2;
  LPy = constrain(LPy, 0, (height - pad_ht)); 
  rect(LPx, LPy, pad_d, pad_ht);
}

void drawRightPaddle() {  
  RPx = width-LPx-pad_d;   
  RPy += (RPy - prevRPy) / 200.;
  //RPy = constrain(RPy, 0, (height - pad_ht)); 
  rect(RPx, RPy, pad_d, pad_ht);
}

void drawBouncingBall() {

  pingPong.bounceEdges();

  if (pingPong.x < width/2) {
    pingPong.bounceLeft(LPx, LPy, pad_ht, pad_d);
    pingPong.display();
  }

  if (pingPong.x > width/2) {
    pingPong.bounceRight(RPx, RPy, pad_ht, pad_d); 
    pingPong.display();
  }

  if (pingPong.x < 0) {
    p2Score++;
    state = STATE_SCORE;
  }

  if (pingPong.x > width) {
    p1Score++;
    state = STATE_SCORE;
  }
}

void displayScores() {

  textSize(250);
  text(p1Score, width/4, height/2+50);
  text(p2Score, width-width/4, height/2+50);
}

void drawDividingLine() {
  strokeWeight(8);
  stroke(255);
  for (int i=0; i < height; i++) {
    line(width/2, (i*50), width/2, (i*50)+15);
  }
}

void drawState_Win() {

  player.pause();

  background(bgCol);
  textSize(48);

  if (p1Score == winScore) {
    text("PLAYER ONE WINS!", width/2, height/2);
  }

  if (p2Score == winScore) {
    text("PLAYER TWO WINS!", width/2, height/2);
  }

  text("press button to play again", width/2, height/2 + 75);

  btnVal = int(vals[1]);

  if (btnVal == 0) {
    p1Score = 0;
    p2Score = 0;
    player.rewind();
    state = STATE_PLAY;
  }
}


void serialEvent( Serial ard_port) {

  /*

   if (madeContact == false) {
   ard_port.clear();
   madeContact = true;
   ard_port.write('\r');
   }
   */

  String ard_string = ard_port.readStringUntil( '\n' );

  if ( ard_string != null) {
    ard_string = trim(ard_string);
    println( ard_string );
    vals = int(split(ard_string, ','));

    if ( vals.length == 2) {
      if (vals[0] <= rightMax) {
        float rightRange = rightMax - rightMin;
        RPy = (height-pad_ht) * (vals[0] - rightMin) / rightRange;
      }
      btnVal = vals[1];

      // ard_port.write('\r');
    }
  }
}

void stop()
{
  // always close Minim audio classes when done
  player.close();
  // always stop Minim before exiting
  minim.stop();

  super.stop();
}

