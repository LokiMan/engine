// Значение аргумента ways получено с сервера из метода Ways.toClient()
const Ways = function(ways, {gui, remote}) {
  const {div, link} = gui

  function Way(name, i) {
    return div(function() {
      return link({
        html: name,
        click: function() {
          // Отправляем команду на сервер, в функцию ways/$remotes$.way()
          return remote('way', i)
        }
      })
    })
  }

  ways.forEach(Way)

  return {}
}

module.exports = Ways
