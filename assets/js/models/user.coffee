#= require ../underscore
# =require ../backbone
# =require ../jquery

User = Backbone.Model.extend({
  defaults: {
    leftHand: {},
    rightHand: {},
    torso: {},
    status: ""
  },
  initialize: () ->
    console.log 'i live. you die...'
    @.on 'change:leftHand', (model, hand) ->
      console.log "updated left hand"
    @.on 'change:rightHand', (model, hand) ->
      console.log "updated right hand"
    @.on 'change:torso', (model, torso) ->
      console.log "updated torso"
    @.on 'change:status', (model, status) ->
      console.log "updated status: #{status}"
  ,
  updatePosition: (data) ->
    data.hands.left.x = map data.hands.left.x, 0, 640, 0, $(window).width()   
    data.hands.right.x = map data.hands.right.x, 0, 640, 0, $(window).width()   
    data.hands.left.y = map data.hands.left.y, 0, 640, 0, $(window).height()   
    data.hands.right.y = map data.hands.right.y, 0, 640, 0, $(window).height()   
    data.hands.left.z  = parseFloat data.hands.left.z
    data.hands.right.z = parseFloat data.hands.right.z
    @.set {
      leftHand : data.hands.left
      rightHand : data.hands.right
      torso : data.torso
    }
  ,

  updateStatus: (status) ->
    @.set { status: status }
})

@User = User

