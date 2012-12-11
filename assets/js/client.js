//= require jquery
//= require jquery.validate
//= require underscore
// =require backbone
// =require socket.io
// =require osc.io

var leftHand = {};
var rightHand = {};

var isGrabbing = false;

function initGrabbale(){
  $('.grabbable').each(function(){
    var me = this;
    var w0 = $(me).width();
    var h0 = $(me).height();
    $(me).data('ratio', h0/w0);
    //console.log('ratio: ' + h0/w0); 
    $(me).bind('click', function(e){
    });
  });
}

$.fn.grabbed = function(pos){
  var me = this;
  var other = {};
  if(pos == leftHand)
    other = rightHand;
  else
    other = leftHand;
  var width = other.x - pos.x;
  $(me).width(width);
  $(me).height(width * $(me).data('ratio'));
  var x = pos.x - $(me).width()/2;
  var y = pos.y - $(me).height()/2;
  $(me).css('position', 'fixed');
  $(me).css('left', x + 'px');
  $(me).css('top' , y + 'px');
}

$.fn.handOver = function(){
  $(this).addClass('over');
}

$.fn.handLeave = function(){
  $(this).removeClass('over');
}

$.fn.isHandOver = function(pos){
  var me = this;
  var myPos = {};
  myPos.left = $(me).position().left;
  myPos.right = myPos.left + $(me).width();
  myPos.top = $(me).position().top;
  myPos.bottom = myPos.top + $(me).height();
  myPos.cenX = myPos.right - ($(me).width() / 2);
  myPos.cenY = myPos.bottom - ($(me).height() / 2);
  if(myPos.left < pos.x && myPos.right > pos.x){
    if(myPos.top < pos.y && myPos.bottom > pos.y){
      //console.log('hand over!');
      //console.log(me);
      $(me).handOver();
      return true;
    }
  }
  $(me).handLeave();
  return false;
}

//leftHand = function(){
  //return{
    //x: _leftHand.x,
    //y: _leftHand.y,
    //z: _leftHand.z
  //}
//}

//rightHand = function(){
  //return{
    //x: _rightHand.x,
    //y: _rightHand.y,
    //z: _rightHand.z
  //}
//}

handleHands = function(data){
  data.hands.left.x = map(data.hands.left.x, 0, 640, 0, $(window).width());
  data.hands.right.x = map(data.hands.right.x, 0, 640, 0, $(window).width());
  data.hands.left.y = map(data.hands.left.y, 0, 640, 0, $(window).height());
  data.hands.right.y = map(data.hands.right.y, 0, 640, 0, $(window).height());
  $('#left').css('left',  data.hands.left.x +"px");
  $('#left').css('top',   data.hands.left.y +"px");
  $('#right').css('left', data.hands.right.x+"px");
  $('#right').css('top',  data.hands.right.y+"px");
  leftHand = data.hands.left;
  rightHand = data.hands.right;
  // lets put some scale on them
  var lScale = data.torso.z - data.hands.left.z;
  var rScale = data.torso.z - data.hands.right.z;
  var maxScale = 100;
  lScale = map(lScale, 0, 500, 5, maxScale);
  rScale = map(rScale, 0, 500, 5, maxScale);
  if(lScale > maxScale){
    lScale = maxScale;
    $('#left').push();
  }
  else{
    $('#left').reset();
  }
  if(lScale < 5){
    lScale = 5;
  }
  if(rScale > maxScale){
    rScale = maxScale;
    $('#right').push();
  }
  else{
    $('#right').reset();
  }
  if(rScale < 5){
    rScale = 5;
  }
  $('#left').width(lScale);
  $('#left').height(lScale);
  $('#right').width(rScale);
  $('#right').height(rScale);
  checkHandOver();
}

checkHandOver = function(){
  $('.grabbable').each(function(){
    var me = this;
    $(me).isHandOver(leftHand);
    //$(me).isHandOver(rightHand);
  });
}

map = function(value, fromMin, fromMax, toMin, toMax) {
  var norm;
  value = parseInt(value);
  fromMin = parseInt(fromMin);
  fromMax = parseInt(fromMax);
  toMin = parseInt(toMin);
  toMax = parseInt(toMax);
  norm = (value - fromMin) / (fromMax - fromMin).toFixed(1);
  return norm * (toMax - toMin) + toMin;
};

$.fn.push = function(){
  $(this).addClass('pushed');
  if($('.over') && !isGrabbing ){
    $('.over').first().grabbed(leftHand)
  }
}

$.fn.reset = function(){
  $(this).removeClass('pushed');
  isGrabbing = false;
}

$(window).ready(function(){
  console.log('lets do it');
  var socket = io.connect('http://localhost');

  var osc_client = new OscClient();//UdpSender('127.0.0.1', 7654);
  var osc_server = new OscServer({ host:'127.0.0.1', port: 7655 });

  osc_server.on('osc', function(msg){
    //console.log('got message');
    //console.log(msg.path, msg.params);
    var data = JSON.parse(msg.path);
    if(data.hands){
      handleHands(data);
    }
    if(data.user){
      $('#status').text(data.user);
    }

  });
  initGrabbale();
});

