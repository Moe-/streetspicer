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
  self.player1:update(dt)
  self.player2:update(dt)
end

function World:draw()
	love.graphics.setColor(255, 255, 255)
  
  love.graphics.draw(self.stageImg, self.stage, 0, 2 * self.screenHeight / 3)
  
  self.player1:draw()
  self.player2:draw()
	
end

function World:keyreleased(key)

end

function World:keypressed(key, scancode, isrepeat)

end
