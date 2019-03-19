Title = (text)->
  titleDiv = null

  center ->
    titleDiv = div html: text

  # Если у компонента есть функция updateComponent, то при смене сцены
  # не происходит удаление компонента и его пересоздание, а только вызов
  # этой функции с обновляемыми данными
  updateComponent: (text)->
    titleDiv.update html: text

module.exports = Title
