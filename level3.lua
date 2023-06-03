local composer = require( "composer" )
local physics = require ("physics")
local scene = composer.newScene()
local widget = require "widget"
physics.start()

local gravityTimer
local pipeTimer
local blackCoinTimer
local returnButton
local winButton
local coinTimer
local winTimer
local coinY
local checkSpawn = { false, false, true, false, false }
local birdSound = audio.loadSound( "sound/birdFly3.mp3" )
local coinSound = audio.loadSound( "sound/sfx_point.mp3" )
local blackCoinSound = audio.loadSound( "sound/min-life.mp3" )

function scene:create(event)
    local sceneGroup = self.view

    local top = display.newRect(sceneGroup, 320/2, -100, 500, 10)
    physics.addBody(top,"static")

    local bottom = display.newRect(sceneGroup, 320/2, 600, 500, 10)
    physics.addBody(bottom,"static")

    local back = display.newImageRect(sceneGroup, "city.jpeg", display.actualContentWidth, display.actualContentHeight)
    back.anchorX = 0
	back.anchorY = 0
	back.x = 0 + display.screenOriginX
	back.y = 0 + display.screenOriginY

    local colCoin = display.newImageRect(sceneGroup, "coin.png", 60, 60)
    colCoin.x = 30
    colCoin.y = -50

    local bird = display.newImageRect(sceneGroup, "golub.png", 80, 80)
    bird.x = 100
    bird.y = 480 / 2
    bird:setFillColor (1,1,2,1)
    bird.ID = "Player"
    physics.addBody(bird,"dynamic")
    bird.gravityScale = 0

    local moneyCount = math.random(1, 3)
    local moneyText = display.newText(sceneGroup, ":"..moneyCount, 80, -50, "RubikWetPaint-Regular.ttf", 35)
    moneyText:setFillColor (1,0,0)

    local function push()
        bird:applyLinearImpulse(0,-0.04, bird.x, bird.y)
        local flyChannel = audio.play(birdSound)
    end
    back:addEventListener("touch", push)

    local function birdGravity()
        bird.gravityScale = 3
    end
    gravityTimer = timer.performWithDelay(500, birdGravity, 1)

    local function onReturnButton()
        composer.removeScene("level3")
        composer.gotoScene("menu", "fade", 500 )
        display.remove(returnButton)
    end

    local function onWinButton()
        composer.removeScene("level3")
        composer.gotoScene("menu", "fade", 500 )
        display.remove(winButton)
    end

    local function spawnPipes()
        local y = math.random(-200, 150)
        coinY = y
        print("hell0")

        local pipe = display.newImageRect(sceneGroup, "pipe1.png", 40, 500)
        pipe.x = 500
        pipe.y = y
        pipe.yScale = -1
        pipe.ID = "GameOver"
        physics.addBody(pipe,"dynamic")
        pipe.isSensor = true
        pipe.gravityScale = 0

        local pipe2 = display.newImageRect(sceneGroup, "pipe1.png", 40, 500)
        pipe2.x = 500
        pipe2.y = y + 650
        pipe2.ID = "GameOver"
        physics.addBody(pipe2,"dynamic")
        pipe2.isSensor = true
        pipe2.gravityScale = 0

        pipe:setLinearVelocity(-200,0)
        pipe2:setLinearVelocity(-200,0)
        colCoin:toFront()
        moneyText:toFront()
    end
    pipeTimer = timer.performWithDelay(2000, spawnPipes, 0)

    local function spawnCoin()
        local coin = display.newImageRect(sceneGroup, "semki.png", 90, 100)
        coin.x = 500
        coin.y = coinY + 320
        coin.ID = "Coin"
        physics.addBody(coin,"dynamic")
        coin.isSensor = true
        coin.gravityScale = 0
        coin:setLinearVelocity(-200,0)

        local function deleteCoin(self, event)
            if (event.phase == "began" and event.other.ID == "Player") then
                local collectSound = audio.play(coinSound)
                coin:removeSelf()
            end
        end
        coin.collision = deleteCoin
        coin:addEventListener("collision", coin)
    end
    coinTimer = timer.performWithDelay(6000, spawnCoin, 0)

    local function spawnBlackCoin()
        if (checkSpawn[math.random(1,5)]) then
            local coin = display.newImageRect(sceneGroup, "bread.png", 80, 60)
            coin.x = 500
            coin.y = coinY + 320
            coin.ID = "BlackCoin"
            physics.addBody(coin,"dynamic")
            coin.isSensor = true
            coin.gravityScale = 0
            coin:setLinearVelocity(-200,0)

            local function deleteCoin(self, event)
                if (event.phase == "began" and event.other.ID == "Player") then
                    local collectSound = audio.play(blackCoinSound)
                    coin:removeSelf()
                end
            end
            coin.collision = deleteCoin
            coin:addEventListener("collision", coin)
        end
    end
    blackCoinTimer = timer.performWithDelay(4000, spawnBlackCoin, 0)

    local function onCollision(self, event)
        if (event.phase == "began" and event.other.ID == "Coin") then
            moneyCount = moneyCount - 1
            moneyText.text = ":"..moneyCount
        end
        if (event.phase == "began" and event.other.ID == "BlackCoin") then
            moneyCount = moneyCount + 1
            print(moneyCount)
            moneyText.text = ":"..moneyCount
        end
        if (event.phase == "began" and event.other.ID == "GameOver") then
            timer.cancel( pipeTimer )
            timer.cancel( gravityTimer )
            timer.cancel( coinTimer )
            timer.cancel( blackCoinTimer )
            timer.cancel( winTimer )
            display.remove(bird)
            display.remove(pipe)
            display.remove(pipe2)
            display.remove(coin)
            back:removeEventListener("touch", push)

            local backOver = display.newRect( sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight )
            backOver.x = display.contentCenterX
            backOver.y = display.contentCenterY
            backOver:setFillColor(0)
            backOver.alpha = 0.8

            local endText = display.newText( sceneGroup, "Игра окончена", 100, 200, "RubikWetPaint-Regular.ttf", 32)
            endText.x = display.contentCenterX
            endText.y = 150

            returnButton = widget.newButton{
                label = "В меню",
                labelColor = { default={ 1.0 }, over={ 0.5 } },
                defaultFile = "button.png",
                font = "RubikWetPaint-Regular.ttf",
                width = 180,
                height = 70,
                fontSize = 24,
                onRelease = onReturnButton
            }
            returnButton.x = display.contentCenterX
            returnButton.y = display.contentHeight - 260
            return sceneGroup
        end
    end
    bird.collision = onCollision
    bird:addEventListener("collision", bird)

    local function win(event)
        if (moneyCount == 0) then
            timer.cancel( pipeTimer )
            timer.cancel( gravityTimer )
            timer.cancel( coinTimer )
            timer.cancel( blackCoinTimer )
            timer.cancel( winTimer )
            display.remove(bird)
            back:removeEventListener("touch", push)

            local backOver = display.newRect( sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight )
            backOver.x = display.contentCenterX
            backOver.y = display.contentCenterY
            backOver:setFillColor(0)
            backOver.alpha = 0.8

            local endText = display.newText( sceneGroup, "Поздравляем!", 100, 200, "RubikWetPaint-Regular.ttf", 32)
            endText.x = display.contentCenterX
            endText.y = 150

            winButton = widget.newButton{
                label = "В меню",
                labelColor = { default={ 1.0 }, over={ 0.5 } },
                defaultFile = "button.png",
                font = "RubikWetPaint-Regular.ttf",
                width = 180,
                height = 70,
                fontSize = 24,
                onRelease = onWinButton
            }
            winButton.x = display.contentCenterX
            winButton.y = display.contentHeight - 260
            return sceneGroup
        end
    end
    winTimer = timer.performWithDelay(100, win, 0)
end

function scene:show(event)
end

function scene:hide(event)
end

function scene:destroy(event)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene