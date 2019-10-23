// Значение аргумента ways получено с сервера из метода Ways.toClient()
const Ways = function(ways, {remote}) {
  function Way(name, i) {
    return div(function() {
      return link({
        html: name,
        click: function() {
          // Отправляем команду на сервер, в функцию ways/$remotes$.way()
          return remote('way', i);
        }
      });
    });
  }

  for (let i = 0, len = ways.length; i < len; i++) {
    const way = ways[i];
    Way(way, i);
  }

  return {}
};

module.exports = Ways;
