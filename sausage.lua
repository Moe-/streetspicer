class "Sausage" {
	posX = 0;
	posY = 0;
  state = "walk";
}

function Sausage:__init(posX, posY, player)	
	self.state = "walk"
  
  if player == 1 then
    self.sausageImg = love.graphics.newImage("gfx/sausage_white.png")
    self.lookRight = true
  else
    self.sausageImg = love.graphics.newImage("gfx/sausage_red.png")
    self.lookRight = false
  end
  
  self.posX = posX;
	self.posY = posY - self.sausageImg:getHeight();
  
  self.sausageQuad = love.graphics.newQuad(0, 0, self.sausageImg:getWidth(), self.sausageImg:getHeight(), self.sausageImg:getWidth(), self.sausageImg:getHeight())

end

function Sausage:update(dt)

end


function Sausage:draw()
  if self.lookRight then
    love.graphics.draw(self.sausageImg, self.sausageQuad, self.posX, self.posY)
  else
    love.graphics.draw(self.sausageImg, self.sausageQuad, self.posX, self.posY, 0, -1, 1)
  end
end