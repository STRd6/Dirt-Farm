Plant = (I) ->
  $.reverseMerge I,
    width: 32
    height: 32
    solid: true

  self = GameObject(I)

  self.bind "destroy", ->
    engine.add
      x: I.x
      y: I.y
      sprite: Sprite.loadByName("shrub_destroy")

  self

