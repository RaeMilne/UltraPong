/*
Rae Milne
 Arduino Pong
 V3.1
 
 2 Dec 2012
 Physical Computing
 
 */

import processing.serial.*;
import ddf.minim.*;

Minim minim;
AudioPlayer player;

Serial myPort;
String vals[] = new String[2];

final int STATE_START = 0;
final int STATE_PLAY = 1;
final int STATE_SCORE = 2;
final int STATE_WIN = 3;

int state = STATE_START;

int rad = 12; //radius of the ping pong ball
float LPx = 25; //x-position of left paddle
float RPx = 365; //x-position of right paddle
float LPy = 0;
float RPy = 0;

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

void setup() {

  size(400, 400);
  smooth();
  background(0);

  vals[0] = "0";
  vals[1] = "1";
  // vals[2] = "1";
  prevRtPadVal = 0;

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

  LPy = pingPong.y - pad_ht/2;
  //RPy = pingPong.y - pad_ht/2;

  currentRtPadVal = float(vals[0]);
  /*
  speed = abs(currentRtPadVal - prevRtPadVal);
   
   print("speed: ");
   println(speed);
   
   if (speed >= 2) { 
   */

  RPy = map(currentRtPadVal, 0, 150, 0, height);

  //   prevRtPadVal = float(vals[0]);
  // }

  /*
  
   speed = currentRtPadVal - prevRtPadVal;
   
   print("speed: ");
   println(speed);
   
   if (speed >= 5) { 
   ySpeedDown = map(speed, 0, 150, 1, 10);
   RPy+= ySpeedDown;
   //RPy = map(currentRtPadVal, 5, 250, 0, height);
   prevRtPadVal = float(vals[0]);
   } else if (speed < 5) {
   ySpeedUp = map(speed, 0, 150, 1, 10);
   RPy-= ySpeedUp;
   prevRtPadVal = float(vals[0]);
   } else {
   }
   
   */

  LPy = constrain(LPy, 0, (height - pad_ht)); //set boundaries to Y-coordinate
  RPy = constrain(RPy, 0, (height - pad_ht)); //set boundaries to Y-coordinate

  leftPaddle(); 
  rightPaddle(); 

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


  displayScores();
}

void drawState_Score() {

  pingPong.reset();

  if (playerOneScore == winScore || playerTwoScore == winScore) {
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

  text("Press button to Play Another Game", (width/2), (height/2 + 50));

  btnVal = int(vals[1]);

  if (btnVal == 0) {
    playerOneScore = 0;
    playerTwoScore = 0;
    player.rewind();
    state = STATE_PLAY;
  }
}

void serialEvent( Serial serial) {

  String s = serial.readStringUntil( '\n' );

  if ( s == null ) {
    // no thanks
  }
  else {
    s = trim(s);
    println( s );
    parseSerialData(s);
  }
}

void parseSerialData( String s ) {
  s= trim(s);

  String temp[] = split(s, ',');
  if ( temp.length == 2) {
    vals = temp;
  }
}

void leftPaddle() {
  rect(LPx, LPy, pad_d, pad_ht);
}

void rightPaddle() {
  rect(RPx, RPy, pad_d, pad_ht);
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

void stop()
{
  // always close Minim audio classes when you are done with them
  player.close();
  // always stop Minim before exiting
  minim.stop();

  super.stop();
}

