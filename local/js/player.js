(function() {
  var playerData;

  playerData = {
    name: "Nola",
    lastScene: "home",
    level: 1,
    assert: {
      money: 4000,
      gem: 300,
      packItem: [],
      storageItem: [],
      equipment: {
        hat: {
          id: 10
        },
        clothes: {
          id: 11
        },
        belt: {
          id: 20
        },
        shose: {
          id: 25
        }
      }
    },
    ability: {
      hp: 300,
      mp: 300,
      atk: 20,
      def: 30,
      spd: 8,
      luk: 10
    }
  };

  window.PlayerData = (function() {

    function PlayerData(data) {
      var name;
      this.data = data;
      if (!data) {
        this.data = playerData;
      }
      for (name in this.data) {
        this[name] = this.data[name];
      }
    }

    return PlayerData;

  })();

}).call(this);
