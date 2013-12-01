class window.SpritesDB extends SubDB
  constructor:()->
    super "sprites"
    @sprites = new SubDB "sprites-monsters"
    @effects = new SubDB "sprites-effects"
    @init()
  get:(name)->
    res = @sprites.get(name)
    if res then return res
    return @effects.get(name)
  init:->
    @sprites.data =
      player:
        name:"艾丽西亚"
        sprite:Res.sprites.player
        icon:Res.imgs.playerBattleIcon
        anchor:"200,330"
        movements:
          normal:"0,0"
          attack:"0,10:10"
          cast:"0,10:10"
      qq:
        sprite:Res.sprites.qq
        icon:Res.imgs.qqBattleIcon
        anchor:"270,240"
        movements:
          normal:"0,6"
          move:"7,15"
          attack:"16,23:4,6"
          cast:"0,6"
      iceQQ:
        sprite:Res.sprites.iceQQ
        icon:Res.imgs.qqBattleIcon
        anchor:"270,240"
        movements:
          normal:"0,6"
          move:"7,15"
          attack:"16,23:4,6"
          cast:"0,6"
      pig:
        sprite:Res.sprites.pig
        icon:Res.imgs.pigBattleIcon
        anchor:"245,240"
        movements:
          normal:"0,0"
          move:"0,7"
          attack:"8,16:4"
          onattack:"17,17"
          cast:"0,6"
      pigDark:
        sprite:Res.sprites.pigDark
        icon:Res.imgs.pigBattleIcon
        anchor:"245,240"
        movements:
          normal:"0,0"
          move:"0,7"
          attack:"8,16:4"
          onattack:"17,17"
          cast:"0,6"
      slime:
        sprite:Res.sprites.slime
        icon:Res.imgs.slimeBattleIcon
        anchor:"191,180"
        movements:
          normal:"0,0"
          move:"0,6"
          attack:"7,17:9"
          cast:"0,6"
    @effects.data =
      fireBall:
        name:"水球术"
        movements:
          normal:""
          active:""
