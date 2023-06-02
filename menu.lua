-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local level1
local level2
local level3

-- 'onRelease' event listener for playBtn
local function onLevel1Button()
	
	-- go to level1.lua scene
	composer.gotoScene( "level1", "fade", 500 )
	
	return true	-- indicates successful touch
end

local function onLevel2Button()
	
	-- go to level1.lua scene
	composer.gotoScene( "level2", "fade", 500 )
	
	return true	-- indicates successful touch
end

local function onLevel3Button()
	
	-- go to level1.lua scene
	composer.gotoScene( "level3", "fade", 500 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "mainMenu.jpeg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY

	local logo = display.newText(sceneGroup, "Мини-игры", 160, 70, "RubikWetPaint-Regular.ttf", 40)
	
	-- create/position logo/title image on upper-half of the screen
	-- local titleLogo = display.newImageRect( "logo.png", 264, 42 )
	-- titleLogo.x = display.contentCenterX
	-- titleLogo.y = 100
	
	-- create a widget button (which will loads level1.lua on release)
	level1 = widget.newButton{
		label = "Уровень 1",
		labelColor = { default={ 1.0 }, over={ 0.5 } },
		defaultFile = "button.png",
		font = "RubikWetPaint-Regular.ttf",
		width = 154, height = 40,
		onRelease = onLevel1Button	-- event listener function
	}
	level1.x = display.contentCenterX
	level1.y = display.contentHeight - 330

	level2 = widget.newButton{
		label = "Уровень 2",
		labelColor = { default={ 1.0 }, over={ 0.5 } },
		defaultFile = "button.png",
		font = "RubikWetPaint-Regular.ttf",
		width = 154, height = 40,
		onRelease = onLevel2Button	-- event listener function
	}
	level2.x = display.contentCenterX
	level2.y = display.contentHeight - 260

	level3 = widget.newButton{
		label = "Уровень 3",
		labelColor = { default={ 1.0 }, over={ 0.5 } },
		defaultFile = "button.png",
		font = "RubikWetPaint-Regular.ttf",
		width = 154, height = 40,
		onRelease = onLevel3Button	-- event listener function
	}
	level3.x = display.contentCenterX
	level3.y = display.contentHeight - 190
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( logo )
	sceneGroup:insert( level1 )
	sceneGroup:insert( level2 )
	sceneGroup:insert( level3 )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if level1 then
		level1:removeSelf()	-- widgets must be manually removed
		level1 = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
