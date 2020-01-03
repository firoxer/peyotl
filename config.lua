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

         background_color = { 39 / 255, 59 / 255, 45 / 255 },

         lighting = {
            algorithm = "full",
            fog_of_war = false,
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
            aggro_range = math.huge,
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

         background_color = { 3 / 255, 7 / 255, 16 / 255 },

         lighting = {
            algorithm = "fog_of_war",

            fog_of_war = true,

            lighting_range = 5.8, -- Nice and round

            unexplored_alpha = 0.0,
            explored_alpha = 0.4,
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

      enable_vsync = true,
   },
})
