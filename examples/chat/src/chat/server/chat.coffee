# {broadcast, logger, cron} - объекты, внедренные в компонент из движка
# broadcast - для отправки сообщения списку игроков
# logger - логированние информации и ошибок
# cron - для периодического запуска задач
# Список всех объектов, передаваемых в компоненты можно найти
# в файле: game/server/constructGame.coffee
Chat = ({broadcast, logger, cron})-> (room)->
  players = []

  toClient = ->
    room

  # Функция online вызывается при входе игрока в игру
  online = (player)->
    players.push player

  # Функция offline вызывается при выходе игрока из игры
  offline = (player)->
    players.splice players.indexOf(player), 1

  _broadcast = broadcast.bind null, players

  # Текст для запуска cron-задач парсится при помощи библиотеки later.js -
  # http://bunkat.github.io/later/
  cron 'every 1 minute', ->
    _broadcast 'out', 'Системное сообщение...'

  # Функции, доступные для вызова из клиента, находятся в этом объекте
  $remotes$ =
    message: (player, text)->
      message = "#{player.id}: #{text}"
      _broadcast 'out', message
      logger.info message

  {toClient, online, offline, $remotes$}

module.exports = Chat
