class window.Drawable extends Suzaku.EventEmitter
  constructor:(x,y,width,height)->
    super()
    @x = x or 0
    @y = y or 0
    @z = null
    @offsetSize = true
    @imgData = null
    @width = width or 30
    @height = height or 30
    @anchorX = parseInt @width/2
    @anchorY = parseInt @height/2
    @renderData = null
    @onshow = true
    @transform =
      opacity:null
      translateX:0
      translateY:0
      translateZ:0
      scaleX:null
      scaleY:null
      scale:null
      rotate:null
      martrix:null
    @drawQueue = 
      before:[]
      after:[]
    @realValue = {}
    @_initAnimate()
  _initAnimate:->
    @_animates = []
    for name,f of Animate.funcs
      this[name] = f
  onDraw:(context,tickDelay)->
    @_handleAnimate tickDelay
    for name,value in @transform when value isnt null
      @realValue[name] = value
    context.save()
    @_handleTransform context
    @emit "render",this
    for item in @drawQueue.before
      item.onDraw context,tickDelay
    @draw context if @draw
    for item in @drawQueue.after
      item.onDraw context,tickDelay
    context.restore()
  _handleTransform:(context)->
    r = @realValue
    context.translate parseInt @x,parseInt @y
    context.globalAlpha = r.opacity if r.opacity isnt null
    if r.scaleX or r.scaleY isnt null or r.scale isnt null
      r.scaleX = r.scaleX or r.scale or 1
      r.scaleY = r.scaleY or r.scale or 1
      context.scale r.scaleX,r.scaleY
    context.rotate r.rotate if r.rotate isnt null
  setImg:(img,resX,resY,resWidth,resHeight)->
    @imgData =
      img:img
      x:resX
      y:resY
      width:resWidth
      height:resHeight
  draw:(context)->
    return if not @onshow
    s = Utils.getSize()
    x = @x - @anchorX
    y = @y - @anchorY
    return if x >= s.width or y >= s.height
    if @imgData
      i = @imgData
      if i.x
        context.drawImage i.img,i.x,i.y,i.width,i.height,x,y,@width,@height
      else
        context.drawImage i.img,x,y,@width,@height
    else if GameConfig.debug is 2
      context.fillStyle = "rgba(20,20,20,0.2)"
      context.fillRect x,y,@width,@height
  clearDrawQueue:->
    @drawBefore = []
    @drawAfter = []
  drawQueueRemove:(drawable)->
    return if Utils.removeItem drawable,@drawQueue.after
    Utils.removeItem drawable,@drawQueue.before
  drawQueueAddAfter:->
    for d in arguments
      console.error "#{d} is not drawable" if not d.onDraw
      @drawQueue.after.push d 
  drawQueueAddBefore:->
    for d in arguments
      console.error "#{d} is not drawable" if not d.onDraw
      @drawQueue.before.push d 
  _handleAnimate:(tickDelay)->
    for a in @_animates
      a.sumDelay += tickDelay
      p = a.easing(a.time,a.sumDelay,a.tickDelay)
      if p > 0.99
        p = 1
        a.end = true
      a.func.call this,p
    arr = []
    for a in @_animates
      if a.end
        a.callback() if a.callback
      else arr.push a
    item = null for item in @_animates
    @_animates = arr
  animate:(func,time="normal",easing="swing",callback)->
    return console.error "no func" if not func
    if typeof func is "object"
      obj = func
      func = @_generateAnimateFunc obj
    if typeof time is "string"
      switch time
        when "fast" then time = 200
        when "normal" then time = 350
        when "slow" then time = 600
    if typeof easing is "string"
      easing = Animate.easing[easing]
    @_animates.push
      func:func
      time:time
      easing:easing
      end:false
      callback:callback
      sumDelay:0
  _generateAnimateFunc:(obj)->
    dataObj = {}
    for name,targetValue of obj
      if isNaN targetValue then console.error "invailid value:#{targetValue}" if GameConfig.debug
      arr = name.split(".")
      ref = this
      for n in arr
        ref = ref[n]
      if isNaN ref then console.error "invailid key:#{name},#{n}" if GameConfig.debug
      dataObj[name] = origin:ref,delta:(targetValue - ref)
    f = (p)->
      for name,delta of dataObj
        arr = name.split(".")
        ref = this
        for n,index in arr when index < (arr.length - 1)
          ref = ref[n]
        n = arr.pop()
        data = dataObj[name]
        ref[n] = data.origin + data.delta * p
    return f
