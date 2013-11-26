class window.ThingsDB extends SubDB
  constructor:->
    super "things"
    @items = new SubDB "things-items"
    @supplies = new SubDB "things-supplies"
    console.log "fuck"
    @initItems()
    @initSupplies()
    console.log @supplies
  initItems:->
    @items.data = 
      scree:
        name:"小石子"
        img:Res.imgs.item
        description:"随处可见的石头，但是要采集的话还是得去森林吧"
        traits:["earth:10"]
        gatherRequire:null #要求包括时间，季节，技能，等级等
      flint:
        name:"燧石"
        description:"可以打火的石头，能够感受到微弱的火属性魔力"
        traits:["fire:10","earth:5"]
      lakeWater:
        name:"湖水"
        description:"清澈的湖水，含有少量净化所需的元素"
        traits:["water:90","clear:3"]
      blueRose:
        name:"蓝玫瑰"
        description:"蓝色的玫瑰，在森林里的背光面会长。得小心它的刺"
        traits:["water:8","life:8"]
      herbs:
        name:"药草"
        description:"有治疗效果的药草，很多药物里都有它的成分"
        traits:["life:16"]
      mouseTailHerbs:
        name:"鼠尾草"
        description:"长在路边很常见的一种小草，为什么叫鼠尾草而不叫狗尾草呢？这还真是奇怪啊，据说晚上会有闪光的鼠尾草出现…"
        traits:["life:5","earth:20"]
      caveMashroom:
        name:"洞穴菇"
        description:"潮湿的山洞里面才会长的蘑菇，但是却异常的有火属性"
        traits:["fire:8","life:5"]
  initSupplies:->
    @supplies.data =
      healPotion:
        name:"治疗药剂"
        description:"有治疗效果的药剂"
        traitName:"heal"
        active:
          name:"治疗术"
          description:"回复一定数量的生命值"
          type:"heal"
          sprite:null
          heal:100
        defense:
          name:"回复结界"
          description:"制造一个结界，在受到攻击时回复生命值"
          type:"flipOver"
          sprite:"null"
          turn:5
          heal:40
        img:null
      muddyPotion:
        name:"泥泞药剂"
        description:"会让人身上变得粘糊糊的药剂，看起来就很奇怪"
        traitName:"muddy"
        active:
          name:"泥泞术"
          description:"降低敌人的行动速度"
          type:"debuff"
          sprite:null
          debuff:
            spd:"*0.8"
        defense:
          name:"泥巴护体"
          description:"生成结界，被攻击到的时候敌人会减速"
          type:"flipOver"
          sprite:"null"
          turn:5
          heal:40
        img:null
      firePotion:
        name:"火焰药剂"
        img:null
        description:"有火焰效果的药剂"
        traitName:"fire"
        active:
          name:"火球术"
          description:"释放火球对单体目标进行攻击"
          type:"attack" # area attack
          sprite:null
          damage:
            normal:80
            fire:100
        defense:
          name:"火焰陷阱"
          description:"使用火焰包围身体，在受到攻击时对敌人造成火焰伤害"
          type:"flipOver"
          turn:5
          damage:
            fire:80