---
slots:
  '0':
    name: slot10
    type:
      events: []
      methods: []
  '1':
    name: slot9
    type:
      events: []
      methods: []
  '2':
    name: slot8
    type:
      events: []
      methods: []
  '3':
    name: slot7
    type:
      events: []
      methods: []
  '4':
    name: slot6
    type:
      events: []
      methods: []
  '5':
    name: slot5
    type:
      events: []
      methods: []
  '6':
    name: slot4
    type:
      events: []
      methods: []
  '7':
    name: slot3
    type:
      events: []
      methods: []
  '8':
    name: slot2
    type:
      events: []
      methods: []
  '9':
    name: slot1
    type:
      events: []
      methods: []
  '-1':
    name: unit
    type:
      events: []
      methods: []
  '-3':
    name: player
    type:
      events: []
      methods: []
  '-2':
    name: construct
    type:
      events: []
      methods: []
  '-4':
    name: system
    type:
      events: []
      methods: []
  '-5':
    name: library
    type:
      events: []
      methods: []
handlers:
- code: queueItem(slot10, status)
  filter:
    args:
    - variable: '*'
    signature: onStatusChanged(status)
    slotKey: '0'
  key: '0'
- code: queueItem(slot9, status)
  filter:
    args:
    - variable: '*'
    signature: onStatusChanged(status)
    slotKey: '1'
  key: '1'
- code: queueItem(slot8, status)
  filter:
    args:
    - variable: '*'
    signature: onStatusChanged(status)
    slotKey: '2'
  key: '2'
- code: queueItem(slot7, status)
  filter:
    args:
    - variable: '*'
    signature: onStatusChanged(status)
    slotKey: '3'
  key: '3'
- code: queueItem(slot6, status)
  filter:
    args:
    - variable: '*'
    signature: onStatusChanged(status)
    slotKey: '4'
  key: '4'
- code: queueItem(slot5, status)
  filter:
    args:
    - variable: '*'
    signature: onStatusChanged(status)
    slotKey: '5'
  key: '5'
- code: queueItem(slot4, status)
  filter:
    args:
    - variable: '*'
    signature: onStatusChanged(status)
    slotKey: '6'
  key: '6'
- code: queueItem(slot3, status)
  filter:
    args:
    - variable: '*'
    signature: onStatusChanged(status)
    slotKey: '7'
  key: '7'
- code: queueItem(slot2, status)
  filter:
    args:
    - variable: '*'
    signature: onStatusChanged(status)
    slotKey: '8'
  key: '8'
- code: queueItem(slot1, status)
  filter:
    args:
    - variable: '*'
    signature: onStatusChanged(status)
    slotKey: '9'
  key: '9'
- code: unit.setTimer("init", 0.1)
  filter:
    args: []
    signature: onStart()
    slotKey: '-1'
  key: '10'
- code: |-
    unitStatuses = {}

    local currentTime = system.getArkTime()

    for unitId, config in pairs(unitItems) do
        local info      = config.unit.getInfo()
        local unitState = info.state
        local cProduct  = info.currentProducts[1]

        queueItem(config.unit, unitState)
       
        local recipe = ""
        local remaining = 0
        local prettyPercent = 0
        local iconPath = 0
        local schematic = ""

        local currentProductAmount = info.currentProductAmount
        local maintainProduct = info.maintainProductAmount

        if cProduct ~= nil then
            local item = system_getItem(cProduct.id)
            recipe = item.displayNameWithSize
            if item.schematics ~= nil and #item.schematics > 0 then
                local schematicId = tostring(item.schematics[1])
                schematic = system_getItem(schematicId).displayNameWithSize:gsub("Schematic Copy", "")
            end
            iconPath = item.iconPath
            local totalTime = getCycleTime(info)
            if totalTime ~= nil then
                remaining = getRemainingTime(totalTime, config.unit, info)
                prettyPercent = 1 - percentage(remaining, totalTime)
            end
        end

        table.insert(unitStatuses, {
            unitState,
            remaining,
            recipe,
            config.unit.getName(), -- slotElementName(config.unit),
            prettyPercent,
            iconPath,
            schematic,
            currentProductAmount,
            maintainProduct,
            currentTime - config.transitionTime
        })
    end

    local encoded = json.encode(unitStatuses):gsub("[\\[][\\[]", "[ ["):gsub("[]][]]", "] ]")
    local rendered = renderScript:gsub("REPLACE_DATA", "[[ " .. encoded .. " ]]")

    for _, screen in pairs(screens) do
        screen.setRenderScript(rendered)
    end

    gc()
  filter:
    args:
    - value: tick
    signature: onTimer(tag)
    slotKey: '-1'
  key: '11'
