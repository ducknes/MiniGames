local composer = require( "composer" )
local physics = require ("physics")
local scene = composer.newScene()
local widget = require "widget"
physics.start()

local createdObjects = {}
local waves = 6
local lifes = 4
local hearts = {}
local checkTerrTimer
local gameoverTimer
local winTimer
local returnButton
local nextLevel
local timeTrans = 3500
local gunSound = audio.loadSound( "sound/laser.mp3" )
local crashShipSound = audio.loadSound( "sound/crashShip.mp3" )
local crashCivilSound = audio.loadSound( "sound/min-life.mp3" )

function scene:create( event )
    local sceneGroup = self.view

    local back = display.newImageRect(sceneGroup, "level2-background.jpeg", display.actualContentWidth, display.actualContentHeight)
    back.anchorX = 0
	back.anchorY = 0
	back.x = 0 + display.screenOriginX 
	back.y = 0 + display.screenOriginY

    local gun = display.newImageRect(sceneGroup, "friendlyShip.png", 100, 100)
    gun.x = 320/2
    gun.y = 480

    local text = display.newText(sceneGroup, "Осталось волн:", 115, -50, "RubikWetPaint-Regular.ttf", 25)
    local wave = display.newText(sceneGroup, waves, 235, -50, "RubikWetPaint-Regular.ttf", 25)

    local score = 0
    local scoreText = display.newText(sceneGroup, "Очки: "..score, 70, -20, "RubikWetPaint-Regular.ttf", 25 )

    local deadCounter = 0

    local heart_x = 300
    local heart_y = -50
    for i = 1, 4 do
        local heart = display.newImageRect(sceneGroup, "heart.png", 50, 50)
        heart.x = heart_x
        heart.y = heart_y
        heart_y = heart_y + 30
        table.insert(hearts, heart)
    end

    local function RotateOb(event)
        if (event.phase == "began") then
            gun.rotation = math.ceil(math.atan2((event.y - gun.y), (event.x - gun.x)) * 180 / math.pi) + 90
        end
        if (event.phase == "moved") then
            gun.rotation = math.ceil(math.atan2((event.y - gun.y), (event.x - gun.x)) * 180 / math.pi) + 90
        end
        if (event.phase == "ended" or event.phase == "canceled") then
            local actualX, actualY = gun:localToContent(0, 0)
            local bullet = display.newImageRect("bullet.png", 10, 20)
            bullet.x = actualX
            bullet.y = actualY
            physics.addBody(bullet, "dynamic", {isSensor = true})
            bullet.ID = "bullet"
            bullet:setFillColor(1, 1, 1, 1)
            local angle = - math.rad(gun.rotation + 90)
            local xComp = math.cos(angle)
            local yComp = - math.sin(angle)
            bullet:applyLinearImpulse(-0.05 * xComp, -0.05 * yComp, gun.x, gun.y)
            local laserChannel = audio.play(gunSound)
        end
    end
    back:addEventListener("touch", RotateOb)

    local function move_terrorist(self)
        local tagrelX = math.random(0, 320)
        local tagrelY = math.random(0, 300)

        transition.moveTo(self, {x = tagrelX, y = tagrelY, time = timeTrans, onComplete = move_terrorist})
    end

    local function spawnbot()
        local x = math.random(0, 320)
        local y = math.random(0, 300)
        local opponent = display.newImageRect(sceneGroup, "evilShip.png", 50, 50)
        opponent.x = x
        opponent.y = y
        physics.addBody(opponent, "dynamic")
        opponent.isSensor = true

        move_terrorist(opponent)

        local function crash(self, event)
            if (event.phase == "began" and event.other.ID == "bullet") then
                self:removeSelf()
                event.other:removeSelf()
                deadCounter = deadCounter - 1
                score = score + 10
                scoreText.text = "Очки: "..score
                local crashChannel = audio.play(crashShipSound)
            end
        end
        opponent.collision = crash
        opponent:addEventListener("collision", opponent)
        table.insert(createdObjects, opponent)
        print("opponent:", #opponent)
        print("spawn opponent", createdObjects[#createdObjects])
    end

    local function spawnCivil()
        local x = math.random(0, 320)
        local y = math.random(0, 320)
        local civil = display.newImageRect(sceneGroup, "friendlyShip.png", 50, 50)
        civil.x = x
        civil.y = y
        physics.addBody(civil, "dynamic")
        civil.isSensor = true
        
        move_terrorist(civil)

        local function crash(self, event)
            if (event.phase == "began" and event.other.ID == "bullet") then
                self:removeSelf()
                event.other:removeSelf()
                display.remove(hearts[#hearts])
                hearts[#hearts] = nil
                lifes = lifes - 1
                score = score - 15
                scoreText.text = "Очки: "..score
                local civilChannel = audio.play(crashCivilSound)
            end
        end
        civil.collision = crash
        civil:addEventListener("collision", civil)
        table.insert(createdObjects, civil)
        print("civil:", #civil)
        print("spawn civil", #createdObjects[#createdObjects])
    end

    local function add_terrorist(event)
        if (deadCounter == 0) then
            deadCounter = 4
            print("array len", #createdObjects)
            for i = #createdObjects, 1, -1 do
                display.remove(createdObjects[i])
                createdObjects[i] = nil
            end
            createdObjects = {}
            waves = waves - 1
            wave.text = waves
            for i = 1, 4 do
                spawnbot()
                print(#createdObjects)
            end
            spawnCivil()
            print(#createdObjects)
            spawnCivil()
            print(#createdObjects)
            timeTrans = timeTrans - 500
        end
    end
    checkTerrTimer = timer.performWithDelay(100, add_terrorist, 0)

    local function onReturnButton()
        timeTrans = 3500
        composer.removeScene("level2")
        composer.gotoScene("menu", "fade", 500 )
        display.remove(returnButton)
        display.remove(nextLevel)
    end

    local function onNextLevelButton()
        timeTrans = 3500
        composer.removeScene("level2")
        composer.gotoScene("level3", "fade", 500 )
        display.remove(nextLevel)
        display.remove(returnButton)
    end

    local function win(event)
        if (waves == 0) then
            timer.cancel( checkTerrTimer )
            timer.cancel( gameoverTimer )
            timer.cancel( winTimer )
            display.remove(gun)
            display.remove(text)
            display.remove(wave)
            for i=1, #createdObjects do
                display.remove( createdObjects[i] )
            end
            back:removeEventListener("touch", RotateOb)

            local backOver = display.newRect( sceneGroup,  0, 0, display.actualContentWidth, display.actualContentHeight )
            backOver.x = display.contentCenterX
            backOver.y = display.contentCenterY
            backOver:setFillColor(0)
            backOver.alpha = 0.8

            local endText = display.newText( sceneGroup, "Поздравляем!", 100, 200, "RubikWetPaint-Regular.ttf", 32)
            endText.x = display.contentCenterX
            endText.y = 150

            local endText1 = display.newText( sceneGroup, "Очки: "..score, 100, 200, "RubikWetPaint-Regular.ttf", 32)
            endText1.x = display.contentCenterX
            endText1.y = endText.y + 50

            nextLevel = widget.newButton{
                label = "Уровень 3",
                labelColor = { default={ 1.0 }, over={ 0.5 } },
                defaultFile = "button.png",
                font = "RubikWetPaint-Regular.ttf",
                width = 180,
                height = 70,
                fontSize = 24,
                onRelease = onNextLevelButton
            }
            nextLevel.x = display.contentCenterX
	        nextLevel.y = endText1.y + 100

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
	        returnButton.y = nextLevel.y + 100
        end
        return sceneGroup
    end
    winTimer = timer.performWithDelay(100, win, 0)

    local function gameover(event)
        if lifes == 0 then
            timer.cancel( checkTerrTimer )
            timer.cancel( gameoverTimer )
            timer.cancel( winTimer )
            display.remove(gun)
            display.remove(text)
            display.remove(wave)
            for i=1, #createdObjects do
                display.remove( createdObjects[i] )
            end
            
            back:removeEventListener("touch", RotateOb)
    
            local backOver = display.newRect( sceneGroup,  0, 0, display.actualContentWidth, display.actualContentHeight )
            backOver.x = display.contentCenterX
            backOver.y = display.contentCenterY
            backOver:setFillColor(0)
            backOver.alpha = 0.8

            local endText = display.newText( sceneGroup, "Игра окончена", 100, 200, "RubikWetPaint-Regular.ttf", 32)
            endText.x = display.contentCenterX
            endText.y = 150

            local endText1 = display.newText( sceneGroup, "Очки:"..score, 100, 200, "RubikWetPaint-Regular.ttf", 32)
            endText1.x = display.contentCenterX
            endText1.y = endText.y + 50

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
	        returnButton.y = endText1.y + 100
        end
        return sceneGroup
    end
    gameoverTimer = timer.performWithDelay(100, gameover, 0)
end

function scene:show( event )

end

function scene:hide( event )

end

function scene:destroy( event )

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene