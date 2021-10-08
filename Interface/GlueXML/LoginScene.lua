--[[текстура--
 LoginscreenLightHit = LoginScene:CreateTexture(nil,"OVERLAY")
      LoginscreenLightHit:SetPoint("TOPRIGHT", LoginScene, "TOPRIGHT", 0, 125)
      LoginscreenLightHit:SetPoint("BOTTOMLEFT", LoginScene, "BOTTOMLEFT", -1, -125)
      LoginscreenLightHit:SetAlpha(0.2)
      LoginscreenLightHit:SetTexture("Interface/Loginscreen/LightHit.blp")
      LoginscreenLightHit:SetBlendMode("ADD")
      ]]--

--[[функция плавного появления

local FramesToFade = {}

local function BaseFrameFade(frame, mode)
    if (frame) then
        frame.FadeTimer = 0
        if (frame.time) then
          frame.TimeToFade = frame.time
        else
        frame.TimeToFade = 3
      end
        frame.FadeMode = mode
        table.insert(FramesToFade, frame)
    end
end

local function BaseFrameFadeIn(frame, mode)
    BaseFrameFade(frame, "IN")
    frame:Show()
end

local function BaseFrameFadeOut(frame, mode)
    BaseFrameFade(frame, "OUT")
    --frame:Show()
end

local function BaseFading(elapsed)
    for k,frame in pairs(FramesToFade) do
        frame.FadeTimer = frame.FadeTimer + 0.1
        if (frame.FadeTimer < frame.TimeToFade) then
            if (frame.FadeMode == "IN") then
            frame:SetAlpha(frame.FadeTimer/frame.TimeToFade)
            elseif (frame.FadeMode == "OUT") then
                frame:SetAlpha((frame.TimeToFade-frame.FadeTimer)/frame.TimeToFade)
            end
        else
            if ( frame.FadeMode == "IN" ) then
                frame:SetAlpha(1.0);
            elseif ( frame.FadeMode == "OUT" ) then
                frame:SetAlpha(0);
                frame:Hide()
            end
            table.remove(FramesToFade, k)
        end
    end
    end

local fadingFunc = CreateFrame("FRAME")
fadingFunc:SetScript("OnUpdate", BaseFading)]]--

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                1     2  3  4  5    6      7                                                  8                                                       9          10           11         12        13				14
--modelData: { sceneID, x, y, z, o, scale, alpha, [{ enabled[,omni,dirX,dirY,dirZ,ambIntensity[,ambR,ambG,ambB[,dirIntensity[,dirR,dirG,dirB]]]] }], sequence, widthSquish, heightSquish, path [,referenceID] [,cameraModel] }
--[[ DOCUMENTATION:
	sceneID:			number	- on which scene it's supposed to show up
	x:					number	- moves the model left and right  \
	y:					number	- moves the model up and down	   |	if the model doesn't show up at all try moving it around sometimes it will show up | blue white box: wrong path | no texture: texture is set through dbc, needs to be hardcoded | green texture: no texture
	z:					number	- moves the model back and forth  /
	o:					number	- the orientation in which direction the model will face | number in radians | math.pi = 180° | math.pi * 2 = 360° | math.pi / 2 = 90°
	scale:				number	- used to scale the model | 1 = normal size | does not scale particles of flames for example on no camera models, use width/heightSquish for that
	alpha:				number  - opacity of the model | 1 = 100% , 0 = 0%
	light:				table	- table containing light data (look in light documentation for further explanation) | is optional
	sequence:			number	- the animation that should be played after the model is loaded
	widthSquish:		number	- squishes the model on the X axis | 1 = normal
	heightSquish:		number	- squishes the model on the Y axis | 1 = normal
	path:				String  - the path to the model ends with .mdx
	referenceID:		number  - mainly used for making changes while the scene is playing | example:
	
	local m = GetModel(1)	<- GetModel(referenceID) the [1] to use the first model with this referenceID without it it would be a table with all models inside
	if m then
		m = m[1]
		local x,y,z = m:GetPosition()
		m:SetPosition(x-0.1,y,z)				<- move the model -0.1 from it's current position on the x-axis
	end
	
	cameraModel:		String	- if a path to a model is set here, it will be used as the camera
]]
--[[ LIGHT:
	enabled:			number	- appears to be 1 for lit and 0 for unlit
    omni:				number	- ?? (default of 0)
    dirX, dirY, dirZ:	numbers	- vector from the origin to where the light source should face
    ambIntensity:		number	- intensity of the ambient component of the light source
    ambR, ambG, ambB:	numbers	- color of the ambient component of the light source
    dirIntensity:		number	- intensity of the direct component of the light source
    dirR, dirG, dirB:	numbers	- color of the direct component of the light source 
]]
--[[ METHODS:
	GetModelData(referenceID / sceneID, (bool) get-all-scene-models)	table									- gets the model data table out of ModelList (returns a table with all model datas that have the same referenceID) or if bool is true from the scene
	GetModel(referenceID / sceneID, (bool) get-all-scene-models)		table									- gets all models with the same referenceID or the same sceneID (if bool is true)
	SetScene(sceneID)													nil										- sets the current scene to the sceneID given to the function
	GetScene([sceneID])													sceneID, sceneData, models, modeldatas	- gets all information of the current scene [of the sceneID]

	some helpful globals:
	ModelList.sceneCount	number	- the count of how many scenes exist
	ModelList.modelCount	number	- the count of how many models exist
]]
--[[ CREDITS:
	Made by Mordred P.H.
	
	Thanks to:
	Soldan - helping me with all the model work
	Chase - finding a method to copy cameras on the fly
	Stoneharry - bringing me to the conclusion that blizzard frames are never fullscreen, so it works with every resolution
	Blizzard - for making it almost impossible to make it work properly
]]
-------------------------------------------------------------------------
--                   1                2
--sceneData: {time_in_seconds, background_path}   --> (index is scene id)
local mainlight_2 = {
1, --	enabled:			number	- appears to be 1 for lit and 0 for unlit
0, --    omni:				number	- ?? (default of 0)
0, --    dirX, 
-0.707, --    dirY, 
-0.707, --    dirZ:	numbers	- vector from the origin to where the light source should face
0.8,--    ambIntensity:		number	- intensity of the ambient component of the light source
0.6,--    ambR, 
0.8,--    ambG, 
1.0, --    ambB:	numbers	- color of the ambient component of the light source
1.0,--    dirIntensity:		number	- intensity of the direct component of the light source
0.6, --    dirR, 
0.8,--    dirG, 
0.0--    dirB:	numbers	- color of the direct component of the light source 
}
local fireflieslight = {1, 0, 0, -0.707, -0.707, 0.7, 0.0,1.0, 1.0, 1.0, 0.8, 1.0}

