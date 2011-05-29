Plant = (I) ->
  $.reverseMerge I,
    width: 32
    height: 32
    solid: true
    zIndex: 2

  loadSprites = (type) ->
    [0..1].map (n) ->
      Sprite.loadByName("#{type}_#{n}")

  if I.type
    sprites = loadSprites(I.type)
    I.sprite = sprites.first()

  self = GameObject(I)

  self.bind "destroy", ->
    Sound.play("thresh")

    engine.add
      x: I.x
      y: I.y
      sprite: Sprite.loadByName("shrub_destroy")
      zIndex: 1

  self

