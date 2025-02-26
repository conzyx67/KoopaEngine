-- Default player properties
local Player = {
    x = 0,
    y = 0,
    width = 16,
    height = 16,
    velocityX = 0,
    velocityY = 0,
    speed = 150,
    acceleration = 1000,
    deceleration = 1500,
    maxSpeed = 300,
    sprintMaxSpeed = 450,  -- Maximum speed while sprinting
    sprintAcceleration = 1500,  -- Faster acceleration while sprinting
    isSprinting = false,  -- Track sprint state
    jumpForce = -500,
    jumpTime = 0,
    maxJumpTime = 0.2,
    minJumpVelocity = -150,
    gravity = 2300,
    maxFallSpeed = 800,
    grounded = false,
    jumping = false,
    facingRight = true,
    state = 'small',
    sprites = {}

}

-- Create a new player instance
function Player.new(x, y)
    local instance = setmetatable({}, { __index = Player })
    instance.x = x or 0
    instance.y = y or 0
    
    -- Load sprites with nearest neighbor filtering for pixel-perfect rendering
    instance.sprites.idle = love.graphics.newImage('assets/sprites/mario/idle/idle1.png')
    instance.sprites.idle:setFilter('nearest', 'nearest')  -- Disable texture filtering
    
    return instance
end

-- Update player physics and state
function Player:update(dt)
    -- Reset grounded state at the start of each frame
    self.grounded = false
    
    -- Update sprint state with smooth transition
    local targetMaxSpeed = love.keyboard.isDown('x') and self.sprintMaxSpeed or self.maxSpeed
    local targetAcceleration = love.keyboard.isDown('x') and self.sprintAcceleration or self.acceleration
    
    -- Smoothly interpolate between normal and sprint speeds
    local transitionSpeed = 1000 -- Speed of transition
    self.currentMaxSpeed = self.currentMaxSpeed or self.maxSpeed
    self.currentAcceleration = self.currentAcceleration or self.acceleration
    
    self.currentMaxSpeed = self.currentMaxSpeed + (targetMaxSpeed - self.currentMaxSpeed) * math.min(1, dt * transitionSpeed)
    self.currentAcceleration = self.currentAcceleration + (targetAcceleration - self.currentAcceleration) * math.min(1, dt * transitionSpeed)
    
    -- Handle horizontal movement with acceleration
    if love.keyboard.isDown('left') then
        self.velocityX = self.velocityX - self.currentAcceleration * dt
        if self.velocityX < -self.currentMaxSpeed then
            self.velocityX = -self.currentMaxSpeed
        end
        self.facingRight = false
    elseif love.keyboard.isDown('right') then
        self.velocityX = self.velocityX + self.currentAcceleration * dt
        if self.velocityX > self.currentMaxSpeed then
            self.velocityX = self.currentMaxSpeed
        end
        self.facingRight = true
    else
        -- Apply deceleration when no movement keys are pressed
        local currentDeceleration = self.deceleration
        if not self.grounded then
            currentDeceleration = self.deceleration * 0.6
        else
            currentDeceleration = self.deceleration * 1.5
        end
        
        if self.velocityX > 0 then
            self.velocityX = math.max(0, self.velocityX - currentDeceleration * dt)
        elseif self.velocityX < 0 then
            self.velocityX = math.min(0, self.velocityX + currentDeceleration * dt)
        end
    end

    -- Handle variable jump height
    if self.jumping then
        if love.keyboard.isDown('z') then
            self.jumpTime = self.jumpTime + dt
            if self.jumpTime < self.maxJumpTime then
                self.velocityY = self.jumpForce
            end
        else
            -- If jump key is released early, reduce upward velocity
            if self.velocityY < self.minJumpVelocity then
                self.velocityY = self.minJumpVelocity
            end
            self.jumping = false
        end
    end

    -- Apply gravity with terminal velocity
    if not self.grounded then
        self.velocityY = self.velocityY + self.gravity * dt
        if self.velocityY > self.maxFallSpeed then
            self.velocityY = self.maxFallSpeed
        end
    end

    -- Update position
    self.x = self.x + self.velocityX * dt
    self.y = self.y + self.velocityY * dt
end

-- Handle key press events
function Player:keypressed(key)
    if key == 'z' then
        if self.grounded then
            self.velocityY = self.jumpForce
            self.grounded = false
            self.jumping = true
            self.jumpTime = 0
        end
    end
end

-- Handle key release events
function Player:keyreleased(key)
    -- Add key release handling as needed
end

-- Draw the player
function Player:draw()
    if self.state == 'small' and math.abs(self.velocityX) < 1 then
        -- Draw idle sprite centered horizontally and aligned vertically with ground
        local spriteWidth = self.sprites.idle:getWidth()
        local spriteHeight = self.sprites.idle:getHeight()
        local horizontalOffset = (spriteWidth - self.width) / 2
        local verticalOffset = spriteHeight - self.height
        love.graphics.draw(
            self.sprites.idle,
            self.x + (self.width / 2),
            self.y - verticalOffset,
            0,
            1,
            1,
            spriteWidth / 2,
            0
        )
    else
        -- Fallback to rectangle for other states/animations
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end
end

return Player