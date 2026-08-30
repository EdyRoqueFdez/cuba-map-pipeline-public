-- Muevete Cuba full basemap - tilemaker v3 process script
-- All OSM features retained for Maps.me dark styling
-- Layers: water, landuse, buildings, roads, road_labels, admin, poi

local ROAD_CLASSES = {
	motorway = true, trunk = true, primary = true, secondary = true,
	tertiary = true, unclassified = true, residential = true,
	service = true, track = true, motorway_link = true, trunk_link = true,
	primary_link = true, secondary_link = true, tertiary_link = true,
	living_street = true, pedestrian = true, steps = true
}

local LANDUSE_CLASSES = {
	residential = true, commercial = true, industrial = true,
	retail = true, cemetery = true, forest = true, farmland = true,
	grass = true, meadow = true, orchard = true, vineyard = true,
	railway = true, military = true, conservation = true, nature_reserve = true
}

local NATURAL_CLASSES = {
	wood = true, grassland = true, scrub = true, wetland = true,
	sand = true, bare_rock = true, scree = true, cliff = true,
	coastline = true
}

local LANDCOVER_CLASSES = {
	grass = true, trees = true, sand = true, snow = true
}

local WATERWAY_CLASSES = {
	riverbank = true, pond = true, canal = true, dock = true,
	marsh = true, wetland = true, stream = true, river = true
}

local POI_CLASSES = {
	fuel = true, hospital = true, clinic = true, pharmacy = true,
	police = true, fire_station = true, bus_station = true,
	restaurant = true, cafe = true, bar = true, pub = true,
	hotel = true, motel = true, hostal = true,
	parking = true, bank = true, supermarket = true,
	marketplace = true, school = true, university = true,
	library = true, post_office = true, telephone = true,
	toilets = true, drinking_water = true, bench = true,
	atm = true, cinema = true, theatre = true, nightclub = true,
	sports_centre = true, stadium = true, park = true,
	playground = true, garden = true, attraction = true,
	museum = true, gallery = true, information = true
}

node_keys = { "amenity", "shop", "tourism", "leisure", "information" }

function node_function()
	local amenity = Find("amenity")
	if amenity ~= "" and POI_CLASSES[amenity] then
		Layer("poi", false)
		Attribute("class", amenity)
		local name = Find("name")
		if name ~= "" then Attribute("name", name) end
		if amenity == "hospital" or amenity == "clinic" then
			MinZoom(10)
		elseif amenity == "fuel" or amenity == "pharmacy" or amenity == "police" then
			MinZoom(11)
		else
			MinZoom(12)
		end
		return
	end

	local shop = Find("shop")
	if shop ~= "" then
		Layer("poi", false)
		Attribute("class", shop)
		local name = Find("name")
		if name ~= "" then Attribute("name", name) end
		MinZoom(13)
		return
	end

	local tourism = Find("tourism")
	if tourism ~= "" then
		Layer("poi", false)
		Attribute("class", tourism)
		local name = Find("name")
		if name ~= "" then Attribute("name", name) end
		if tourism == "hotel" or tourism == "hostel" then
			MinZoom(12)
		else
			MinZoom(13)
		end
		return
	end

	local leisure = Find("leisure")
	if leisure ~= "" then
		Layer("poi", false)
		Attribute("class", leisure)
		local name = Find("name")
		if name ~= "" then Attribute("name", name) end
		MinZoom(13)
		return
	end
end

function way_function()
	-- Water polygons (highest priority, closed ways)
	local natural = Find("natural")
	if natural == "water" then
		Layer("water", true)
		local water = Find("water")
		if water ~= "" then Attribute("class", water)
		else Attribute("class", "water") end
		return
	end

	local waterway = Find("waterway")
	if WATERWAY_CLASSES[waterway] then
		Layer("water", true)
		Attribute("class", waterway)
		return
	end

	local landuse = Find("landuse")
	if landuse == "reservoir" or landuse == "basin" then
		Layer("water", true)
		Attribute("class", landuse)
		return
	end

	-- Landuse polygons
	if landuse ~= "" and LANDUSE_CLASSES[landuse] then
		Layer("landuse", true)
		Attribute("class", landuse)
		return
	end

	-- Natural land cover
	if natural ~= "" and NATURAL_CLASSES[natural] then
		Layer("landuse", true)
		Attribute("class", natural)
		return
	end

	local landcover = Find("landcover")
	if landcover ~= "" and LANDCOVER_CLASSES[landcover] then
		Layer("landuse", true)
		Attribute("class", landcover)
		return
	end

	-- Leisure areas (parks, gardens)
	local leisure = Find("leisure")
	if leisure == "park" or leisure == "garden" or leisure == "nature_reserve" then
		Layer("landuse", true)
		Attribute("class", leisure)
		return
	end

	-- Buildings
	local building = Find("building")
	if building ~= "" then
		Layer("buildings", true)
		if building ~= "yes" then Attribute("class", building) end
		return
	end

	-- Roads
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
			MinZoom(2)
		elseif highway == "primary" then
			MinZoom(4)
		elseif highway == "secondary" then
			MinZoom(6)
		elseif highway == "tertiary" then
			MinZoom(8)
		elseif highway == "unclassified" or highway == "residential" then
			MinZoom(10)
		else
			MinZoom(12)
		end
		return
	end

	-- Administrative boundaries
	local boundary = Find("boundary")
	if boundary == "administrative" then
		local level = Find("admin_level")
		if level == "2" or level == "4" or level == "6" or level == "8" then
			Layer("admin", true)
			Attribute("admin_level", level)
			local name = Find("name")
			if name ~= "" then Attribute("name", name) end
		end
		return
	end
end

function relation_function()
	-- Water multipolygon relations
	local natural = Find("natural")
	if natural == "water" then
		Layer("water", true)
		local water = Find("water")
		if water ~= "" then Attribute("class", water)
		else Attribute("class", "water") end
		return
	end

	local waterway = Find("waterway")
	if WATERWAY_CLASSES[waterway] then
		Layer("water", true)
		Attribute("class", waterway)
		return
	end

	local landuse = Find("landuse")
	if landuse == "reservoir" or landuse == "basin" then
		Layer("water", true)
		Attribute("class", landuse)
		return
	end

	-- Landuse multipolygon relations
	if landuse ~= "" and LANDUSE_CLASSES[landuse] then
		Layer("landuse", true)
		Attribute("class", landuse)
		return
	end

	-- Natural land cover relations
	if natural ~= "" and NATURAL_CLASSES[natural] then
		Layer("landuse", true)
		Attribute("class", natural)
		return
	end

	local landcover = Find("landcover")
	if landcover ~= "" and LANDCOVER_CLASSES[landcover] then
		Layer("landuse", true)
		Attribute("class", landcover)
		return
	end

	local leisure = Find("leisure")
	if leisure == "park" or leisure == "garden" or leisure == "nature_reserve" then
		Layer("landuse", true)
		Attribute("class", leisure)
		return
	end

	-- Buildings multipolygon
	local building = Find("building")
	if building ~= "" then
		Layer("buildings", true)
		if building ~= "yes" then Attribute("class", building) end
		return
	end

	-- Administrative boundaries
	local boundary = Find("boundary")
	if boundary == "administrative" then
		local level = Find("admin_level")
		if level == "2" or level == "4" or level == "6" or level == "8" then
			Layer("admin", true)
			Attribute("admin_level", level)
			local name = Find("name")
			if name ~= "" then Attribute("name", name) end
		end
		return
	end
end
