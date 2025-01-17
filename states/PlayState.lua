--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 120
PIPE_WIDTH = 70
PIPE_HEIGHT = 288
PIPE_HEIGHT_MIN = 270
PIPE_HEIGHT_MAX = 290
PIPE_SPAWN_MIN = 1.18
PIPE_SPAWN_MAX = 1.32
PIPE_MOVER_PER = 5
PIPE_MOVER_SPEED = 24

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0
    self.nextPipe = math.random (PIPE_SPAWN_MIN / 3, PIPE_SPAWN_MAX / 3)
    self.paused = false
    self.nextMover = PIPE_MOVER_PER
    -- LIKE I KNOW NIL IS A WORD BUT THIS IS LITERALLY THE ONLY LANGUAGE THAT USES IT

    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -math.random(PIPE_HEIGHT_MIN, PIPE_HEIGHT_MAX) + math.random(80) + 20
end

function PlayState:update(dt)
    if love.keyboard.wasPressed ('escape') then
        self.paused = not self.paused
        scrolling = not self.paused
    end

    if self.paused then
        return
    end

    -- update timer for pipe spawning
    self.timer = self.timer + dt

    -- spawn a new pipe pair every second and a half
    if self.timer > self.nextPipe then
        self.nextMover = self.nextMover - 1

        -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length (90 pixels) from the bottom
        local pipeHeight = math.random (PIPE_HEIGHT_MIN, PIPE_HEIGHT_MAX)

        local y = math.max(-pipeHeight + 10, 
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - pipeHeight))
        self.lastY = y

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, PipePair(y, (self.nextMover <= 0)))

        if self.nextMover <= 0 then
            self.nextMover = PIPE_MOVER_PER
        end

        -- reset timer
        self.timer = 0

        -- set next pipe spawn timer
        self.nextPipe = math.random (PIPE_SPAWN_MIN, PIPE_SPAWN_MAX)
    end

    -- for every pair of pipes..
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end

        -- update position of pair
        pair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because
    -- modifying the table in-place without explicit keys will result in skipping the
    -- next pipe, since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()

                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end
    end

    -- update bird based on gravity and input
    self.bird:update(dt)

    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        sounds['explosion']:play()
        sounds['hurt']:play()

        gStateMachine:change('score', {
            score = self.score
        })
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)

    if self.paused then
        love.graphics.print ('Press ESC to unpause', 8, 8 + 28)
    end

    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end