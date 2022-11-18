function serialize_list (tabl, indent)
    if indent == nil then
        indent = 0
    end

    local str = string.rep("    ", indent) .. "{\n"
    for key, value in pairs (tabl) do
        if type(key) == "number" then
            key = "[" .. key .. "]"
	end

	if type(value) == "table" then
            if type(key) == "string" then
                str = str .. string.rep("    ", indent+1) .. key .. " = "
            end
            str = str .. serialize_list(value, indent+1)
	elseif type(value) == "number" then
	    str = str .. string.rep("    ", indent+1) .. key .. " = " .. value .. ",\n"
	elseif type(value) == "string" then
	    str = str .. string.rep("    ", indent+1) .. key .. " = \"" .. value .. "\",\n"
	end
    end
    str = str .. string.rep("    ", indent) .. "}"
    if indent ~= 0 then
        str = str .. ",\n"
    end

    return str
end

local industryConfigs = require("industry_unit_map")
industryConfigs.products = require("industry_config")

items = require("items_api_dump")
itemsByName = {}

for itemId in pairs(items) do
    itemsByName[items[itemId].displayNameWithSize] = itemId
end

if industryConfigs.products then
    for i, product in pairs(industryConfigs.products) do
	local productName = product
	local quantity = 1

        if type(product) == "table" and product.item then
             productName = product.item
	end
        if type(product) == "table" and product.quantity then
	     quantity = product.quantity
	end
	
        industryConfigs.products[i] = {
            id = itemsByName[productName],
	    quantity = quantity
	}
    end
end

units = {}

for _, c in pairs(industryConfigs.recipes) do
    local items = {}

    for _, item in pairs(c.items) do
        if itemsByName[item] == nil then
            print("invalid item name: " .. item)
            exit()
        end
	table.insert(items, {
	    itemName = item,
            item = tonumber(itemsByName[item]),
	})
    end

    c.items = items

    for itemName, itemId in pairs(itemsByName) do
        if itemName:lower():match(c.unit:lower()) then
            units[tonumber(itemId)] = itemName
        end
    end
end

print("return " .. serialize_list({
    units = units,
    industryConfigs = industryConfigs.recipes,
    products = industryConfigs.products
}))
