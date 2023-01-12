local _defaultConfig = {
  profile = {
    minimapButton = {
      hide = false,
      lock = false,
      minimapPos = 0,
    },
    config = {
      layout = "Default",
      buttonsPerRow = 5,
      guild = {
        greeting = true,
        farewell = true,
        congratulations = true,
        thanks = true,
      },
      party = {
        greeting = true,
        farewell = true,
        thanks = true,
      },
      instance = {
        greeting = true,
        farewell = true,
      },
    },
    messages = {
      guild = {
        greeting = "Hello",
        farewell = "Bye",
        congratulations = "GZ",
        thanks = "Thanks",
      },
      party = {
        greeting = "Hello",
        farewell = "Bye",
        thanks = "Thanks",
      },
      instance = {
        greeting = "Hello",
        farewell = "Bye",
      }
    }
  }
}

function FHABAddon_GetDefaultConfig()
  return _defaultConfig
end
