local Collision = {}

-- Check if two rectangles are colliding
function Collision.checkRectangleCollision(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect1.x + rect1.width > rect2.x and
           rect1.y < rect2.y + rect2.height and
           rect1.y + rect1.height > rect2.y
end

-- Resolve collision between player and platform
function Collision.resolvePlayerPlatform(player, platform)
    if not Collision.checkRectangleCollision(player, platform) then
        return false
    end

    -- Get the player's position before and after movement
    local playerBottom = player.y + player.height
    local platformTop = platform.y
    local platformBottom = platform.y + platform.height
    local playerTop = player.y

    -- Vertical collision resolution
    if player.velocityY >= 0 then  -- Moving down or stationary
        if math.abs(playerBottom - platformTop) < math.abs(player.velocityY) + 10 then
            player.y = platform.y - player.height - 0.2  -- Small offset for stable ground detection
            player.velocityY = 0
            player.grounded = true
            if player.jumping and player.jumpTime >= player.maxJumpTime then
                player.jumping = false
            end
            return true
        end
    elseif player.velocityY < 0 then  -- Moving up
        if math.abs(playerTop - platformBottom) < math.abs(player.velocityY) then
            player.y = platform.y + platform.height
            player.velocityY = 0
            return true
        end
    end

    -- Horizontal collision resolution
    if player.velocityX > 0 then
        player.x = platform.x - player.width
        player.velocityX = 0
    elseif player.velocityX < 0 then
        player.x = platform.x + platform.width
        player.velocityX = 0
    end
    
    return true
end

return Collision