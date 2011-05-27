Wall = (I) ->
  $.reverseMerge I,
    width: 32
    height: 32
    solid: true

  if I.invisible 
    I.sprite = Sprite.NONE

  GameObject(I)

