// Значение аргумента ways получено с сервера из метода Ways.toClient()
const Ways = (ways, {gui, remote}) => {
  const {div, link} = gui

  const Way = (name, i) =>
    div(() =>
      link({
        html: name,
        click: () => {
          // Отправляем команду на сервер, в функцию ways/$remotes$.way()
          remote('way', i)
        }
      }))

  ways.forEach(Way)

  return {}
}

module.exports = Ways
