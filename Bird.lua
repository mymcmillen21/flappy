--[[
    Bird Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Bird is what we control in the game via clicking or the space bar; whenever we press either,
    the bird will flap and go up a little bit, where it will then be affected by gravity. If the bird hits
    the ground or a pipe, the game is over.
]]

Bird = Class{}

local GRAVITY = 2

function Bird:init()
    self.image = love.graphics.newImage('bird.png')
    self.x = VIRTUAL_WIDTH / 2 - 8
    self.y = VIRTUAL_HEIGHT / 2 - 8

    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.dy = 0
end

--[[
    AABB collision that expects a pipe, which will have an X and Y and reference
    global pipe width and height values.
]]
function Bird:collides(pipe)
    if (self.x + 2 - (self.width / 2)) + (self.width) >= pipe.x and self.x + 0 <= pipe.x + PIPE_WIDTH then
        if (self.y + 4 - (self.height / 2)) + (self.height) >= pipe.y and self.y - 10 <= pipe.y + PIPE_HEIGHT then
            return true
        end
    end
    return false
end

function Bird:update(dt)
    self.dy = self.dy + GRAVITY * dt

    -- burst of anti-gravity when space or left mouse are pressed
    if love.keyboard.wasPressed('space') or love.mouse.wasPressed(1) then
        self.dy = -0.75
        sounds['jump']:play()
    end

    self.y = self.y + self.dy
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y, (math.pi / 2) * (self.dy / GRAVITY), 1, 1, 19, 12)
end