Animate =
  easing:
    swing:(time,sumDelay)->
      return p = sumDelay/time
    linear:(time,sumDelay,tickDelay)->
      p = sumDelay/time
      return (-Math.cos(p*Math.PI)/2+0.5)
  funcs:
    fadeIn:(time,callback)->
      @animate ((p)->
        @transform.opacity = p
        ),time,"linear",callback
    fadeOut:(time,callback)->
      @animate ((p)->
        @transform.opacity = 1 - p
        ),time,"linear",callback
        
class window.Layer extends Drawable
  constructor:->
    s = Utils.getSize()
    super 0,0,s.width,s.height
    @anchorX = 0
    @anchorY = 0
    
class window.Camera extends Drawable
  #Camera need to be pushed to drawQueue
  constructor:(x,y)->
    size = Utils.getSize()
    x = x or size.width/2
    y = y or size.height/2
    super x,y,size.width,size.height
    @scale = 0
    @defaultX = @x
    @defaultY = @y
    @lens = @defaultLens = 1
    @degree = 30
  lookAt:(target,time)->
    @moveTo target.x,target.y,time
    @lensTo (@width/target.width * 1.1),time
  lensTo:(l,time)->
    dl = l -
     @lens
    @animate ((p)=>
      @lens = dl * p
      ),time,"swing"
  moveTo:(x,y,time)->
    dx = x - @x
    dy = y - @y
    @animate ((p)=>
      @x = dx * p
      @y = dy * p
      ),time,"swing"
  reset:()->
    @x = @defaultX
    @y = @defaultY
    @lens = @defaultLens
  onDraw:(context,tickDelay)->
    @_handleAnimate tickDelay
  render:->
    #先用render方法对drawable或者menu设置监听器，再将他们压入stage的绘制队列中
    self = this
    size = Utils.getSize()
    for d in arguments
      if d.onDraw
        d.on "render",->
          self._render this,size
      else if d instanceof Menu
        d.on "render",->
          self._renderMenu this,size
      console.error "#{d} is not drawable or Menu" if not d.onDraw and GameConfig.debug
  _render:(d,s)->
    if not d.renderData
      d.renderData =
        z:d.z - 1
    rd = d.renderData
    if rd.z isnt d.z + d.realValue.translateZ
      rd.z = d.z + d.realValue.translateZ
      rd.scaleX = (s.width + d.z * Math.tan(@degree))/s.width
      rd.scaleY = (s.height + d.z * Math.tan(@degree))/s.height
    sX = rd.scaleX * @lens
    sY = rd.scaleY * @lens
    r = d.realValue
    if not d.offsetSize
      r.scaleX *= sX
      r.scaleY *= sY
    r.rotate -= @rotate
    r.translateX -= this.x * sX
    r.translateY -= this.y * sY
  _renderMenu:(m,s)->
    if not m.renderData
      m.renderData =
        z:d.z - 1
    rd = d.renderData
    if rd.z isnt m.z
      rd.z = m.z
      rd.scaleX = (s.width + m.z * Math.tan(@degree))/s.width
      rd.scaleY = (s.height + m.z * Math.tan(@degree))/s.height
    Utils.setCSS3Attr m.J,"transform-origin","#{@x}px #{@y}px"
    value = "translate(#{-@x},#{-@y})"
    if not m.offsetSize
      value += "scale(#{rd.scaleX * @lens},#{rd.scaleY * @lens})"
    Utils.setCSS3Attr m.J,"transform",value
    
class window.Menu extends Suzaku.Widget
  constructor:(tpl)->
    super tpl
    console.log this
    @z = 0
    @UILayer = $ GameConfig.UILayerId 
  init:->
    @UILayer.hide()
    @UILayer.html ""
    @appendTo @UILayer 
  show:->
    @init()
    @UILayer.fadeIn "fast"
  hide:->
    @UILayer.fadeOut "fast"
  onDraw:->
    @emit "render"
    
class window.Stage extends Drawable
  constructor:(@game)->
    super()
    @anchorX = 0
    @anchorY = 0
  show:(callback)->
    @fadeIn "fast",callback
  hide:(callback)->
    @fadeOut "fast",callback
  draw:->
  tick:->
