Ways = (ways, {scenes})->
  # Вызывается при показе игроку сцены с этим компонентом
  # Возвращаемое значение отправляются как аргумент в клиентскую часть
  # компонента - src/ways/client/ways.coffee
  toClient: ->
    (way[0] for way in ways)

  # Функции, доступные для вызова из клиента, находятся в этом объекте
  $remotes$:
    way: (player, numWay)->
      if (way = ways[numWay])? and scenes[way[1]]?
        player.goTo way[1]

module.exports = Ways
