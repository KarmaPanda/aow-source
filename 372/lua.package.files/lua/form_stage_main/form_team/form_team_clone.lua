require("share\\client_custom_define")
require("share\\view_define")
require("define\\request_type")
require("util_functions")
require("custom_sender")
local SCENE_CONFIG_PATH = "ini\\scenes.ini"
local CLONE_SAVE_REC = "clone_rec_save"
local FORM_OUT_CLONE = "form_stage_main\\form_team\\form_team_out_clone"
local FORM_CLONE = "form_stage_main\\form_team\\form_team_clone"
local FORM_CONFIRM = "form_common\\form_confirm"
local CLONE_LEVEL = {
  "ui_clone_normal",
  "ui_clone_hard",
  "ui_clone_hell"
}
function refresh_form(form)
  if nx_is_valid(form) then
    nx_execute("custom_sender", "get_leave_time_clone")
    on_rec_refresh(form, CLONE_SAVE_REC)
    on_TeamCaption_Change(form)
  end
end
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  local cloneini = nx_execute("util_functions", "get_ini", SCENE_CONFIG_PATH)
  if not nx_is_valid(cloneini) then
    nx_msgbox(SCENE_CONFIG_PATH .. " " .. get_msg_str("msg_120"))
    return
  end
  nx_set_value("cloneini", cloneini)
  data_bind_prop(self)
  nx_execute("custom_sender", "get_leave_time_clone")
  self.textgrid_1:SetColAlign(0, "left")
  self.textgrid_1:SetColAlign(1, "left")
end
function on_main_form_close(self)
  del_data_bind_prop(self)
  nx_destroy(self)
  nx_set_value("form_clone", nx_null())
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function data_bind_prop(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(CLONE_SAVE_REC, self, nx_current(), "on_rec_refresh")
    databinder:AddRolePropertyBind("TeamCaptain", "widestr", self, FORM_CLONE, "on_TeamCaption_Change")
  end
end
function del_data_bind_prop(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(CLONE_SAVE_REC, self)
    databinder:DelRolePropertyBind("TeamCaptain", self)
  end
end
function on_rec_refresh(self, recordname, optype, row, clomn)
  if not nx_is_valid(self) then
    return
  end
  if not self.Visible then
    return
  end
  if recordname ~= CLONE_SAVE_REC then
    return
  end
  self.textgrid_1:ClearRow()
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(CLONE_SAVE_REC) then
    return
  end
  local cloneini = nx_value("cloneini")
  if not nx_is_valid(cloneini) then
    return
  end
  local rownum = client_player:GetRecordRows(CLONE_SAVE_REC)
  for i = 0, rownum - 1 do
    local propID = client_player:QueryRecord(CLONE_SAVE_REC, i, 0)
    local index = cloneini:FindSectionIndex(nx_string(propID))
    local name = ""
    if 0 <= index then
      name = cloneini:ReadString(index, "Config", "")
    end
    local nametxt = gui.TextManager:GetText(nx_string(name))
    local prog = client_player:QueryRecord(CLONE_SAVE_REC, i, 1)
    local progtxt = gui.TextManager:GetFormatText("ui_fuben0011", nx_int(prog))
    local time = client_player:QueryRecord(CLONE_SAVE_REC, i, 5)
    local datelist = util_split_string(time, ",")
    local timetxt = gui.TextManager:GetFormatText("ui_fuben0003", nx_int(datelist[1]), nx_int(datelist[2]), nx_int(datelist[3]))
    local level = client_player:QueryRecord(CLONE_SAVE_REC, i, 6)
    if 0 > nx_number(level) or 3 < nx_number(level) then
      level = 1
    end
    local leveltxt = gui.TextManager:GetText(CLONE_LEVEL[nx_number(level)])
    local alltext = nx_widestr(nametxt) .. nx_widestr("<br>") .. nx_widestr(leveltxt) .. nx_widestr(" ") .. nx_widestr(progtxt) .. " " .. nx_widestr(timetxt)
    if i % 2 == 0 then
      self.textgrid_1:InsertRow(-1)
      self.textgrid_1:SetGridControl(i / 2, 0, get_multibox(alltext))
    else
      self.textgrid_1:SetGridControl(i / 2, 1, get_multibox(alltext))
    end
  end
  return 1
end
function get_multibox(text)
  local gui = nx_value("gui")
  local mltbox = gui:Create("MultiTextBox")
  mltbox.ForeColor = "255,0,0,0"
  mltbox.BackColor = "60,255,255,255"
  mltbox.ShadowColor = "0,255,0,0"
  mltbox.LineColor = "255,0,0,0"
  mltbox.TextColor = "255,128,101,74"
  mltbox.SelectBarColor = "0,0,0,0"
  mltbox.SelectBarDraw = "0,0,0,0"
  mltbox.MouseInBarColor = "50,0,0,0"
  mltbox.ViewRect = "0,0,262,40"
  mltbox.Font = "font_main"
  mltbox.NoFrame = true
  mltbox:AddHtmlText(nx_widestr(text), -1)
  return mltbox
end
function on_TeamCaption_Change(self)
  if not self.Visible then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local TeamCaptain = client_player:QueryProp("TeamCaptain")
  local Name = client_player:QueryProp("Name")
  if nx_ws_equal(nx_widestr(TeamCaptain), nx_widestr(Name)) then
    self.btn_3.Enabled = true
  else
    self.btn_3.Enabled = false
  end
end
function on_click_reset_clone()
  local dialog = nx_execute(FORM_CONFIRM, "get_new_confirm_form", "reset_clone")
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_fuben0008"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  local res = nx_wait_event(100000000, dialog, "reset_clone_confirm_return")
  if res == "cancel" then
    return false
  elseif res == "ok" then
    nx_execute("custom_sender", "reset_all_clone")
    return true
  end
end
