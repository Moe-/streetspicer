class "Sausage" {
	posX = 0;
	posY = 0;
  state = "walk";
}

gSoundHit1 = love.audio.newSource("sfx/hit1.ogg", "static")
gSoundHit2 = love.audio.newSource("sfx/hit2.wav", "static")
gSoundHit3 = love.audio.newSource("sfx/hit3.wav", "static")
gSoundKick = love.audio.newSource("sfx/strong_kick.wav", "static")

sausageSize = 256

-- entry: length, x-delta mov, y-delta mov
StepPhases = {{3, -2, 0}, {5, -2, 0}, {4, -2, 0}}
BackPhases = {{3, -2, 22}, {10, 0, 0}, {11, 2, -6}}
ForwardPhases = {{3, 2, -22}, {10, 0, 0}, {11, -2, 6}}
HeavyPhases = {{7, 4, 0}, {6, 4, 0}, {35, 4, 0}}
idleFrames = 24
function Sausage:__init(posX, posY, player)	
	self.state = "walk"
  self.substate = "none"
  self.substateIdx = -1
  self.subframes = 0
  self.pushback = 0
  
  gSoundHit1:setLooping(false)
  gSoundHit2:setLooping(false)
  gSoundHit3:setLooping(false)
  gSoundKick:setLooping(false)
  
  if player == 1 then
    self.sausageImg = love.graphics.newImage("gfx/sausage_white.png")
    self.sausageQuad = love.graphics.newQuad(0, 0, sausageSize, sausageSize, self.sausageImg:getWidth(), self.sausageImg:getHeight())
    self.red = false
    self.lookRight = true
  else
    self.sausageImg = love.graphics.newImage("gfx/sausage_red.png")
    self.sausageQuad = love.graphics.newQuad(0, sausageSize, sausageSize, sausageSize, self.sausageImg:getWidth(), self.sausageImg:getHeight())
    self.red = true
    self.lookRight = false
  end
  
  self.posX = posX - sausageSize / 2
	self.posY = posY - sausageSize / 2
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
      self.subframes = idleFrames - 1
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
    if self.posX + sausageSize/2 > enemy.posX then
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
  drawOffsetX = -sausageSize / 2
  drawOffsetY = -sausageSize / 2
  
  local quadTile = love.graphics.newQuad(self:getAnimFrame() * sausageSize, self:getAnimRow() * sausageSize, sausageSize, sausageSize, self.sausageImg:getWidth(), self.sausageImg:getHeight())
  love.graphics.draw(self.sausageImg, quadTile, self.posX + drawOffsetX, self.posY + drawOffsetY)
end

function Sausage:getAnimFrame()
  if self.phases == nil then return 0 end
  local idx = 0
  if self.state ~= "walk" then
    for i = 1, self.substateIdx - 1 do
      idx = idx + self.phases[i][1]
    end
    idx = idx + (self.phases[self.substateIdx][1] - self.subframes) - 1
  else
    idx = idleFrames - self.subframes - 2
  end
  return idx
end

function Sausage:getAnimRow()
  if self.red == true then
    if self.state == "walk" then
      if self.lookRight == true then
        return 6
      else
        return 7
      end
    elseif self.state == "heavy" then
      if self.lookRight == true then
        return 0
      else
        return 1
      end
    elseif self.state == "step" then
      if self.lookRight == true then
        return 2
      else
        return 3
      end
    elseif self.state == "forward" then
      return 4
    elseif self.state == "back" then
      return 5
    end
  else
    if self.state == "walk" then
      if self.lookRight == true then
        return 7
      else
        return 6
      end
    elseif self.state == "heavy" then
      if self.lookRight == true then
        return 1
      else
        return 0
      end
    elseif self.state == "step" then
      if self.lookRight == true then
        return 3
      else
        return 2
      end
    elseif self.state == "forward" then
      return 5
    elseif self.state == "back" then
      return 4
    end
  end
end

function Sausage:getBox()
  --if self.state == "heavy" then
    return sausageSize, sausageSize
  --else
  --  return sausageSize/2, sausageSize
  --end
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
    love.audio.play(gSoundKick)
  elseif state == "step" then
    self.pushback = 5
    love.audio.play(gSoundHit1)
  elseif state == "forward" then
    self.pushback = 15
    love.audio.play(gSoundHit3)
  elseif state == "back" then
    self.pushback = 10
    love.audio.play(gSoundHit2)
  end
end

function Sausage:moveToPos(pos)
  factor = 8
  dx = pos[1] - self.posX
  dy = pos[2] - self.posY
  length = getLength(dx, dy)
  dx = dx / length
  dy = dy / length
  self.posX = self.posX + factor * dx
  self.posY = self.posY + factor * dy
  if getDistance(pos[1], pos[2], self.posX, self.posY) < 16 then
    self.posX = pos[1]
    self.posY = pos[2]
    return true
  end
  return false
end