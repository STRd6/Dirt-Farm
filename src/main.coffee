window.engine = Engine 
  canvas: $("canvas").powerCanvas()
  includedModules: "Tilemap"
  excludedModules: ["Developer"]

engine.loadMap "house", ->
  engine.add
    class: "Player"
    location: "start"

engine.start()

leversTriggered = {}
window.triggerLever = (name) ->
  leversTriggered[name] = true

window.leverTriggered = (name) ->
  leversTriggered[name]

parent.gameControlData =
  Movement: "Arrow Keys"
  "Action": "Spacebar"

