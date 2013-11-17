window.Widget = Suzaku.Widget
window.EventEmitter = Suzaku.EventEmitter
class window.Clock extends Suzaku.EventEmitter
  constructor:->
    super
    @setRate "normal"
    @currentDelay = 0
    @currentDelay = 0
    @paused = false
  setRate:(value)->
    switch value
      when "normal" then value = 13
      when "fast" then value = 20
      when "slow" then value = 8
      else value = parseInt(value)
    @frameRate = value
    @frameDelay = parseInt(1000/@frameRate)
  tick:(tickDelay)->
    @currentDelay += tickDelay
    while @currentDelay > @frameDelay
      @currentDelay -= @frameDelay
      if not @paused then @emit "next"
      
class window.Menu extends Suzaku.Widget
  constructor:(tpl)->
    super tpl
    @isMenu = yes
    @z = 0
    @UILayer = $ GameConfig.UILayerId
  init:->
    @UILayer.hide()
    @UILayer.html ""
    @appendTo @UILayer 
  show:(callback)->
    @init()
    @J.show()
    @UILayer.fadeIn "fast",callback
  hide:(callback)->
    @UILayer.fadeOut "fast",=>
      @J.hide()
      callback() if callback
  onDraw:->
    @emit "render",this
    
class window.PopupBox extends Suzaku.Widget
  constructor:(tpl)->
    super tpl or Res.tpls['popup-box']
    @box = @UI.box
    @J.hide()
    @box.J.hide()
    @UILayer = $ GameConfig.UILayerId
    self = this
    if @UI['close-btn']
      @UI['close-btn'].onclick = ->
        self.close()
    if @UI['accept-btn']
      @UI['accept-btn'].onclick = ->
        self.accept()
  show:->
    @appendTo @UILayer
    @J.fadeIn "fast"
    @box.J.slideDown "fast"
  close:->
    self = this
    @J.fadeOut "fast"
    @box.J.slideUp "fast",->
      self.remove()
      self = null
  accept:->
    console.log this,"accept" if window.GameConfig.debug
