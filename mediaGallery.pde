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
PVector leftHand = new PVector();
PVector rightHand = new PVector();

// Font vars
PFont fontA;

// UDP vars
UDP udp;
String ip = "localhost";	// the remote IP address
int port  = 7655;

void setup()
{
  context = new SimpleOpenNI(this);
   
  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  
  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  
  size(context.depthWidth(), context.depthHeight()); 
  fontA = loadFont("Ziggurat-HTF-Black-32.vlw");

  // Set the font and its size (in units of pixels)
  textFont(fontA, 25);
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
    if(context.isTrackingSkeleton(userList[i])){
      int userId = userList[i];
      context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
      context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
      context.convertRealWorldToProjective(leftHand,leftHand);
      context.convertRealWorldToProjective(rightHand,rightHand);
      stroke(0,0,255);
      fill(0,0,255);
      ellipse(leftHand.x, leftHand.y, 5, 5);
      stroke(255,0,0);
      fill(255,0,0);
      ellipse(rightHand.x, rightHand.y, 5, 5);
      text("left: (" + leftHand.x + ", " + leftHand.y + ", " + leftHand.z +")",
        20, 20);
      text("right: (" + rightHand.x + ", " + rightHand.y + ", " + rightHand.z +")",
        20, 80);
      sendHands();
    }
  }    
}

// send the hand data over udp to the node server
void sendHands(){
  String msg = "{";
  msg += "\"left\":{";
  msg += "\"x\": \""+leftHand.x+"\",";
  msg += "\"y\": \""+leftHand.y+"\",";
  msg += "\"z\": \""+leftHand.z+"\"},";
  msg += "\"right\":{";
  msg += "\"x\": \""+rightHand.x+"\",";
  msg += "\"y\": \""+rightHand.y+"\",";
  msg += "\"z\": \""+rightHand.z+"\"}";
  msg += "}}\n";
  udp.send( msg, ip, port );
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
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
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

