require("src.entities")
require("src.constants")
require("src.background")

local player = Player
local background = Background
local platformTable = {}

-- State variables
local gameState = "menu"
local loseState = false
local highScore = 0
local score = 0

-- Load fonts
local textFont = love.graphics.newFont("assets/m6x11.ttf", 36)
local buttonFont = love.graphics.newFont("assets/m6x11.ttf", 48)
local titleFont = love.graphics.newFont("assets/Rah-Regular.otf", 72)

-- Called once at the start of the game
function love.load()
  love.graphics.setFont(buttonFont)
  love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
  local icon = love.image.newImageData("assets/ganesha.jpg")
  love.window.setIcon(icon)
  love.window.setTitle("Roga Lompat | " .. TITLE_LIST[math.ceil(love.math.random() * #TITLE_LIST)])
end

-- Called to draw to the screen
function love.draw()
  if gameState == "menu" then
    -- Game is at start menu
    love.graphics.setBackgroundColor(173 / 255, 216 / 255, 230 / 255, 1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("ROGA", titleFont, (SCREEN_WIDTH - titleFont:getWidth("ROGA")) / 2,
      (SCREEN_HEIGHT - titleFont:getHeight("ROGA")) / 10,
      0, 1, 1)
    love.graphics.print("LOMPAT", titleFont, (SCREEN_WIDTH - titleFont:getWidth("LOMPAT")) / 2,
      (SCREEN_HEIGHT - titleFont:getHeight("LOMPAT")) * 2 / 10,
      0, 1, 1)
    love.graphics.rectangle("fill", SCREEN_WIDTH / 3, SCREEN_HEIGHT * 2 / 5, SCREEN_WIDTH / 3, SCREEN_HEIGHT / 5)
    love.graphics.setColor(173 / 255, 216 / 255, 230 / 255, 1)
    love.graphics.print("PLAY", buttonFont, (SCREEN_WIDTH - buttonFont:getWidth("PLAY")) / 2,
      (SCREEN_HEIGHT - buttonFont:getHeight("PLAY") * 2 / 3) / 2,
      0, 1, 1)
    love.graphics.setColor(1, 1, 1, 1)
  elseif gameState == "game" then
    -- Game is playing
    background.draw(background)

    for k, platform in pairs(platformTable) do
      platform.draw(platform, platform.position.x, platform.position.y)
    end

    player.draw(player, player.position.x, player.position.y, 0, player.flip)

    -- Gameover screen
    if loseState == true then
      -- Translucent background
      love.graphics.setColor(1, 1, 1, .8)
      love.graphics.rectangle("fill", 0, SCREEN_HEIGHT * 2 / 5, SCREEN_WIDTH, SCREEN_HEIGHT / 5)

      -- High Score
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.rectangle("fill",
        (SCREEN_WIDTH - textFont:getWidth("HIGH SCORE : " .. highScore)) / 2 * .9,
        SCREEN_HEIGHT * 10 / 25,
        textFont:getWidth("HIGH SCORE : " .. highScore) * 1.1,
        textFont:getHeight("HIGH SCORE : " .. highScore) * 1.3)
      love.graphics.setColor(173 / 255, 216 / 255, 230 / 255, 1)
      love.graphics.print("HIGH SCORE : " .. highScore, textFont,
        (SCREEN_WIDTH - textFont:getWidth("HIGH SCORE : " .. highScore)) / 2,
        (SCREEN_HEIGHT - textFont:getHeight("HIGH SCORE : " .. highScore)) * .875 / 2,
        0, 1, 1)

      -- Quit and Play Again buttons
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.rectangle("fill", SCREEN_WIDTH / 16, SCREEN_HEIGHT * 12 / 25, SCREEN_WIDTH * 2 / 8,
        SCREEN_HEIGHT * 2.5 / 25)
      love.graphics.rectangle("fill", SCREEN_WIDTH * 7 / 16, SCREEN_HEIGHT * 12 / 25, SCREEN_WIDTH * 4 / 8,
        SCREEN_HEIGHT * 2.5 / 25)
      love.graphics.setColor(173 / 255, 216 / 255, 230 / 255, 1)
      love.graphics.print("QUIT", buttonFont, (SCREEN_WIDTH + buttonFont:getWidth("QUIT")) * 1.35 / 16,
        (SCREEN_HEIGHT + buttonFont:getHeight("QUIT") * 9.5 / 25) / 2,
        0, 1, 1)
      love.graphics.print("PLAY AGAIN", buttonFont,
        (SCREEN_WIDTH + buttonFont:getWidth("PLAY AGAIN")) * 5.4 / 16,
        (SCREEN_HEIGHT + buttonFont:getHeight("PLAY AGAIN") * 9.5 / 25) / 2,
        0, 1, 1)

      -- Reset The Colors (DO NOT REMOVE)
      love.graphics.setColor(1, 1, 1, 1)
    end
  end
end

-- Called every frame
function love.update(dt)
  if gameState == "menu" then
    -- Game is at start menu, nothing to update here
  elseif gameState == "game" and loseState == false then
    -- Game is playing and not losing
    local dx = 0
    local dy = 0
    local scroll = 0

    for k, platform in pairs(platformTable) do
      if platform.position.y + platform.dimension.height > SCREEN_HEIGHT then
        platformTable[k] = nil
        local platform = Platform.new()
        platform.position.x = math.ceil(love.math.random(0, SCREEN_WIDTH - platform.dimension.width))
        platform.position.y = 0
        table.insert(platformTable, platform)
      end
    end

    -- Collision with the ground
    if player.position.y + player.dimension.height > SCREEN_HEIGHT then
      loseState = true
      if highScore < score then
        highScore = score
      end
    else
      -- Collision with platforms
      for k, platform in pairs(platformTable) do
        if
            (
              player.position.y + player.dimension.height >= platform.position.y - 10
              and
              player.position.y + player.dimension.height <= platform.position.y + 10
              and
              player.yVel > 0
            )
            and
            (
              player.position.x >= platform.position.x - 60
              and
              player.position.x + player.dimension.width <= platform.position.x + platform.dimension.width + 60
            )
        then
          player.yVel = BOUNCE
          dy = dy + player.yVel
        end
      end
      player.yVel = player.yVel + GRAVITY
      dy = dy + player.yVel
    end

    -- Movement
    if love.keyboard.isDown("left") and love.keyboard.isDown("right") then
      dx = dx
    elseif love.keyboard.isDown("left") and player.position.x > 0 then
      player.flip = false
      dx = dx - PLAYER_SPEED
      -- Collision with the screen
    elseif love.keyboard.isDown("right") and player.position.x < SCREEN_WIDTH - player.dimension.width then
      player.flip = true
      dx = dx + PLAYER_SPEED
    end

    -- Player scrolling threshold hit
    if
        player.position.y + player.dimension.height - 20 <= SCROLL_THRESHOLD
        and
        player.yVel < 0
    then
      scroll = -dy
      background.scroll = background.scroll + scroll
      dy = dy * .05
      for key, platform in pairs(platformTable) do
        platform.update(platform, scroll)
      end
    end

    if scroll > 0 then
      score = score + scroll
    end

    player.position.x = player.position.x + dx
    player.position.y = player.position.y + dy
  end
end

-- Called when a mouse is pressed
function love.mousepressed(x, y, button, _isTouch)
  if button == 1 then
    -- Left click
    if gameState == "menu" then
      if (x > SCREEN_WIDTH / 3 and y > SCREEN_HEIGHT * 2 / 5) and (x < SCREEN_WIDTH * 2 / 3 and y < SCREEN_HEIGHT * 3 / 5) then
        gameState = "game"
        loseState = false

        player.position.x = (SCREEN_WIDTH - player.dimension.width) / 2
        player.position.y = SCREEN_HEIGHT - 150

        for i = 1, MAX_PLATFORMS, 1 do
          local platform = Platform.new()
          if i == MAX_PLATFORMS then
            platform.position.x = (SCREEN_WIDTH - platform.dimension.width) / 2
            platform.position.y = SCREEN_HEIGHT * 9 / 10
          else
            platform.position.x = math.ceil(love.math.random(0, SCREEN_WIDTH - platform.dimension.width))
            platform.position.y = i * math.ceil(SCREEN_HEIGHT / (MAX_PLATFORMS + 1))
          end
          table.insert(platformTable, platform)
          print("created platform", platform.position.x, platform.position.y)
        end
      end
    elseif gameState == "game" then
      if loseState == true then
        if (x > SCREEN_WIDTH * 7 / 16 and y > SCREEN_HEIGHT * 12 / 25) and (x < SCREEN_WIDTH * 15 / 16 and y < SCREEN_HEIGHT * 14.5 / 25) then
          loseState = false

          player.position.x = (SCREEN_WIDTH - player.dimension.width) / 2
          player.position.y = SCREEN_HEIGHT - 150

          platformTable = {}
          for i = 1, MAX_PLATFORMS, 1 do
            local platform = Platform.new()
            if i == MAX_PLATFORMS then
              platform.position.x = (SCREEN_WIDTH - platform.dimension.width) / 2
              platform.position.y = SCREEN_HEIGHT * 9 / 10
            else
              platform.position.x = math.ceil(love.math.random(0, SCREEN_WIDTH - platform.dimension.width))
              platform.position.y = i * math.ceil(SCREEN_HEIGHT / (MAX_PLATFORMS + 1))
            end
            table.insert(platformTable, platform)
            print("created platform", platform.position.x, platform.position.y)
          end
        elseif (x > SCREEN_WIDTH / 16 and y > SCREEN_HEIGHT * 12 / 25) and (x < SCREEN_WIDTH * 5 / 16 and y < SCREEN_HEIGHT * 14.5 / 25) then
          love.event.quit()
        end
      end
    end
  end
end
