/*
Rae Milne
 Arduino Pong
 V3.1
 
 2 Dec 2012
 Physical Computing
 
 Includes Serial Code from
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
int rad = 12; //radius

//

//Left Paddle Varibles

float LPx = 0; // x-position 
float LPy = 0; // y-position

//Right Paddle Position

float RPx = 0; // x-position 
float RPy = 0; // y-position
float prevRPy = 0;//previous y-position
float rightMax = 150;
float rightMin = 5;


int pad_d = 10; //depth of the paddle
int pad_ht = 60; //height of the paddle

int playerOneScore = 0;
int playerTwoScore = 0;
int winScore = 10;

Ball pingPong;   //declare Ball

float prevRtPadVal;
float currentRtPadVal;

float speed;
float ySpeedUp = 0;
float ySpeedDown = 0;
int btnVal = 1;

boolean madeContact;

void setup() {

  size(400, 400);
  smooth();
  background(0);

  vals[0] = 0;
  vals[1] = 0;
  // vals[2] = "1";

  int portId = 0;
  String portName = Serial.list()[portId];
  myPort = new Serial(this, portName, 9600);

  pingPong = new Ball(rad);

  PFont font;
  font = loadFont("Helvetica-Bold-28.vlw");
  textAlign(CENTER);
  textFont(font, 18);

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

  background(0);
  textAlign(CENTER);
  text("Press button to Start", width/2, height/2);

  btnVal = int(vals[1]);

  if (btnVal == 0) 
  {
    state = STATE_PLAY;
  }
}

void drawState_Play() {

  player.play();

  println(vals);

  background(0);
  drawDividingLine();
  noStroke();

  drawLeftPaddle(); 

  drawRightPaddle(); 

  drawBouncingBall();

  displayScores();
}

void drawState_Score() {

  pingPong.reset();

  if (playerOneScore == winScore 
    || playerTwoScore == winScore) {
    state = STATE_WIN;
  } 
  else {
    state = STATE_PLAY;
  }
}

void drawState_Win() {

  player.pause();

  background(0);

  if (playerOneScore == winScore) {
    text("Player One Wins!", width/2, height/2);
  }

  if (playerTwoScore == winScore) {
    text("Player Two Wins!", width/2, height/2);
  }

  text("Press button to Play Another Game", width/2, height/2 + 50);

  btnVal = int(vals[1]);

  if (btnVal == 0) {
    playerOneScore = 0;
    playerTwoScore = 0;
    player.rewind();
    state = STATE_PLAY;
  }
}

void drawLeftPaddle() {
  LPx = 25;

  LPy = pingPong.y - pad_ht/2;

  //set boundaries to Y-coordinate
  LPy = constrain(LPy, 0, (height - pad_ht)); 

  rect(LPx, LPy, pad_d, pad_ht);
}

void drawRightPaddle() {

  RPx = width-LPx;   
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
    playerTwoScore++;
    state = STATE_SCORE;
  }

  if (pingPong.x > width) {
    playerOneScore++;
    state = STATE_SCORE;
  }
}

void displayScores() {

  text(playerOneScore, 100, 100);
  text(playerTwoScore, width-100, 100);
}

void drawDividingLine() {
  strokeWeight(5);
  stroke(255);
  line(width/2, 0, width/2, height);
}


void serialEvent( Serial ard_port) {

  if (madeContact == false) {
    ard_port.clear();
    madeContact = true;
    ard_port.write('\r');
  }

  String ard_string = ard_port.readStringUntil( '\n' );

  if ( ard_string != null ) {
    ard_string = trim(ard_string);
    println( ard_string );
    int vals[] = int(split(ard_string, ','));

    if ( vals.length == 2) {
      float rightRange = rightMax - rightMin;
      RPy = height * (vals[1] - rightMin) / rightRange;
      btnVal = vals[0];
      
      ard_port.write('\r');
    }
  }
}

void stop()
{
  // always close Minim audio classes when you are done with them
  player.close();
  // always stop Minim before exiting
  minim.stop();

  super.stop();
}

