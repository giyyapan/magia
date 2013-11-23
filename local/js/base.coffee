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
      
class window.Menu extends Widget
  constructor:(tpl)->
    super tpl
    @isMenu = yes
    @z = 0
    @UILayer =
      J:$ GameConfig.UILayerId
      dom:$(GameConfig.UILayerId).get 0
  init:->
    @UILayer.J.hide()
    @UILayer.J.html ""
    @appendTo @UILayer 
  show:(callback)->
    @init()
    @J.show()
    @UILayer.J.fadeIn "fast",callback
  hide:(callback)->
    @UILayer.J.fadeOut "fast",=>
      @J.hide()
      callback() if callback
  onDraw:->
    @emit "render",this
