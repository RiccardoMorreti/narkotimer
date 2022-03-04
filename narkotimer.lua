require 'lib.moonloader'
require "lib.sampfuncs"
local inicfg = require 'inicfg'
local sampev = require "lib.samp.events"
local directIni = "NarkoTimer.ini"
local mainIni = inicfg.load({settings = {
	timer = 60,
	sbiv = 0, -- in seconds
	lomka = 1,
	posX = 15.0,
	posY = 150.0,
}}, directIni)

local hasuse = 0
local timer = 0
local editInfo = false

local font_flag = require('moonloader').font_flag

local fonts = renderCreateFont('Arial', 13, font_flag.BOLD + font_flag.SHADOW) --(название шрифта, размер шрифта, флаги[жирный и т.д.])

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	if not doesFileExist(directIni) then inicfg.save(mainIni, directIni) end
	if mainIni.settings.posX == nil then
		mainIni.settings.posX = 15.0
		inicfg.save(mainIni, directIni)
	end
	if mainIni.settings.posY == nil then
		mainIni.settings.posY = 150.0
		inicfg.save(mainIni, directIni)
	end
	sampAddChatMessage(" NarkoTimer by morreti loaded", 0xFFFFFF)
	
	sampRegisterChatCommand("nmove", function()
		if editInfo == false then
			editInfo = true
			sampAddChatMessage(" [NarkoTimer] {FFFFFF}Нажмите LMB(ЛКМ) для применения новых координат", 0x00FF00)
			sampAddChatMessage(" [NarkoTimer] {FFFFFF}Нажмите RMB(ПКМ) для отмены редактирования", 0x00FF00)
			sampSetCursorMode(CMODE_LOCKCAM)
			showCursor(true, true)
		else
			editInfo = false
			sampSetCursorMode(0)
			showCursor(false, false)
		end
	end)
	sampRegisterChatCommand("ntime", function(i)
		local timeL = string.match(i, '(%d+)')
		if timeL == nil then sampAddChatMessage(" Введите: /ntime [секунды]", -1) return end
		mainIni.settings.timer = timeL
		sampAddChatMessage(" Количество секунд отсчета установлено на ".. timeL .. "", -1)
		inicfg.save(mainIni, directIni)
	end)
	sampRegisterChatCommand("nlomka", function()
		mainIni.settings.lomka = not mainIni.settings.lomka
		if mainIni.settings.lomka then sampAddChatMessage(" Автопринятие нарко при ломке включено", -1)
		else sampAddChatMessage(" Автопринятие нарко при ломке выключено", -1) end
		inicfg.save(mainIni, directIni)
	end)
	sampRegisterChatCommand("nsbiv", function()
		mainIni.settings.sbiv = not mainIni.settings.sbiv
		if mainIni.settings.sbiv then sampAddChatMessage(" Автосбив нарко включено", -1)
		else sampAddChatMessage(" Автосбив нарко выключено", -1) end
		inicfg.save(mainIni, directIni)
	end)
	
	while true do
		if isKeyJustPressed(1) then
			if editInfo == true then
				editInfo = false
				sampSetCursorMode(0)
				local posX, posY = getCursorPos()
				mainIni.settings.posX = posX
				mainIni.settings.posY = posY
				inicfg.save(mainIni, directIni)
				showCursor(false, false)
				sampAddChatMessage(" [NarkoTimer] {FFFFFF}Координаты инфо-бара сохранены", 0x00FF00)
			end
		end
		if isKeyJustPressed(2) then
			if editInfo == true then
				editInfo = false
				sampSetCursorMode(0)
				showCursor(false, false)
				sampAddChatMessage(" [NarkoTimer] {FFFFFF}Режим редактирования инфо-бара отключен", 0x00FF00)
			end
		end
        wait(0)
		local oTime = os.time()
		if timer >= oTime then
			if editInfo == true then
				local posX, posY = getCursorPos()
				renderFontDrawText(fonts, string.format('Осталось %d секунд', timer-oTime), posX, posY, 0xFFFFFFFF)
			else
				renderFontDrawText(fonts, string.format('Осталось %d секунд', timer-oTime), mainIni.settings.posX, mainIni.settings.posY, 0xFFFFFFFF)
			end
		else
			if editInfo == true then
				local posX, posY = getCursorPos()
				renderFontDrawText(fonts, string.format('{00FF00}Можно юзать'), posX, posY, 0xFFFFFFFF)
			else
				renderFontDrawText(fonts, string.format('{00FF00}Можно юзать'), mainIni.settings.posX, mainIni.settings.posY, 0xFFFFFFFF)
			end
			hasuse = 0
			timer = 0
		end
		
		if testCheat('x') and not sampIsCursorActive() and hasuse == 0 then
			sampSendChat('/usedrugs')
			if mainIni.settings.sbiv and not isCharInAnyCar(PLAYER_PED) then
				sampSetSpecialAction(68)
				wait(100)
				setVirtualKeyDown(13, true)
				wait(50)
				setVirtualKeyDown(13, false)
			end
		end
        if testCheat('p') and not sampIsCursorActive() then
            sampSetSpecialAction(68)
			wait(100)
			setVirtualKeyDown(13, true)
			wait(50)
			setVirtualKeyDown(13, false)
		end
	end
end

function onScriptTerminate(script, quitGame)
    if thisScript() == script then
		inicfg.save(mainIni, directIni)
    end
end

function sampev.onServerMessage(color, text)
	if string.find(text, "~~~~~~~~ У вас началась ломка ~~~~~~~~") and mainIni.settings.lomka == 1 then 
		sampSendChat('/usedrugs')
		if mainIni.settings.sbiv and not isCharInAnyCar(PLAYER_PED) then
			sampSetSpecialAction(68)
			wait(100)
			setVirtualKeyDown(13, true)
			wait(50)
			setVirtualKeyDown(13, false)
		end
		if timer == 0 then
			hasuse = 1
			timer = os.time() + mainIni.settings.timer
		end
	end
	if text:find(" %(%( Остаток%: (%d+) грамм %)%)") then
		hasuse = 1
		timer = os.time() + mainIni.settings.timer
	end
end