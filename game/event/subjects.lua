local Subject = require("game.event.subject")

return {
   entity_manager = Subject.new(),
   player_input = Subject.new(),
}
