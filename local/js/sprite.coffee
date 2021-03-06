class window.Sprite extends Drawable
  constructor:(x,y,spriteOriginData)->
    super x,y
    @spriteOriginData = spriteOriginData
    @dspName = spriteOriginData.name
    @animateClock = new Clock()
    @animateClock.setRate "normal"
    @animateClock.on "next",=>
      @_nextFrame()
    @currentMove = null
    @currentFrame = 0
    @initSprite()
    @width = @spriteData.frames[0].frame.w
    @height = @spriteData.frames[0].frame.h
    if @movements.normal then @defaultMovement = "normal"
    else
      for name of @movements
        @defaultMovement = name
        break
    @useMovement @defaultMovement,true
    @currentFrame = (@currentMove.startFrame - 1) + Math.round(Math.random() * @currentMove.length)
  onDraw:(context,tickDelay)->
    @animateClock.tick tickDelay
    super context,tickDelay
  initSprite:->
    @spriteMap = @spriteOriginData.sprite.map
    @spriteData = @spriteOriginData.sprite.data
    @movements = {}
    for name,data of @spriteOriginData.movements
      a1 = data.split(":")
      arr = a1[0].split(",")
      @movements[name] =
        startFrame:parseInt(arr[0])
        endFrame:parseInt(arr[1])
        length:parseInt(arr[1]) - parseInt(arr[0])
        keyFrames:null
      if a1[1]
        kfs = []
        kfs.push parseInt(f) for f in a1[1].split(",")
        @movements[name].keyFrames = kfs
    @defaultAnchor = 
      x:parseInt(@spriteOriginData.anchor.split(",")[0])
      y:parseInt(@spriteOriginData.anchor.split(",")[1])
    @setAnchor @defaultAnchor
  useMovement:(name,loopThisMove=false,callback)->
    if not @movements[name]
      return console.error "no movment:#{name} in ",this
    if typeof loopThisMove is "function"
      callback = loopThisMove
      loopThisMove = false
    @emit "startMove:#{name}"
    if @currentMove
      @emit "endMove:#{@currentMove.name}"
      if name isnt @currentMove.name then @emit "changeMove",name
    if loopThisMove then @loopMovement = name
    data = @movements[name]
    @currentMove =
      name:name
      startFrame:data.startFrame
      endFrame:data.endFrame
      length:data.length
      keyFrames:data.keyFrames
    #console.error "use movement",@currentMove.name,"loopMovement:",@loopMovement
    @currentFrame = -1
    if callback then @once "endMove:#{name}",callback
    #@_nextFrame()
  _nextFrame:->
    @currentFrame += 1
    if @currentMove.keyFrames
      for f,index in @currentMove.keyFrames
        if (@currentFrame + 1) is f
          @emit "keyFrame",index,@currentMove.keyFrames.length
          break
    realFrame = @currentMove.startFrame + @currentFrame
    if realFrame > @currentMove.endFrame
      @useMovement @loopMovement
      @_nextFrame()
    else
      data = @spriteData.frames[realFrame]
      if not data
        console.error "movement frame out of range!",this,realFrame
        return
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
