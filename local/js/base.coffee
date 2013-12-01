window.Dict =
    QualityLevel:[50,150,400,800,1200,2000]
    TraitName:
      life:"生命"
      heal:"治疗"
      fire:"火焰"
      water:"水"
      earth:"地"
      ice:"冰"
      air:"空气"
      minus:"负能量"
      spirit:"灵能"
      snow:"雪"
      explode:"爆炸"
      burn:"燃烧"
      poison:"毒"
      clear:"净化"
      muddy:"泥泞"
      brave:"勇气"
      corrosion:"腐蚀"
      stun:"晕眩"
      fog:"雾气"
      iron:"钢"
      freeze:"霜冻"
      traitTime:"时"
      space:"空"
    TraitLevel:
      1:"life,fire,wind,air,earth"
      2:"heal,minus,spirit,snow,poison,clear,fog,iron,traitTime,space"
      3:"explode,burn,freeze,corrosion"
      
window.Widget = Suzaku.Widget
window.EventEmitter = Suzaku.EventEmitter
class window.Clock extends Suzaku.EventEmitter
  constructor:(rate,callback)->
    super null
    @setRate (rate or "normal")
    @currentDelay = 0
    @paused = false
    if callback then @on "next",callback
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
