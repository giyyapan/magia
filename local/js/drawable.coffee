class window.Drawable extends Suzaku.EventEmitter
  constructor:(x,y,width,height)->
    super()
    @x = x or 0
    @y = y or 0
    @z = null
    @offsetSize = true
    @imgData = null
    @width = width or null
    @height = height or null
    @fixedYCoordinates = false
    @anchor =
      x:parseInt @width/2
      y:parseInt @height/2
    @renderData = null
    @onshow = true
    @transform =
      opacity:1
      translateX:0
      translateY:0
      translateZ:0
      scaleX:1
      scaleY:1
      scale:1
      rotate:0
      martrix:null
    @drawQueue = 
      before:[]
      after:[]
    @realValue = {}
    @_initAnimate()
  setAnchor:(x,y)->
    if x.x
      y = x.y
      x = x.x
    @anchor =
      x:parseInt x
      y:parseInt y
  _initAnimate:->
    @_animates = []
    for name,f of Animate.funcs
      this[name] = f
  onDraw:(context,tickDelay)->
    @_handleAnimate tickDelay
    for name,value of @transform when value isnt null
      @realValue[name] = value
    context.save()
    @emit "render",this
    @_handleTransform context
    for item in @drawQueue.before
      item.onDraw context,tickDelay
    @draw context if @draw
    for item in @drawQueue.after
      item.onDraw context,tickDelay
    context.restore()
  _handleTransform:(context)->
    r = @realValue
    x = r.translateX + @x
    y = r.translateY + @y
    context.globalAlpha = r.opacity if r.opacity isnt null
    if r.scaleX < 0 then x = - x
    if r.scaleY < 0 then y = - y
    if r.scaleX is null then r.scaleX = r.scale or 1
    if r.scaleY is null then r.scaleY = r.scale or 1
    #console.log r.scaleX,r.scaleY,x,y
    context.scale r.scaleX,r.scaleY
    context.translate parseInt(x),parseInt(y)
    context.rotate r.rotate if r.rotate
  setImg:(img,resX,resY,resWidth,resHeight)->
    if img not instanceof Image
      console.error "need a img to set!",this
      return
    @imgData =
      img:img
      x:resX or null
      y:resY or null
      width:resWidth or null
      height:resHeight or null
    @width = img.width if not @width
    @height = img.height if not @height
    return this
  draw:(context)->
    return if not @onshow
    s = Utils.getSize()
    return if -@anchor.x >= s.width or -@anchor.y >= s.height
    if @imgData
      i = @imgData
      if i.x
        context.drawImage i.img,i.x,i.y,i.width,i.height,-@anchor.x,-@anchor.y,@width,@height
      else
        context.drawImage i.img,-@anchor.x,-@anchor.y,@width,@height
    else if GameConfig.debug is 2
      context.fillStyle = "black"
      context.fillRect(-50,-50,100,100)
      context.fillStyle = "darkred"
      context.fillText("#{parseInt @anchor.x},#{parseInt @anchor.y}",0,100)
  clearDrawQueue:->
    @drawQueue.after = []
    @drawQueue.before = []
  drawQueueRemove:(drawable)->
    return if Utils.removeItem drawable,@drawQueue.after
    Utils.removeItem drawable,@drawQueue.before
  drawQueueAdd:->
    @drawQueueAddAfter.apply this,arguments
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
      if p > 0.98
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
  animate:(func,time="normal",easing,callback)->
    #1:func or obj,time,easing,callback
    #2:func or obj,time,callback
    if typeof easing is "function" and typeof callback is "undefined"
      callback = easing
      easing = "swing"
    if not easing then easing = "swing"
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
    shake:(time,callback)->
      x = @x
      y = @y
      @animate ((p)->
        if p is 1
          @x = x
        else
          @x = x + Math.sin(p*10) * 10
        ),time,"swing",callback
    fadeIn:(time,callback)->
      @animate ((p)->
        @transform.opacity = p
        ),time,"linear",callback
    fadeOut:(time,callback)->
      @animate ((p)->
        @transform.opacity = 1 - p
        ),time,"linear",callback
        
class window.Layer extends Drawable
  constructor:(img)->
    s = Utils.getSize()
    super 0,0,s.width,s.height
    z = 100
    @setAnchor 0,0
    if img instanceof Image then @setImg img
  fixToBottom:->
    s = Utils.getSize()
    @y = s.height - @height
    @fixedYCoordinates = true
  setImg:(img)->
    super img
    @width = img.width
    @height = img.height
    return this
    
class window.Stage extends Drawable
  constructor:(@game)->
    super()
    @setAnchor 0,0
  show:(callback)->
    @fadeIn "normal",callback
  hide:(callback)->
    @fadeOut "normal",callback
  draw:->
  tick:->
    
