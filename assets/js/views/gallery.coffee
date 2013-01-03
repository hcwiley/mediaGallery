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
    count = 0
    for obj in @.objs
      vars = obj
      vars.pos = "left: " + ( (count % 4) * ( 200 + 40 )+ 100 ) + "px;"
      vars.pos += "top: " + ( ( (count / 4) * 400) - 250 ) + "px;"
      html += _.template $('#gallery-template').html(), obj
      console.log 'got the template'
      count++
    
    @.$el.html html
})

@GalleryView = GalleryView
