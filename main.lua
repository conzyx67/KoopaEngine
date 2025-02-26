-- KoopaEngine: A LÖVE2D-based Mario game engine

-- Load required modules
local Player = require('core.player')
local Collision = require('core.collision')
local Debug = require('core.debug')

-- Game state variables
local gameState = {
    player = nil,
    platforms = {},
    world = nil,
    camera = {
        x = 0,
        y = 0,
        scale = 2  -- Scale factor for 32x32 visual size while maintaining 16x16 logical size
    }
}

-- LÖVE2D callback: Called once at startup
function love.load()
    -- Initialize game components
    gameState.player = Player.new(100, 100)  -- Starting position
    
    -- Create some test platforms aligned to 16x16 grid
    table.insert(gameState.platforms, {
        x = 96,  -- 6 * 16
        y = 400, -- 25 * 16
        width = 192, -- 12 * 16
        height = 16
    })
    
    table.insert(gameState.platforms, {
        x = 384, -- 24 * 16
        y = 304, -- 19 * 16
        width = 192, -- 12 * 16
        height = 16
    })
    
    -- Set up window
    love.window.setMode(800, 600, {
        resizable = true,
        vsync = true,
        minwidth = 400,
        minheight = 300
    })
 end

-- LÖVE2D callback: Called every frame
function love.update(dt)
    -- Update player
    if gameState.player then
        gameState.player:update(dt)
        
        -- Check collision with each platform
        for _, platform in ipairs(gameState.platforms) do
            Collision.resolvePlayerPlatform(gameState.player, platform)
        end
    end
    
    -- Update camera to follow player
    if gameState.player then
        -- Simple camera following
        -- Adjust camera position accounting for scale
        gameState.camera.x = (gameState.player.x * gameState.camera.scale) - love.graphics.getWidth() / 2
        gameState.camera.y = (gameState.player.y * gameState.camera.scale) - love.graphics.getHeight() / 2
    end
end

-- LÖVE2D callback: Called every frame after update
function love.draw()
    -- Apply camera transform with scaling
    love.graphics.push()
    love.graphics.scale(gameState.camera.scale)
    love.graphics.translate(-gameState.camera.x / gameState.camera.scale, -gameState.camera.y / gameState.camera.scale)
    
    -- Draw game world
    if gameState.player then
        gameState.player:draw()
        
        -- Draw platforms
        love.graphics.setColor(0.5, 0.5, 0.5)
        for _, platform in ipairs(gameState.platforms) do
            love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
        end
        love.graphics.setColor(1, 1, 1)
    end
    
    love.graphics.pop()
    
    -- Draw debug overlay
    Debug.draw(gameState)
end

-- LÖVE2D callback: Handle keyboard input
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'q' then
        Debug.toggle()
    end
    
    -- Pass input to player
    if gameState.player then
        gameState.player:keypressed(key)
    end
end

function love.keyreleased(key)
    if gameState.player then
        gameState.player:keyreleased(key)
    end
end