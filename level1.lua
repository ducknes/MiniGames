local composer = require( "composer" )
local physics = require ("physics")
local scene = composer.newScene()
local widget = require( "widget" )
physics.start()

local audio1 = audio.loadSound( "sound/sound.mp3" )
local audio2 = audio.loadSound( "sound/min-life.mp3" )
local audio3 = audio.loadSound( "sound/heal-sound.mp3" )
local playAgain
local nextLevel
local spawnBomb_timer
local spawnPlus_timer
local spawnHeal_timer
local spawnPlus5_timer
local gameoverTimer
local winTimer
local count = 0
local life = 5
local h = 130
local w = 120
local phionas = math.random(1, 3)
local frogs = math.random(2, 6)
local rats = math.random(3, 12)
local score =  0
local hearts = {}

function scene:create( event )
  local sceneGroup = self.view

  local background = display.newImageRect(sceneGroup,"level1-bg.jpeg", 350, 600)
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  local r = display.newImageRect(sceneGroup, "rat1.png", 50, 50)
  r.x = 30
  r.y = -50
  r:setFillColor(0,1,2,1)
  local rt = display.newText(sceneGroup,":"..rats, 90, -50,"RubikWetPaint-Regular.ttf", 20 )
  rt.x = 70
  rt.y = -50

  local f = display.newImageRect(sceneGroup, "frog1.png", 50, 50)
  f.x = 120
  f.y = -50
  local ft = display.newText(sceneGroup,":"..frogs, 90, -50,"RubikWetPaint-Regular.ttf", 20 )
  ft.x = 160
  ft.y = -50

  local ph = display.newImageRect(sceneGroup, "phiona1.png", 50, 50)
  ph.x = 210
  ph.y = -50
  local pht = display.newText(sceneGroup,":"..phionas, 90, -50,"RubikWetPaint-Regular.ttf", 20 )
  pht.x = 250
  pht.y = -50

  local scoreText = display.newText(sceneGroup, "Очки:"..score, 50, -20, "RubikWetPaint-Regular.ttf", 20 )

  local hx = 300
  local hy = -50
  for i = 0, 4 do
    local heart = display.newImageRect(sceneGroup, "heart.png", 50, 50)
    heart.x = hx
    heart.y = hy
    hy = hy + 30
    table.insert(hearts, heart)
  end


--спавн +25 и -25
  local function spawnBomb ()
    local bomb = display.newImageRect("donkey.png", 50, 50)
    bomb.ID = "bomb"
    bomb.x = math.random(10,460)
    bomb.y = -200
    bomb.myName = "bomb"
    physics.addBody(bomb, "dynamic", {radius = 20, isSensor = true})
  end
  spawnBomb_timer = timer.performWithDelay (200,spawnBomb, 0)

  local function spawnPlus()
    if (rats > 0) then
      local plus = display.newImageRect("rat1.png", 70, 70)
      plus.ID = "plus"
      plus:setFillColor(0,1,2,1)
      plus.x = math.random(10, 460)
      plus.y = -200
      plus.myName = "plus"
      physics.addBody(plus, "dynamic", {radius = 40, isSensor = true})
    end
  end
  spawnPlus_timer = timer.performWithDelay (1300, spawnPlus, 0)

  local function spawnPlus5()
    if (frogs > 0) then
      local plus5 = display.newImageRect("frog1.png", 70,70)
      plus5.ID = "plus5"
      plus5.x = math.random(10, 460)
      plus5.y = -200
      plus5.myName = "plus5"
      physics.addBody(plus5, "dynamic", {radius = 40, isSensor = true})
    end
  end
  spawnPlus5_timer = timer.performWithDelay (5300,spawnPlus5, 0)

  local function spawnHeal()
    if (phionas > 0) then
      local heal = display.newImageRect("phiona1.png", 70,70)
      heal.ID = "heal"
      heal.x = math.random(10, 460)
      heal.y = -200
      heal.myName = "heal"
      physics.addBody(heal, "dynamic", {radius = 40, isSensor = true})
    end
  end
  spawnHeal_timer = timer.performWithDelay (7300,spawnHeal, 0)

--игрок
  local player = display.newImage(sceneGroup, "shrek-lvl1-player.png", 100, 470)
  player.height = h
  player.width = w
  player.myName = "player"
  physics.addBody(player, "dynamic", {radius = 20, isSensor = true} )
  player.gravityScale = 0

--управление игроком
  local function dragPlayer (event)
    if(event.phase == "began") then
        display.currentStage:setFocus(player)
        player.touchOffsetX = event.x - player.x
    elseif(event.phase == "moved") then
      player.x = event.x - player.touchOffsetX
    elseif(event.phase == "ended") then
      display.currentStage:setFocus(nil)
      return true
    end
  end