ModelList = {
	max_scenes = 1,			-- number of scenes you use to shuffle through
	fade_duration = 3,		-- fade animation duration in seconds (to next scene if more than 1 exists)
	sceneData = {
		{1800,"Interface\\GLUES\\Loadingscreens\\Background.blp"},
	},

	-- Scene: 1
	{1, -0.372, 3.145, -5.985, 1.184, 0.085, 1.000, mainlight, 1, 1, 1, "Environments\\Stars\\skywallskybox.m2", _, _},
	{1, -0.712, 0.499, 0.000, 6.245, 0.047, 1.000, mainlight, 1, 1, 1, "Environments\\Stars\\auroraorange.m2", _, _},
	{1, -0.318, 0.932, 0.000, 0.000, 0.255, 0.333, mainlight, 1, 1, 1, "World\\Kalimdor\\silithus\\passivedoodads\\ahnqirajglow\\quirajglow.m2", _, _},
	{1, 0.282, 0.932, 0.000, 0.000, 0.255, 0.329, mainlight, 1, 1, 1, "World\\Kalimdor\\silithus\\passivedoodads\\ahnqirajglow\\quirajglow.m2", _, _},
	{1, -0.894, 1.105, 0.000, 0.000, 0.017, 0.722, mainlight, 1, 1, 1, "World\\Expansion02\\doodads\\howlingfjord\\firefx\\burntstonetreesmoke_vfx.m2", _, _},
		{1, -0.016, 1.165, 0.000, 1.764, 0.022, 0.569, mainlight_2, 1, 1, 1, "World\\Critter\\birds\\birds_condor_01.m2", _, _},
	{1, -0.819, 1.149, 0.000, 3.910, 0.011, 0.702, mainlight, 1, 1, 1, "World\\Expansion02\\doodads\\howlingfjord\\firefx\\burntstonetreesmoke_vfx.m2", _, _},
	{1, 0.982, 1.532, 0.000, 0.000, 0.255, 0.557, mainlight, 1, 1, 1, "World\\Kalimdor\\silithus\\passivedoodads\\ahnqirajglow\\quirajglow.m2", _, _},
	{1, 0.913, 1.714, 0.000, 0.000, 0.040, 0.718, mainlight_2, 1, 1, 1, "World\\Critter\\birds\\birds_condor_01.m2", _, _},
	{1, -0.501, 1.572, 0.000, 3.407, 0.040, 0.718, mainlight_2, 1, 1, 1, "World\\Critter\\birds\\birds_condor_01.m2", _, _},
	{1, 1.887, 1.079, 0.000, 5.194, 0.037, 0.122, mainlight, 1, 1, 1, "World\\Expansion03\\doodads\\uldum\\blowingsand\\uldum_blowing_sand_particle_01.m2", _, _},
	{1, 0.187, 0.879, 0.000, 5.194, 0.037, 0.122, mainlight, 1, 1, 1, "World\\Expansion03\\doodads\\uldum\\blowingsand\\uldum_blowing_sand_particle_01.m2", _, _},
	{1, -0.051, 0.660, 0.000, 5.851, 0.049, 0.075, mainlight, 1, 1, 1, "World\\Expansion03\\doodads\\uldum\\blowingsand\\uldum_blowing_sand_particle_01.m2", _, _},
	{1, 0.436, 0.826, 0.000, 5.604, 0.027, 0.122, mainlight, 1, 1, 1, "World\\Expansion03\\doodads\\uldum\\blowingsand\\uldum_blowing_sand_particle_01.m2", _, _},
	{1, 0.580, 1.046, 0.000, 5.672, 0.031, 0.153, mainlight, 1, 1, 1, "World\\Expansion03\\doodads\\uldum\\blowingsand\\uldum_blowing_sand_particle_01.m2", _, _},
	{1, -0.720, 0.900, 0.000, 5.593, 0.040, 0.059, mainlight, 1, 1, 1, "World\\Expansion03\\doodads\\uldum\\blowingsand\\uldum_blowing_sand_particle_01.m2", _, _},
	{1, 1.356, 1.086, 0.000, 5.387, 0.037, 0.118, mainlight, 1, 1, 1, "World\\Expansion03\\doodads\\uldum\\blowingsand\\uldum_blowing_sand_particle_01.m2", _, _},
	{1, 0.979, 0.673, 0.000, 3.910, 0.123, 0.620, mainlight, 97, 1, 1, "Creature\\Raven\\raven.m2", _, _},
	{1, 1.137, 0.714, 0.000, 2.635, 0.128, 0.765, mainlight, 97, 1, 1, "Creature\\Raven\\raven.m2", _, _},
	{1, -0.842, 0.403, 0.000, 2.773, 0.221, 0.855, mainlight, 97, 1, 1, "Creature\\Raven\\raven.m2", _, _},
	{1, 0.803, 1.205, 0.000, 5.610, 0.044, 0.373, mainlight, 97, 1, 1, "Creature\\Raven\\raven.m2", _, _},
	{1, 0.887, 1.218, 0.000, 0.304, 0.030, 0.514, mainlight, 97, 1, 1, "Creature\\Raven\\raven.m2", _, _},
	{1, 1.404, 0.054, 0.000, 1.188, 0.460, 1.000, mainlight_2, 1, 1, 1, "World\\Expansion06\\doodads\\highmountain\\7hm_bush_a02.m2", _, _},
	{1, -1.512, -0.108, 0.000, 0.432, 0.568, 1.000, mainlight_2, 1, 1, 1, "World\\Expansion06\\doodads\\highmountain\\7hm_bush_a02.m2", _, _},
	{1, 1.566, 0.917, 0.000, 5.920, 0.120, 0.404, mainlight, 1, 1, 1, "World\\Dungeon\\shadowpanhideout\\pa_shadowpan_lightrays.m2", _, _},
	{1, 1.313, -0.809, 0.000, 0.000, 0.036, 0.902, mainlight, 1, 1, 1, "World\\Generic\\human\\passive doodads\\fog\\sfx_fog_nasty_pink.m2", _, _},
	{1, -1.309, -0.464, 0.000, 0.000, 0.020, 1.000, mainlight, 1, 1, 1, "World\\Generic\\human\\passive doodads\\fog\\sfx_fog_nasty_pink.m2", _, _},
	{1, 3.633, 4.158, 0.000, 4.620, -0.630, 1.000, mainlight, 1, 1, 1, "World\\Dungeon\\shadowpanhideout\\pa_shadowpan_lightrays.m2", _, _},
	{1, 2.279, 0.848, 0.000, 0.053, 0.149, 1.000, mainlight, 1, 1, 1, "World\\Dungeon\\shadowpanhideout\\pa_shadowpan_lightrays.m2", _, _},
	--{1, 0.677, 0.534, 0.074, 1.950, 0.277, 0.569, mainlight_2, 1, 1, 1, "World\\Expansion06\\doodads\\highmountain\\7hm_bush_a02.m2", _, _},
	{1, -0.828, 0.396, 0.074, 2.308, 0.256, 0.569, mainlight_2, 1, 1, 1, "World\\Expansion06\\doodads\\highmountain\\7hm_bush_a02.m2", _, _},
	--{1, 0.591, 0.519, 0.000, 3.482, 0.225, 0.824, mainlight, 97, 1, 1, "Creature\\Epicdruidflighthorde\\epicdruidflighthorde.m2", _, _},
	--{1, 0.495, 0.531, 0.074, 4.322, 0.146, 0.816, mainlight_2, 1, 1, 1, "World\\Expansion06\\doodads\\highmountain\\7hm_bush_a02.m2", _, _},
	{1, -0.384, 0.650, 0.000, 1.219, 0.009, 1.000, mainlight, 1, 1, 1, "World\\Generic\\human\\passive doodads\\fog\\sfx_fog_thick_brown.m2", _, _},
	{1, 0.272, 0.714, 0.000, 6.079, 0.007, 0.965, mainlight, 1, 1, 1, "World\\Generic\\human\\passive doodads\\fog\\sfx_fog_thick_brown.m2", _, _},
	{1, -1.585, 0.725, 0.000, 6.122, 0.008, 0.506, mainlight, 1, 1, 1, "World\\Generic\\human\\passive doodads\\fog\\sfx_fog_thick_brown.m2", _, _},
	{1, -0.994, 0.497, 0.000, 0.000, 0.006, 0.882, mainlight, 1, 1, 1, "World\\Generic\\human\\passive doodads\\fog\\sfx_fog_thick_brown.m2", _, _},
	{1, -1.562, 0.497, 0.000, 5.289, 0.006, 0.702, mainlight, 1, 1, 1, "World\\Generic\\human\\passive doodads\\fog\\sfx_fog_thick_brown.m2", _, _},
	{1, 1.278, 0.600, 0.000, 0.000, 0.006, 0.922, mainlight, 1, 1, 1, "World\\Generic\\human\\passive doodads\\fog\\sfx_fog_thick_brown.m2", _, _},
	{1, -0.036, 0.430, 0.000, 0.038, 0.010, 1.000, mainlight, 1, 1, 1, "World\\Generic\\human\\passive doodads\\fog\\sfx_fog_thick_brown.m2", _, _},
	{1, -1.285, 0.241, 0.000, 6.187, 0.010, 0.451, mainlight, 1, 1, 1, "World\\Generic\\human\\passive doodads\\fog\\sfx_fog_thick_brown.m2", _, _},
	{1, 1.626, 0.987, 0.000, 0.000, 0.008, 1.000, mainlight, 1, 1, 1, "World\\Generic\\human\\passive doodads\\fog\\sfx_fog_thick_brown.m2", _, _},
	{1, 1.404, 1.692, 0.000, 0.000, 0.280, 0.569, mainlight, 1, 1, 1, "World\\Kalimdor\\silithus\\passivedoodads\\ahnqirajglow\\quirajglow.m2", _, _},
}

