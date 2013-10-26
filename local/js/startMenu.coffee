class window.StartMenu extends Stage
  constructor:(game)->
    super game
    @menu = new Menu Res.tpls['start-menu']
    @menu.UI.start.onclick = =>
      console.log  "start game btn click"
      lastStage = @game.playerData.lastStage
      @game.switchStage lastStage
    @menu.show()
    console.log @menu
