class window.ThingsDB extends SubDB
  constructor:->
    super "things"
    @items = new SubDB "things-items"
    @supplies = new SubDB "things-supplies"
    @equipments = new SubDB "things-equipments"
    console.log "fuck"
    @initItems()
    @initSupplies()
    @initEquipments()
    console.log @supplies
  get:(name)->
    return @items.get(name) or @supplies.get(name) or @equipments.get(name)
  initItems:->
    @items.data = 
      earthLow:
        name:"双生蘑菇"
        description:"森林里面会生长的奇特蘑菇，有地属性的能量。"
        traits:["earth:10"]
        gatherRequire:null #要求包括时间，季节，技能，等级等
      earthMid:
        name:"发光石"
        description:"比较少见到的发光宝石，是很多地属性魔法的原料"
        traits:["earth:50"]
        gatherRequire:null #要求包括时间，季节，技能，等级等
      earthHigh:
        name:"圣甲虫琥珀"
        description:"只有在很极端的情况下才能保留下来的宝石，里面的圣甲虫充满了地属性的魔力"
        traits:["earth:200"]
        gatherRequire:null #要求包括时间，季节，技能，等级等
      airLow:
        name:"不化之雾"
        description:"清晨的森林里面可以搜集到的神奇雾气，如果装在瓶子里面就不会化开"
        traits:["air:20"]
        gatherRequire:null #要求包括时间，季节，技能，等级等
      fireLow:
        name:"火焰苔藓"
        description:"一种富含火元素的植物，制作火药的时候会加入这样的粉末"
        traits:["fire:15","earth:8"]
      fireMid:
        name:"火榴石"
        description:"虽然纯度不高，但是也算是火元素的结晶，有比较搞的火元素含量"
        traits:["fire:60"]
      fireHight:
        name:"龙吸袋"
        description:"巨龙喷射龙吸所用的器官的一部分，非常稀有"
        traits:["fire:180"]
      waterLow:
        name:"湖水"
        description:"清澈的湖水，在森林中的小湖里面可以找到"
        traits:["water:10"]
      waterHigh:
        name:"无尽之泉"
        description:"光放着就会有源源不断的水流出来，是一种非常神奇的素材"
        traits:["water:150"]
      iceLow:
        name:"冰结晶"
        description:"冰元素稍微丰富一点的区域就能找到这样的结晶，用来保存食物非常有效"
        traits:["ice:15"]
      iceMid:
        name:"蓝钻"
        description:"很多冰结晶能够生成一颗这样的宝石，冰元素含量不错"
        traits:["ice:60"]
      iceHigh:
        name:"天河之尘"
        description:"非常稀有的一种陨石，虽然表面感受不到温度，但是冰元素的含量非常惊人"
        traits:["ice:380","minus:50"]
      lifeLow:
        name:"药草"
        description:"有治疗效果的药草，很多汉方药里都有它的成分"
        traits:["life:16"]
      lifeMid:
        name:"生命之水"
        description:"擦在伤口上就能让伤口快速愈合的神奇泉水，生命元素很丰富"
        traits:["life:55"]
      minusLow:
        name:"彼岸花"
        description:"生长在生和死的境界线之间的花，有种让人不悦的力量"
        traits:["minus:20"]
      minusMid:
        name:"虚无碎片"
        description:"来自深渊的碎片，据说是魔法战争时期造成的大震动留下的遗产，负能量含量较高"
        traits:["minus:80"]
      spiritLow:
        name:"妖精的羽毛"
        description:"魅惑的妖精翅膀上的羽毛，有一种光是看着就让人着迷的魔力"
        traits:["spirit:30"]
      spiritMid:
        name:"梦魇之角"
        description:"梦魇偶尔会在现界中被找到，他们的角是强大的灵能和负能量来源"
        traits:["spirit:180","minus:120"]
      timeLow:
        name:"时之沙"
        description:"古代遗迹中出土的沙子，据说有操纵时间的神奇能量"
        traits:["traitTime:25"]
      spaceLow:
        name:"以太"
        description:"被称为“不存在之物”的神奇元素，配合适当的魔法能够左右空间"
        traits:["space:20"]
  initSupplies:->
    # 关于魔法属性 type:attack heal buff debuff dot hot
    # 其中 attack,dot使用damage，heal,hot使用heal buff,debuff 使用 effect,onHurt,onHeal 属性
    @supplies.data =
      healPotion:
        name:"治疗药剂"
        description:"有治疗效果的药剂"
        traitName:"heal"
        active:
          name:"治疗术"
          description:"回复一定数量的生命值"
          type:"heal"
          heal:1
        defense:
          name:"回复结界"
          description:"制造一个结界，在受到攻击时回复生命值"
          sameWithActive:true
      muddyPotion:
        name:"泥泞药剂"
        description:"会让人身上变得粘糊糊的药剂，看起来就很奇怪"
        traitName:"muddy"
        active:
          name:"泥泞术"
          description:"降低敌人的行动速度"
          type:"debuff" #debuff 属性值决定效果和成功率
          effect:
            spd:[0.9,0.5]
        defense:
          name:"泥泞陷阱"
          description:"制造一个陷阱，在被攻击时将攻击者减速"
          sameWithActive:true
      firePotion:
        name:"火焰药剂"
        description:"有火焰效果的药剂"
        traitName:"fire"
        active:
          name:"火球术"
          description:"释放火球对单体目标进行攻击"
          type:"attack" # area attack
          sprite:"fireBall"
          damage:#rate
            fire:2
        defense:
          name:"火焰陷阱"
          description:"使用火焰包围身体，在受到攻击时对敌人造成火焰伤害"
          sameWithActive:true
      ironPotion:
        name:"坚硬药剂"
        description:""
        traitName:"iron"
        active:
          name:"坚硬术"
          description:"提升自己的物理防御"
          type:"buff"
          effect:
            def:[1.3,2]
      explodePotion:
        name:"爆炸药剂"
        traitName:"explode"
        active:
          name:"引爆"
          description:"压缩敌人周围的空气一次引爆，造成爆炸伤害并点燃敌人"
          type:"attack"
          damage:
            normal:5
            fire:3
          next:
            type:"dot"
            damage:
              fire:1
      burnPotion:
        name:"燃烧药剂"
        traitName:"burn"
        active:
          name:"点燃"
          description:"点燃敌人，使其每次行动都受到火焰伤害"
          type:"dot"
          sprite:"fireBall"
          damage:
            fire:1
        defense:
          name:"火焰之环"
          description:"制造一个燃烧场，点燃攻击的敌人"
          sameWithActive:true
      corrosionPotion:
        name:"腐蚀药剂"
        traitName:"corrosion"
        active:
          name:"腐蚀术"
          description:"造成负能量伤害，并降低敌人物理防御"
          type:"attack"
          damage:
            minus:5
          next:
            type:"debuff"
            effect:
              def:[0.8,0.3]
        defense:
          name:"腐化结界"
          description:"制造一个腐化结界"
          sameWithActive:true
          rate:0.3
      icePotion:
        name:"冰霜药剂"
        traitName:"ice"
      fogPotion:
        name:"雾气药剂"
        traitName:"fog"
        active:
          type:"debuff"
          name:"雾气召唤"
          description:"在敌人周围制造雾气，降低他们的精准"
          effect:
            accuracy:[0.8,0.5]
      snowPotion:
        name:"风雪药剂"
        traitName:"snow"
      bravePotion:
        name:"勇气药剂"
        traitName:"brave"
        active:
          type:"buff"
          name:"勇气术"
          description:"增加自己的物理攻击力"
          effect:
            atk:[1.5,3]
      cleanPotion:
        name:"净化药剂"
        traitName:"clean"
      poisonPotion:
        name:"毒药"
      stunPotion:
        name:"晕眩药剂"
        traitName:"stun"
        active:
          type:"debuff"
          name:"晕眩术"
          turn:[1,5]
          effect:
            spd:0.1
  initEquipments:->
    # h for hat ; r for robe ; s for shose ; w for weapon
    @equipments.data =
      hat1:"h 20 普通的黑帽 hp:20,def:5"
      robe1:"r 20 普通的披肩 def:15"
      shose1:"s 20 普通的皮鞋 spd:5"
      weapon1:"w 20 木头法杖 atk:15"
      hat2:"h 200 见习魔女帽 hp:50,def:10"
      robe2:"r 300 见习魔女披风 def:40"
      shose2:"s 200 见习魔女鞋 spd:8"
      weapon2:"w 300 木头法杖 atk:20"
        
