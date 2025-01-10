-- Used to help draw the background of the game
Background = {
  sprite = love.graphics.newImage("assets/bg.png"),
  scroll = 0
}

function Background.draw(self)
  for i = 0, love.graphics.getWidth() / self.sprite:getWidth() do
    for j = 0, love.graphics.getHeight() / self.sprite:getHeight() do
      love.graphics.draw(self.sprite, i * self.sprite:getWidth(), j * self.sprite:getHeight())
    end
  end
end
