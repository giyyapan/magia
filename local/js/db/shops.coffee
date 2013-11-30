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
        waitText:["嗯？～","你想做什么呢～？","别看啦～那么喜欢就买呗！"]
        conversations:
          0:"最近货源有些不好弄呢，我都在工会登记了好几个任务了！如果你能帮我完成他们我可是会很开心的哟～| 嘛，对你这样的菜鸟可能有点难就是了~～``呵``呵``呵``呵"
          100:"多亏你的帮忙店里多了很多东西呢～真是太谢谢啦~❤|东西我会给你更低的折扣的～要多来光顾哟～"
        sellableType:"supplies"
        playerSellPrice:{0:0.5,100:0.55,500:0.6,1000:0.65}
        buyableType:"supplies"
        buyableItems:
          0:[
            {name:"healPotion",traitValue:50}
            {name:"firePotion",traitValue:50}
            {name:"muddyPotion",traitValue:50}
            ]
        playerBuyPrice:{0:1,100:0.9,500:0.8}
      equipmentShop:
        name:"奇迹裁缝"
        npc:"lilith"
        bg:"equipShopBg"
      adventurerGuild:
        name:"法师协会"
        npc:"dirak"
        npcName:"狄拉克"
        bg:"guildBg"
        exitText:"嗯。一路顺风！"
        welcomeText:
          0:"你好，年轻的魔女。冒险者协会欢迎你！"
        waitText:["你在找什么？","看看吧，这儿有不少适合你的任务。","嗯..你手上的任务都完成了吗？"]
        conversations:
          0:"只有多完成任务，才能提高你在协会的声望。否则你就只能接到一些鸡毛蒜皮的小事情啦!"
          100:"最近你的表现很不错嘛！公会对你的评价上升了呢！"
        missionLevel:
          0:1
          50:2
          100:3
