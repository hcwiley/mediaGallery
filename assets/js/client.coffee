#= require jquery
#= require jquery.validate
#= require underscore
# =require backbone
# =require socket.io
# =require osc.io
# =require helpers
# =require body

@a = @a || {}

@a.leftHand = {}
@a.rightHand = {}

isGrabbing =  @a.isGrabbing = false

@initGrabbale = ->
  $(".grabbable").each ->
    me = @
    w0 = $ me .width  
    h0 = $ me .height  
    $(me).data "ratio", h0 / w0
    #$(me).bind "click",  e  ->

$.fn.grabbed =  (pos)  ->
  me = @
  $(me).addClass 'grabbed'
  other = {}
  if pos is a.leftHand
    other = a.rightHand
  else
    other = a.leftHand
  width = other.x - pos.x
  width = 50 if width < 50
  $(me).width width
  $(me).height width * $(me).data "ratio" 
  x = pos.x - $(me).width() / 2
  y = pos.y - $(me).height() / 2
  $(me).css "position", "fixed"
  $(me).css "left", x + "px"
  $(me).css "top", y + "px"

$.fn.push = ->
  $(@).addClass "pushed"
  if $(".over").length > 0 and !isGrabbing
    $($(".over")[0]).grabbed(a.leftHand)

$.fn.reset = ->
  $(@).removeClass "pushed"
  isGrabbing = false

$(window).ready ->
  console.log "lets do it"
  socket = io.connect "http://localhost" 
  osc_client = new OscClient   #UdpSender '127.0.0.1', 7654 ;
  osc_server = new OscServer 
    host: "127.0.0.1"
    port: 7655
   
  osc_server.on "osc",  (msg)  ->
    
    #console.log 'got message' ;
    #console.log msg.path, msg.params ;
    data = JSON.parse msg.path 
    handleHands data  if data.hands
    $("#status").text data.user  if data.user

  initGrabbale()

