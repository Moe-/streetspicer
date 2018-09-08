require("sausage")

class "World" {
	screenWidth = 0;
	screenHeight = 0;
}

gTileSize = 64

gLevelsets = {

}

function World:__init(width, height, level)
	self.screenWidth = width;
	self.screenHeight = height;
	
	--love.audio.play(gBackgroundMusic)
	
	self.gameState = "alive"
  
  self.stageImg = love.graphics.newImage("gfx/stage.png")
  self.stage = love.graphics.newQuad(0, 0, self.stageImg:getWidth(), self.stageImg:getHeight(), self.stageImg:getWidth(), self.stageImg:getHeight())
  
  self.player1 = Sausage:new(640, 2 * self.screenHeight / 3, 1)
  self.player2 = Sausage:new(1280, 2 * self.screenHeight / 3, 2)

end

function World:update(dt)
  self.player1:update(dt, self.player2)
  self.player2:update(dt, self.player1)
  
  p1_box = {self.player1:getBoundingBox()}
  p2_box = {self.player2:getBoundingBox()}
  
  c1 = {self.player1:getBoundingCircle()}
  c2 = {self.player2:getBoundingCircle()}
  print(c1[1], c1[2], c1[3], c2[1], c2[2], c2[3], getDistance(c1[1], c1[2], c2[1], c2[2]), (c1[3] + c2[3])/2)
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
	
end

function World:keyreleased(key)
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

function World:keypressed(key, scancode, isrepeat)

end
