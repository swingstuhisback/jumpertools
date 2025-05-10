local draw = draw
local engine = engine
local entities = entities
local font = draw.CreateFont("Verdana", 20, 500) -- change to your liking
local MASK_SOLID = 0x200400B
local lastFrameTime = globals.RealTime()
local frameCount = 0
local fps = 0
local updateInterval = 0.5

callbacks.Unregister("Draw", "units")
callbacks.Register("Draw", "units", function()
    --checks
    local lp = entities.GetLocalPlayer()
    if not lp or not lp:IsAlive() then return end
    

    -- fps
    local currentTime = globals.RealTime()
    frameCount = frameCount + 1
    
    if currentTime - lastFrameTime >= updateInterval then
        fps = math.floor(frameCount / (currentTime - lastFrameTime))
        frameCount = 0
        lastFrameTime = currentTime
    end
    
    -- height calc (hu)
    local pos = lp:GetAbsOrigin()
    if not pos then return end
    local down = Vector3(pos.x, pos.y, pos.z - 2147483647) -- just incase you somehow jump the 32bit int limit
    local trace = engine.TraceLine(pos, down, MASK_SOLID)
    if not trace or not trace.endpos then return end
    local height = pos.z - trace.endpos.z
   
    -- vel calc
    local velocity = lp:EstimateAbsVelocity()
    local speed = 0
    if velocity then
        speed = math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        speed = math.floor(speed + 0.5) -- round
    end
   
    -- format height
    local heightDisplay = string.format("%.1f", height)
   
    -- screen dimensions
    local screenW, screenH = draw.GetScreenSize()
    draw.SetFont(font)
    
    --[[

        -- gradient(s) --
          (disclaimer)

    this is a super ass solution, 
    if you have a better one please fork this
    fuckass script and fix it

    thanks!
    ]]
    local r, g, b, a = 128, 128, 128, 255
   
    if height <= 100 then
        local factor = height / 100
        r, g, b = 255, math.floor(factor * 255), 0
    elseif height <= 200 then
        local factor = (height - 100) / 100
        r, g, b = math.floor(255 * (1 - factor)), 255, 0
    elseif height <= 350 then
        local factor = (height - 200) / 150
        r = math.floor(0 * (1 - factor) + 128 * factor)
        g = math.floor(255 * (1 - factor) + 128 * factor)
        b = math.floor(0 * (1 - factor) + 128 * factor)
        a = math.floor(255 * (1 - factor) + 128 * factor)
    else
        r, g, b, a = 128, 128, 128, 128
    end
   
    -- draw height
    draw.Color(r, g, b, a)
    local heightText = heightDisplay .. " u"
    local heightTextW, heightTextH = draw.GetTextSize(heightText)
    local heightX = math.floor((screenW - heightTextW) / 2)
    local heightY = math.floor((screenH / 2) + 100)  -- below crosshair, change if needed
    draw.Text(heightX, heightY, heightText)
    draw.TextShadow(heightX, heightY, heightText)
    
    -- draw velocity
    local velText = speed .. " u/s"
    local velTextW, velTextH = draw.GetTextSize(velText)
    local velX = math.floor((screenW - velTextW) / 2)
    local velY = heightY + heightTextH + 5  -- pos below height
    
    local velR, velG, velB, velA = 255, 255, 255, 255
    
    if speed < 250 then
        local factor = speed / 250
        velR, velG, velB = 255, math.floor(factor * 255), 0
    elseif speed < 300 then
        local factor = (speed - 250) / 50
        velR, velG, velB = math.floor(255 * (1 - factor)), 255, 0
    else
        velR, velG, velB = 0, 255, 0
    end
    
    draw.Color(velR, velG, velB, velA)
    draw.Text(velX, velY, velText)
    draw.TextShadow(velX, velY, velText)
    
    -- draw frame counter
    local fpsText = fps .. " FPS"
    local fpsTextW, fpsTextH = draw.GetTextSize(fpsText)
    local fpsX = math.floor((screenW - fpsTextW) / 2)
    local fpsY = velY + velTextH + 5  -- pos below vel
    
    local fpsR, fpsG, fpsB, fpsA = 255, 255, 255, 255
    
    if fps < 30 then
        fpsR, fpsG, fpsB = 255, 0, 0
    elseif fps < 60 then
        local factor = (fps - 30) / 30
        fpsR, fpsG, fpsB = 255, math.floor(factor * 255), 0
    elseif fps < 120 then
        local factor = (fps - 60) / 84
        fpsR, fpsG, fpsB = math.floor(255 * (1 - factor)), 255, 0
    else
        fpsR, fpsG, fpsB = 0, 255, 128
    end
    
    draw.Color(fpsR, fpsG, fpsB, fpsA)
    draw.Text(fpsX, fpsY, fpsText)
    draw.TextShadow(fpsX, fpsY, fpsText)
end)

print"[JumpMetrics] We gangsta :steamhappy:"
