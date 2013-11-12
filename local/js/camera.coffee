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
  lookAt:(target,time)->
    @moveTo target.x,target.y,time
    @scaleTo (@width/target.width * 1.1),time
  scaleTo:(scale,time)->
    @animate {scale:scale},time,"swing"
  moveTo:(x,y,time,callback)->
    if x is null then x = @x
    if y is null then y = @y
    @animate {x:x,y:y},time,"swing",callback
  getOffsetPositionX:(x,reference)->
    return x * @getOffsetScaleX(reference)
  getOffsetPositionY:(y,reference)->
    return y * @getOffsetScaleY(reference)
  reset:()->
    @x = @defaultX
    @y = @defaultY
    @scale = @defaultScale
  onDraw:(context,tickDelay)->
    @_handleAnimate tickDelay
    context.save()
    context.translate parseInt(@width/2),parseInt(@height/2)
    @preRender tickDelay
    @draw context
    context.restore()
  draw:(context)->
    context.fillStyle = "black"
    context.drawImage(@secondCanvas,
      -parseInt(@secondCanvas.width/2*@scale),-parseInt(@secondCanvas.height/2*@scale),
      @secondCanvas.width*@scale,@secondCanvas.height*@scale)
    #context.fillRect(-10*@scale,-10*@scale,20*@scale,20*@scale)
  preRender:(tickDelay)->
    s = Utils.getSize()
    w = parseInt s.width / @scale
    h = parseInt s.height / @scale
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
      if d.onDraw
        if d.isMenu
          d.on "render",->
            self._renderMenu this,size
        else
          d.on "render",->
            self._render this,size
        @drawQueueAddAfter d
      console.error "#{d} is not drawable or Menu" if not d.onDraw and GameConfig.debug
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
    originX = parseInt(-x + s.width/2)
    originY = parseInt(-y + s.height/2)
    Utils.setCSS3Attr m.J,"transform-origin","#{originX}px #{originY}px"
    value = "translate(#{parseInt x}px,#{parseInt y}px) "
    value += "rotate(#{@transform.rotate}deg) "
    value += "scale(#{@scale},#{@scale}) "
    Utils.setCSS3Attr m.J,"transform",value
    
