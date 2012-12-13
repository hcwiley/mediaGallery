#= require jquery
#= require jquery.validate
#= require underscore
# =require backbone
# =require socket.io
# =require osc.io
# =require helpers
# =require body
# =require models/user
# =require models/entry
# =require collections/entries

@a = @a || {}

@a.user = {}

@a.entries = {}
@a.grabbed = {}

isGrabbing =  @a.isGrabbing = false

@initGrabbale = ->
  $(".grabbable").each ->
    me = @
    w0 = $(me).width()
    h0 = $(me).height()
    entry = new Entry { width0: w0, height0: h0 }
    a.entries.add entry
    $(me).data "ratio", h0 / w0
    #$(me).bind "click",  e  ->

$.fn.grabbed =  (pos)  ->
  me = @
  isGrabbing = true
  $(me).addClass 'grabbed'
  other = {}
  if pos is a.user.leftHand
    other = a.user.rightHand
  else
    other = a.user.leftHand
  width = other.x - pos.x
  width = 50 if width < 50
  $(me).width width
  #$(me).height width * $(me).data "ratio" 
  $(me).height $(me).children('img').height() + 20
  x = pos.x - $(me).width() / 2
  y = pos.y - $(me).height() / 2
  $(me).css "position", "fixed"
  $(me).css "left", x + "px"
  $(me).css "top", y + "px"

$.fn.push = ->
  $(@).addClass "pushed"
  if $(".over").length > 0 and !isGrabbing
    $($(".over")[0]).grabbed(a.user.leftHand)

$.fn.reset = ->
  $(@).removeClass "pushed"
  isGrabbing = false

$(window).ready ->
  console.log "lets do it"
  socket = io.connect "http://localhost" 
  osc_client = new OscClient {
    host: "127.0.0.1"
    port: 7654
  }
  osc_server = new OscServer {
    host: "127.0.0.1"
    port: 7655
  }
   
  a.user = new User()
  a.entries = new Entries()
  osc_server.on "osc",  (msg)  ->
    
    #console.log 'got message' ;
    #console.log msg.path, msg.params ;
    data = JSON.parse msg.path 
    a.user.updatePosition data  if data.hands
    a.user.updateStatus data  if data.user
    $("#status").text data.user  if data.user

  initGrabbale()


