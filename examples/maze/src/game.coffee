config
  title: 'Maze'
  port: 5330

scene 'start',
  maze: [21, 21] # Параметры создания лабиринты, попадают в качестве аргумента
                 # серверной части компоненты - src/maze/server/maze.coffee
