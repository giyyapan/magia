class window.Sprite extends Drawable
  constructor:(x,y,originData)->
    super x,y
    @originData = originData
    @dspName = originData.name
    @frameRate = 20
    @frameDelay = parseInt(1000/@frameRate)
    @currentDelay = 0
    @currentFrame = 0
    @initSprite()
    @startFrame = 0
    @endFrame = 0
    @currentFrame = 0
    @defaultMovement = "normal"
    @useMovement "normal",true
  onDraw:(context,tickDelay)->
    @_handleMovementAnimate tickDelay
    super context,tickDelay
  initSprite:->
    @spriteMap = @originData.sprite.map
    @spriteData = @originData.sprite.data
    @movements = {}
    for name,data of @originData.movements
      @movements[name] =
        startFrame:parseInt(data.split(",")[0])
        endFrame:parseInt(data.split(",")[1])
    @defaultAnchor = 
      x:parseInt(@originData.anchor.split(",")[0])
      y:parseInt(@originData.anchor.split(",")[1])
    @setAnchor @defaultAnchor
  useMovement:(name,loopMovement=false)->
    if loopMovement then @defaultMovement = name
    @startFrame = @movements[name].startFrame
    @endFrame = @movements[name].endFrame
    @currentFrame = 0
  _handleMovementAnimate:(tickDelay)->
    @currentDelay += tickDelay
    while @currentDelay > @frameDelay
      @currentDelay -= @frameDelay
      @_nextFrame()
  _nextFrame:->
    realFrame = @startFrame + @currentFrame
    if realFrame > @endFrame
      @useMovement @defaultMovement
      @_nextFrame()
    else
      data = @spriteData.frames[realFrame]
      ax = @defaultAnchor.x - data.spriteSourceSize.x
      ay = @defaultAnchor.y - data.spriteSourceSize.y
      frameData = data.frame
      resX = frameData.x
      resY = frameData.y
      resWidth = frameData.w
      resHeight = frameData.h
      @width = frameData.w
      @height = frameData.h
      @setAnchor ax,ay
      @setImg @spriteMap,resX,resY,resWidth,resHeight
