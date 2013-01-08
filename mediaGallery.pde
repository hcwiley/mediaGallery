/* --------------------------------------------------------------------------
 * mediaGallery
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  H. Cole Wiley / http://hcwiley.com
 * date:  12/10/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import hypermedia.net.*;

// SimpleOpenNI vars
SimpleOpenNI  context;
boolean       autoCalib=true;
PVector pleftHand = new PVector();
PVector prightHand = new PVector();
PVector leftHand = new PVector();
PVector rightHand = new PVector();
PMatrix3D leftHandO = new PMatrix3D();
PMatrix3D rightHandO = new PMatrix3D();
PVector torso = new PVector();

// Font vars
//PFont fontA;

// UDP vars
UDP udp;
String ip = "localhost";	// the remote IP address
int port  = 7655;
float lastHandsSend = 0;

void setup()
{
  frameRate(15);
  context = new SimpleOpenNI(this);
   
  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  
  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_UPPER);
  context.setMirror(true);
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  
  size(context.depthWidth(), context.depthHeight()); 
//  fontA = loadFont("Ziggurat-HTF-Black-32.vlw");

  // Set the font and its size (in units of pixels)
//  textFont(fontA, 25);
//  text("left: (###, ###, ###)", 20, 20);
//  text("right: (###, ###, ###)", 20, 120);
  udp = new UDP( this, 7654 );
  //udp.log( true ); 		// <-- printout the connection activity
  udp.listen( true );
}

void draw()
{
  // update the cam
  context.update();
  
  // draw depthImageMap
  image(context.depthImage(),0,0);
  
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  
  for(int i=0;i<userList.length;i++)
  {
    if(i > 1)
      break;
    if(context.isTrackingSkeleton(userList[i])){
      int userId = userList[i];
      context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
      context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
//      context.getJointOrientationSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, leftHandO);
//      context.getJointOrientationSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightHandO);
      context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_TORSO, torso);
      context.convertRealWorldToProjective(leftHand,leftHand);
      context.convertRealWorldToProjective(torso,torso);
      context.convertRealWorldToProjective(rightHand,rightHand);
//      println("\n-------------------------------------------------------------");
//      println(leftHandO.m00+", "+leftHandO.m01+", "+leftHandO.m02+", "+leftHandO.m03+", "+leftHandO.m10+"\n"
//      +leftHandO.m11+", "+leftHandO.m12+", "+leftHandO.m13+", "+leftHandO.m20+"\n"
//      +leftHandO.m21+", "+leftHandO.m22+", "+leftHandO.m23+", "+leftHandO.m30+"\n"
//      +leftHandO.m31+", "+leftHandO.m32+", "+leftHandO.m33);
//      println("-------------------------------------------------------------\n");
      stroke(0,0,255);
      fill(0,0,255);
      ellipse(leftHand.x, leftHand.y, 10, 10);
      stroke(255,0,0);
      fill(255,0,0);
      ellipse(rightHand.x, rightHand.y, 10, 10);
//      text("left: (" + leftHand.x + ", " + leftHand.y + ", " + leftHand.z +")",
//        20, 20);
//      text("right: (" + rightHand.x + ", " + rightHand.y + ", " + rightHand.z +")",
//        20, 80);
      sendHands();
    }
  }    
}

// send the hand data over udp to the node server
void sendHands(){
  if(millis() - lastHandsSend > 5){
    lastHandsSend = millis();
    lerpHands();
    String msg = "{\"hands\":{";
    msg += "\"left\":{";
    msg += "\"x\": \""+leftHand.x+"\",";
    msg += "\"y\": \""+leftHand.y+"\",";
    msg += "\"z\": \""+leftHand.z+"\"},";
    msg += "\"right\":{";
    msg += "\"x\": \""+rightHand.x+"\",";
    msg += "\"y\": \""+rightHand.y+"\",";
    msg += "\"z\": \""+rightHand.z+"\"}},";
    msg += "\"torso\":{";
    msg += "\"x\": \""+torso.x+"\",";
    msg += "\"y\": \""+torso.y+"\",";
    msg += "\"z\": \""+torso.z+"\"}";
    msg += "}";
    
    convertAndSend(msg);
  }
}

void lerpHands(){
  float lerpAmt = .8;
  PVector tmpL = new PVector(leftHand.x, leftHand.y, leftHand.z);
  PVector tmpR = new PVector(rightHand.x, rightHand.y, rightHand.z);
  tmpL.x  = lerp(tmpL.x, pleftHand.x, lerpAmt);
  tmpL.y  = lerp(tmpL.y, pleftHand.y, lerpAmt);
  tmpL.z  = lerp(tmpL.z, pleftHand.z, lerpAmt);
  tmpR.x  = lerp(tmpR.x, prightHand.x, lerpAmt);
  tmpR.y  = lerp(tmpR.y, prightHand.y, lerpAmt);
  tmpR.z  = lerp(tmpR.z, prightHand.z, lerpAmt);
  pleftHand = new PVector(leftHand.x, leftHand.y, leftHand.z);
  prightHand = new PVector(rightHand.x, rightHand.y, rightHand.z);
  leftHand = new PVector(tmpL.x, tmpL.y, tmpL.z);
  rightHand = new PVector(tmpR.x, tmpR.y, tmpR.z);
}

void sendEvent(String event, String stat){
  String msg = "{";
  msg += "\"" + event + "\":";
  msg += "\"" + stat + "\"";
  msg += "}";
  convertAndSend(msg);
  
}

void convertAndSend(String msg){
  byte bmsg[] = new byte[msg.length()+10];
  
  for(int i = 0; i < msg.length(); i++){
    bmsg[i] = byte(msg.charAt(i));
  }
  bmsg[bmsg.length - 1] = byte('\0');
  
  udp.send( bmsg, ip, port ); 
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  if(autoCalib)
    context.requestCalibrationSkeleton(userId,true);
  else    
    context.startPoseDetection("Psi",userId);
  sendEvent("user", "found");
}

void onLostUser(int userId)
{
  sendEvent("user", "lost");
  println("onLostUser - userId: " + userId);
}

void onExitUser(int userId)
{
  sendEvent("user", "exit");
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  sendEvent("user", "reenter");
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  sendEvent("user", "calibrating");
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) 
  { 
    println("  User calibrated !!!");
    sendEvent("user", "calibrated");
    context.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    sendEvent("user", "failed calibration");
    context.startPoseDetection("Psi",userId);
  }
}

void onStartPose(String pose,int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
  
  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
 
}

void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

