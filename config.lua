return tablex.uptight({
   player_input = {
      keyboard_short_tick_s = 0.125,
      keyboard_long_tick_s = 0.50,
   },

   rendering = {
      tiles = {
         scale = 3,
         size = 16,
      },

      window = {
         width = 20,
         height = 20,
      },

      fps_overlay_enabled = true,
      debug_overlay_enabled = false,

      enable_vsync = true,
   },

   level = {
      width = 64,
      height = 64,

      background_color = { 3 / 255, 7 / 255, 16 / 255 },

      lighting = {
         algorithm = "fog_of_war",

         fog_of_war = true,

         lighting_range = 5.8, -- Nice and round

         unexplored_alpha = 0.0,
         explored_alpha = 0.4,
      },

      player = {
         initial_health = 100,
         max_health = 100,
      },

      monsters = {
         max_n = 100,

         spawning = {
            seconds_per_spawn = 100,
         },

         chase_target = "player",

         batches_n = 8,
         update_interval_s = 1 / 8,

         movement_erraticness = 0.1,
         damage = 3,
         aggro_range = 8,
      },

      gems = {
         density = 0.01,
      },

      tiles = {
         algorithm = "cellular_automatons",

         initial_wall_chance = 0.45,
         iterations = 8,
         birth_threshold = 5,
         survival_threshold = 4,
      },
   },
})
