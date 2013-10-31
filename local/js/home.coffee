class FirstFloor extends Layer
  constructor:(@stage)->
    super()
    @camera = new Camera()
    @menu = new Menu Res.tpls["home-1st-floor"]
    @setImg Res.imgs.homeDown
    @menu.UI.upstairs.onclick = =>
      @emit "goUp"
    @menu.UI.exit.onclick = =>
      @emit "exit"
  moveDown:(callback)->
    s = Utils.getSize()
    @transform.rotate = 0
    #@animate {y:s.height,"transform.rotate":0.5,"transform.opacity":0},"normal","swing",callback
    @animate {y:s.height},"normal","swing",callback
  moveUp:(callback)->
    #@animate {y:0,"transform.rotate":0,"transform.opacity":1},"normal","swing",callback
    @animate {y:0},"normal","swing",callback
  show:->
    @fadeIn "fast"
    @menu.show()
    
class SecondFloor extends Layer
  constructor:(@stage)->
    super()
    @y = - Utils.getSize().height
    @camera = @stage.camera
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
    @camera = new Camera()
    @firstFloor = new FirstFloor this
    @secondFloor = new SecondFloor this
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
    @firstFloor.on "exit",=>
      @clearDrawQueue()
      @game.switchStage "worldMap"
    @firstFloor.show()
  tick:->