local use_random_starting_scene = true														-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
local shuffle_scenes_randomly = false														-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID

local login_music_path = {
"Interface/GlueXML/Nightwish-Nemo.mp3",		-- path to the music
}
local login_music_time_in_seconds = 30												-- minutes * 60 + seconds

----------------------------------------------------------------------------- end of configuration part ----------------------------------------------------------------------------------------------
local width, height = GlueParent:GetSize()
current_scene = 1

function randomScene()
	return (time() % ModelList.max_scenes) + 1
end
if use_random_starting_scene then
	current_scene = randomScene()
end

PlayMusic(login_music_path[current_scene])

-- main frame for displaying and positioning of the whole loginscreen
LoginScene = CreateFrame("Frame",nil,AccountLogin)
	LoginScene:SetSize(width, (width/16)*9)
	LoginScene:SetPoint("CENTER", AccountLogin, "CENTER", 0,0)
	LoginScene:SetFrameStrata("LOW")

-- main background that changes according to the scene
LoginScreenBackground = LoginScene:CreateTexture(nil,"LOW")
	LoginScreenBackground:SetPoint("TOPRIGHT", LoginScene, "TOPRIGHT", 0, 125)
	LoginScreenBackground:SetPoint("BOTTOMLEFT", LoginScene, "BOTTOMLEFT", -1, -125)