- code: |-
    if initCoroutine == nil then
        initCoroutine = coroutine.create(initFn)
    end

    coroutine.resume(initCoroutine)

    if coroutine.status(initCoroutine) == "dead" then
        unit.stopTimer("init")
        unit.setTimer("tick", 0.5)
    end
  filter:
    args:
    - value: init
    signature: onTimer(tag)
    slotKey: '-1'
  key: '12'
- code: |-
    configFile = require("industry_config")
    items = configFile.units
    if items[4139262245] == nil then
        items[4139262245] = "Transfer Unit l"
    end
    industryConfigs = configFile.industryConfigs
    products = configFile.products

    STOPPED        = 1
    STARTED        = 2
    NO_INGREDIENTS = 3
    OUTPUT_FULL    = 4
    NO_OUTPUT      = 5
    PENDING        = 6
    MISSING_SCHEM  = 7
    INVALID_STUCK  = 10

    stateNames = {
        [STOPPED] = "Stopped",
        [STARTED] = "Running",
        [NO_INGREDIENTS] = "No Ingredients",
        [OUTPUT_FULL] = "Output Full",
        [NO_OUTPUT] = "No Output Container",
        [PENDING] = "No Ingredients",
        [MISSING_SCHEM] = "Missing Schematic",
        [INVALID_STUCK] = "Unit Needs Restart",
    }

    renderScript = [[
    rslib = require("rslib")
    json = require("dkjson")

    STOPPED        = 1
    STARTED        = 2
    NO_INGREDIENTS = 3
    OUTPUT_FULL    = 4
    NO_OUTPUT      = 5
    PENDING        = 6
    MISSING_SCHEM  = 7
    INVALID_STUCK  = 10

    stateNames = {
        [STOPPED] = "Stopped",
        [STARTED] = "Running",
        [NO_INGREDIENTS] = "No Ingredients",
        [OUTPUT_FULL] = "Output Full",
        [NO_OUTPUT] = "No Output Container",
        [PENDING] = "No Ingredients",
        [MISSING_SCHEM] = "Missing Schematic",
        [INVALID_STUCK] = "Unit Needs Restart",
    }

    -- red: 0.73152, 0.32042, 0.31876
    -- green: 0.29412, 0.70196, 0.39608
    -- blue: 0.30588, 0.67843, 0.70980
    -- grey: 0.75686, 0.81176, 0.89412
    -- pink: 0.90196, 0.78039, 0.77255
    -- dark green: 0.25098, 0.49412, 0.43922

    colors = {
        ["Output Full"] = {0.73152, 0.32042, 0.31876},
        ["No Output Container"] = {0.73152, 0.32042, 0.31876},
        ["No Ingredients"] = {0.90196, 0.78039, 0.77255},
        ["Missing Schematic"] = {0.73152, 0.32042, 0.31876},
        ["Completed"] = {0.25098, 0.49412, 0.43922},
        ["Running"] = {0.29412, 0.70196, 0.39608},
    }

    function prettyTime(timeS)
        local timeM = 0

        if timeS > 60 then
            timeM = math.floor(timeS / 60)
            timeS = math.floor(timeS % 60)
        end

        if timeM == 0 then
            return numtostr(timeS) .. "s"
        end

        local timeH = 0

        if timeM > 60 then
            timeH = math.floor(timeM / 60)
            timeM = math.floor(timeM % 60)
        end

        if timeH == 0 then
            return numtostr(timeM) .. "m" .. numtostr(timeS) .. "s"
        end

        return numtostr(timeH) .. "h" .. numtostr(timeM) .. "m" .. numtostr(timeS) .. "s"
    end

    function numtostr(num)
        return string.format("%.0f", num)
    end

    function printRenderCost()
        logMessage(string.format("render cost: %d / %d", getRenderCost(), getRenderCostMax()))
    end

    function mkTable(tableData)
        local nColumns = 8
        local nRows = #tableData

        local tbl = {}

        local layer = createLayer()
        local imageLayer = createLayer()
        local rx, ry = getResolution()
        local font = loadFont("Play", 18)
        local smallFont = loadFont("Play", 14)
        setDefaultTextAlign(imageLayer, AlignH_Center, AlignV_Middle)

        local rowIndex = 0

        for i, r in pairs(tableData) do        
            local boxWidth = rx / 3.5
            local boxHeight = ry / 3.5
            local imageSize = boxWidth / 5

            if (i - 1) % 3 == 0 then
                rowIndex = rowIndex + 1
            end

            local boxStartX = ((rx - (boxWidth*3.1)) / 3) + ((boxWidth * 1.1) * ((i - 1) % 3))
            local boxStartY = ((ry - (boxHeight*3.1)) / 3) + ((boxHeight * 1.1) * (rowIndex - 1))

            local boxMidX = boxStartX + (boxWidth / 2)
            local textPaddingY = boxHeight / 9
            local textPaddingX = boxWidth / 10
            local imagePaddingX = (boxWidth - imageSize) / 2
            local imagePaddingY = textPaddingY

            local iconPath = r[6]
            local recipe = r[3]
            local industryUnit = r[4]
            local schematicName = r[7]
            local progress = r[5]
            local remainingTime = prettyTime(r[2])
            local desired = r[9]
            local lastTransition = r[10]

            local current = r[8]
            if current >= 16777216 then
                current = math.floor(current / 16777216)
            end

            local state = ""
            if r[1] ~= nil and stateNames[ r[1] ] ~= nil then
                state = stateNames[ r[1] ]
            end       
            if current >= desired and state ~= "Running" then
                state = "Completed"
            end

            setNextShadow(layer, 20, 0.1, 0.1, 0.1, 0.5)

            local color = {0.75686, 0.81176, 0.89412}
            if colors[state] ~= nil then
                color = colors[state]
            end        
            if lastTransition > 180 and state ~= "Running" then
                color = {0.73152, 0.32042, 0.31876}
            end

            setNextFillColor(layer, color[1], color[2], color[3], 1)
            addBoxRounded(layer, boxStartX, boxStartY, boxWidth, boxHeight, 10)
            setNextFillColor(layer, 0, 0, 0, 1)
            local boxPaddingX = boxWidth / 40
            local boxPaddingY = boxHeight / 40
            local innerBoxStartX = boxStartX + boxPaddingX
            local innerBoxStartY = boxStartY + boxPaddingX + textPaddingY
            local innerBoxHeight = boxHeight - (boxPaddingX*2) - textPaddingY
            addBoxRounded(layer, innerBoxStartX, innerBoxStartY, boxWidth - (boxPaddingX*2), innerBoxHeight, 10)

            local recipeLines = rslib.getTextWrapped(font, recipe, boxWidth - (textPaddingX * 2))
            local recipeLinesStartY = innerBoxStartY + textPaddingY
            for i, line in ipairs(recipeLines) do
                setNextFillColor(imageLayer, 1, 1, 1, 1)
                setNextTextAlign(imageLayer, AlignH_Center, AlignV_Middle)
                addText(imageLayer, font, line, boxMidX, recipeLinesStartY + textPaddingY*(i-1))
            end

            local imageId = loadImage(iconPath)
            addImage(imageLayer, imageId, boxMidX - (imageSize / 2), innerBoxStartY + (innerBoxHeight - imageSize) / 2, imageSize, imageSize)

            setNextFillColor(imageLayer, 0, 0, 0, 1)
            setNextTextAlign(imageLayer, AlignH_Center, AlignV_Middle)
            addText(imageLayer, smallFont, industryUnit, boxMidX, boxStartY + (textPaddingY/2))

            setNextTextAlign(imageLayer, AlignH_Center, AlignV_Middle)
            addText(imageLayer, smallFont, current .. " / " .. math.floor(desired), boxMidX, boxStartY + boxHeight - textPaddingY*2)

            addText(imageLayer, smallFont, schematicName, boxMidX, boxStartY + boxHeight - textPaddingY*3)

            if state == "Running" then
                setNextTextAlign(imageLayer, AlignH_Center, AlignV_Middle)
                addText(imageLayer, smallFont, remainingTime, boxMidX, boxStartY + boxHeight - textPaddingY)
                setNextFillColor(imageLayer, 0, 1, 0, 1)
                addLine(imageLayer, boxStartX + textPaddingX, boxStartY + boxHeight - textPaddingY, boxStartX + ((boxWidth - textPaddingX*2) * progress), boxStartY + boxHeight - textPaddingY)
            else
                setNextTextAlign(imageLayer, AlignH_Center, AlignV_Middle)
                addText(imageLayer, smallFont, state .. " (" .. prettyTime(lastTransition) .. ")", boxMidX, boxStartY + boxHeight - textPaddingY)
            end

            printRenderCost()
        end

        return tbl
    end

    local input = REPLACE_DATA
    if input ~= nil then
        logMessage("length: " .. #input .. " input: " .. input)
    end
    local decoded = json.decode(input)
    if decoded ~= nil then
        mkTable(decoded)
    end
    ]]

    function shuffle(tbl)
      for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
      end
      return tbl
    end

    function gc()
        local count = collectgarbage("count")
        --system.print(unit.getName() .. ": memory usage: " .. count)
        collectgarbage("collect")
        collectgarbage("collect")
    end

    function ingredientQuantity(item, ingredient)
        local quantity = ingredient.quantity
        if item.type == "worldMaterial" and item.tier == 1 then
            quantity = ingredient.quantity * 18
        elseif item.type == "worldMaterial" and item.tier == 2 then
            quantity = ingredient.quantity * 6
        elseif item.type == "worldMaterial" and item.tier == 3 then
            quantity = ingredient.quantity * 2
        elseif item.name:lower():match("scrap$") and item.tier == 3 then
            quantity = ingredient.quantity * 3
        elseif item.name:lower():match("scrap$") and item.tier == 2 then
            quantity = ingredient.quantity * 15
        elseif item.name:lower():match("scrap$") and item.tier == 1 then
            quantity = ingredient.quantity * 60
        elseif item.name:lower() == "nitron" then
            quantity = ingredient.quantity * 3
        elseif item.description:lower():match("^complex") and item.tier == 1 then
            quantity = ingredient.quantity * 3
        elseif item.description:lower():match("^intermediary") and item.tier == 1 then
            quantity = ingredient.quantity * 2
        elseif item.name:lower():match("plant") and ingredient.quantity < 2 then
            quantity = 2
        end
        return quantity
    end

    function queueItem(unit, status)
        local id = unit.getLocalId()

        if unitItems == nil then
            return
        end

        if unitItems[id].lastState ~= status then
            unitItems[id].lastState = status
            unitItems[id].transitionTime = system.getArkTime()
        end

        if unitItems[id].lastCheck == nil then
            unitItems[id].lastCheck = 0
        end
        
        local currentTime = system.getArkTime()

        if currentTime - unitItems[id].lastCheck < 5 and not unitItems[id].needsStop and not unitItems[id].needsStart and not unitItems[id].stopped then
            return
        end

        if currentTime - unitItems[id].lastCheck < 2 then
            return
        end

        unitItems[id].lastCheck = currentTime
        system.print("unit: " .. unit.getName() .. " status: " .. status)

        if currentTime - unitItems[id].transitionTime > 60 and status ~= STARTED and unitItems[id].needsStop ~= true then
            system.print("unit: " .. unit.getName() .. " in exceptional state, force stop")
            unit.startMaintain(1)
            unitItems[id].needsStop = true
            return
        end

        if unitItems[id].needsStop then
            unit.stop(true)
            unitItems[id].stopped = true
            unitItems[id].needsStop = false
            return
        end

        if status == STARTED then
            printProduction(unit)
        elseif status == STOPPED or (status == PENDING and unitItems[id].stopped) then
            processQueue(unit)
        else
            unitItems[id].needsStop = true
        end
        
        unitItems[id].stopped = false
    end

    function processQueue(unit)
        local info = unit.getInfo()

        local queue = unitItems[unit.getLocalId()]

        if queue == nil then
            return
        end

        if queue.index == nil then
            queue.index = 0
        end

        if not queue.needsStart then
            queue.index = queue.index + 1
            if queue.index > #queue.items then
                queue.index = 1
            end
        end

        local item = queue.items[queue.index]
        if item == nil then
            return
        end

        if queue.needsStart then
            queue.needsStart = false

            local outputs = queue.unit.getOutputs()

            if outputs and outputs[1] and tostring(outputs[1].id) == item.item then
                queue.unit.startMaintain(item.maintain)
            else
                system.print("output did not match: " .. outputs[1].id .. " ~= " .. item.item .. " item: " .. item.itemName .. " on " .. unit.getName())
            end
        else
            system.print("queueing: " .. item.itemName .. " on " .. unit.getName())
            if queue.unit.setOutput(item.item) ~= 0  then
                system.print("cannot queue: setOutput() returned -1: " .. item.itemName .. " on " .. unit.getName() .. " current status: " .. info.state)
                return
            end

            queue.needsStart = true
        end
    end

    function printProduction(unit)
        local queue = getItem(config, unit)

        if queue ~= nil and queue.index == nil then
            system.print(queue.unit.getName() .. " already running")
        end

        if queue == nil or queue.unit == nil or queue.items == nil or queue.items[queue.index] == nil then
            return
        end

        system.print(queue.unit.getName() .. " began production " .. queue.items[queue.index].itemName)
    end

    function getItem(config, unit)
        for k in pairs(config) do
            if config[k].unit.getLocalId() == unit.getLocalId() then
                return config[k]
            end
        end
    end

    function slotElementName(slot)
        return items[tonumber(slot.getItemId())]
    end

    config = {}
    _cache = { recipes = {}, item = {}, cycleTimes = {} }

    function system_getRecipes(itemId)
        if true then
            return system.getRecipes(itemId)
        end
        if _cache.recipes[itemId] ~= nil then
            return _cache.recipes[itemId]
        end
        _cache.recipes[itemId] = system.getRecipes(itemId)
        return _cache.recipes[itemId]
    end

    function system_getItem(itemId)
        if true then
            return system.getItem(itemId)
        end
        if _cache.item[itemId] ~= nil then
            return _cache.item[itemId]
        end
        _cache.item[itemId] = system.getItem(itemId)
        return _cache.item[itemId]
    end

    function walkDependencies(itemId, dependencies)
        local itemId = tostring(itemId)

        local recipe = system_getRecipes(itemId)
        local item   = system_getItem(itemId)

        if dependencies == nil then
            dependencies = {}
        end

        if dependencies[itemId] ~= nil then
            return dependencies
        end

        if recipe == nil or recipe[1] == nil then
            return {}
        end

        -- recipes for honeycomb show nanocrafter requirements
        local quantity = recipe[1].products[1].quantity
        if item.type == "worldMaterial" and item.tier == 1 then
            quantity = quantity * 18
        elseif item.type == "worldMaterial" and item.tier == 2 then
            quantity = quantity * 6
        elseif item.type == "worldMaterial" and item.tier == 3 then
            quantity = quantity * 2
        elseif item.type == "material" and quantity < 100 then
            quantity = 100
        elseif item.description:lower():match("^complex") and quantity < 50 then
            quantity = 50
        elseif item.description:lower():match("^intermediary") and quantity < 200 then
            quantity = 200
        elseif item.description:lower():match("^fuel") then
            quantity = quantity * 3
        end

        dependencies[itemId] = quantity

        for _, ingredient in pairs(recipe[1].ingredients) do
            local ingredientId = tostring(ingredient.id)
            
            walkDependencies(ingredientId, dependencies)

            local quantity = ingredientQuantity(item, ingredient)

            if dependencies[ingredientId] == nil then
                dependencies[ingredientId] = 0
            end

            if dependencies[ingredientId] < quantity then
                dependencies[ingredientId] = quantity
            end
        end

        return dependencies
    end

    function percentage(current, total)
        return math.floor(current / total * 100) / 100
    end

    function getRemainingTime(cycleTime, slot, info)
        local uptime = slot.getUptime()
        local efficiency = slot.getEfficiency()
        local completedCycles = info.unitsProduced

        return cycleTime - (uptime * efficiency-completedCycles * cycleTime)
    end

    function getCycleTime(info)
        local output = info.currentProducts
        
        if not output or #output == 0 then
            return 0
        end

        if _cache.cycleTimes[output[1].id] then
            if info.remainingTime ~= nil and info.remainingTime > _cache.cycleTimes[output[1].id] then
                _cache.cycleTimes[output[1].id] = info.remainingTime
            end
            return _cache.cycleTimes[output[1].id]
        end

        local recipes = system_getRecipes(output[1].id)
        local item = system_getItem(output[1].id)

        if item.tier == 1 and item.type == "material" then
            _cache.cycleTimes[output[1].id] = 180
            return 180
        end

        for _, recipe in pairs(recipes) do
            local recipeMatched = true

            for i, product in pairs(recipe.products) do
                if output[i].id ~= product.id or output[i].quantity ~= product.quantity then
                    recipeMatched = false
                    break
                end
            end
            
            if recipeMatched then
                _cache.cycleTimes[output[1].id] = recipe.time
                if item.type == "worldMaterial" then
                    _cache.cycleTimes[output[1].id] = recipe.time * 18
                end
                if info.remainingTime ~= nil and info.remainingTime > _cache.cycleTimes[output[1].id] then
                    _cache.cycleTimes[output[1].id] = info.remainingTime
                end
                return _cache.cycleTimes[output[1].id]
            end
        end

        return nil
    end

    function initFn()
        yieldInterval = 5

        screens = {}
        for slot_name, slot in pairs(unit) do
            if type(slot) == "table" and slot.getClass and slot.getClass() == "ScreenUnit" then
                table.insert(screens, slot)
                slot.setRenderScript([[local layer = createLayer()
    local rx, ry = getResolution()
    local font = loadFont("Play", 50)

    setNextTextAlign(layer, AlignV_Middle, AlignH_Center)
    setNextFillColor(layer, 0.5, 0.5, 0.5, 1)

    addText(layer, font, "Loading...", rx*0.5, ry*0.5)]])
            end
        end

        coroutine.yield()
        gc()

        dependencies = {}
        if products and #products > 0 then
            for i, product in pairs(products) do            
                dependencies = walkDependencies(product.id, dependencies)
                if product.quantity > dependencies[tostring(product.id)] then
                    dependencies[product.id] = product.quantity
                end
                coroutine.yield()
                gc()
            end
        end

        transferUnits = {}
        unitItems = {}

        coroutine.yield()
        gc()

        for slot_name, slot in pairs(unit) do
            if type(slot) == "table" and slot.getItemId and slotElementName(slot) then
                local elementName = slotElementName(slot)
                local unitId = slot.getLocalId()
                local tier = system_getItem(slot.getItemId()).tier

                unitItems[unitId] = {
                    unit = slot,
                    items = {},
                    transitionTime = system.getArkTime(),
                    lastState = slot.getState()
                }

                if elementName:lower():match("transfer unit") then
                    table.insert(transferUnits, slot)
                end

                for _, c in pairs(industryConfigs) do
                    if elementName:lower():match(c.unit:lower() .. "$") then
                        if c.stage == nil or slot.getName():lower():match(c.stage:lower()) then
                            for i, item in pairs(c.items) do
                                if i % yieldInterval == 0 then
                                    gc()
                                    coroutine.yield()
                                end
                
                                local itemId = tostring(item.item)

                                if dependencies[itemId] and system_getItem(itemId).tier <= tier+1 then
                                    item.maintain = dependencies[itemId]
                                    system.print("Loaded recipe: " .. item.itemName .. " maintain: " .. item.maintain)
                                    table.insert(unitItems[unitId].items, {
                                            item = itemId,
                                            itemName = item.itemName,
                                            maintain = item.maintain,
                                        })
                                end
                            end

                            system.print("Loaded config for " .. elementName .. " stage: " .. tostring(c.stage))
                        end
                    end
                end
                
                unitItems[unitId].items = shuffle(unitItems[unitId].items)
            end
        end

        local transferUnitItems = {}
        local seenItems = {}

        for _, c in pairs(industryConfigs) do
            for _, item in pairs(c.items) do
                seenItems[tostring(item.item)] = true
            end
        end

        gc()
        coroutine.yield()

        for k in pairs(unitItems) do
            for i, item in pairs(unitItems[k].items) do
                if i % yieldInterval == 0 then
                    gc()
                    coroutine.yield()
                end

                local recipe = system_getRecipes(item.item)
                local itemInfo = system_getItem(item.item)

                for _, ingredient in pairs(recipe[1].ingredients) do
                    local id = tostring(ingredient.id)

                    local quantity = ingredientQuantity(itemInfo, ingredient)

                    if transferUnitItems[id] == nil then
                        transferUnitItems[id] = 1
                    end

                    if quantity > transferUnitItems[id] then
                        transferUnitItems[id] = quantity
                    end

                    if seenItems[id] ~= true then
                        local ingInfo = system_getItem(id)
                        system.print("Unknown ingredient for " .. itemInfo.displayNameWithSize .. ": " .. ingInfo.displayNameWithSize)
                    end
                end
            end
        end

        gc()
        coroutine.yield()

        if #transferUnits ~= 0 then
            for i, tu in pairs(transferUnits) do
                if i % yieldInterval == 0 then
                    gc()
                    coroutine.yield()
                end

                local tuItems = {}
                for id, quantity in pairs(transferUnitItems) do
                    local depName = system_getItem(id).displayNameWithSize
                    table.insert(tuItems, {
                            itemName = depName,
                            item = id,
                            maintain = quantity,
                        })
                    system.print("Loaded transfer unit recipe: " .. depName .. " maintain: " .. quantity)
                end
                tuItems = shuffle(tuItems)
                unitItems[tu.getLocalId()] = {
                    unit = tu,
                    items = tuItems,
                }
                system.print("Loaded config for transfer unit: " .. slotElementName(tu))
            end
        end

        seenItems = nil
        transferUnitItems = nil
        gc()
        
        for unitId, config in pairs(unitItems) do
            gc()
            coroutine.yield()
            queueItem(config.unit, config.unit.getState())
        end
    end
  filter:
    args: []
    signature: onStart()
    slotKey: '-5'
  key: '13'
methods: []
events: []
