require("sausage")

class "World" {
	screenWidth = 0;
	screenHeight = 0;
}

gBorder = 256

gBackgroundFrying = love.audio.newSource("sfx/background.ogg", "static")
gBackgroundMusic = love.audio.newSource("sfx/music.ogg", "static")

function World:__init(width, height)
	self.screenWidth = width
	self.screenHeight = height
  
  self.targetLeft1 = {gBorder / 2, 5 * self.screenHeight / 6}
  self.targetLeft2 = {0, 2 * self.screenHeight / 3}
  self.targetRight1 = {self.screenWidth - gBorder / 2, 5 * self.screenHeight / 6}
  self.targetRight2 = {self.screenWidth, 2 * self.screenHeight / 3}
	
  gBackgroundFrying:setLooping(true)
	love.audio.play(gBackgroundFrying)
  gBackgroundMusic:setLooping(true)
	love.audio.play(gBackgroundMusic)
	
  self.lifesPlayer1 = 3
  self.lifesPlayer2 = 3
  
  self.stageImg = love.graphics.newImage("gfx/stage.png")
  self.stage = love.graphics.newQuad(0, 0, self.stageImg:getWidth(), self.stageImg:getHeight(), self.stageImg:getWidth(), self.stageImg:getHeight())
  
  self:reset()
end  

function World:reset()
  self.gameState = "alive"
  self.player1 = Sausage:new(640, 2 * self.screenHeight / 3, 1)
  self.player2 = Sausage:new(1280, 2 * self.screenHeight / 3, 2)
end

function World:updateGame(dt)
  self.player1:update(dt, self.player2)
  self.player2:update(dt, self.player1)
  
  p1_box = {self.player1:getBoundingBox()}
  p2_box = {self.player2:getBoundingBox()}
  
  c1 = {self.player1:getBoundingCircle()}
  c2 = {self.player2:getBoundingCircle()}
  if getDistance(c1[1], c1[2], c2[1], c2[2]) < (c1[3] + c2[3])/2 then
    state1, substate1, time1 = self.player1:getAction()
    state2, substate2, time2 = self.player2:getAction()
    if substate1 == "active" and substate2 == "active" then
      if time1 < time2 then
        self.player2:hit(state1)
      elseif time1 > time2 then
        self.player1:hit(state2)
      else
        self.player2:hit(state1)
        self.player1:hit(state2)
      end
    elseif substate1 == "active" then
      self.player2:hit(state1)
    elseif substate2 == "active" then
      self.player1:hit(state2)
    end
  end
  
  b1 = {self.player1:getBox()}
  b2 = {self.player2:getBox()}
  x1 = c1[1] - b1[1] / 2
  x2 = c2[1] - b2[1] / 2
  if x1 < gBorder or x1 > self.screenWidth - gBorder then
    self.gameState = "p1_lost_life_plate"
    if x1 < gBorder then
      self.target1 = self.targetLeft1
      self.target2 = self.targetLeft2
    else
      self.target1 = self.targetRight1
      self.target2 = self.targetRight2
    end
    print("Player 1 lost")
  elseif x2 < gBorder or x2 > self.screenWidth - gBorder then
    self.gameState = "p2_lost_life_plate"
    if x2 < gBorder then
      self.target1 = self.targetLeft1
      self.target2 = self.targetLeft2
    else
      self.target1 = self.targetRight1
      self.target2 = self.targetRight2
    end
    print("Player 2 lost")
  end
end

function World:update(dt)
  if self.gameState == "alive" then
    self:updateGame(dt)
  elseif self.gameState == "p1_lost_life_plate" then
    if self.player1:moveToPos(self.target1) then
      self.gameState = "p1_lost_life_out"
    end
  elseif self.gameState == "p2_lost_life_plate" then
    if self.player2:moveToPos(self.target1) then
      self.gameState = "p2_lost_life_out"
    end
  elseif self.gameState == "p1_lost_life_out" then
    if self.player1:moveToPos(self.target2) then
      self.lifesPlayer1 = self.lifesPlayer1 - 1
      if self.lifesPlayer1 < 1 then
        self.gameState = "p2_wins"
      else
        self.gameState = "alive"
        self:reset()
      end
    end
  elseif self.gameState == "p2_lost_life_out" then
    if self.player2:moveToPos(self.target2) then
      self.lifesPlayer2 = self.lifesPlayer2 - 1
      if self.lifesPlayer2 < 1 then
        self.gameState = "p1_wins"
      else
        self.gameState = "alive"
        self:reset()
      end
    end
  end
end

function World:checkInside(px, py, box)
  if px > box[1] and px < box[3] and py > box[2] and py < box[4] then
    return true
  end
  return false
end

function World:draw()
	love.graphics.setColor(255, 255, 255)
  
  love.graphics.draw(self.stageImg, self.stage, 0, 2 * self.screenHeight / 3)
  
  self.player1:draw()
  self.player2:draw()
  
  if self.gameState == "p1_wins" then
    love.graphics.setColor(gMenuColor, 255 - gMenuColor, 0, 255)
    love.graphics.print("Player 1 wins", 2*self.screenWidth/5, self.screenHeight/4, 0, 4, 4)
  elseif self.gameState == "p2_wins" then
    love.graphics.setColor(gMenuColor, 255 - gMenuColor, 0, 255)
    love.graphics.print("Player 2 wins", 2*self.screenWidth/5, self.screenHeight/4, 0, 4, 4)
  else
    for i = 1, self.lifesPlayer1 do
      love.graphics.draw(self.player1.sausageImg, self.player1.sausageQuad, self.screenWidth/8 + i * 150, 50)
    end
    for i = self.lifesPlayer2, 1, -1 do
      love.graphics.draw(self.player2.sausageImg, self.player2.sausageQuad, 7 * self.screenWidth/8 - i * 150, 50, 0, -1, 1)
    end
  end
end

function World:keyreleased(key)
  
  if self.gameState == "alive" then
    if key == "a" then
      self.player1:pressLeft(self.player2)
    elseif key == "s" then
      self.player1:pressRight(self.player2)
    elseif key == "k" then
      self.player2:pressLeft(self.player1)
    elseif key == "l" then
      self.player2:pressRight(self.player1)
    end
  end
end

function World:keypressed(key, scancode, isrepeat)

end
