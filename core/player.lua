-- Default player properties
local Player = {
    x = 0,
    y = 0,
    width = 32,
    height = 32,
    velocityX = 0,
    velocityY = 0,
    speed = 200,
    acceleration = 1500,
    deceleration = 2000,
    maxSpeed = 400,
    jumpForce = -600,
    jumpTime = 0,
    maxJumpTime = 0.25,
    minJumpVelocity = -200,
    gravity = 1500,
    maxFallSpeed = 800,
    grounded = false,
    jumping = false,
    facingRight = true,
    state = 'small'  -- Player states: 'small', 'super', 'fire'
}

-- Create a new player instance
function Player.new(x, y)
    local instance = setmetatable({}, { __index = Player })
    instance.x = x or 0
    instance.y = y or 0
    return instance
end

-- Update player physics and state
function Player:update(dt)
    -- Reset grounded state at the start of each frame
    self.grounded = false
    
    -- Handle horizontal movement with acceleration
    if love.keyboard.isDown('left') then
        self.velocityX = self.velocityX - self.acceleration * dt
        if self.velocityX < -self.maxSpeed then
            self.velocityX = -self.maxSpeed
        end
        self.facingRight = false
    elseif love.keyboard.isDown('right') then
        self.velocityX = self.velocityX + self.acceleration * dt
        if self.velocityX > self.maxSpeed then
            self.velocityX = self.maxSpeed
        end
        self.facingRight = true
    else
        -- Apply deceleration when no movement keys are pressed
        if self.velocityX > 0 then
            self.velocityX = math.max(0, self.velocityX - self.deceleration * dt)
        elseif self.velocityX < 0 then
            self.velocityX = math.min(0, self.velocityX + self.deceleration * dt)
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
    -- Temporary rectangle representation
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end

return Player