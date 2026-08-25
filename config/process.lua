-- Muevete Cuba transport basemap - tilemaker v3 process script
-- Layers: roads, road_labels, admin, poi. No buildings/landuse/natural.
-- Names: only `name` (Spanish), never name:* multilingual tags.

local ROAD_CLASSES = {
	motorway = true, trunk = true, primary = true, secondary = true,
	tertiary = true, unclassified = true, residential = true,
	service = true, track = true,
	motorway_link = true, trunk_link = true, primary_link = true,
	secondary_link = true, tertiary_link = true
}

local POI_CLASSES = {
	fuel = true, hospital = true, clinic = true, pharmacy = true,
	police = true, fire_station = true, bus_station = true
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
	end
end
