# Значение аргумента ways получено с сервера из метода Ways.toClient()
Ways = (ways, {gui, remote})->
  {div, link} = gui

  Way = (name, i)->
    div ->
      link html: name, click: ->
        # Отправляем команду на сервер, в функцию ways/$remotes$.way()
        remote 'way', i

  for way, i in ways
    Way way, i

module.exports = Ways
