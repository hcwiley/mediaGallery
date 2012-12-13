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
    el: ""
  },
  initialize: (attrs) ->
    @.set {
      width: attrs.width0
      height: attrs.height0
      x: attrs.x0
      y: attrs.y0
    }
    console.log "im such a drag...\n#{attrs.height0}" 
})

@Entry = Entry
