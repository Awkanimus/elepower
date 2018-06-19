
local PLANTER_TICK = 5

local ranges = {
	-- Slot 1 (starts from upper left corner)
	{
		{x = -4, z = 2,  y = 1},
		{x = -2, z = 4,  y = 1},
	},
	-- Slot 2
	{
		{x = -1, z = 2,  y = 1},
		{x = 1,  z = 4,  y = 1},
	},
	-- Slot 3
	{
		{x = 2,  z = 2,  y = 1},
		{x = 4,  z = 4,  y = 1},
	},
	-- Slot 4
	{
		{x = -4, z = -1, y = 1},
		{x = -2, z = 1,  y = 1},
	},
	-- Slot 5 (center)
	{
		{x = -1, z = -1, y = 1},
		{x = 1,  z = 1,  y = 1},
	},
	-- Slot 6
	{
		{x = 2, z = -1,  y = 1},
		{x = 4, z = 1,   y = 1},
	},
	-- Slot 7
	{
		{x = -4, z = -4, y = 1},
		{x = -2, z = -2, y = 1},
	},
	-- Slot 8
	{
		{x = -1, z = -4, y = 1},
		{x = 1, z = -2,  y = 1},
	},
	-- Slot 9 (last one, bottom right)
	{
		{x = 2, z = -4,  y = 1},
		{x = 4, z = -2,  y = 1},
	},
}

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("src")
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	if listname == "layout" then
		local inv = minetest.get_meta(pos):get_inventory()
		stack:set_count(1)
		inv:set_stack(listname, index, stack)
		return 0
	end

	return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)

	if from_list == "layout" then
		inv:set_stack(from_list, from_index, ItemStack(nil))
		return 0
	end

	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	if listname == "layout" then
		local inv = minetest.get_meta(pos):get_inventory()
		inv:set_stack(listname, index, ItemStack(nil))
		return 0
	end

	return stack:get_count()
end

local function plant(pos, range, stack, inv)
	local planted   = 0
	local range_st  = vector.add(ranges[range][1], pos)
	local range_end = vector.add(ranges[range][2], pos)

	local y_top = 0
	if minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name ~= "air" then
		y_top = y_top + 1
	end

	if not stack or stack:is_empty() then
		return 0
	end

	local to_plant = stack:get_name()
	local to_place = nil
	local amount = 0
	local till   = false
	for _,stack in ipairs(inv:get_list("src")) do
		if stack:get_name() == to_plant then
			amount = amount + stack:get_count()
		end
	end

	-- Saplings
	if ele.helpers.get_item_group(to_plant, "sapling") then
		to_place = to_plant
		to_plant = nil
	elseif ele.helpers.get_item_group(to_plant, "seed") then
		to_place = nil
		till     = true
	end

	if (to_plant or to_place) and amount > 0 then
		for x = range_st.x, range_end.x do
			if amount == 0 then break end
			for z = range_st.z, range_end.z do
				if amount == 0 then break end
				local place_pos = {x = x,           y = range_st.y  + y_top, z = z}
				local base_pos  = {x = place_pos.x, y = place_pos.y - 1,     z = place_pos.z}
				local base_node = minetest.get_node_or_nil(base_pos)

				-- Make sure we're planting on soil, till it if necessary
				if base_node and ele.helpers.get_item_group(base_node.name, "soil") then
					local node = minetest.get_node_or_nil(place_pos)
					if node and node.name == "air" then
						if till then
							local regN = minetest.registered_nodes
							if regN[base_node.name].soil     == nil or
							   regN[base_node.name].soil.wet == nil or
							   regN[base_node.name].soil.dry == nil then
								till = false
							end

							if till then
								minetest.sound_play("default_dig_crumbly", {
									pos = base_pos,
									gain = 0.5,
								})

								minetest.set_node(base_pos, {name = regN[base_node.name].soil.dry})
							end
						end

						local take = to_place
						if to_place then
							minetest.set_node(place_pos, {name = to_place})
						else
							local seeddef = minetest.registered_items[to_plant]

							farming.place_seed(to_plant, nil, {type = "node", under = base_pos, above = place_pos},
								seeddef.next_plant)

							take = to_plant
						end

						planted = planted + 1
						amount  = amount  - 1

						inv:remove_item("src", ItemStack(take, 1))
					end
				end
			end
		end
	end

	return planted
end

local function on_timer(pos, elapsed)
	local refresh = false
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()

	local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
	local usage    = ele.helpers.get_node_property(meta, pos, "usage")
	local storage  = ele.helpers.get_node_property(meta, pos, "storage")

	local work = meta:get_int("src_time")

	if storage > usage then
		if work == PLANTER_TICK then
			local planted = 0
			for index, slot in ipairs(inv:get_list("layout")) do
				if planted >= 9 then break end
				if not slot:is_empty() then
					planted = planted + plant(pos, index, slot, inv)
				end
			end

			work = 0
			if planted > 0 then
				storage = storage - usage
			end
		else
			work = work + 1
		end

		refresh = true
	end

	local power_percent = math.floor((storage / capacity)*100)
	local work_percent  = math.floor((work / PLANTER_TICK)*100)

	meta:set_string("formspec", elefarm.formspec.planter_formspec(work_percent, power_percent))
	meta:set_int("storage", storage)
	meta:set_int("src_time", work)

	return refresh
end

ele.register_base_device("elepower_farming:planter", {
	description  = "Automatic Planter",
	ele_capacity = 12000,
	ele_inrush   = 288,
	ele_usage    = 128,
	tiles = {
		"elefarming_machine_planter.png", "elefarming_machine_base.png", "elefarming_machine_side.png",
		"elefarming_machine_side.png", "elefarming_machine_side.png", "elefarming_machine_side.png",
	},
	groups = {
		oddly_breakable_by_hand = 1,
		ele_machine = 1,
		ele_user = 1,
		cracky = 1,
		tubedevice = 1,
		tubedevice_receiver = 1,
	},
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()
		inv:set_size("layout", 9)
		inv:set_size("src", 16)

		meta:set_int("src_time", 0)

		meta:set_string("formspec", elefarm.formspec.planter_formspec(0,0))
	end,
	allow_metadata_inventory_put  = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	can_dig  = can_dig,
	on_timer = on_timer,
})
