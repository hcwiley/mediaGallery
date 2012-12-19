#= require ../underscore
# =require ../backbone
# =require ../jquery
# =require ../models/entry

Entries = Backbone.Collection.extend({
  model: Entry
  
  , isOver: (hand) ->
    @.forEach (e) ->
      e.checkOver hand

  , isPushed: (hand) ->
    @.forEach (e) ->
      if e.inMyBoundingBox hand
        e.pushed()
      else
        e.attributes.wasPushed = false

  , isPulled: (hand) ->
    @.forEach (e) ->
      if e.inMyBoundingBox hand
        e.pulled()

  , notGrabbed: (grabbed) ->
    @.forEach (e) ->
      if e != grabbed
        e.attributes.el.addClass 'not-grabbed'

  , reset: () ->
    @.forEach (e) ->
      e.reset()

})


@Entries = Entries
