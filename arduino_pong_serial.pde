/*
Rae Milne
ULTRAPONG
 
 18 Dec 2012
 Physical Computing
 
 includes Serial Code
 modified from:
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
int speed = 4;
Ball pingPong;   //declare Ball

//Left Paddle Position
float LPx = 0; // x-position 
float LPy = 0; // y-position

//Right Paddle Position
float RPx = 0; // x-position 
float RPy = 0; // y-position
float prevRPy = 0;//previous y-position
float rightMax = 210;
float rightMin = 50;

//Control Variables
int pad_d = 15; //depth of the paddle
int pad_ht = 120; //height of the paddle
int btnVal = 1;

//Score Variables
int p1Score = 0;
int p2Score = 0;
int winScore = 10;

//Background and Image Values
int bgCol = 50;
PShape startImage;

void setup() {

  //set up Background and Start Display
  size(displayWidth, displayHeight);
  shapeMode(CENTER);
  startImage = loadShape("startImage.svg");
  smooth();
  background(bgCol);

  //set up text variables
  PFont score;
  score = loadFont("MuseoSans-900-96.vlw");
  textFont(score, 72);
  textAlign(CENTER);
 
  vals[0] = 0; //initialize Paddle val
  vals[1] = 1; //initialize Button val

  int portId = 0;
  String portName = Serial.list()[portId];
  myPort = new Serial(this, portName, 9600);

  pingPong = new Ball(rad, speed);
  
  //set up audio
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

  player.play(); //start music

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
  RPy += (RPy - prevRPy) / 50.;
  RPy = constrain(RPy, 0, (height - pad_ht)); 
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
  textSize(36);
  text("player one", width/4, 50);
  text("player two", width*3/4, 50);

  textSize(250);
  text(p1Score, width/4, height/2+50);
  text(p2Score, width*3/4, height/2+50);
  //text(RPy, width*3/4, height/2+50);
}

void drawDividingLine() {
  strokeWeight(12);
  stroke(255);
  for (int i=0; i < height; i++) {
    line(width/2, (i*50), width/2, (i*50)+15);
  }
}

void drawState_Win() {

  player.pause();

  background(bgCol);

  if (p1Score == winScore) {
    textSize(72);
    text("PLAYER ONE WINS!", width/2, height/2);
  }

  if (p2Score == winScore) {
    textSize(72);
    text("PLAYER TWO WINS!", width/2, height/2);
  }
  textSize(36);
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

  //read in values
  String ard_string = ard_port.readStringUntil( '\n' );

  if ( ard_string != null) {
    ard_string = trim(ard_string);
    println( ard_string );
    vals = int(split(ard_string, ','));

    float rightRange = rightMax - rightMin;

    if ( vals.length == 2 && vals[0] <= rightMax) {
      //map y-location of right paddle
      RPy = (height-pad_ht) * ((vals[0] - rightMin) / rightRange);
      btnVal = vals[1];
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

