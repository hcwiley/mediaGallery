#= require jquery
#= require jquery.validate
#= require underscore
# =require backbone
# =require socket.io
# =require osc.io
initGrabbale = ->
  $(".grabbable").each ->
    me = this
    w0 = $(me).width()
    h0 = $(me).height()
    $(me).data "ratio", h0 / w0
    
    #console.log('ratio: ' + h0/w0); 
    $(me).bind "click", (e) ->


leftHand = {}
rightHand = {}
isGrabbing = false
$.fn.grabbed = (pos) ->
  me = this
  other = {}
  if pos is leftHand
    other = rightHand
  else
    other = leftHand
  width = other.x - pos.x
  $(me).width width
  $(me).height width * $(me).data("ratio")
  x = pos.x - $(me).width() / 2
  y = pos.y - $(me).height() / 2
  $(me).css "position", "fixed"
  $(me).css "left", x + "px"
  $(me).css "top", y + "px"

$.fn.handOver = ->
  $(this).addClass "over"

$.fn.handLeave = ->
  $(this).removeClass "over"

$.fn.isHandOver = (pos) ->
  me = this
  myPos = {}
  myPos.left = $(me).position().left
  myPos.right = myPos.left + $(me).width()
  myPos.top = $(me).position().top
  myPos.bottom = myPos.top + $(me).height()
  myPos.cenX = myPos.right - ($(me).width() / 2)
  myPos.cenY = myPos.bottom - ($(me).height() / 2)
  if myPos.left < pos.x and myPos.right > pos.x
    if myPos.top < pos.y and myPos.bottom > pos.y
      
      #console.log('hand over!');
      #console.log(me);
      $(me).handOver()
      return true
  $(me).handLeave()
  false


#leftHand = function(){
#return{
#x: _leftHand.x,
#y: _leftHand.y,
#z: _leftHand.z
#}
#}

#rightHand = function(){
#return{
#x: _rightHand.x,
#y: _rightHand.y,
#z: _rightHand.z
#}
#}
handleHands = (data) ->
  data.hands.left.x = map(data.hands.left.x, 0, 640, 0, $(window).width())
  data.hands.right.x = map(data.hands.right.x, 0, 640, 0, $(window).width())
  data.hands.left.y = map(data.hands.left.y, 0, 640, 0, $(window).height())
  data.hands.right.y = map(data.hands.right.y, 0, 640, 0, $(window).height())
  $("#left").css "left", data.hands.left.x + "px"
  $("#left").css "top", data.hands.left.y + "px"
  $("#right").css "left", data.hands.right.x + "px"
  $("#right").css "top", data.hands.right.y + "px"
  leftHand = data.hands.left
  rightHand = data.hands.right
  
  # lets put some scale on them
  lScale = data.torso.z - data.hands.left.z
  rScale = data.torso.z - data.hands.right.z
  maxScale = 100
  lScale = map(lScale, 0, 500, 5, maxScale)
  rScale = map(rScale, 0, 500, 5, maxScale)
  if lScale > maxScale
    lScale = maxScale
    $("#left").push()
  else
    $("#left").reset()
  lScale = 5  if lScale < 5
  if rScale > maxScale
    rScale = maxScale
    $("#right").push()
  else
    $("#right").reset()
  rScale = 5  if rScale < 5
  $("#left").width lScale
  $("#left").height lScale
  $("#right").width rScale
  $("#right").height rScale
  checkHandOver()

checkHandOver = ->
  $(".grabbable").each ->
    me = this
    $(me).isHandOver leftHand



#$(me).isHandOver(rightHand);
map = (value, fromMin, fromMax, toMin, toMax) ->
  norm = undefined
  value = parseInt(value)
  fromMin = parseInt(fromMin)
  fromMax = parseInt(fromMax)
  toMin = parseInt(toMin)
  toMax = parseInt(toMax)
  norm = (value - fromMin) / (fromMax - fromMin).toFixed(1)
  norm * (toMax - toMin) + toMin

$.fn.push = ->
  $(this).addClass "pushed"
  $(".over").first().grabbed leftHand  if $(".over") and not isGrabbing

$.fn.reset = ->
  $(this).removeClass "pushed"
  isGrabbing = false

$(window).ready ->
  console.log "lets do it"
  socket = io.connect("http://localhost")
  osc_client = new OscClient() #UdpSender('127.0.0.1', 7654);
  osc_server = new OscServer(
    host: "127.0.0.1"
    port: 7655
  )
  osc_server.on "osc", (msg) ->
    
    #console.log('got message');
    #console.log(msg.path, msg.params);
    data = JSON.parse(msg.path)
    handleHands data  if data.hands
    $("#status").text data.user  if data.user

  initGrabbale()

