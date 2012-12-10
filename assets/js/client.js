//= require jquery
//= require jquery.validate
//= require underscore
// =require backbone
// =require socket.io
// =require osc.io

$(function(){
  console.log('lets do it');
  var socket = io.connect('http://localhost');

  var osc_client = new OscClient();//UdpSender('127.0.0.1', 7654);
  var osc_server = new OscServer({ host:'127.0.0.1', port: 7655 });

  osc_server.on('osc', function(msg){
    //console.log('got message');
    //console.log(msg.path, msg.params);
    var data = JSON.parse(msg.path);
    if(data.hands){
      $('#left').css('left',  data.hands.left.x +"px");
      $('#left').css('top',   data.hands.left.y +"px");
      $('#right').css('left', data.hands.right.x+"px");
      $('#right').css('top',  data.hands.right.y+"px");
      // lets put some scale on them
      var lScale = data.torso.z - data.hands.left.z;
      var rScale = data.torso.z - data.hands.right.z;
      var maxScale = 150;
      lScale = map(lScale, 0, 500, 5, maxScale);
      rScale = map(rScale, 0, 500, 5, maxScale);
      if(lScale > maxScale)
        lScale = maxScale;
      if(lScale < 5)
        lScale = 5;
      if(rScale > maxScale)
        rScale = maxScale;
      if(rScale < 5)
        rScale = 5;
      $('#left').width(lScale);
      $('#left').height(lScale);
      $('#right').width(rScale);
      $('#right').height(rScale);
    }

  });
});


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


