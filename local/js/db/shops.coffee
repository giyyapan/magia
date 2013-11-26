class window.ShopsDB extends SubDB
  constructor:->
    super "shops"
    @data =
      magicItemShop:
        name:"绯红魔法店"
        npc:"luna"
        npcName:"露娜"
        bg:"magicShopBg"
        exitText:"下次再来哟～❤"
        welcomeText:
          0:"啊呀，欢迎光临～"
        conversations:
          0:"最近货源有些不好弄呢，我都在工会登记了好几个任务了。|最近的魔法师都懒得很呢～ | 啊，我可不是在说你哟呵呵呵呵"
          100:"多亏你的帮忙店里多了很多东西呢～真是太谢谢啦~"
        sellableType:"supplies"
        playerSellPrice:["0:0.5","100:0.55","500:0.6","1000:0.65"]
        buyableItems:
          0:"healPotion,firePotion,muddyPotion"
        playerBuyPrice:["0:1","100:0.9","500:0.8"]
