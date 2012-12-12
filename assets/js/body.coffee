@a = @a || {}

isGrabbing =  @a.isGrabbing

@handleHands =  (data)  ->
  data.hands.left.x = map data.hands.left.x, 0, 640, 0, $(window).width()   
  data.hands.right.x = map data.hands.right.x, 0, 640, 0, $(window).width()   
  data.hands.left.y = map data.hands.left.y, 0, 640, 0, $(window).height()   
  data.hands.right.y = map data.hands.right.y, 0, 640, 0, $(window).height()   
  $("#left").css("left", data.hands.left.x + "px")
  $("#left").css("top", data.hands.left.y + "px")
  $("#right").css("left", data.hands.right.x + "px")
  $("#right").css("top", data.hands.right.y + "px")
  @a.leftHand = data.hands.left
  @a.rightHand = data.hands.right
  @a.leftHand.z = parseFloat @a.leftHand.z
  @a.rightHand.z = parseFloat @a.rightHand.z
  
  # lets put some scale on them
  # scale is the difference between the hands and the torso
  # using this to detect selection
  lScale = data.torso.z - data.hands.left.z
  rScale = data.torso.z - data.hands.right.z
  maxScale = 100
  minScale = 5
  pushed = 50
  # map the scale between 5 
  lScale = map lScale, 0, 500, 5, maxScale 
  rScale = map rScale, 0, 500, 5, maxScale 
  if lScale > pushed
    lScale = maxScale
    $("#left").push()
  else
    $("#left").reset()
  lScale = 5  if lScale < 5
  if rScale > pushed
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
    $(@).isHandOver a.leftHand
    return null

$.fn.handOver = ->
  # check other overs
  # if no others over add class over
  # else fuck off, i'm holding something
  $(@).addClass "over"

$.fn.handLeave = ->
  $(@).removeClass "over"
  $(@).removeClass "grabbed"

$.fn.isHandOver =  (pos)  ->
  me = @
  myPos = {}
  myPos.left = $(me).position().left
  myPos.right = myPos.left + $(me).width()
  myPos.top = $(me).position().top
  myPos.bottom = myPos.top + $(me).height() 
  myPos.cenX = myPos.right -  $(me).width() / 2 
  myPos.cenY = myPos.bottom -  $(me).height() / 2 
  buf = 10
  if myPos.left < ( pos.x - buf ) and myPos.right > ( pos.x + buf )
    if myPos.top < ( pos.y - buf ) and myPos.bottom > ( pos.y + buf)
      $(me).handOver()
      return true
  $(me).handLeave()
  false


