class Magia
  constructor:->
    @playerData = new PlayerData()
    @size = null
    @canvas = new Suzaku.Widget("#gameCanvas")
    @UILayer = new Suzaku.Widget("#UILayer")
    @handleDisplaySize()
    window.onresize = =>
      @handleDisplaySize()
    #@db = new Database()
    @loadResources =>
      @initScene "start"
  initScene:(scene)->
    console.log "init scene:",scene
    switch scene
      when "start" then s = new StartScene this
      when "home" then s = new HomeScene this
    s.show()
  handleDisplaySize:->
    s =
      width:window.innerWidth
      height:window.innerHeight
      defaultWidth:1280
      defaultHeight:720
    @screenSize = s
    if (s.width/s.height) < (s.defaultWidth/s.defaultHeight)
      targetWidth = s.width
      targetHeight = targetWidth/s.defaultWidth * s.defaultHeight
    else
      targetHeight = s.height
      targetWidth = targetHeight/s.defaultHeight * s.defaultWidth
    console.log targetHeight
    console.log targetWidth
    w = Utils.sliceNumber targetWidth/s.defaultWidth,3
    h = Utils.sliceNumber targetHeight/s.defaultHeight,3
    J = $(".screen")
    console.log s.width,targetWidth
    console.log parseInt((s.width-targetWidth)/2)
    J.css "left",parseInt((s.width-targetWidth)/2)+"px"
    Utils.setCSS3Attr J,"transform","scale(#{w},#{h})"
    Utils.setCSS3Attr J,"transform-origin","#{0}px 0"
    console.log @canvas.dom
  loadResources:(callback)->
    loadingPage = new Suzaku.Widget "#loadingPage"
    rm = new ResourceManager()
    rm.setPath "img","img/"
    for name,src of window.Imgs
      rm.useImg name,src
    rm.on "loadOne",(total,loaded,type)=>
      percent = loaded/total*100
      loadingPage.UI.percent.innerText = "#{parseInt percent}%"
    rm.start callback
    
window.onload = ->
  magia = new Magia()
    
    
      
        
