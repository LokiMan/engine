const Ways = function(ways, {scenes}) {
  return {
    // Вызывается при показе игроку сцены с этим компонентом
    // Возвращаемое значение отправляются как аргумент в клиентскую часть
    // компонента - src/ways/client/ways.coffee
    toClient: function() {
      let results = [];
      for (let i = 0, len = ways.length; i < len; i++) {
        const way = ways[i];
        results.push(way[0]);
      }
      return results;
    },

    // Функции, доступные для вызова из клиента, находятся в этом объекте
    $remotes$: {
      way: function(player, numWay) {
        let way;
        if (((way = ways[numWay]) != null) && (scenes[way[1]] != null)) {
          return player.goTo(way[1]);
        }
      }
    }
  };
};

module.exports = Ways;
