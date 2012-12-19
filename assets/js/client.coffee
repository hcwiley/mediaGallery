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
@a.grabbed = false
@a.grabbedMap = undefined
@a.pushed = {}

@initGrabbale = ->
  $(".grabbable").each ->
    me = $(@)
    me.css 'left', (me.index() % 4) * ( me.width() + parseInt(me.css('margin-left').replace('px','')) )+ 100
    me.animate {
      opacity: 1
    }, 500
    w0 = $(me).width()
    h0 = $(me).height()
    entry = new Entry { 
      width0: w0,
      height0: h0
      x0: $(me).position().left,
      y0: $(me).position().top,
      el: $(me)
    }
    a.entries.add entry
    # lets bind some mouse events to trigger kinect driven events
    $(me).mouseover(->
      entry.trigger 'over'
    ).mouseleave( ->
      entry.checkOver()
    ).mousedown(->
      entry.trigger 'pushed'
    ).mouseup ->
      entry.trigger 'pulled'

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
   
  a.user = new User({
    leftCursor: $('#leftCursor'),
    rightCursor: $('#rightCursor')
  })
  a.entries = new Entries()
  osc_server.on "osc",  (msg)  ->
    
    #console.log 'got message' ;
    #console.log msg.path, msg.params ;
    data = JSON.parse msg.path 
    a.user.updatePosition data  if data.hands
    a.user.updateStatus data  if data.user
    $("#status").text data.user  if data.user

  initGrabbale()


