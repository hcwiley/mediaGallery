#= require jquery
#= require jquery.validate
#= require underscore
# =require backbone
#= require bootstrapManifest
#= require baseClasses
# =require socket.io
# =require osc.io
# =require helpers
# =require models/user
# =require models/entry
# =require collections/entries

@a = @a || {}

@a.user = {}

@a.entries = {}
@a.grabbed = false
@a.lastGrabbed = false
@a.grabbedMap = undefined
@a.pushed = {}

@initGrabbale = ->
  a.entries = new Entries()
  $(".grabbable").each ->
    me = $(@)
    if me.hasClass('obj')
      me.css 'left', (me.index() % 4) * ( me.width() + 40 )+ 100
      me.css 'top', (parseInt(me.index() / 4) * 400) 
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
      el: $(me),
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

    # check if its the tutorial box
    if me.attr('id') == 'tut'
      entry.on 'wasGrabbed', ->
        $('#ended .text').text 'Well done.. now lets play'
        entry.drop()
        setTimeout ->
          me.animate({
            opacity: 0
          }, 700, ->
            me.remove()
            $('#gallery').css('visibility', 'visible').animate({
              opacity: 1
            }, 600)
          )
        , 1500

@startTutorial = ->
  $('#tut').show()
  vid = document.getElementById 'tut-video'
  vid.play()
  vid.addEventListener 'ended', ->
    $('#tut-video').fadeOut( ->
      $('#ended').show()
    )

$(window).ready ->
  $('#signInModal .submit').click (e) ->
    e.preventDefault()
    $.post '/email', $(@).parent('form').serialize(), (data) ->
      $('#signInModal').modal 'hide'
      startTutorial()
      console.log data
  $('#signInModal').modal 'show'
  setTimeout ->
    $('#email').val('foo@bar.com')
    setTimeout ->
      $('.submit').trigger 'click'
    , 800
  , 1000
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

  initGrabbale()
   
  a.user = new User({
    leftCursor: $('#leftCursor'),
    rightCursor: $('#rightCursor')
  })
  osc_server.on "osc",  (msg)  ->
    
    #console.log 'got message' ;
    #console.log msg.path, msg.params ;
    data = JSON.parse msg.path 
    a.user.updatePosition data  if data.hands
    a.user.updateStatus data  if data.user
    $("#status").text data.user  if data.user



