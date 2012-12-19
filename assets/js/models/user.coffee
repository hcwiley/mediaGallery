#= require ../underscore
# =require ../backbone
# =require ../jquery

User = Backbone.Model.extend({
  defaults: {
    leftHand: {},
    rightHand: {},
    leftCursor: "",
    rightCursor: "",
    torso: {},
    status: ""
  }
  
  , initialize: () ->
    console.log 'i live. you die...'
    @.on 'change:leftHand', @leftMoved
    @.on 'change:rightHand', @rightMoved
    @.on 'change:torso', @torsoMoved
    @.on 'change:status', (model, status) ->
      console.log "updated status: #{status}"

  , updatePosition: (data) ->
    data.hands.left.x = map data.hands.left.x, 0, 640, 0, $(window).width()   
    data.hands.right.x = map data.hands.right.x, 0, 640, 0, $(window).width()   
    data.hands.left.y = map data.hands.left.y, 0, 320, 0, $(window).height()   
    data.hands.right.y = map data.hands.right.y, 0, 320, 0, $(window).height()   
    data.hands.left.z  = parseFloat data.hands.left.z
    data.hands.right.z = parseFloat data.hands.right.z
    @.set {
      leftHand : data.hands.left
      rightHand : data.hands.right
      torso : data.torso
    }
  
  , updateStatus: (status) ->
    @.set { status: status }
  
  , leftMoved: () ->
      me = @.attributes
      me.leftCursor.css 'left', me.leftHand.x
      me.leftCursor.css 'top', me.leftHand.y
      if a.grabbedMap?.hand == @
        console.log 'left hand holding'
        a.grabbedMap.entry.center me.leftHand.x
      else
        a.entries.isOver me.leftHand

  , rightMoved: () ->
      me = @.attributes
      me.rightCursor.css 'left', me.rightHand.x
      me.rightCursor.css 'top', me.rightHand.y
      if a.grabbedMap?.hand == @
        console.log 'right hand holding'
        a.grabbedMap.entry.center me.rightHand.x
      else
        a.entries.isOver me.rightHand
  
  , torsoMoved: () ->
      me = @.attributes
      # lets do some push threshhold and hand scale mapping
      # left then right
      leftPush = me.torso.z - me.leftHand.z
      leftPush = map leftPush, 0, 700, 0, 100
      leftScale = map leftPush, 0, 100, 10, 100

      rightPush = me.torso.z - me.rightHand.z
      rightPush = map rightPush, 0, 700, 0, 100
      rightScale = map rightPush, 0, 100, 10, 100
      me.leftCursor.width leftScale
      me.leftCursor.height leftScale
      me.rightCursor.width rightScale
      me.rightCursor.height rightScale

      # lets check and see if they pushed
      pushedThresh = 70
      if leftPush > pushedThresh
        me.leftCursor.addClass 'pushed'
        a.entries.isPushed me.leftHand
      else
        me.leftCursor.removeClass 'pushed'
        a.entries.isPulled me.leftHand

      if rightPush > pushedThresh
        me.rightCursor.addClass 'pushed'
        a.entries.isPushed me.rightHand
      else
        me.rightCursor.removeClass 'pushed'
        a.entries.isPulled me.rightHand


})

@User = User

