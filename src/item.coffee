Item = (I) ->
  $.reverseMerge I,
    width: 16
    height: 16

  #TODO: This is a gross hack to center
  I.x += 8
  I.y += 8
  I.x += 2 if I.cat

  self = GameObject(I)

  self.bind "step", ->
    if I.cat
      player = engine.find("Cat").first()
    else
      player = engine.find("Player").first()

    return unless player

    I.active = false if player.I.items[I.name]

    if Collision.rectangular(self.bounds(), player.collisionBounds())
      if I.active
        player.pickup(self)
        I.active = false

  return self

