return tablex.uptight({
   player_input = {
      keyboard_short_tick_s = 0.125,
      keyboard_long_tick_s = 0.50,
   },

   player = {
      initial_level = "temple",
      initial_health = 100,
      max_health = 100,
   },

   levels = {
      temple = {
         width = 32,
         height = 32,

         background_color = { 187 / 256, 187 / 256, 187 / 256 },

         lighting = {
            algorithm = "full",
         },

         monsters = {
            max_n = 50,

            spawning = {
               seconds_per_spawn = 30,
               location = "bottom_edge",
            },

            chase_target = "altar",

            batches_n = 8,
            update_interval_s = 1 / 8,

            movement_erraticness = 0.1,
            damage = 3,
            aggro_range = false,
         },

         gems = false,

         altar = true,

         generation = {
            algorithm = "preset_temple",

            square_size_min = 2,
            square_size_max = 15,
            minimum_wall_density = 0.3,
         },
      },

      dungeon = {
         width = 64,
         height = 64,

         background_color = { 0 / 256, 0 / 256, 0 / 256 },

         lighting = {
            algorithm = "fog_of_war",

            lighting_range = 7.8, -- Nice and round

            unexplored_alpha = 0.0,
            explored_alpha = 0.2,
         },

         monsters = {
            max_n = 100,

            spawning = {
               seconds_per_spawn = 100,
               location = "everywhere"
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

         altar = false,

         generation = {
            algorithm = "cellular_automatons",

            initial_wall_chance = 0.45,
            iterations = 8,
            birth_threshold = 5,
            survival_threshold = 4,
         },
      },
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

      camera_rigidness = 0.05,

      debug_overlay_enabled = false,
   },
})
