class FirstFloor extends Layer
  constructor:(@stage)->
    super()
    @menu = new Menu Res.tpls["home-1st-floor"]
    @setImg Res.imgs.homeDown
    @menu.UI.upstairs.onclick = =>
      @emit "goUp"
  moveDown:(callback)->
    s = Utils.getSize()
    @transform.rotate = 0
    @animate {y:s.height,"transform.rotate":0.5,"transform.opacity":0},"normal","swing",callback
  moveUp:(callback)->
    @animate {y:0,"transform.rotate":0,"transform.opacity":1},"normal","swing",callback
  show:->
    @menu.hide()
    @fadeIn "fast",=>
      @menu.show()
    
class SecondFloor extends Layer
  constructor:(@stage)->
    super()
    @y = - Utils.getSize().height
    @menu = new Menu Res.tpls["home-2nd-floor"]
    @setImg Res.imgs.homeUp
    @menu.UI.downstairs.onclick = =>
      @emit "goDown"
  moveDown:(callback)->
    @animate {y:0},"normal","swing",callback
  moveUp:(callback)->
    s = Utils.getSize()
    @animate {y:-s.height},"normal","swing",callback
    
class window.Home extends Stage
  constructor:(game)->
    super()
    @game = game
    playerData = game.playerData
    @camera = new Camera()
    @firstFloor = new FirstFloor playerData
    @secondFloor = new SecondFloor playerData
    @drawQueueAddAfter @secondFloor,@firstFloor
    @firstFloor.on "goUp",=>
      @firstFloor.menu.hide()
      @firstFloor.moveDown()
      @secondFloor.moveDown =>
        @secondFloor.menu.show()
    @secondFloor.on "goDown",=>
      @secondFloor.menu.hide()
      @secondFloor.moveUp()
      @firstFloor.moveUp =>
        @firstFloor.menu.show()
    @firstFloor.show()
  tick:->
  draw:->
