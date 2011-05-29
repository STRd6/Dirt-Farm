Player = (I) ->
  $.reverseMerge I,
    collisionMargin: Point(2, 2)
    currentAction: "thresh"
    width: 32
    height: 32
    x: 192
    y: 128
    solid: true
    state: {}
    speed: 4
    items: [{
      action: "thresh"
      sprite: Sprite.loadByName("scyth")
    }, {
      action: "hoe"
      sprite: Sprite.loadByName("hoe")
    }]
    zIndex: 3

  TILE_SIZE = 32

  I.sprite = Sprite.loadByName("player")
  walkSprites =
    up: [Sprite.loadByName("walk_up0"), Sprite.loadByName("walk_up1")]
    right: [Sprite.loadByName("walk_right0"), Sprite.loadByName("walk_right1")]
    down: [Sprite.loadByName("walk_down0"), Sprite.loadByName("walk_down1")]
    left: [Sprite.loadByName("walk_left0"), Sprite.loadByName("walk_left1")]

  pickupSprite = Sprite.loadByName("player_get")

  pickupItem = null

  self = GameObject(I).extend
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

    drawHUD: (canvas) ->
      screenPadding = 8
      hudWidth = 32
      hudHeight = 32
      hudMargin = 8

      I.items.each (item, i) ->
        canvas.withTransform Matrix.translation(i * (hudWidth + hudMargin) + screenPadding, screenPadding), (canvas) ->
          canvas.clearRect(0, 0, hudWidth, hudHeight)

          color = "rgba(0, 255, 255, 0.25)"

          canvas.fillColor color
          canvas.fillRoundRect 0, 0, hudWidth, hudHeight
          item.sprite.draw(canvas, 0, 0)


  walkCycle = 0

  facing = Point(0, 0)

  self.bind "draw", (canvas) ->
    if I.state.pickup && pickupItem
      pickupItem.I.sprite.draw(canvas, 8, -8)

  self.bind "step", ->
    movement = Point(0, 0)

    if I.state.pickup
      I.state.pickup -= 1
      I.sprite = pickupSprite
    else if I.state.action
      target = facing.scale(32).add(self.center()).subtract(Point(8, 8))
      actionBounds =
        x: target.x
        y: target.y
        width: 1
        height: 1

      switch I.state.action
        when "thresh"
          engine.find("Plant").each (plant) ->
            if plant.collides(actionBounds)
              plant.destroy()
        when "plant"
          plantBounds = 
            x: target.x.snap(TILE_SIZE)
            y: target.y.snap(TILE_SIZE)
            width: TILE_SIZE
            height: TILE_SIZE

          if !engine.collides(plantBounds)
            engine.add $.extend(plantBounds,
              class: "Plant"
              type: "tomato"
            )
        when "hoe"
          engine.add
            sprite: Sprite.loadByName("hoed")
            x: target.x.snap(TILE_SIZE)
            y: target.y.snap(TILE_SIZE)
            width: TILE_SIZE
            height: TILE_SIZE
            zIndex: 1

      I.state.action = false

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

      if keydown.space
        I.state.action = I.currentAction

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

