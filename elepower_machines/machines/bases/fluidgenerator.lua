
-- A generator that creates power using a fuel
function ele.register_fluid_generator(nodename, nodedef)
	local fuel  = nodedef.fuel
	local btime = nodedef.fuel_burn_time or 60

	local buffer_name = nil

	-- Autodetect fluid buffer and the fuel if necessary
	if not nodedef.fluid_buffers then return nil end
	for buf,data in pairs(nodedef.fluid_buffers) do
		buffer_name = buf

		if not fuel and data.accepts and type(data.accepts) == "table" then
			fuel = data.accepts[1]
		end

		break
	end

	local defaults = {
		groups = {
			fluid_container = 1,
			ele_provider = 1,
			oddly_breakable_by_hand = 1,
		},
		tube = false,
		on_timer = function (pos, elapsed)
			local meta     = minetest.get_meta(pos)
			local nodename = nodename

			local burn_time      = meta:get_int("burn_time")
			local burn_totaltime = meta:get_int("burn_totaltime")
			
			local capacity   = ele.helpers.get_node_property(meta, pos, "capacity")
			local generation = ele.helpers.get_node_property(meta, pos, "usage")
			local storage    = ele.helpers.get_node_property(meta, pos, "storage")

			-- Fluid buffer
			local flbuffer = fluid_lib.get_buffer_data(pos, buffer_name)
			if not flbuffer or flbuffer.fluid == "" then return false end

			-- If more to burn and the energy produced was used: produce some more
			if burn_time > 0 then
				if storage + generation > capacity then
					return false
				end

				meta:set_int("storage", storage + generation)

				burn_time = burn_time - 1
				meta:set_int("burn_time", burn_time)
			end

			local pow_percent = math.floor((storage / capacity) * 100)

			-- Burn another bucket of lava
			if burn_time == 0 then
				local inv = meta:get_inventory()
				if flbuffer.amount >= 1000 then
					meta:set_int("burn_time", btime)
					meta:set_int("burn_totaltime", btime)

					-- Take lava
					flbuffer.amount = flbuffer.amount - 1000

					local active_node = nodename.."_active"
					ele.helpers.swap_node(pos, active_node)
				else
					meta:set_string("formspec", ele.formspec.get_fluid_generator_formspec(pow_percent, 0, flbuffer))
					meta:set_string("infotext", ("%s Idle\n%s\n%s"):format(nodedef.description,
						ele.capacity_text(capacity, storage), fluid_lib.buffer_to_string(flbuffer)))

					ele.helpers.swap_node(pos, nodename)
					return false
				end
			end
			if burn_totaltime == 0 then burn_totaltime = 1 end

			local percent = math.floor((burn_time / burn_totaltime) * 100)
			meta:set_string("formspec", ele.formspec.get_fluid_generator_formspec(pow_percent, percent, flbuffer))
			meta:set_string("infotext", ("%s Active\n%s\n%s"):format(nodedef.description,
				ele.capacity_text(capacity, storage), fluid_lib.buffer_to_string(flbuffer)))

			meta:set_int(buffer_name .. "_fluid_storage", flbuffer.amount)

			return true
		end,
		on_construct = function (pos)
			local meta = minetest.get_meta(pos)

			local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
			local storage  = ele.helpers.get_node_property(meta, pos, "storage")

			meta:set_string("formspec", ele.formspec.get_fluid_generator_formspec(math.floor((storage / capacity) * 100), 0))
		end
	}

	nodedef.fuel = nil

	for key,val in pairs(defaults) do
		if not nodedef[key] then
			nodedef[key] = val
		end
	end
	
	ele.register_machine(nodename, nodedef)
end