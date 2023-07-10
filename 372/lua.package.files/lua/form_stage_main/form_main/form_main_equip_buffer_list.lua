require("const_define")
require("util_gui")
require("share\\view_define")
require("share\\itemtype_define")
require("custom_sender")
require("define\\shortcut_key_define")
require("tips_data")
require("form_stage_main\\switch\\switch_define")
require("util_role_prop")
require("util_static_data")
require("tips_game")
local FormEquipOtherBufferRec = "form_stage_main\\form_main\\form_main_equip_buffer_list"
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("EquipOtherBufferRec", self, nx_current(), "refresh_form")
  end
  return 1
end
function main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("EquipOtherBufferRec", form)
  end
  nx_destroy(form)
end
function show_form(show)
  local form = nx_value("form_stage_main\\form_main\\form_main_equip_buffer_list")
  if not nx_is_valid(form) then
    return
  end
  form.Visible = show
end
function refresh_form()
  local form = nx_value(FormEquipOtherBufferRec)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_1
  if not nx_is_valid(grid) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  grid:Clear()
  local rows = 0
  if client_player:FindRecord("EquipOtherBufferRec") then
    rows = client_player:GetRecordRows("EquipOtherBufferRec")
    if nx_int(rows) > nx_int(0) then
      for i = 0, rows - 1 do
        if i >= grid.RowNum * grid.ClomnNum then
          return
        end
        local buffer_id = client_player:QueryRecord("EquipOtherBufferRec", i, 0)
        local photo = buff_static_query(nx_string(buffer_id), "Photo")
        grid:AddItem(nx_int(i), photo, nx_widestr(buffer_id), nx_int(1), nx_int(-1))
      end
    end
  end
  reset_ctrl_size(form, rows)
  return
end
function on_imagegrid_1_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if grid:IsEmpty(index) then
    return
  end
  local buffer_id = grid:GetItemName(index)
  if nx_string(buffer_id) == nx_string("") then
    return
  end
  local rows = client_player:GetRecordRows("EquipOtherBufferRec")
  if nx_int(rows) > nx_int(0) then
    for i = 0, rows - 1 do
      local find_buffer_id = client_player:QueryRecord("EquipOtherBufferRec", i, 0)
      if nx_string(buffer_id) == nx_string(find_buffer_id) then
        local str_index = ""
        local level = client_player:QueryRecord("EquipOtherBufferRec", i, 3)
        if level ~= nil and nx_int(level) > nx_int(0) then
          str_index = str_index .. nx_string(gui.TextManager:GetText("desc_" .. nx_string(buffer_id) .. "_" .. nx_string(level))) .. nx_string("<br>")
        else
          str_index = str_index .. nx_string(gui.TextManager:GetText("desc_" .. nx_string(buffer_id) .. "_" .. "0")) .. nx_string("<br>")
        end
        local msgdelay = nx_value("MessageDelay")
        if not nx_is_valid(msgdelay) then
          return
        end
        local server_time = msgdelay:GetServerNowTime()
        local end_time = client_player:QueryRecord("EquipOtherBufferRec", i, 1)
        local live_time = end_time - server_time
        str_index = str_index .. nx_string("<font color=\"#00FF00\">") .. nx_string(gui.TextManager:GetText(nx_string(get_format_time(live_time / 1000)))) .. nx_string("</font>")
        local times = client_player:QueryRecord("EquipOtherBufferRec", i, 2)
        if nx_int(times) > nx_int(1) then
          str_index = str_index .. "  " .. nx_string("<font color=\"#FFFF00\">") .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_lay_times", nx_int(times))) .. nx_string("</font>")
        end
        if str_index == nil then
          return
        end
        local mouse_x, mouse_z = gui:GetCursorPosition()
        nx_execute("tips_game", "show_text_tip", nx_widestr(str_index), mouse_x, mouse_z)
        break
      end
    end
  end
end
function on_imagegrid_1_mouseout_grid(grid, index)
  hide_tip(grid.ParentForm)
end
function get_format_time(time)
  if nx_number(time) < nx_number(0) then
    return ""
  end
  local hour = nx_int(nx_number(time) / 3600)
  local minute = nx_int(nx_number(time) % 3600 / 60)
  local second = nx_int(nx_number(time) % 60)
  local gui = nx_value("gui")
  local str = ""
  if nx_int(hour) > nx_int(0) then
    str = str .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_live_time_1", nx_int(hour)))
  end
  if nx_int(minute) > nx_int(0) then
    str = str .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_live_time_2", nx_int(minute)))
  end
  if nx_int(second) > nx_int(0) then
    str = str .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_live_time_3", nx_int(second)))
  end
  return str
end
function reset_ctrl_size(form, rows)
  form.groupbox_keyequip.Width = 36 * rows
  form.lbl_2.Left = form.lbl_1.Width + form.groupbox_keyequip.Width
  form.Width = form.lbl_2.Left + 20
end
