class window.Camera extends Drawable
  #Camera need to be pushed to drawQueue
  constructor:(x,y)->
    s = Utils.getSize()
    x = x or 0
    y = y or 0
    super x,y,s.width,s.height
    @defaultScale = @scale = 1
    @defaultX = @x
    @defaultY = @y
    @degree = 45
    @secondCanvas = $("#secondCanvas").get(0)
    @defaultReferenceZ = 0
    @followData = null
  follow:(target,z)->
    @followData =
      target:target
      z:z
  unfollow:->
    @followData = null
  _handleFollow:->
    return if not @followData
    @setCenter @followData.target.x,@followData.target.y,@followData.z
  setCenter:(x,y,z)->
    s = Utils.getSize()
    z = @defaultReferenceZ if not z
    x = @getOffsetPositionX (s.width/2 - x),z
    y = @getOffsetPositionY (s.height/2 - y),z
    @x = -x
    @y = -y
  lookAtInsideBorder:(target,border,scale,callback)->
    z = border.z or @defaultReferenceZ
    
  lookAt:(target,time,scale,z,callback)->
    if not z then z = @defaultReferenceZ
    s = Utils.getSize()
    x = @getOffsetPositionX (s.width/2 - target.x),z
    y = @getOffsetPositionY (s.height/2 - target.y),z
    @moveTo -x,-y,time,callback
    @scaleTo (scale or s.width/target.width * 0.48),time,callback
  scaleTo:(scale,time)->
    @animate {scale:scale},time,"expoOut"
  moveTo:(x,y,time,callback)->
    if x is null then x = @x
    if y is null then y = @y
    @animate {x:x,y:y},time,"expoOut",callback
  getOffsetPositionX:(x,reference)->
    return x * @getOffsetScaleX(reference)
  getOffsetPositionY:(y,reference)->
    return y * @getOffsetScaleY(reference)
  reset:()->
    @x = @defaultX
    @y = @defaultY
    @scale = @defaultScale
  onDraw:(context,tickDelay)->
    context.globalCompositeOperation = "source-over"
    @_handleFollow()
    @_handleAnimate tickDelay
    context.save()
    context.translate (@width/2) >> 0,(@height/2) >> 0
    @preRender tickDelay
    @draw context
    context.restore()
  draw:(context)->
    if @transform.opacity isnt null
      context.globalAlpha = @transform.opacity
    context.fillStyle = "black"
    context.drawImage(@secondCanvas,
      -(@secondCanvas.width/2*@scale) >> 0,-(@secondCanvas.height/2*@scale) >> 0,
      @secondCanvas.width*@scale,@secondCanvas.height*@scale)
    #context.fillRect(-10*@scale,-10*@scale,20*@scale,20*@scale)
  preRender:(tickDelay)->
    s = Utils.getSize()
    w = s.width / @scale >> 0
    h = s.height / @scale >> 0
    @secondCanvas.width = w
    @secondCanvas.height = h
    context = @secondCanvas.getContext "2d"
    context.clearRect(0,0,w,h)
    context.save()
    context.translate (w-s.width)/2,(h-s.height)/2
    for item in @drawQueue.after
      item.onDraw context,tickDelay
    context.restore()
  render:->
    #对drawable或者menu设置监听器,再将其压入绘制队列。camera本身必须被绘制
    self = this
    size = Utils.getSize()
    for d in arguments
      if d instanceof HTMLElement or d instanceof $
        z = d.z or @defaultReferenceZ
        d = new Menu d
        d.z = z
      if d.onDraw
        if d.isMenu
          d.on "render",->
            self._renderMenu this,size
        else
          d.on "render",->
            self._render this,size
        @drawQueueAddAfter d
      console.error "#{d} is not drawable or Menu" if not d.onDraw and GameConfig.debug
    @sortDrawQueue()
  sortDrawQueue:->
    @drawQueue.after.sort (a,b)-> return (b.z or 0) - (a.z or 0)
  getOffsetScaleX:(targetZ,s)->
    if typeof targetZ is "object"
      targetZ = targetZ.z
    s = Utils.getSize() if not s
    return (s.width + (targetZ) * Math.tan(@degree))/s.width
  getOffsetScaleY:(targetZ,s)->
    if typeof targetZ is "object"
      targetZ = targetZ.z
    s = Utils.getSize() if not s
    return (s.height + (targetZ) * Math.tan(@degree))/s.height
  _render:(d,s)->
    if not d.renderData
      d.renderData =
        z:d.z - 1
    rd = d.renderData
    if rd.z isnt (d.z + d.realValue.translateZ)
      rd.z = d.z + d.realValue.translateZ
      rd.scaleX = @getOffsetScaleX d,s
      rd.scaleY = @getOffsetScaleY d,s
    sX = rd.scaleX
    sY = rd.scaleY
    r = d.realValue
    r.rotate = r.rotate - @rotate
    r.translateX = r.translateX - (@x / sX)
    if not d.fixedYCoordinates
      r.translateY = r.translateY - (@y / sY) 
    if not d.offsetSize
      r.scaleX *= sX
      r.scaleY *= sY
  _renderMenu:(m,s)->
    if not m.z then m.z = @defaultReferenceZ
    if not m.renderData
      m.renderData =
        z:m.z - 1
    rd = m.renderData
    if rd.z isnt m.z 
      rd.z = m.z
      rd.scaleX = @getOffsetScaleX m,s
      rd.scaleY = @getOffsetScaleY m,s
    sX = rd.scaleX 
    sY = rd.scaleY
    x = - (@x / sX)
    y = - (@y / sY)
    if rd.x is x and rd.y is y and rd.rotate is @transform.rotate and rd.scale is @scale
      return
    rd.x = x
    rd.y = y
    rd.rotate = @transform.rotate
    rd.scale = @scale
    originX = (-x + s.width/2) >> 0
    originY = (-y + s.height/2) >> 0
    Utils.setCSS3Attr m.J,"transform-origin","#{originX}px #{originY}px"
    value = "translate(#{x >> 0}px,#{y >> 0}px) "
    value += "rotate(#{@transform.rotate}deg) "
    value += "scale(#{@scale},#{@scale}) "
    Utils.setCSS3Attr m.J,"transform",value
    
