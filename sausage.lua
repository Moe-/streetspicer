class "Sausage" {
	posX = 0;
	posY = 0;
  state = "walk";
}

-- entry: length, x-delta mov, y-delta mov
StepPhases = {{2, -2, 0}, {0, -2, 0}, {2, -2, 0}}
BackPhases = {{3, -2, -8}, {3, 0, 0}, {3, 2, 8}}
ForwardPhases = {{3, 2, -8}, {3, 0, 0}, {3, -2, 8}}
HeavyPhases = {{4, 4, 0}, {4, 4, 0}, {6, 4, 0}}
idleFrames = 8
function Sausage:__init(posX, posY, player)	
	self.state = "walk"
  self.substate = "none"
  self.substateIdx = -1
  self.subframes = 0
  self.pushback = 0
  
  if player == 1 then
    self.sausageImg = love.graphics.newImage("gfx/sausage_white.png")
    self.lookRight = true
  else
    self.sausageImg = love.graphics.newImage("gfx/sausage_red.png")
    self.lookRight = false
  end
  
  self.posX = posX + self.sausageImg:getWidth() / 2
	self.posY = posY - self.sausageImg:getHeight() + self.sausageImg:getHeight() / 2
  
  self.sausageQuad = love.graphics.newQuad(0, 0, self.sausageImg:getWidth(), self.sausageImg:getHeight(), self.sausageImg:getWidth(), self.sausageImg:getHeight())

end

function Sausage:update(dt, enemy)
  factor = -1.0
  if self.lookRight then
    factor = 1.0
  end
  
  if self.state ~= "walk" then
    while self.subframes <= 0 do
      if self.substate == "none" then
        self.substate = "startup"
        self.subframes = self.phases[1][1]
        self.substateIdx = 1
      elseif self.substate == "startup" then
        self.substate = "active"
        self.subframes = self.phases[2][1]
        self.substateIdx = 2
      elseif self.substate == "active" then
        self.substate = "recovery"
        self.subframes = self.phases[3][1]
        self.substateIdx = 3
      else -- "recovery"
        if self.state == "forward" or self.state == "back" then
          self.lookRight = not self.lookRight
        end
        self.substate = "none"
        self.state = "walk"
        self.subframes = 0
        self.substateIdx = 0
        break
      end
    end
    if self.substateIdx > 0 then
      self.posX = self.posX + factor * self.phases[self.substateIdx][2]
      self.posY = self.posY + factor * self.phases[self.substateIdx][3]
    end
  else
    if self.subframes < 0 then
      self.subframes = idleFrames
    end
  end
  
  if self.pushback > 0 then
    diff = math.max(5, math.floor(self.pushback * 0.25))
    self.pushback = self.pushback - diff
    self.posX = self.posX - factor * diff
  end
  
  self.subframes = self.subframes - 1
end

function Sausage:pressLeft(enemy)
  if self.state == "walk" then
    enemyRight = true
    if self.posX > enemy.posX then
      enemyRight = false
    end
    if self.lookRight == false and enemyRight == false then
      self.state = "heavy"
      self.phases = HeavyPhases
    elseif self.lookRight == true and enemyRight == true then
      self.state = "step"
      self.phases = StepPhases
    elseif self.lookRight == true and enemyRight == false then
      self.state = "forward"
      self.phases = ForwardPhases
    elseif self.lookRight == false and enemyRight == true then
      self.state = "back"
      self.phases = BackPhases
    end
    self.subframes = 0
    self.actionTime = love.timer.getTime()
  end
  --self.posX = self.posX - 32
end

function Sausage:pressRight(enemy)
  if self.state == "walk" then
    enemyRight = true
    if self.posX > enemy.posX then
      enemyRight = false
    end
    if self.lookRight == true and enemyRight == true then
      self.state = "heavy"
      self.phases = HeavyPhases
    elseif self.lookRight == false and enemyRight == false then
      self.state = "step"
      self.phases = StepPhases
    elseif self.lookRight == false and enemyRight == true then
      self.state = "forward"
      self.phases = ForwardPhases
    elseif self.lookRight == true and enemyRight == false then
      self.state = "back"
      self.phases = BackPhases
    end
    self.subframes = 0
    self.actionTime = love.timer.getTime()
  end
  --self.posX = self.posX + 32
end

function Sausage:draw()
  drawOffsetX = -self.sausageImg:getWidth() / 2
  drawOffsetY = -self.sausageImg:getHeight() / 2
  
  if self.lookRight then
    love.graphics.draw(self.sausageImg, self.sausageQuad, self.posX + drawOffsetX, self.posY + drawOffsetY)
  else
    love.graphics.draw(self.sausageImg, self.sausageQuad, self.posX + drawOffsetX, self.posY + drawOffsetY, 0, -1, 1)
  end
end

function Sausage:getBox()
  if self.state == "heavy" then
    return self.sausageImg:getWidth(), self.sausageImg:getHeight()
  else
    return self.sausageImg:getWidth()/2, self.sausageImg:getHeight()
  end
end

function Sausage:getBoundingBox()
  w, h = self:getBox()
  return self.posX, self.posY, self.posX + w, self.posY + h
end

function Sausage:getBoundingCircle()
  w, h = self:getBox()
  r = math.sqrt(w*w + h * h)
  return self.posX, self.posY, r
end

function Sausage:getAction()
  return self.state, self.substate, self.actionTime
end

function Sausage:hit(state)
  if state == "heavy" then
    self.pushback = 20
  elseif state == "step" then
    self.pushback = 5
  elseif state == "forward" then
    self.pushback = 15
  elseif state == "back" then
    self.pushback = 10
  end
  print("Hit ", state)
end