LoginScreenBlackBoarderTOP = AccountLogin:CreateTexture(nil,"OVERLAY")
	LoginScreenBlackBoarderTOP:SetTexture(0,0,0,1)
	LoginScreenBlackBoarderTOP:SetHeight(500)
	LoginScreenBlackBoarderTOP:SetPoint("BOTTOMLEFT", LoginScene, "TOPLEFT", 0,0)
	LoginScreenBlackBoarderTOP:SetPoint("BOTTOMRIGHT", LoginScene, "TOPRIGHT", 0,0)

LoginScreenBlackBoarderBOTTOM = AccountLogin:CreateTexture(nil,"OVERLAY")
	LoginScreenBlackBoarderBOTTOM:SetTexture(0,0,0,1)
	LoginScreenBlackBoarderBOTTOM:SetHeight(500)
	LoginScreenBlackBoarderBOTTOM:SetPoint("TOPLEFT", LoginScene, "BOTTOMLEFT", 0,0)
	LoginScreenBlackBoarderBOTTOM:SetPoint("TOPRIGHT", LoginScene, "BOTTOMRIGHT", 0,0)

LoginScreenBlend = AccountLogin:CreateTexture(nil,"OVERLAY")
	LoginScreenBlend:SetTexture(0,0,0,1)
	LoginScreenBlend:SetHeight(500)
	LoginScreenBlend:SetAlpha(1)
	LoginScreenBlend:SetAllPoints(GlueParent)

