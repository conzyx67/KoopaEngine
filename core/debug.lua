local Debug = {
    enabled = false,
    padding = 10,  -- Padding from screen edges
    lineHeight = 20,  -- Height between lines
    backgroundColor = {0, 0, 0, 0.7},  -- Semi-transparent black
    textColor = {1, 1, 1, 1}  -- White text
}

-- Toggle debug display
function Debug.toggle()
    Debug.enabled = not Debug.enabled
end

-- Format a number to 2 decimal places
local function formatNumber(num)
    return string.format("%.2f", num)
end

-- Draw debug information
function Debug.draw(gameState)
    if not Debug.enabled then return end

    -- Store current graphics state
    local r, g, b, a = love.graphics.getColor()
    
    -- Reset any camera transformations
    love.graphics.push()
    love.graphics.origin()
    
    -- Draw background
    love.graphics.setColor(unpack(Debug.backgroundColor))
    love.graphics.rectangle('fill', 0, 0, 200, 200)
    
    -- Draw debug text
    love.graphics.setColor(unpack(Debug.textColor))
    local y = Debug.padding
    
    -- Player information
    if gameState.player then
        local player = gameState.player
        local debugInfo = {
            string.format("Pos: (%s, %s)", formatNumber(player.x), formatNumber(player.y)),
            string.format("Vel: (%s, %s)", formatNumber(player.velocityX), formatNumber(player.velocityY)),
            string.format("Grounded: %s", tostring(player.grounded)),
            string.format("Jumping: %s", tostring(player.jumping)),
            string.format("State: %s", player.state),
            string.format("FPS: %d", love.timer.getFPS())
        }
        
        for _, text in ipairs(debugInfo) do
            love.graphics.print(text, Debug.padding, y)
            y = y + Debug.lineHeight
        end
    end
    
    -- Restore graphics state
    love.graphics.pop()
    love.graphics.setColor(r, g, b, a)
end

return Debug