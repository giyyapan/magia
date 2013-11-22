class window.StartMenu extends Stage
  constructor:(game)->
    super game
    @menu = new Menu Res.tpls['start-menu']
    @initMenu()
  initMenu: ->
    $(".logo-holder").animate
      opacity:"1"
      1000
    @menu.UI["logo-line"].J.animate
      width:  "+=620px"
      800,=>
        @menu.UI["logo-bg"].J.animate
          opacity:"1"
          1500
        @menu.UI["logo-text"].J.animate
          opacity:"1"
          right:"+=80px"
          1500,=>
            @menu.UI["start-but"].J.show().animate
              opacity:"1"
              1000

    @menu.UI.start.onclick = =>
      console.log  "start game btn click"
      lastStage = @game.player.data.lastStage
      @game.switchStage lastStage
    @menu.UI.test.onclick = =>
      console.log  "start game btn click"
      @game.switchStage "test"
    @menu.show()
    console.log @menu
    @menu.UI["start-but"].onclick = =>
      console.log "start-but click"
      @menu.UI["start-but"].J.fadeOut "fast"
      @menu.UI["sub-btn-list"].J.fadeIn "slow"
      @menu.UI["logo-holder"].J.animate
        bottom:"100px"
        500,->
          console.log "logo animate finish"


