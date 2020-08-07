local function validate_player_input(subconfig)
   assertx.is_table(subconfig)
   assertx.is_number(subconfig.keyboard_short_tick_s)
   assertx.is_number(subconfig.keyboard_long_tick_s)
end

local function validate_rendering(subconfig)
   assertx.is_table(subconfig)

   assertx.is_table(subconfig.tiles)
   assertx.is_number(subconfig.tiles.scale)
   assertx.is_number(subconfig.tiles.size)

   assertx.is_table(subconfig.window)
   assertx.is_number(subconfig.window.width)
   assertx.is_number(subconfig.window.height)

   if subconfig.debug_overlay_enabled then
      assertx.is_boolean(subconfig.debug_overlay_enabled)
   end

   assertx.is_boolean(subconfig.enable_vsync)
end

local function validate_level(subconfig)
   assertx.is_table(subconfig)

   assertx.is_number(subconfig.width)
   assertx.is_number(subconfig.height)

   assertx.is_table(subconfig.background_color)
   assertx.is_number(subconfig.background_color[1])
   assertx.is_number(subconfig.background_color[2])
   assertx.is_number(subconfig.background_color[3])

   assertx.is_table(subconfig.lighting)
   assertx.is_string(subconfig.lighting.algorithm)
   assertx.is_boolean(subconfig.lighting.fog_of_war)
   assertx.is_number(subconfig.lighting.lighting_range)
   if subconfig.lighting.algorithm == "fog_of_war" then
      assertx.is_number(subconfig.lighting.unexplored_alpha)
      assertx.is_number(subconfig.lighting.explored_alpha)
   elseif subconfig.lighting.algorithm == "full" then
      -- Good
   else
      error("bad lighting algorithm")
   end

   assertx.is_table(subconfig.player)
   assertx.is_number(subconfig.player.initial_health)
   assertx.is_number(subconfig.player.max_health)

   if subconfig.monsters then
      assertx.is_table(subconfig.monsters)
      assertx.is_number(subconfig.monsters.max_n)
      if subconfig.monsters.spawning then
         assertx.is_table(subconfig.monsters.spawning)
         assertx.is_number(subconfig.monsters.spawning.seconds_per_spawn)
      end
      if subconfig.monsters.chase_target then
         assertx.is_string(subconfig.monsters.chase_target)
      end
      assertx.is_number(subconfig.monsters.batches_n)
      assertx.is_number(subconfig.monsters.update_interval_s)
      assertx.is_number(subconfig.monsters.movement_erraticness)
      assertx.is_number(subconfig.monsters.damage)
      assertx.is_number(subconfig.monsters.aggro_range)
   end

   if subconfig.gems then
      assertx.is_table(subconfig.gems)
      assertx.is_number(subconfig.gems.density)
   end

   assertx.is_table(subconfig.tiles)
   if subconfig.tiles.algorithm == "cellular_automatons" then
      assertx.is_number(subconfig.tiles.initial_wall_chance)
      assertx.is_number(subconfig.tiles.iterations)
      assertx.is_number(subconfig.tiles.birth_threshold)
      assertx.is_number(subconfig.tiles.survival_threshold)
   else
      error("bad tile algorithm")
   end
end

return function(config)
   validate_player_input(config.player_input)

   validate_rendering(config.rendering)

   validate_level(config.level)
end