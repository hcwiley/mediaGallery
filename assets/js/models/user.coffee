#= require ../underscore
# =require ../backbone
# =require ../jquery

Hand = Backbone.Model.extend({
  defaults: {
    x: 0,
    y: 0,
    z: 0,
    cursor: "",
    parent: "",
  }
  
  initialize: ->
    console.log "i'm a hand object damn it"
    @.on 'change', @moved

  moved: ->
    me = @.attributes
    me.cursor.css 'left', me.x
    me.cursor.css 'top', me.y
    if a.grabbed?.hand == @
      a.grabbed.entry.center @
      a.grabbed.entry.scaleTo @, me.parent.otherHand(@)
    else
      a.entries.isOver @

  doPushCheck: ->
    me = @.attributes
    push = me.parent?.attributes.torso?.z - me.z
    push = map push, 0, 700, 0, 100
    scale = map push, 0, 100, 10, 100

    me.cursor.width scale
    me.cursor.height scale

    # lets check and see if they pushed
    pushedThresh = 70
    if push > pushedThresh
      me.cursor.addClass 'pushed'
      a.entries.isPushed @
    else
      me.cursor.removeClass 'pushed'
      a.entries.isPulled @

  x: ->
    @.attributes.x
  y: ->
    @.attributes.y
  z: ->
    @.attributes.z
})

User = Backbone.Model.extend({
  defaults: {
    leftHand: new Hand(),
    rightHand: new Hand(),
    torso: {},
    status: ""
  }
  
  initialize: (attrs) ->
    @.attributes.leftHand.set {
      cursor: attrs.leftCursor
      , parent: @
    }
    @.attributes.rightHand.set {
      cursor: attrs.rightCursor
      , parent: @
    }

    console.log 'i live. you die...'
    @.on 'change:leftHand', @leftMoved
    @.on 'change:rightHand', @rightMoved
    @.on 'change:torso', @torsoMoved
    @.on 'change:status', (model, status) ->
      console.log "updated status: #{status}"

  updatePosition: (data) ->
    me = @.attributes
    data.hands.left.x = map data.hands.left.x, 0, 640, 0, $(window).width()   
    data.hands.right.x = map data.hands.right.x, 0, 640, 0, $(window).width()   
    data.hands.left.y = map data.hands.left.y, 0, 320, 0, $(window).height()   
    data.hands.right.y = map data.hands.right.y, 0, 320, 0, $(window).height()   
    data.hands.left.z  = parseFloat data.hands.left.z
    data.hands.right.z = parseFloat data.hands.right.z
    @.set {
      torso : data.torso
    }
    me.leftHand.set {
      x: data.hands.left.x,
      y: data.hands.left.y,
      z: data.hands.left.z
    }
    me.rightHand.set {
      x: data.hands.right.x,
      y: data.hands.right.y,
      z: data.hands.right.z
    }
  
  updateStatus: (status) ->
    @.set { status: status }
  
  torsoMoved: ->
    me = @.attributes
    # lets do some push threshhold and hand scale mapping
    # left then right
    me.leftHand.doPushCheck()
    me.rightHand.doPushCheck()

  otherHand: (thisHand) ->
    me = @.attributes
    if thisHand == me.leftHand
      return me.rightHand
    me.leftHand


})

@User = User
@Hand = Hand