--информация о жизнях и набранных очках
  player:addEventListener("touch", dragPlayer)

  local function onPlayAgainTouch()
    life = 5
    display.remove(playAgain)
    print(playAgain)
    playAgain = nil
    display.remove(nextLevel)
    nextLevel = nil
    print(nextLevel)
    composer.removeScene("level1")
    composer.gotoScene("menu", "fade") -- move player to menu
  end

  local function onNextLevelTouch()
    composer.removeScene("level1")
    life = 5
    display.remove(playAgain)
    display.remove(nextLevel)
    playAgain = nil
    nextLevel = nil
    composer.gotoScene("level2","fade", 500) -- move player
  end

  local function incCount()
    if (rats > 0) then 
      rats = rats - 1
      rt.text = ":"..rats
      score = score + 1
      scoreText.text = "Очки:"..score
    end
  end

  local function incCount5()
    if (frogs > 0) then 
      frogs = frogs - 1
      ft.text = ":"..frogs
      score = score + 5
      scoreText.text = "Очки:"..score
    end
  end

  local function minLife()
    life = life - 1
    display.remove(hearts[#hearts])
    hearts[#hearts] = nil
    score = score - 7
    scoreText.text = "Очки:"..score
  end

  local function incLife()
    if (phionas > 0) then
      phionas = phionas - 1
      pht.text = ":"..phionas
      score = score + 10
      scoreText.text = "Очки:"..score
    end
  end

  local function win(event)
    if (frogs + rats + phionas == 0) then
      timer.cancel(spawnBomb_timer)
      timer.cancel(winTimer)
      timer.cancel(spawnPlus_timer)
      timer.cancel(spawnPlus5_timer)
      timer.cancel(spawnHeal_timer)
      timer.cancel( gameoverTimer )
      display.remove(countText)
      display.remove(lifeText)
      display.remove(player)

      local gameOverBack = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
      gameOverBack.x = display.contentCenterX
      gameOverBack.y = display.contentCenterY
      gameOverBack:setFillColor(0)
      gameOverBack.alpha = 0.5

      local gameOverText1 = display.newText( sceneGroup, "Поздравляем!", 100, 200, "RubikWetPaint-Regular.ttf", 32 )
      gameOverText1.x = display.contentCenterX
      gameOverText1.y = 150
      gameOverText1:setFillColor( 1, 1, 1 )

      local gameOverText2 = display.newText( sceneGroup, "Очки:"..score, 100, 200, "RubikWetPaint-Regular.ttf", 32 )
      gameOverText2.x = display.contentCenterX
      gameOverText2.y = gameOverText1.y + 50
      gameOverText2:setFillColor( 1, 1, 1 )

      nextLevel = widget.newButton{
        width = 180,
        height = 70,
        defaultFile = "button.png",
        label = "Уровень 2",
        font = "RubikWetPaint-Regular.ttf",
        fontSize = 24,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } },
        onEvent = onNextLevelTouch
      }
      nextLevel.x = display.contentCenterX
      nextLevel.y = gameOverText2.y + 100
      print("nextLevel: ", nextLevel)

      playAgain = widget.newButton{
        width = 180,
        height = 70,
        defaultFile = "button.png",
        label = "В меню",
        font = "RubikWetPaint-Regular.ttf",
        fontSize = 24,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } },
        onEvent = onPlayAgainTouch
      }
      playAgain.x = display.contentCenterX
      playAgain.y = nextLevel.y + 100
      print("next playAgain", playAgain)

      return sceneGroup
    end
  end
  winTimer = timer.performWithDelay(500, win, 0)

  local function gameover()
    if (life == 0) then
      timer.cancel(spawnBomb_timer)
      timer.cancel(winTimer)
      timer.cancel(spawnPlus_timer)
      timer.cancel(spawnPlus5_timer)
      timer.cancel(spawnHeal_timer)
      timer.cancel( gameoverTimer )
      display.remove(countText)
      display.remove(lifeText)
      display.remove(player)

      local gameOverBack = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
      gameOverBack.x = display.contentCenterX
      gameOverBack.y = display.contentCenterY
      gameOverBack:setFillColor(0)
      gameOverBack.alpha = 0.5

      local gameOverText1 = display.newText( sceneGroup, "Игра окончена", 100, 200, "RubikWetPaint-Regular.ttf", 32 )
      gameOverText1.x = display.contentCenterX
      gameOverText1.y = 150
      gameOverText1:setFillColor( 1, 1, 1 )

      local gameOverText2 = display.newText( sceneGroup, "Очки:"..score, 100, 200, "RubikWetPaint-Regular.ttf", 32 )
      gameOverText2.x = display.contentCenterX
      gameOverText2.y = gameOverText1.y + 50
      gameOverText2:setFillColor( 1, 1, 1 )
      
      playAgain = widget.newButton{
        width = 180,
        height = 70,
        defaultFile = "button.png",
        label = "В меню",
        font = "RubikWetPaint-Regular.ttf",
        fontSize = 24,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } },
        onEvent = onPlayAgainTouch
      }
      playAgain.x = display.contentCenterX
      playAgain.y = gameOverText2.y + 100
      print("gameover pa", playAgain)
      return sceneGroup
    end
  end
  gameoverTimer = timer.performWithDelay( 100, gameover,0 )

  local function onCollision (event)
    local obj1 = event.object1
    local obj2 = event.object2
    if(event.phase == "began") then
      if (obj1.myName == "player" and obj2.myName == "bomb") then
        local audio2Channel = audio.play( audio2 )
        print("life")
        minLife()
        display.remove(obj2)
      end
      if (obj1.myName == "player" and obj2.myName == "plus") then
        local audio1Channel = audio.play( audio1 )
        print(1)
        incCount()
        display.remove(obj2)
      end
      if (obj1.myName == "player" and obj2.myName == "plus5") then
        print(5)
        local audio1Channel = audio.play( audio1 )
        incCount5()
        display.remove(obj2)
      end
      if (obj1.myName == "player" and obj2.myName == "heal") then
        print(10)
        local audio3Channel = audio.play( audio1 )
        incLife()
        display.remove(obj2)
      end
    end
  end
  Runtime:addEventListener("collision", onCollision)
end

function scene:show( event )
  local prevScene = composer.getSceneName( "previous" )
  if(prevScene) then
    composer.removeScene(prevScene)
      end
end

function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then

    end
end

function scene:destroy( event )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

display.remove(playAgain)
return scene