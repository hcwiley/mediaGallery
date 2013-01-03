#= require ../underscore
# =require ../backbone
# =require ../jquery

GalleryView = Backbone.View.extend({
  #template: _.template $('#gallery-template').html()
  initialize: (attrs) ->
    console.log "ima thing"
    @.objs = attrs.objs
    @.$el = attrs.el
    @.render()

  render: ->
    html = ""
    for obj in @.objs
      html += _.template $('#gallery-template').html(), obj
      console.log 'got the template'
    
    @.$el.html html
})

@GalleryView = GalleryView
