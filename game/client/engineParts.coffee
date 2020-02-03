EngineParts = (components, scene, gui, animate, send, PackFor, common)->
  (componentName)->
    packFor = PackFor componentName

    componentAnimate = (duration, finish)->
      if typeof duration is 'object'
        animate {duration..., componentName}, finish
      else
        animate duration, finish, componentName

    componentAnimate.fromTo = (arg)->
      animate.fromTo arg, componentName

    {
      components...
      components
      scene
      gui
      common
      remote: (command...)-> send packFor command
      animate: componentAnimate
    }

module.exports = EngineParts
