class window.TestStage extends Stage
  constructor:(game)->
    super game
    @camera = new Camera()
    l1 = new Layer Res.imgs.layer1
    l1.z = 100000
    l1.width = 2000
    l1.x = -0
    l2 = new Layer Res.imgs.layer2
    l2.z = 2000
    l2.width = 5000
    l3 = new Layer Res.imgs.layer3
    l3.z = 1000
    l3.width = 5000
    l4 = new Layer Res.imgs.layer4
    l4.z = 500
    l4.width = 5000
    l5 = new Layer Res.imgs.layer5
    l5.z = 200
    l5.width = 5000
    l6 = new Layer Res.imgs.layer6
    l6.z = 1
    l6.width = 5000
    @menu = new Menu Res.tpls['test-menu']
    @camera.render l1,l2,l3,l4,l5,l6,@menu
    @drawQueueAddAfter @camera
    #@drawQueueAddAfter @camera,l1,@menu
    @menu.show()
    @key = {}
    window.onmousewheel = (evt)=>
      @camera.sacle += evt.wheelDeltaY/500
      console.log @camera.scale
  tick:->
    if Key.up
      if Key.shift
        @camera.scale += 0.03
        #@camera.z += 20
      else @camera.y -= 20
    if Key.down
      if Key.shift
        @camera.scale -= 0.03
        #@camera.scale = 1 if @camera.scale < 1
        #@camera.z -= 20
      else @camera.y += 20
    if Key.right then @camera.x += 20
    if Key.left then @camera.x -= 20
    #console.log @camera
        
