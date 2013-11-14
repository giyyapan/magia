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
    
class window.PopupBox extends Suzaku.Widget
  constructor:(tpl)->
    super tpl or Res.tpls['popup-box']
    @box = @UI.box
    @J.hide()
    @box.J.hide()
    self = this
    if @UI['close-btn']
      @UI['close-btn'].onclick = ->
        self.close()
    if @UI['accept-btn']
      @UI['accept-btn'].onclick = ->
        self.accept()
  show:->
    @appendTo $("#UILayer")
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
