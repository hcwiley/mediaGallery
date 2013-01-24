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
# =require models/dropzone
# =require collections/entries
# =require views/gallery

@a = @a || {}

@a.user = {}

@a.entries = {}
@a.grabbed = false
@a.lastGrabbed = false
@a.grabbedMap = undefined
@a.pushed = {}

@initGrabbale = ->
  a.grabbables = a.grabbables || new Grabbables()
  if a.entries?.length > 0
    for e in a.entries.models
      i = a.grabbables.indexOf e
      if i > 0
        a.grabbables.remove(i)
        e.destroy()
        _i--
  a.entries = new Grabbables()
  $(".grabbable").each ->
    me = $(@)
    if me.hasClass('obj')
      me.css 'left', (me.index() % 4) * ( me.width() + 40 )+ 100
      me.css 'top', (parseInt(me.index() / 4) * 400) + 20 
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
    a.grabbables.add entry
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
            me.css 'display', 'none'
            entry.set { isGrabbable: false }
            $('#gallery').css('visibility', 'visible').animate({
              opacity: 1
            }, 600)
            $('.corner, .drop').css('visibility', 'visible')
          )
        , 1500

@initCorners = ->
  a.corners = new Grabbables()
  a.grabbables = a.grabbables || new Grabbables()

  # need to update corners as the window resizes
  #$(window).resize ->
  ww = $(window).width()
  wh = $(window).height()
  dW = 150
  dH = 150

  d = $('.bottom.right')
  d.css 'top', wh - dH + "px"
  d.css 'left', ww - dW + "px"

  d = $('.bottom.left')
  d.css 'top', wh - dH + "px"
  d.css 'left', 0 + "px"

  d = $('.top.right')
  d.css 'top', 0 + "px"
  d.css 'left', ww - dW + "px"

  d = $('.top.left')
  d.css 'top', 0 + "px"
  d.css 'left', 0 + "px"


  $('.corner').each ->
    me = $(@)
    w0 = 150
    h0 = 150
    corner = new CornerEntry {
      width0: w0,
      height0: h0,
      x0: $(me).position().left,
      y0: $(me).position().top,
      el: $(me),
    }
    a.grabbables.add corner
    a.corners.add corner
    corner.on 'wasGrabbed', ->
      initGrabbale()
    $(me).mouseover(->
      corner.trigger 'over'
    ).mouseleave( ->
      corner.checkOver()
    ).mousedown(->
      corner.trigger 'pushed'
    ).mouseup ->
      corner.trigger 'pulled'

@initDrops = ->
  $('.drop').each ->
    me = @
    w0 = $(me).width()
    h0 = $(me).height()
    drop = new Drop {
      width0: w0,
      height0: h0,
      x0: $(window).width() / 2 - $(me).width() / 2,
      y0: $(me).position().top,
      el: $(me),
    }
    $(me).mouseover( ->
      drop.trigger 'over'
    ).mouseleave( ->
      drop.checkOver()
    ).mousedown( ->
      drop.trigger 'pushed'
    ).mouseup ->
      drop.trigger 'pulled'

    if $(me).attr("id").match("email")
      drop.set {
        x: $(window).width() / 4 - $(me).width() / 2,
      }
      a.emailDrop = drop
      a.emailDrop.on "wasPushed", ->
        console.log "do email for:"
        console.log a.grabbed.entry
    if $(me).attr("id").match("return")
      drop.set {
        x: $(window).width() / 2 - $(me).width() / 2,
      }
      a.returnDrop = drop

@doGrabAnimations = ($el) ->
  $('#info').animate {
    top: '0',
  }, 500
  $('.corner').fadeOut(500)
  $('.drop').animate({
    top: '80%'
  }, 500, ->
    a.emailDrop?.set {
      y: $('#email-drop').position().top,
    }
    a.returnDrop?.set {
      y: $('#return-drop').position().top,
    }
  )

@doDropAnimations = () ->
  $('#info').animate {
    top: '-2500',
  }, 500
  $('.corner').fadeIn(500)
  $('.drop').animate({
    top: '150%',
  }, 500, ->
    me = $('#email-drop')
    a.emailDrop?.set {
      y: $(me).position().top,
    }
    a.returnDrop?.set {
      y: $('#return-drop').position().top,
    }
  )


@startTutorial = ->
  $('#tut').show()
  vid = document.getElementById 'tut-video'
  vid.play()
  vid.addEventListener 'ended', ->
    $('#tut-video').fadeOut( ->
      $('#ended').show()
    )

@populateGalleries = ->
  a.galleries =  a.galleries || {}
  $.get '/galleries', (data) ->
    for gallery in data
      a.galleries[gallery.type] = a.galleries[gallery.type] || []
      a.galleries[gallery.type].push gallery

$(window).ready ->
  # lets make some shit grabbable
  initGrabbale()

  initCorners()
  
  populateGalleries()
  
  initDrops()
   
  a.user = new User({
    leftCursor: $('#leftCursor'),
    rightCursor: $('#rightCursor')
  })

  $('#signInModal .submit').click (e) ->
    e.preventDefault()
    $.post '/email', $(@).parent('form').serialize(), (data) ->
      $('#signInModal').modal 'hide'
      startTutorial()
      console.log data
  $('#signInModal').modal 'show'
  if window.location.hash.match 'skip'
    setTimeout ->
      $('#email').val('foo@bar.com')
      setTimeout ->
        $('.submit').trigger 'click'
        setTimeout ->
          a.entries.models[0].grab()
        , 500
      , 200
    , 200
  # set up the socket.io and OSC
  socket = io.connect "http://localhost" 
  osc_client = new OscClient {
    host: "127.0.0.1"
    port: 7654
  }
  osc_server = new OscServer {
    host: "127.0.0.1"
    port: 7655
  }

  osc_server.on "osc",  (msg)  ->
    data = JSON.parse msg.path 
    a.user.updatePosition data  if data.hands
    a.user.set({'status': data.user })  if data.user



