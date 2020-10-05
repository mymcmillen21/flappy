--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')

    -- draw medal
    local color = self.score >= 100 and {0.51, 0.96, 0.17} or -- emerald at 100
        self.score >= 50 and {0.9, 0.1, 0, 1} or -- ruby at 50
        self.score >= 25 and {0.8, 0.68, 0, 1} or -- gold at 25
        self.score >= 15 and {0.5, 0.5, 0.5, 1} or -- silver at 15
        self.score >= 5 and {0.65, 0.39, 0.12, 1} or -- bronze at 5
        {1, 1, 1, 0.25} -- no medal below 5

    love.graphics.setColor (color)
    love.graphics.circle (self.score > 0 and "fill" or "line", VIRTUAL_WIDTH / 2, (VIRTUAL_HEIGHT / 2) - 8, 18, 32)
    love.graphics.setColor (1, 1, 1, 1)
    if self.score < 5 then
        love.graphics.printf ('you are a failure', 0, (VIRTUAL_HEIGHT / 2), VIRTUAL_WIDTH, 'center')
    elseif self.score < 15 then
        love.graphics.printf ('bronze', 0, (VIRTUAL_HEIGHT / 2), VIRTUAL_WIDTH, 'center')
    elseif self.score < 25 then
        love.graphics.printf ('silver', 0, (VIRTUAL_HEIGHT / 2), VIRTUAL_WIDTH, 'center')
    elseif self.score < 50 then
        love.graphics.printf ('gold', 0, (VIRTUAL_HEIGHT / 2), VIRTUAL_WIDTH, 'center')
    elseif self.score < 100 then
        love.graphics.printf ('ruby', 0, (VIRTUAL_HEIGHT / 2), VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf ('emerald', 0, (VIRTUAL_HEIGHT / 2), VIRTUAL_WIDTH, 'center')
    end
end