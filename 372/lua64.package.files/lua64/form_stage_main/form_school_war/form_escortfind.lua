require("util_functions")
require("util_gui")
require("define\\gamehand_type")
local escort_list_length = 4
function main_form_init(form)
  form.Fixed = false
  nx_execute("util_functions", "get_ini", "share\\War\\escort_path.ini")
  local gui = nx_value("gui")
  form.teamid = 0
  form.pathnum = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = 50
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_path_click(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital = client_player:QueryProp("CapitalType1") + client_player:QueryProp("CapitalType2")
  for i = 1, nx_number(pathnum) do
    local pathgroupbox = form.groupscrollpathbox_desc:Find("groupbox_path_" .. i)
    if nx_is_valid(pathgroupbox) then
      local pathbtn = pathgroupbox:Find("btn_path_" .. i)
      if nx_is_valid(pathbtn) then
      end
    end
  end
  form.teamid = btn.teamid
end
function clear_info(form)
  form.groupscrollpathbox_desc:DeleteAll()
end
function on_btn_escort_click(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital = client_player:QueryProp("CapitalType1") + client_player:QueryProp("CapitalType2")
  if capital < 500 then
    return false
  end
  nx_execute("custom_sender", "custom_get_escort_info", form.teamid)
  return true
end
function on_tree_job_select_changed(self)
end
function on_imagegrid_mousein_grid(grid, index)
end
function on_imagegrid_mouseout_grid(grid, index)
end
function on_imagegrid_select_changed(grid, index)
end
function on_imagegrid_rightclick_grid(grid, index)
end
function ClosetForm()
  local form = util_get_form("form_stage_main\\form_school_war\\form_escortfind", true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function OnEscortListMsg(...)
  local form = util_get_form("form_stage_main\\form_school_war\\form_escortfind", true)
  if not nx_is_valid(form) then
    return
  end
  clear_info(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital = client_player:QueryProp("CapitalType1") + client_player:QueryProp("CapitalType2")
  local formula_path = nx_execute("util_functions", "get_ini", "share\\War\\escort_path.ini")
  if not nx_is_valid(formula_path) then
    return
  end
  form.pathnum = nx_number(arg[1])
  form.groupscrollpathbox_desc.IsEditMode = true
  form.groupscrollpathbox_desc:DeleteAll()
  local group_top = 0
  for i = 1, form.pathnum do
    local teamid = arg[2]
    local playername = arg[3]
    local GuildName = arg[4]
    local TeamCount = arg[5]
    local path_id = arg[6]
    local path_index = formula_path:FindSectionIndex(nx_string(path_id))
    local Difficult = -1
    local TimeLimit = -1
    local GoodsNum = -1
    local Endscene = -1
    local Endpos = -1
    local EndText = ""
    if 0 <= path_index then
      Difficult = formula_path:ReadInteger(path_index, "Difficult", 0)
      TimeLimit = formula_path:ReadInteger(path_index, "TimeLimit", 0)
      GoodsNum = formula_path:ReadInteger(path_index, "GoodsNum", 0)
      Endscene = formula_path:ReadInteger(path_index, "Endscene", 0)
      Endpos = formula_path:ReadInteger(path_index, "Endpos", 0)
      EndText = formula_path:ReadString(path_index, "desc", "")
    end
    local groupbox = gui:Create("GroupBox")
    form.groupscrollpathbox_desc:Add(groupbox)
    groupbox.AutoSize = false
    groupbox.Name = "groupbox_path_" .. nx_string(i)
    groupbox.BackColor = "0,0,0,0"
    groupbox.NoFrame = true
    groupbox.Left = 0
    groupbox.Top = group_top
    groupbox.Width = 250
    groupbox.Height = 90
    local btn = gui:Create("Button")
    groupbox:Add(btn)
    btn.Name = "btn_path_" .. nx_string(i)
    btn.Left = 0
    btn.Top = 0
    btn.Width = groupbox.Width
    btn.Height = groupbox.Height
    btn.DrawMode = "Expand"
    btn.teamid = teamid
    btn.PushImage = ""
    nx_bind_script(btn, nx_current(), "")
    nx_callback(btn, "on_click", "on_btn_path_click")
    local multitextbox = gui:Create("MultiTextBox")
    groupbox:Add(multitextbox)
    multitextbox.AutoSize = false
    multitextbox.Transparent = true
    multitextbox.Name = "MultiTextBox_path_" .. nx_string(i)
    multitextbox.Width = 240
    multitextbox.Height = 80
    multitextbox.Left = 5
    multitextbox.Top = 5
    multitextbox.TextColor = "255,255,255,255"
    multitextbox.SelectBarColor = "0,0,0,0"
    multitextbox.MouseInBarColor = "0,0,0,0"
    multitextbox.Font = "FZHKJT17"
    multitextbox.LineColor = "0,0,0,0"
    multitextbox.ShadowColor = "0,0,0,0"
    multitextbox.ViewRect = "0,0,240,80"
    multitextbox:AddHtmlText(nx_widestr("\239\218\205\183") .. nx_widestr(playername), nx_int(-1))
    multitextbox:AddHtmlText(nx_widestr("\185\171\187\225") .. nx_widestr(GuildName), nx_int(-1))
    multitextbox:AddHtmlText(nx_widestr("\239\218\182\211\200\203\202\253") .. nx_widestr(TeamCount), nx_int(-1))
    multitextbox:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_escort_accept_destination") .. gui.TextManager:GetText(EndText)), nx_int(-1))
    local stringtime = nx_string(TimeLimit / 60) .. nx_string(gui.TextManager:GetText("ui_escort_accept_timeM"))
    if TimeLimit % 60 < 10 then
      stringtime = stringtime .. "0" .. TimeLimit % 60
    else
      stringtime = stringtime .. TimeLimit % 60
    end
    stringtime = stringtime .. nx_string(gui.TextManager:GetText("ui_escort_accept_timeS"))
    if Difficult <= 1 then
      stringtime = stringtime .. "    " .. nx_string(gui.TextManager:GetText("ui_escort_accept_easy"))
    elseif Difficult == 2 then
      stringtime = stringtime .. "    " .. nx_string(gui.TextManager:GetText("ui_escort_accept_normal"))
    else
      stringtime = stringtime .. "    " .. nx_string(gui.TextManager:GetText("ui_escort_accept_difficult"))
    end
    multitextbox:AddHtmlText(nx_widestr(nx_string(gui.TextManager:GetText("ui_escort_accept_time")) .. stringtime), nx_int(-1))
    multitextbox:AddHtmlText(nx_widestr(nx_string(gui.TextManager:GetText("ui_escort_accept_goods")) .. nx_string(GoodsNum)), nx_int(-1))
    group_top = group_top + 110
  end
  form.groupscrollpathbox_desc:ResetChildrenYPos()
  form.groupscrollpathbox_desc.IsEditMode = false
  util_auto_show_hide_form("form_stage_main\\form_school_war\\form_escortfind")
end
function OnEscortInfoMsg(...)
end
