return table.uptight({
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
         gems = false,

         width = 32,
         height = 32,

         background_color = { 195 / 256, 163 / 256, 138 / 256 },

         lighting = "full",

         monsters = false,

         generation_algorithm =  "preset_aboveground",
         generation_algorithm_settings = {
            square_size_min = 2,
            square_size_max = 15,
            minimum_wall_density = 0.3,
         },
      },

      underground = {
         width = 64,
         height = 64,

         background_color = { 6 / 256, 15 / 256, 23 / 256 },

         lighting = "fog_of_war",
         lighting_settings = {
            lighting_range = 7.8, -- Nice and round

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

         gems = {
            density = 0.01,
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
      scale = 3,

      tile_size = 16,

      window_width = 20,
      window_height = 20,

      camera_rigidness = 0.05,

      debug_overlay_enabled = false,
   },
})
