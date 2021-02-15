const Ways = ({scenes}) =>
  (ways) => ({
    // Вызывается при показе игроку сцены с этим компонентом
    // Возвращаемое значение отправляются как аргумент в конструктор
    // клиентской части компонента - src/ways/client/ways.coffee
    toClient() {
      return ways.map((way) => way[0])
    },

    // Функции, доступные для вызова из клиента, находятся в этом объекте
    $remotes$: {
      way(player, numWay) {
        const way = ways[numWay]
        if ((way != null) && (scenes[way[1]] != null)) {
          player.goTo(way[1])
        }
      }
    }
  })

module.exports = Ways
