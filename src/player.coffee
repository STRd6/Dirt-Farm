Player = (I) ->
  $.reverseMerge I,
    width: 32
    height: 32
    x: 160
    y: 160
    state: {}
    speed: 4
    items: {
      #kitten: true
      #bomb: true
    }
    excludedModules: ["Movable"]

  I.sprite = Sprite.loadByName("player")
  walkSprites =
    up: [Sprite.loadByName("walk_up0"), Sprite.loadByName("walk_up1")]
    right: [Sprite.loadByName("walk_right0"), Sprite.loadByName("walk_right1")]
    down: [Sprite.loadByName("walk_down0"), Sprite.loadByName("walk_down1")]
    left: [Sprite.loadByName("walk_left0"), Sprite.loadByName("walk_left1")]

  pickupSprite = Sprite.loadByName("player_get")
  bombCooldown = 0

  pickupItem = null

  self = GameObject(I).extend
    collisionBounds: (xOffset, yOffset) ->
      x: I.x + (xOffset || 0) + collisionMargin.x
      y: I.y + (yOffset || 0) + collisionMargin.y
      width: I.width - 2 * collisionMargin.x
      height: I.height - 2 * collisionMargin.y

    pickup: (item) ->
      I.state.pickup = 45
      pickupItem = item

      I.items[item.I.name] = true

      if item.I.message
        engine.add
          class: "Text"
          duration: 150
          message: item.I.message
          y: 32

      Sound.play "fanfare"

  walkCycle = 0

  facing = Point(0, 0)

  collisionMargin =
    x: 2
    y: 2

  self.bind "draw", (canvas) ->
    if I.state.pickup && pickupItem
      pickupItem.I.sprite.draw(canvas, 8, -8)

  self.bind "step", ->
    bombCooldown = bombCooldown.approach(0, 1)

    movement = Point(0, 0)

    if I.state.pickup
      I.state.pickup -= 1
      I.sprite = pickupSprite
    else if I.state.cat

    else
      if keydown.left
        movement = movement.add(Point(-1, 0))
        I.sprite = walkSprites.left.wrap((walkCycle/4).floor())
      if keydown.right
        movement = movement.add(Point(1, 0))
        I.sprite = walkSprites.right.wrap((walkCycle/4).floor())
      if keydown.up
        movement = movement.add(Point(0, -1))
        I.sprite = walkSprites.up.wrap((walkCycle/4).floor())
      if keydown.down
        movement = movement.add(Point(0, 1))
        I.sprite = walkSprites.down.wrap((walkCycle/4).floor())

      if I.items.bomb && keydown.return && !bombCooldown
        bombCooldown += 90

        target = facing.scale(32).add(self.center()).subtract(Point(8, 8))

        engine.add
          class: "Bomb"
          x: target.x
          y: target.y

      if I.items.kitten && keydown.space
        target = facing.scale(32).add(self.center()).subtract(Point(8, 8))

        catBounds =
          x: target.x
          y: target.y
          width: 16
          height: 16

        unless engine.collides catBounds
          I.state.cat = true
          I.items.kitten = false

          engine.add
            class: "Cat"
            playerData: I
            x: target.x
            y: target.y

    if movement.equal(Point(0, 0))
      I.velocity = movement
    else
      walkCycle += 1

      facing = movement.norm()
      I.velocity = facing.scale(I.speed)

      I.velocity.x.abs().times ->
        if !engine.collides(self.collisionBounds(I.velocity.x.sign(), 0), self)
          I.x += I.velocity.x.sign()
        else 
          I.velocity.x = 0

      I.velocity.y.abs().times ->
        if !engine.collides(self.collisionBounds(0, I.velocity.y.sign()), self)
          I.y += I.velocity.y.sign()
        else 
          I.velocity.y = 0

    I.x = I.x.clamp(0, 480 - I.width)
    I.y = I.y.clamp(0, 320 - I.height)

  self

