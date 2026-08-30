-- Muevete Cuba transport basemap - tilemaker v3 process script
-- Layers: roads, road_labels, admin, poi, water.
-- Names: only `name` (Spanish), never name:* multilingual tags.
--
-- MPC-02 OPTIMIZATION CANDIDATES (NOT locked):
--   config.json carries per-layer simplification flags:
--     roads       simplify_below 13, level 0.0003, ratio 2.0
--     road_labels simplify_below 12, level 0.0003, ratio 2.0
--     admin       simplify_below 9,  level 0.0005, ratio 2.0
--     poi         none (points; simplification does not apply)
--   These values stay CANDIDATES until the visual before/after gate
--   (spec MPC-04) is reviewed and approved in this repo. If the gate
--   rejects, revert/adjust these flags and re-run.
--
-- DECISION (recorded per MPC-02): classes `service` and `track` are
-- FILTERED OUT of ROAD_CLASSES entirely instead of minzoom-elevated.
-- Rationale: dense low-value geometry at z12+ for a transport basemap;
-- exclusion shrinks tiles with no orientation loss at the zooms the app
-- ships (z2-z14). Subject to the same MPC-04 visual approval.

local ROAD_CLASSES = {
	motorway = true, trunk = true, primary = true, secondary = true,
	tertiary = true, unclassified = true, residential = true,
	-- service / track intentionally excluded (MPC-02 candidates, see above)
	motorway_link = true, trunk_link = true, primary_link = true,
	secondary_link = true, tertiary_link = true
}

local POI_CLASSES = {
	fuel = true, hospital = true, clinic = true, pharmacy = true,
	police = true, fire_station = true, bus_station = true
}

local WATER_WAY_CLASSES = {
	riverbank = true, pond = true, canal = true, dock = true,
	marsh = true, wetland = true
}

local WATER_LANDUSE_CLASSES = {
	reservoir = true, basin = true
}

-- Nodes are only scanned when one of these keys is present (tilemaker contract)
node_keys = { "amenity" }

function node_function()
	local amenity = Find("amenity")
	if amenity ~= "" and POI_CLASSES[amenity] then
		Layer("poi", false)
		Attribute("class", amenity)
		local name = Find("name")
		if name ~= "" then Attribute("name", name) end
		MinZoom(10)
	end
end

-- Emit a water layer feature for the current object
function emit_water(class)
	Layer("water", true)
	Attribute("class", class)
end

function way_function()
	local highway = Find("highway")
	if highway ~= "" and ROAD_CLASSES[highway] then
		Layer("roads", false)
		Attribute("class", highway)
		local name = Find("name")
		if name ~= "" then
			Attribute("name", name)
			Layer("road_labels", false)
			Attribute("name", name)
			Attribute("class", highway)
		end
		if highway == "motorway" or highway == "trunk" then
			MinZoom(6)
		elseif highway == "primary" then
			MinZoom(8)
		elseif highway == "secondary" then
			MinZoom(10)
		else
			MinZoom(12)
		end
		return
	end

	local boundary = Find("boundary")
	if boundary == "administrative" then
		local level = Find("admin_level")
		if level == "2" or level == "4" or level == "6" then
			Layer("admin", true)
			Attribute("admin_level", level)
			local name = Find("name")
			if name ~= "" then Attribute("name", name) end
		end
		return
	end

	-- Water polygons (closed ways)
	local natural = Find("natural")
	if natural == "water" then
		local water = Find("water")
		if water ~= "" then emit_water(water)
		else emit_water("water") end
		return
	end

	local waterway = Find("waterway")
	if WATER_WAY_CLASSES[waterway] then
		emit_water(waterway)
		return
	end

	local landuse = Find("landuse")
	if WATER_LANDUSE_CLASSES[landuse] then
		emit_water(landuse)
		return
	end
end

function relation_function()
	-- Administrative boundaries come as multipolygon relations
	local boundary = Find("boundary")
	if boundary == "administrative" then
		local level = Find("admin_level")
		if level == "2" or level == "4" or level == "6" then
			Layer("admin", true)
			Attribute("admin_level", level)
			local name = Find("name")
			if name ~= "" then Attribute("name", name) end
		end
		return
	end

	-- Water multipolygon relations
	local natural = Find("natural")
	if natural == "water" then
		local water = Find("water")
		if water ~= "" then emit_water(water)
		else emit_water("water") end
		return
	end

	local waterway = Find("waterway")
	if WATER_WAY_CLASSES[waterway] then
		emit_water(waterway)
		return
	end

	local landuse = Find("landuse")
	if WATER_LANDUSE_CLASSES[landuse] then
		emit_water(landuse)
		return
	end
end
