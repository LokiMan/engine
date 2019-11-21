EngineParts = (components, scene, gui, send, PackFor)->
  (componentName)->
    packFor = PackFor componentName

    {
      components...
      components
      scene
      gui
      remote: (command...)-> send packFor command
    }

module.exports = EngineParts