M = {}
function newScene()	-- creates a scene object that gets used internaly
	local s = {parent = CreateFrame("Frame",nil,LoginScene),
				background = ModelList.sceneData[#M+1 or 1][2],
				duration = ModelList.sceneData[#M+1 or 1][1]}
	s.parent:SetSize(LoginScene:GetWidth(), LoginScene:GetHeight())
	s.parent:SetPoint("CENTER")
	s.parent:SetFrameStrata("MEDIUM")
	table.insert(M, s)
	return s
end

function newModel(parent,alpha,light,wSquish,hSquish,camera)	-- creates a new model object that gets used internally but also can be altered after loading
	local mod = CreateFrame("Model",nil,parent)
	light = light or {1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8}
	mod:SetModel(camera or "Character/Human/Male/HumanMale.mdx")
	mod:SetSize(LoginScene:GetWidth() / wSquish, LoginScene:GetHeight() / hSquish)
	mod:SetPoint("CENTER")
	mod:SetCamera(1)
	mod:SetLight(unpack(light))
	mod:SetAlpha(alpha)
	
	return mod
end

function Generate_M()	-- starts the routine for loading all models and scenes
	ModelList.sceneCount = #ModelList.sceneData
	
	local counter = 0
	for i=1, ModelList.sceneCount do
		local s = newScene()
		
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == i then
					table.insert(s, num, newModel(s.parent, m[7], m[8], m[10], m[11], m[14]))
					counter = counter + 1
					ModelList.lastModelNum = num
				end
			end
		end
		
		s.parent:Hide()
		if i == current_scene then
			LoginScreenBackground:SetTexture(s.background)
		end
	end
	ModelList.modelCount = counter
end
Generate_M()

------- updating and methods

local nextC, nextCset, blend_start
timed_update, blend_timer, music_timer = 0, 0, 0
function LoginScreen_OnUpdate(self,dt)
	--if ServerAlertFrame:IsVisible() then ServerAlertFrame:Hide() end
	if (music_timer == login_music_time_in_seconds) then		-- Music timer to loop the background music
		StopMusic()
		elseif music_timer > login_music_time_in_seconds+3 then
					PlayMusic(login_music_path[current_scene])
					music_timer = 0
	else
		music_timer = music_timer + dt
	end
	
	if blend_start then				-- Start blend after the loginscreen loaded to hide the setting up frame
		if blend_start < 0.5 then
			LoginScreenBlend:SetAlpha( 1 - blend_start*2 )
			blend_start = blend_start + dt
		else
			LoginScreenBlend:SetAlpha(0)
			blend_start = false
		end
	end
	
	if timed_update and timed_update > 5 then		-- frame delayed update to hackfix some errors with blizzard masterrace code
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" and m[1] <= ModelList.max_scenes then
				local mod = M[m[1]][num]
				--for emeralddream
				if ((m[12] == "Environments\\Stars\\skywallskybox.m2")
				 or (m[12] == "Environments\\Stars\\auroraorange.m2")
				  or (m[12] == "World\\Expansion06\\doodads\\valsharah\\7vs_tree_ancient_c01_dark.m2")
				   or (m[12] == "Environments\\Stars\\rubysanctumsky.m2")
				    or (m[12] == "Environments\\Stars\\icecrownstarrysky.m2"))
					then 
					mod:SetFrameStrata("BACKGROUND")
				end
				--end for emeralddream
				mod:SetModel(m[12])
				mod:SetPosition(m[4], m[2], m[3])
				mod:SetFacing(m[5])
				mod:SetModelScale(m[6])
				mod:SetSequence(m[9])
			end
		end
		
		blend_start = 0
		timed_update = false
		
		M[current_scene].parent:Show()
		Scene_OnStart(current_scene)
	elseif timed_update then
		timed_update = timed_update + 1
	end
	
	local cur = M[current_scene]
	
	if cur.duration < blend_timer then		-- Scene and blend timer for next scene and blends between the scenes
		if ModelList.max_scenes > 1 then
			local blend = blend_timer - cur.duration
			if blend < ModelList.fade_duration then
				LoginScreenBlend:SetAlpha( 1 - math.abs( 1 - (blend*2 / ModelList.fade_duration) ) )
				
				if blend*2 > ModelList.fade_duration and not nextCset then
					nextC = randomScene()
					if shuffle_scenes_randomly then
						if current_scene == nextC then
							nextC = ((current_scene+1 > ModelList.max_scenes) and 1) or current_scene + 1
						end
					else
						nextC = ((current_scene+1 > ModelList.max_scenes) and 1) or current_scene + 1
					end
					nextCset = true

					local new = M[nextC]
					cur.parent:Hide()
					new.parent:Show()
					LoginScreenBackground:SetTexture(new.background)
					Scene_OnEnd(current_scene)
					Scene_OnStart(nextC)
					StopMusic()
					PlayMusic(login_music_path[nextC])
				end
				
				blend_timer = blend_timer + dt
			else
				current_scene = nextC
				nextCset = false
				blend_timer = 0
				LoginScreenBlend:SetAlpha(0)
			end
		else
			blend_timer = 0
			Scene_OnEnd(current_scene)
			Scene_OnStart(current_scene)
		end
	else
		blend_timer = blend_timer + dt
	end
	
	SceneUpdate(dt, current_scene, blend_timer, ModelList.sceneData[current_scene][1])
end

function SetScene(sceneID)
	M[current_scene].parent:Hide()
	M[sceneID].parent:Show()
	LoginScreenBackground:SetTexture(M[sceneID].background)
	Scene_OnEnd(current_scene)
	Scene_OnStart(sceneID)
	current_scene = sceneID
end

function GetScene(sceneID)
	local curScene = current_scene
	if sceneID then
		if sceneID <= ModelList.max_scenes and sceneID > 0 then
			curScene = sceneID
		end
	end
	return curScene, ModelList.sceneData[curScene], GetModel(curScene, true), GetModelData(curScene, true)
end

function GetModelData(refID, allSceneModels)
	local data, count = {}, 0
	if allSceneModels then
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == refID then
					table.insert(data, num, m)
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	else
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[13] == refID then
					table.insert(data, num, m)
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	end
end

function GetModel(refID, allSceneModels)
	local data, count = {} ,0
	if allSceneModels then
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == refID then
					table.insert(data, num, M[m[1]][num])
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	else
		local mData = GetModelData(refID)
		if mData then
			for num, m in pairs(mData) do
				table.insert(data, num, M[m[1]][num])
				count = count + 1
			end
			return (count > 0 and data) or false
		else
			return false
		end
	end
end

------------------------------------------------------------------------------------------------------
------									SCENE SCRIPTING PART									------
------------------------------------------------------------------------------------------------------

-- update function that gets called each frame
local anim = false
function SceneUpdate(dt, sceneID, timer, sceneTime)
	-- Scene scripts that need updates each frame (moving a model for example) go in here.
end

-- on end function that gets called when the scene ends
function Scene_OnEnd(sceneID)
	-- Scene scripts that need an update at the end of a scene (resetting the position of a moving model for example) go in here.
end

-- on start function that gets called when the scene starts
function Scene_OnStart(sceneID)
	-- Scene scripts that need an update at the start of a scene (one time spell visual for example) go in here.
end



local AccountLogin_SocialMeda_FaceBook = CreateFrame("Button", "AccountLogin_SocialMeda_FaceBook", AccountLogin, nil)
AccountLogin_SocialMeda_FaceBook:SetSize(50, 50)
AccountLogin_SocialMeda_FaceBook:SetPoint("CENTER", AccountLoginLogo, -90, -50)
AccountLogin_SocialMeda_FaceBook:EnableMouse(true)
AccountLogin_SocialMeda_FaceBook:SetNormalTexture("Interface\\GLUES\\COMMON\\FbookIcon")
AccountLogin_SocialMeda_FaceBook:SetHighlightTexture("Interface\\GLUES\\COMMON\\FbookIcon_h")
AccountLogin_SocialMeda_FaceBook:SetScript("OnClick", function()
	PlaySound("gsLoginNewAccount");
	LaunchURL("https://www.facebook.com/Ascensionfeed/?fref=nf");
	end)

local AccountLogin_SocialMeda_Twitter = CreateFrame("Button", "AccountLogin_SocialMeda_Twitter", AccountLogin, nil)
AccountLogin_SocialMeda_Twitter:SetSize(50, 50)
AccountLogin_SocialMeda_Twitter:SetPoint("CENTER", AccountLoginLogo, -30, -50)
AccountLogin_SocialMeda_Twitter:EnableMouse(true)
AccountLogin_SocialMeda_Twitter:SetNormalTexture("Interface\\GLUES\\COMMON\\TwIcon")
AccountLogin_SocialMeda_Twitter:SetHighlightTexture("Interface\\GLUES\\COMMON\\TwIcon_h")
AccountLogin_SocialMeda_Twitter:SetScript("OnClick", function()
	PlaySound("gsLoginNewAccount");
	LaunchURL("https://twitter.com/Ascensionfeed");
	end)

local AccountLogin_SocialMeda_YouTube = CreateFrame("Button", "AccountLogin_SocialMeda_YouTube", AccountLogin, nil)
AccountLogin_SocialMeda_YouTube:SetSize(50, 50)
AccountLogin_SocialMeda_YouTube:SetPoint("CENTER", AccountLoginLogo, 30, -50)
AccountLogin_SocialMeda_YouTube:EnableMouse(true)
AccountLogin_SocialMeda_YouTube:SetNormalTexture("Interface\\GLUES\\COMMON\\YTubeIcon")
AccountLogin_SocialMeda_YouTube:SetHighlightTexture("Interface\\GLUES\\COMMON\\YTubeIcon_h")
AccountLogin_SocialMeda_YouTube:SetScript("OnClick", function()
	PlaySound("gsLoginNewAccount");
	LaunchURL("https://youtu.be/lQUGQEcDF3o"); 
	end)

local AccountLogin_SocialMeda_Discord = CreateFrame("Button", "AccountLogin_SocialMeda_Discord", AccountLogin, nil)
AccountLogin_SocialMeda_Discord:SetSize(45, 45)
AccountLogin_SocialMeda_Discord:SetPoint("CENTER", AccountLoginLogo, 90, -50)
AccountLogin_SocialMeda_Discord:EnableMouse(true)
AccountLogin_SocialMeda_Discord:SetNormalTexture("Interface\\GLUES\\COMMON\\DiscordIcon")
AccountLogin_SocialMeda_Discord:SetHighlightTexture("Interface\\GLUES\\COMMON\\DiscordIcon_h")
AccountLogin_SocialMeda_Discord:SetScript("OnClick", function()
	PlaySound("gsLoginNewAccount");
	LaunchURL("https://discord.gg/bEfV3M5"); 
	end)