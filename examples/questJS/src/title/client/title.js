const Title = function(text) {
  let titleDiv = null;

  center(function() {
    return titleDiv = div({
      html: text
    });
  });

  return {
    // Если у компонента есть функция updateComponent, то при смене сцены
    // не происходит удаление компонента и его пересоздание, а только вызов
    // этой функции с обновляемыми данными
    updateComponent: function(text) {
      return titleDiv.update({
        html: text
      });
    }
  };
};

module.exports = Title;
