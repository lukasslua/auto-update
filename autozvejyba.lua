local hook = require ('samp.events')
local requests = require('requests')
local akasti = false
script_name("Auto Zvejyba")
script_author("Lolikas DC - Lukass#0820")

local imgui = require 'imgui'
local encoding = require 'encoding'
local inicfg = require 'inicfg'
local mod = import 'notifications.lua'
encoding.default = "CP1251"
u8 = encoding.UTF8
local script = imgui.ImBool(false)
local timer1 = imgui.ImInt(0)
local timer2 = imgui.ImInt(0)
local main_window_state = imgui.ImBool(false)

script_version '1'
local dlstatus = require "moonloader".download_status

local mainIni = inicfg.load({
    config =
    {
        script = false,
        sell = false,
        paleidziu = false,
        fix1 = false,
        timer1 = 30,
        timer2 = 30
    }
}, "autozvejyba")

local script = imgui.ImBool(mainIni.config.script)
local sell = imgui.ImBool(mainIni.config.sell)
local paleidziu = imgui.ImBool(mainIni.config.paleidziu)
local fix1 = imgui.ImBool(mainIni.config.fix1)
local timer1 = imgui.ImInt(mainIni.config.timer1)
local timer2 = imgui.ImInt(mainIni.config.timer2)

local status = inicfg.load(mainIni, 'autozvejyba.ini')
if not doesFileExist('moonloader/config/autozvejyba.ini') then inicfg.save(mainIni, 'autozvejyba.ini') end

function imgui.OnDrawFrame()
  if main_window_state.v then
    local wPosX, wPosY = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(wPosX / 2 , wPosY / 2), 2, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(370, 160), 2)
    imgui.Begin('AUTO ZVEJYBA BY Lolikas (DC - Lukass#0820) Versija 1.2', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
    imgui.SliderInt("Laikas 1", timer1, 0, 30)
    imgui.Hint("Delay tarp /zvejoti komandu sekundemis")
    imgui.SliderInt("Laikas 2", timer2, 1, 30)
    imgui.Hint("Delay po pardavimo ir komandos /zvejoti parasymo. Patartina ne maziau 1sec")
    imgui.Checkbox('Aktyvacija', script)
    imgui.Hint('Scripto aktyvacija.')
	imgui.SameLine()
    imgui.Checkbox('Pardavimas', sell)
	imgui.Hint("Automatiskas pardavimas, galima gaut bana jeigu uzgaudo.")
    imgui.SameLine()
    imgui.Checkbox('Zuvu paleidimas', paleidziu)
	imgui.Hint("Automatiskas zuvu paleidimas, naudot tik norint pasikelt lvl ir negaut bano.")
	imgui.Checkbox('/pt Fix', fix1)
	imgui.Hint("Pd/Swat/Ftb /pt fixas")
    if imgui.Button("Issaugoti", imgui.ImVec2(130, 23)) then
            mainIni.config.timer1 = timer1.v
            mainIni.config.timer2 = timer2.v
            inicfg.save(mainIni, 'autozvejyba.ini')
            mod.addNotification('{1e90ff}Nustatymai issaugoti sekmingai', 3)
        end
    end
    imgui.End()
  end

function main()
  repeat wait(0) until isSampAvailable()
  sampRegisterChatCommand('silke',function()
    main_window_state.v = not main_window_state.v
  end)
  while true do
    wait(0)
    imgui.Process = main_window_state.v
        if akasti and script.v then
        wait(timer1.v * 1000)
        sampSendChat("/zvejoti")
        akasti = false
    end
end
end

function hook.onServerMessage(color,text)
    if text:find("Pagavote") or text:find("Pagavai") and script.v then
        akasti = true
    end
    if text:find("jau turite daug") and script.v and sell.v then
        sampSendPickedUpPickup()
    end
    if text:find("jau turite daug") and script.v and paleidziu.v then
		lua_thread.create(function()
		wait(timer2.v * 1000)
        sampSendChat("/p")
		end)
    end
end


function hook.onShowDialog(id, style, title, button1, button2, text)
    if script.v and sell.v and id == 102 and text:find("Jeigu norite parduoti savo") then
        lua_thread.create(function()
            sampSendDialogResponse(102, 1, nil, nil)
            wait(timer2.v * 1000)
            akasti = true
        end)
        return false;
    end
    if script.v and paleidziu.v and id == 318 then
        lua_thread.create(function()
            sampSendDialogResponse(318, 1, 4, -1)
            sampSendDialogResponse(336, 1, 8, -1)
            sampSendDialogResponse(373, 0, -1, -1)
			wait(200)
			sampCloseCurrentDialogWithButton(2)
			wait(timer2.v * 1000)
			akasti = true
        end)
    return false;
    end
	if fix1.v and id == 93 and script.v and sell.v then
		sampSendDialogResponse(93, 0, nil, nil)
	return false;
		end
end
function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowRounding = 4.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 8.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 8.0
    colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
apply_custom_style()

function imgui.Hint(text)
    imgui.SameLine()
    imgui.TextDisabled("(!)")
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.TextUnformatted(u8(text))
        imgui.EndTooltip()
    end
end

