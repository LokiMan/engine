const Ways = function({scenes}) {
  return function(ways) {
    return {
      // Вызывается при показе игроку сцены с этим компонентом
      // Возвращаемое значение отправляются как аргумент в конструктор
      // клиентской части компонента - src/ways/client/ways.coffee
      toClient: function() {
        return ways.map((way) => way[0])
      },

      // Функции, доступные для вызова из клиента, находятся в этом объекте
      $remotes$: {
        way: function(player, numWay) {
          let way
          if (((way = ways[numWay]) != null) && (scenes[way[1]] != null)) {
            return player.goTo(way[1])
          }
        }
      }
    }
  }
}

module.exports = Ways
