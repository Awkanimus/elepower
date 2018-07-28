
-- Radiation-shielded Lead Machine Chassis
minetest.register_craft({
	output = "elepower_nuclear:machine_block",
	recipe = {
		{"elepower_dynamics:induction_coil_advanced", "elepower_dynamics:graphite_ingot", "elepower_dynamics:induction_coil_advanced"},
		{"elepower_dynamics:graphite_ingot", "elepower_dynamics:lead_block", "elepower_dynamics:graphite_ingot"},
		{"elepower_dynamics:lead_block", "elepower_dynamics:graphite_ingot", "elepower_dynamics:lead_block"},
	}
})

-- Enrichment Plant
minetest.register_craft({
	output = "elepower_nuclear:enrichment_plant",
	recipe = {
		{"elepower_dynamics:induction_coil_advanced", "elepower_dynamics:soc", "elepower_dynamics:induction_coil_advanced"},
		{"elepower_nuclear:graphite_rod", "elepower_nuclear:machine_block", "elepower_nuclear:graphite_rod"},
		{"elepower_dynamics:wound_silver_coil", "elepower_dynamics:viridisium_gear", "elepower_dynamics:wound_silver_coil"},
	}
})

-- Graphite Moderator
minetest.register_craft({
	output = "elepower_nuclear:graphite_moderator",
	recipe = {
		{"", "elepower_nuclear:graphite_rod", ""},
		{"elepower_nuclear:graphite_rod", "elepower_dynamics:graphite_ingot", "elepower_nuclear:graphite_rod"},
		{"", "elepower_nuclear:graphite_rod", ""},
	}
})

-- Reactor Controller
minetest.register_craft({
	output = "elepower_nuclear:fission_controller",
	recipe = {
		{"elepower_dynamics:wound_copper_coil", "elepower_nuclear:graphite_moderator", "elepower_dynamics:wound_copper_coil"},
		{"elepower_nuclear:graphite_moderator", "elepower_nuclear:machine_block", "elepower_nuclear:graphite_moderator"},
		{"elepower_dynamics:viridisium_gear", "elepower_nuclear:graphite_moderator", "elepower_dynamics:viridisium_gear"},
	}
})

-- Reactor Core
minetest.register_craft({
	output = "elepower_nuclear:fission_core",
	recipe = {
		{"elepower_dynamics:induction_coil_advanced", "elepower_dynamics:graphite_ingot", "elepower_dynamics:induction_coil_advanced"},
		{"elepower_nuclear:graphite_moderator", "elepower_nuclear:machine_block", "elepower_nuclear:graphite_moderator"},
		{"elepower_dynamics:viridisium_gear", "elepower_dynamics:copper_plate", "elepower_dynamics:viridisium_gear"},
	}
})

-- Reactor Fluid Port
minetest.register_craft({
	output = "elepower_nuclear:reactor_fluid_port",
	recipe = {
		{"elepower_dynamics:portable_tank", "elepower_dynamics:copper_plate", "elepower_dynamics:portable_tank"},
		{"elepower_nuclear:graphite_moderator", "elepower_nuclear:machine_block", "elepower_nuclear:graphite_moderator"},
		{"elepower_dynamics:viridisium_gear", "elepower_dynamics:copper_plate", "elepower_dynamics:viridisium_gear"},
	}
})

-- Heat Exchanger
minetest.register_craft({
	output = "elepower_nuclear:heat_exchanger",
	recipe = {
		{"elepower_dynamics:portable_tank", "elepower_dynamics:copper_plate", "elepower_dynamics:portable_tank"},
		{"elepower_dynamics:copper_plate",  "elepower_nuclear:machine_block", "elepower_dynamics:copper_plate"},
		{"elepower_dynamics:portable_tank", "elepower_dynamics:copper_plate", "elepower_dynamics:portable_tank"},
	}
})

elepm.register_craft({
	type   = "enrichment",
	output = { "elepower_nuclear:uranium_dust", "elepower_nuclear:depleted_uranium_dust 3"},
	recipe = { "elepower_nuclear:uranium_lump 4" },
	time   = 30,
})

elepm.register_craft({
	type   = "enrichment",
	output = { "elepower_nuclear:uranium_dust", "elepower_nuclear:depleted_uranium_dust", "elepower_nuclear:nuclear_waste 2"},
	recipe = { "elepower_nuclear:depleted_uranium_dust 4" },
	time   = 40,
})

elepm.register_craft({
	type   = "enrichment",
	output = { "elepower_nuclear:depleted_uranium_dust", "elepower_nuclear:nuclear_waste 3"},
	recipe = { "elepower_nuclear:nuclear_waste 5" },
	time   = 50,
})

-- Graphite rods
elepm.register_craft({
	type   = "grind",
	recipe = { "elepower_dynamics:graphite_ingot" },
	output = "elepower_nuclear:graphite_rod 3",
	time   = 6,
})