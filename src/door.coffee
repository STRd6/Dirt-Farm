Door = (I) ->
  $.reverseMerge I,
    width: 32
    height: 32

  I.sprite = Sprite.NONE unless I.keepSprite

  self = GameObject(I)

  self.bind "step", ->
    player = engine.find("Player").first()

    if player && Collision.rectangular(self.bounds(), player.collisionBounds())
      engine.loadMap I.destination, ->
        player.I.location = I.destination

        # Pretty hacky...
        engine.add player.I

      if I.autoPosition
        if I.x == 0
          player.I.x = 416
        else if I.x == 448
          player.I.x = 32

        if I.y == 0
          player.I.y = 256
        else if I.y == 288
          player.I.y = 32

      if I.destinationPosition
        player.I.x = I.destinationPosition.x
        player.I.y = I.destinationPosition.y

  return self

