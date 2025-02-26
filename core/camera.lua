local Camera = {
    x = 0,
    y = 0,
    scale = 2,  -- Default scale factor
    deadzone = {  -- Area where camera won't move if player is inside
        x = 100,  -- pixels from center
        y = 80   -- pixels from center
    },
    bounds = {  -- World boundaries
        left = 0,
        right = 800,  -- Will be set based on level width
        top = 0,
        bottom = 600  -- Will be set based on level height
    },
    smoothness = 0.1  -- Lower = smoother camera movement (0-1)
}

-- Create a new camera instance
function Camera.new(scale)
    local instance = setmetatable({}, { __index = Camera })
    instance.scale = scale or 2
    return instance
 end

-- Set world boundaries
function Camera:setBounds(left, right, top, bottom)
    self.bounds.left = left or 0
    self.bounds.right = right or love.graphics.getWidth()
    self.bounds.top = top or 0
    self.bounds.bottom = bottom or love.graphics.getHeight()
end

-- Get camera's view dimensions
function Camera:getViewDimensions()
    return love.graphics.getWidth() / self.scale,
           love.graphics.getHeight() / self.scale
end

-- Update camera position to follow target
function Camera:update(target)
    local viewWidth, viewHeight = self:getViewDimensions()
    local targetX = target.x
    local targetY = target.y

    -- Calculate deadzone boundaries (2 tiles wide, 3 tiles tall)
    local deadzoneWidth = 32  -- 2 tiles
    local deadzoneHeight = 48 -- 3 tiles
    local deadzoneLeft = self.x + (viewWidth - deadzoneWidth) / 2
    local deadzoneRight = deadzoneLeft + deadzoneWidth
    local deadzoneTop = self.y + (viewHeight - deadzoneHeight) / 2
    local deadzoneBottom = deadzoneTop + deadzoneHeight

    -- Only move camera if target is outside deadzone
    if targetX < deadzoneLeft then
        self.x = self.x + (targetX - deadzoneLeft)
    elseif targetX > deadzoneRight then
        self.x = self.x + (targetX - deadzoneRight)
    end

    if targetY < deadzoneTop then
        self.y = self.y + (targetY - deadzoneTop)
    elseif targetY > deadzoneBottom then
        self.y = self.y + (targetY - deadzoneBottom)
    end

    -- Apply bounds constraints
    self.x = math.max(self.bounds.left, math.min(self.x, self.bounds.right - viewWidth))
    self.y = math.max(self.bounds.top, math.min(self.y, self.bounds.bottom - viewHeight))

    -- Store deadzone boundaries for debug rendering
    self.deadzone = {
        left = deadzoneLeft,
        right = deadzoneRight,
        top = deadzoneTop,
        bottom = deadzoneBottom
    }
end

-- Apply camera transform
function Camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.x, -self.y)
end

-- Reset camera transform
function Camera:reset()
    love.graphics.pop()
end

return Camera