class FirstFloor extends Layer
  constructor:(home)->
    super
    @home = home
    @menu = new Menu Res.tpls["home-1st-floor"]
    @setImg Res.imgs.homeDown
    @menu.UI.upstairs.onclick = =>
      @home.goUp()
    @menu.UI.exit.onclick = =>
      @home.exit()
  show:->
    @fadeIn "fast"
    @menu.show()
    
class SecondFloor extends Layer
  constructor:(home)->
    super
    @home = home
    @y = - Utils.getSize().height
    @menu = new Menu Res.tpls["home-2nd-floor"]
    @setImg Res.imgs.homeUp
    @menu.UI['work-table'].onclick = =>
      @showWorkTable()
    @menu.UI.downstairs.onclick = =>
      @home.goDown()
  showWorkTable:->
    workTable = new WorkTable @UI['work-table']
    
class window.Home extends Stage
  constructor:(game)->
    super()
    @game = game
    @camera = new Camera()
    @drawQueueAddAfter @camera
    @firstFloor = new FirstFloor this
    @secondFloor = new SecondFloor this
    @camera.render @firstFloor,@secondFloor
    @firstFloor.show()
  goUp:->
    s = Utils.getSize()
    @firstFloor.menu.hide()
    @firstFloor.animate {y:s.height},"normal"
    @secondFloor.animate {y:0},"normal",=>
      @secondFloor.menu.show()
  goDown:->
    s = Utils.getSize()
    @secondFloor.menu.hide()
    @secondFloor.animate {y:-s.height},"normal"
    @firstFloor.animate {y:0},"normal",=>
      @firstFloor.menu.show()
  exit:->
    @clearDrawQueue()
    @game.switchStage "worldMap"
