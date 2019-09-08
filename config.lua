local seed = require("seed")

return table.uptight({
   seed = seed(),

   player_input = {
      keyboard_short_tick_s = 0.125,
      keyboard_long_tick_s = 0.50,
   },

   player = {
      initial_health = 100,
      max_health = 100,
   },

   levels = {
      aboveground = {
         width = 64,
         height = 64,

         background_color = { 9 / 256, 73  / 256, 63 / 256 },

         lighting = "full",

         monsters = {
            n = 0,
            --add_interval_s = 2,
         },

         generation_algorithm =  "random_squares",
         generation_algorithm_settings = {
            square_size_min = 2,
            square_size_max = 15,
            minimum_wall_density = 0.3,
         },
      },

      underground = {
         width = 64,
         height = 64,

         background_color = { 25 / 256, 16 / 256, 46 / 256 },

         lighting = "fog_of_war",
         lighting_settings = {
            lighting_max_range = 10,
            lighting_dimming_range = 6,

            unexplored_alpha = 0.0,
            explored_alpha = 0.2,
         },

         monsters = {
            n = 100,

            batches_n = 8,
            update_interval_s = 1 / 8,

            movement_erraticness = 0.1,
            damage = 3,
            aggro_range = 8,
         },

         generation_algorithm = "cellular_automatons",
         generation_algorithm_settings = {
            initial_wall_chance = 0.45,

            iterations = 8,

            birth_threshold = 5,
            survival_threshold = 4,
         },
      },
   },

   rendering = {
      tileset_cell_size = 32,
      tileset_pixel_density = 2,

      camera_rigidness = 0.15,

      window_cell_size = 32,
      window_width = 24,
      window_height = 24,
   },

--[[
   rendering = {
      tileset_cell_size = 32,
      window_cell_size = 16,
      window_width = 64,
      window_height = 64,
   },
--]]
})
