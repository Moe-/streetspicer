class "Plate" {
	posX = 0;
	posY = 0;
}

function Plate:__init(left, posX, posY)
  self.posX = posX
  self.posY = posY
  
  self.width = 512
  if left == true then
    self.plateImg = love.graphics.newImage("gfx/Hand_R.png")
  else
    self.plateImg = love.graphics.newImage("gfx/Hand_W.png")
  end
  self.quad = love.graphics.newQuad(0, 0, self.plateImg:getWidth(), self.plateImg:getHeight(), self.plateImg:getWidth(), self.plateImg:getHeight())
end

function Plate:moveBy(dx, dy)
  self.posX = self.posX + dx
  self.posY = self.posY + dy
end

function Plate:draw()
  love.graphics.draw(self.plateImg, self.quad, self.posX, self.posY)
end