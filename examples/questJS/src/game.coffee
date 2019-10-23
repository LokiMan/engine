config
  title: 'Квест'
  port: 5310
  startScene: 'first'

# Создание сцены - ее название и набор используемых компонентов сцены
scene 'first',
  title: 'Начало квеста'
  desc: 'Мы находимся в самом начале нашего пути'
  ways: [
    ['Вперед', 'long road']
    ['Налево', 'left']
    ['Направо', 'right']
  ]

scene 'long road',
  title: 'Дорога вперед'
  desc: 'Дорога вперед длинна не по годам'
  ways: [
    ['Назад', 'first']
  ]

scene 'left',
  title: 'Левый путь'
  desc: 'Налево пойдешь - коня потеряешь'
  ways: [
    ['Назад', 'first']
  ]

scene 'right',
  title: 'Правый путь'
  desc: 'Направо пойдешь - коня найдешь'
  ways: [
    ['Назад', 'first']
  ]
