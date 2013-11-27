class window.MissionsDB extends SubDB
  constructor:->
    super "missions"
    @data =
      firstMission:
        name:"见习魔女"
        from:"dirac"
        description:"想让村里的各位愿意和你交流，首先要证明自己！|用雾之森的外围的素材制作一些药剂看看吧！让我们知道你是个真正的魔法师！"
        catHint:""
        completeStory:"firstMissionComplete"
        reward:
          money:100
        request:
          getSupplies:"firePotion,muddyPotion"
      luna1:
        after:"fistMission"
        name:"魔法物品店老板娘？"
        from:"luna"
        description:"哎呀，你就是那个新来的魔女吧～？|我是在镇上开店的露娜～来我的店里看看"
        request:
          visit:"shop magicItemShop"
          text:"到露娜的商店里去拜会她"
        reward:
          money:50
        autoComplete:true
        catHint:""
        completeStory:"meetLuna"
      luna2:
        after:"luna1"
        name:"药剂是需要素材的！"
        from:"luna"
        description:"最近史莱姆泛滥，搞得货车进不来，我的货源也没法保证了。本来这些家伙是很弱的怪物，可是大家都觉得它们粘粘的太恶心，没一个愿意清理的，你想办法帮帮我吧～|放心，虽然说是帮忙，但是我会付给你报酬的！"
        request:
          kill:"slime 10"
        reward:
          money:200
    
