--[[
    PipePair Class

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Used to represent a pair of pipes that stick together as they scroll, providing an opening
    for the player to jump through in order to score a point.
]]

PipePair = Class{}

-- size of the gap between pipes
local GAP_HEIGHT_MIN = 128
local GAP_HEIGHT_MAX = 150

function PipePair:init(y, mover)
    self.gapHeight = math.random (GAP_HEIGHT_MIN, GAP_HEIGHT_MAX)

    -- flag to hold whether this pair has been scored (jumped through)
    self.scored = false

    -- initialize pipes past the end of the screen
    self.x = VIRTUAL_WIDTH + 32

    -- y value is for the topmost pipe; gap is a vertical shift of the second lower pipe
    self.y = y

    self.mover = mover

    self.moveDir = 1

    -- instantiate two pipes that belong to this pair
    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + PIPE_HEIGHT + self.gapHeight)
    }

    -- whether this pipe pair is ready to be removed from the scene
    self.remove = false
end

function PipePair:update(dt)
    -- if this is a "mover", then move the pipe pair between the top and bottom of the screen
    if self.mover then
        self.pipes['upper'].y = self.pipes['upper'].y + (dt * PIPE_MOVER_SPEED * self.moveDir)
        self.pipes['lower'].y = self.pipes['lower'].y + (dt * PIPE_MOVER_SPEED * self.moveDir)

        if self.pipes['lower'].y > VIRTUAL_HEIGHT - 15 then -- when pipes at lower limit
            self.moveDir = -1
            self.pipes['lower'].y = VIRTUAL_HEIGHT - 15
        elseif self.pipes['upper'].y < -PIPE_HEIGHT then -- when pipes at upper limit
            self.moveDir = 1
            self.pipes['upper'].y = -PIPE_HEIGHT
        end
    end

    -- remove the pipe from the scene if it's beyond the left edge of the screen,
    -- else move it from right to left
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        self.pipes['lower'].x = self.x
        self.pipes['upper'].x = self.x
    else
        self.remove = true
    end
end

function PipePair:render()
    for l, pipe in pairs(self.pipes) do
        pipe:render()
    end
end