class window.Drawable extends Suzaku.EventEmitter
  constructor:(x,y,width,height)->
    super()
    @x = x or 0
    @y = y or 0
    @z = null
    @secondCanvas = null
    @offsetSize = true
    @imgData = null
    @width = width or null
    @height = height or null
    @fixedYCoordinates = false
    @anchor =
      x:parseInt @width/2
      y:parseInt @height/2
    @renderData = null
    @blendQueue = []
    @onshow = true
    @transform =
      opacity:null
      translateX:0
      translateY:0
      translateZ:0
      scaleX:1
      scaleY:1
      scale:null
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
    for name,f of Drawable.Animate.funcs
      this[name] = f
  blendWith:(blendImg,method)->
    if not blendImg instanceof BlendImg
      return console.error "invailid blendImg",blendImg
    if not method
      return console.error "no method!"
    @secondCanvas = $("#secondCanvas").get(0) if not @secondCanvas
    @blendQueue.push
      blendImg:blendImg
      method:method
  onDraw:(context,tickDelay)->
    @_handleAnimate tickDelay
    return if not @onshow
    for name,value of @transform
      @realValue[name] = value
    if @blendQueue.length > 0
      @onDrawBlend context,tickDelay
    else
      @onDrawNormal context,tickDelay
  sortDrawQueue:->
    @drawQueue.after.sort (a,b)-> return (a.z or 0) - (b.z or 0)
    @drawQueue.before.sort (a,b)-> return (a.z or 0) - (b.z or 0) if @drawQueue.before
  onDrawBlend:(context,tickDelay)->
    realContext = context
    tempContext = @secondCanvas.getContext "2d"
    tempContext.clearRect 0,0,@width,@height
    for item in @drawQueue.before
      item.onDraw tempContext,0
    @draw tempContext if @draw
    for item in @drawQueue.after
      item.onDraw tempContext,0
    @currentImgData = tempContext.getImageData 0,0,@width,@height
    for b in @blendQueue
      @currentImgData = @_handleBlend tempContext,@currentImgData,b
    @onDrawNormal(realContext,tickDelay)
  onDrawNormal:(context,tickDelay)->
    context.save()
    @emit "render",this
    @_handleTransform context
    for item in @drawQueue.before
      item.onDraw context,tickDelay
    @draw context if @draw
    for item in @drawQueue.after
      item.onDraw context,tickDelay
    context.restore()
  _handleBlend:(tempContext,currentImgData,blendQueueItem)->
    blendData = blendQueueItem.blendImg.getData tempContext
    switch blendQueueItem.method
      when "overlay","linearLight" then blendFunc = Drawable.BlendMethod[blendQueueItem.method]
      else return console.error "invailid blend method #{blendQueueItem.method}"
    blendImgDataPixars = blendData.imgData.data
    currentImgDataPixars = currentImgData.data
    for x in [0 .. blendData.imgData.width]
      for y in [0 .. blendData.imgData.height]
        blendImgIndex = (x + y * blendData.imgData.width) * 4
        currentImgIndex = ((x + blendData.x) + (y + blendData.y) * currentImgData.width) * 4
        pcr = currentImgDataPixars[currentImgIndex]
        pcg = currentImgDataPixars[currentImgIndex+1]
        pcb = currentImgDataPixars[currentImgIndex+2]
        pca = currentImgDataPixars[currentImgIndex+3]
        pbr = blendImgDataPixars[blendImgIndex]
        pbg = blendImgDataPixars[blendImgIndex+1]
        pbb = blendImgDataPixars[blendImgIndex+2]
        pba = blendImgDataPixars[blendImgIndex+3]
        if pcr is undefined or pbr is undefined
          continue
        p = blendFunc pcr,pcg,pcb,pca,pbr,pbg,pbb,pba
        currentImgDataPixars[currentImgIndex] = p.r
        currentImgDataPixars[currentImgIndex+1] = p.g
        currentImgDataPixars[currentImgIndex+2] = p.b
        currentImgDataPixars[currentImgIndex+3] = p.a
    return currentImgData
  _handleTransform:(context)->
    r = @realValue
    x = r.translateX + @x
    y = r.translateY + @y
    context.globalAlpha = r.opacity if r.opacity isnt null
    if r.scaleX < 0 then x = - x
    if r.scaleY < 0 then y = - y
    r.scaleX = r.scale or r.scaleX or 1
    r.scaleY = r.scale or r.scaleY or 1
    #console.log r.scaleX,r.scaleY,x,y
    context.scale r.scaleX,r.scaleY
    context.translate x >> 0,y >> 0
    context.rotate r.rotate if r.rotate
  clearImg:->
    @imgData = null
  drawColor:(color)->
    @clearImg()
    @fillColor = color
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
    s = Utils.getSize()
    return if -@anchor.x >= s.width or -@anchor.y >= s.height
    if @imgData
      i = @imgData
      if @currentImgData
        context.putImageData @currentImgData,0,0,-@anchor.x,-@anchor.y,@width,@height
        @currentImgData = null
      else
        img = i.img
        if i.x
          context.drawImage img,i.x,i.y,i.width,i.height,-@anchor.x,-@anchor.y,@width,@height
        else
          context.drawImage img,-@anchor.x,-@anchor.y,@width,@height
    else if @fillColor
      context.fillStyle = @fillColor
      context.fillRect(-@anchor.x,-@anchor.y,@width,@height)
  clearDrawQueue:->
    @drawQueue.after = []
    @drawQueue.before = []
  drawQueueRemove:(target)->
    arr1 = []
    arr1.push d for d in @drawQueue.after when d isnt target
    @drawQueue.after = arr1
    if arr1.length isnt @drawQueue.after.length then return
    if not @drawQueue.before then return
    arr2 = []
    arr2.push d for d in @drawQueue.before when d isnt target
    @drawQueue.before = arr2
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
    return if @_animates.length is 0
    for a in @_animates
      a.sumDelay += tickDelay
      p = a.easing(a.time,a.sumDelay,a.tickDelay)
      a.lastP = p
      if p > 0.99 or p < a.lastP
        p = 1
        a.end = true
      a.func.call this,p
    arr = []
    old = @_animates
    for a in @_animates
      if not a.end
        arr.push a
    @_animates = arr
    for a in old #这样做是为了防止callback中添加新的动画被一并删除了
      if a.end
        a.callback() if a.callback
    for item,index in old
      old[index] = null
    return true
  setCallback:(time,callback)->
    return console.error "need a callback func" if not callback
    @animate (->),time,"linear",callback
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
        when "fast" then time = GameConfig.speedValue.fast
        when "normal" then time = GameConfig.speedValue.normal
        when "slow" then time = GameConfig.speedValue.slow
    if typeof easing is "string"
      easing = Drawable.Animate.easing[easing]
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
      arr = name.split(".")
      ref = this
      for n in arr
        ref = ref[n]
      if isNaN ref then console.error "invailid key:#{name},#{n}" if GameConfig.debug
      if typeof targetValue is "string"
        if targetValue.indexOf("+=")> -1
          d = parseFloat(targetValue.replace("+=",""))
        if targetValue.indexOf("-=")> -1
          d = - parseFloat(targetValue.replace("-=",""))
      else
        d = targetValue - ref        
      if isNaN d then console.error "invailid value:#{d} for #{name}"
      dataObj[name] = origin:ref,delta:d
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
Drawable.BlendMethod =
  linearLight:(r1,g1,b1,a1,r2,g2,b2,a2)->
    a = a2/255
    # r2 = ((1 - a ) * r1 + a * r2) >> 0
    # g2 = ((1 - a ) * g1 + a * g2) >> 0
    # b2 = ((1 - a ) * b1 + a * b2) >> 0
    r = Math.min(255, Math.max(0, (r2 + 2 * r1) - 1)) >> 0
    g = Math.min(255, Math.max(0, (g2 + 2 * g1) - 1)) >> 0
    b = Math.min(255, Math.max(0, (b2 + 2 * b1) - 1)) >> 0
    p =
      r:((1 - a ) * r1 + a * r) >> 0
      g:((1 - a ) * g1 + a * g) >> 0
      b:((1 - a ) * b1 + a * b) >> 0
      a:a1
Drawable.Animate =
  easing:
    swing:(time,sumDelay)->
      return p = sumDelay/time
    linear:(time,sumDelay,tickDelay)->
      p = sumDelay/time
      return (-Math.cos(p*Math.PI)/2+0.5)
    expoIn:(d,t)->
      return Math.pow( 2, 10 * (t/d - 1) )
    expoOut:(d,t)->
      return ( -Math.pow( 2, -10 * t/d ) + 1 )
    expoInOut:(d,t)->
    	t = t/(d/2)
    	if (t < 1)
        return Math.pow( 2, 10 * (t - 1) )/2
      else
        t = t - 1
      	return (-Math.pow( 2, -10 * t) + 2 )/2
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
    console.log img,this
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
    
class window.BlendImg extends Drawable
  constructor:(source,x,y,width,height)->
    super x,y,width,height
    if typeof source is "string"
      @type = "color"
    else
      @type = "img"
    @source = source
  getData:(context)->
    context.clearRect 0,0,@width,@height
    if @type is "color"
      context.fillStyle = @source
      context.fillRect 0,0,@width,@height
    else
      context.drawImage @source,0,0,width,data
    return {x:@x,y:@y,imgData:context.getImageData(0,0,@width,@height)}
