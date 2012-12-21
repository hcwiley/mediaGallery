#= require ../underscore
# =require ../backbone
# =require ../jquery

Entry = Backbone.Model.extend({
  defaults: {
    width: 0,
    height: 0,
    width0: 0,
    height0: 0,
    x: 0,
    y: 0,
    x0: 0,
    y0: 0,
    data: {},
    isGrabbed: false,
    el: "",
    left: 0,
    right: 0,
    top: 0,
    bottom: 0
  }

  initialize: (attrs) ->
    @.on 'over', @.over
    @.on 'pushed', @.pushed
    @.on 'pulled', @.pulled
    @.on 'change:x', @.updateX
    @.on 'change:y', @.updateY
    @.on 'change:width', @.updateWidth
    @.on 'change:el', @.updateEl
    @.set {
      width: attrs.width0
      height: attrs.height0
      x: attrs.x0
      y: attrs.y0
      el: attrs.el
    }
    @.setCorners()
    @.updateEl()
    console.log "im such a drag..." 

  updateEl: ->
    me = @.attributes
    @.set {
      title: me.el.data 'title'
      desc: me.el.data 'desc'
      loc: me.el.data 'loc'
      link: me.el.data 'link'
    }

  updateX: ->
    me = @.attributes
    @.setCorners()
    me.el.css 'left', me.x

  updateY: ->
    me = @.attributes
    @.setCorners()
    me.el.css 'top', me.y

  updateWidth: ->
    me = @.attributes
    @.setCorners()
    me.el.width me.width

  setCorners: ->
    me = @.attributes
    me.left = me.x
    me.right = me.x + me.width
    me.top = me.y
    me.bottom = me.y + me.height

  center: (loc) ->
    me = @.attributes
    cenx = loc.x() - (me.width / 2)
    @.set x: cenx
    ceny = loc.y() - (me.height / 2)
    @.set y: ceny

  scaleTo: (controlHand, otherHand) ->
    me = @.attributes
    diff = controlHand.x() - otherHand.x()
    if diff < 0
      diff *= -1
    @.set {
      width: diff
    }

  inMyBoundingBox: (hand) ->
    me = @.attributes
    if hand?.x() > me?.left && hand?.x() < me?.right
      if hand?.y() > me.top && hand?.y() < me?.bottom
        return true
    return false

  checkOver: (hand) ->
    me = @.attributes
    if hand
      if @.inMyBoundingBox hand
          return @.trigger 'over'
    me.el.removeClass 'over' 

  over: ->
    me = @.attributes
    me.el.addClass 'over'

  pushed: ->
    me = @.attributes
    if a.grabbed
      a.grabbed.entry.drop()
    else
      me.wasPushed = true

  pulled: (hand) ->
    me = @.attributes
    if !a.grabbed && me.wasPushed
      @.grab hand

  grab: (hand) ->
    me = @.attributes
    a.grabbed = {
      entry: @,
      hand: hand
    }
    a.entries.notGrabbed @
    me.el.addClass 'grabbed'
    console.log "you grabbing me?: #{me.el.index()}"

  drop: ->
    me = @.attributes
    a.grabbed = false
    me.el.removeClass 'grabbed'
    a.entries.reset()
    console.log "you dropped me!: #{me.el.index()}"

  reset: ->
    me = @.attributes
    me.el.removeClass 'not-grabbed'


})

@Entry = Entry
