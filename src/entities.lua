Player = {
  sprite = love.graphics.newImage("assets/jumper.png"),
  dimension = { width = 90, height = 60 },
  position = { x = 0, y = 0 },
  flip = false,
  yVel = 0
}

function Player.draw(self, x, y, rot, flip)
  if flip then
    love.graphics.draw(self.sprite, x + self.dimension.width, y, rot, -1, 1)
  else
    love.graphics.draw(self.sprite, x, y, rot, 1, 1)
  end
  -- love.graphics.rectangle("fill", x, y, self.dimension.width, self.dimension.height)
end

-- inside entities.lua
Platform = {
  sprite = love.graphics.newImage("assets/wood.png"),
}

function Platform.new()
  local newPlatform = {
    dimension = {
      width = 100,
      height = 25
    },
    position = {
      x = 0,
      y = 0
    },
    sprite = Platform.sprite,
  }

  function newPlatform.draw(self, x, y)
    -- love.graphics.rectangle("fill", x, y, self.dimension.width, self.dimension.height)
    love.graphics.draw(self.sprite, x, y, 0, 1 / 8, 1 / 10)
  end

  function newPlatform.update(self, scroll)
    self.position.y = self.position.y + scroll
  end

  return newPlatform
end
