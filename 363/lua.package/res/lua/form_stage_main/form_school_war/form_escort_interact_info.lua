require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
require("form_stage_main\\form_interact\\form_interact_define")
local team_rec = "team_rec"
local label_name = "name"
local pic_head = "pic_head"
local label_fp = "fp"
local kn = "killnum_"
local escort_state = "ES"
local escort_rob = "ER"
local escort_mem_state = "EMS"
local escort_rob_info = "RI"
local escort_rob_kill_target = "RK"
local escort_rob_goods = "RG"
local escort_mem_killed = "RMK"
local team_member_table = {}
local show_member_count_perpage = 6
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.servertime = 0
  local type = get_escort_type()
  if 0 == type then
    return
  end
  init_member_result(form.groupbox_member)
  form.curpage = 0
  show_team_member_list(form, 0)
  Init_escort_info(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_form_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function ok_btn_click(self)
  local form = self.ParentForm
  form:Close()
end
function cancel_btn_click(self)
  local form = self.ParentForm
  form:Close()
end
function show_team_member_list(form, page)
  local groupform = form.groupbox_member
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local item_row_num = client_player:GetRecordRows(team_rec)
  local gui = nx_value("gui")
  local selfname = client_player:QueryProp("Name")
  show_member_self(groupform)
  if item_row_num <= 0 then
    return
  end
  local index = 1
  for i = page * show_member_count_perpage, item_row_num - 1 do
    local playername = client_player:QueryRecord(team_rec, i, 0)
    if not nx_ws_equal(nx_widestr(selfname), nx_widestr(playername)) then
      local playername = client_player:QueryRecord(team_rec, i, 0)
      local playerpic = client_player:QueryRecord(team_rec, i, 1)
      local FP = client_player:QueryRecord(team_rec, i, 16)
      show_member(groupform, index, playername, playerpic, FP)
      index = index + 1
      if show_member_count_perpage <= index - 1 then
        return
      end
    end
  end
  if item_row_num < show_member_count_perpage + page * show_member_count_perpage then
    form.nextpage.Enabled = false
  else
    form.nextpage.Enabled = true
  end
  if 0 == page then
    form.prevpage.Enabled = false
  else
    form.prevpage.Enabled = true
  end
end
function show_member_self(groupform)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local name = client_player:QueryProp("Name")
  local fp = client_player:QueryProp("LevelTitle")
  local pic = client_player:QueryProp("Photo")
  show_member(groupform, 0, name, pic, fp)
end
function show_member(groupform, index, playername, playerpic, FP)
  local gui = nx_value("gui")
  local name = label_name .. nx_string(index)
  local pic = pic_head .. nx_string(index)
  local fp = label_fp .. nx_string(index)
  local labelname = groupform:Find(name)
  local picturehead = groupform:Find(pic)
  local label_fp = groupform:Find(fp)
  labelname.Text = nx_widestr(playername)
  local fpVal = nx_string(gui.TextManager:GetText("desc_" .. nx_string(FP)))
  label_fp.Text = nx_widestr(fpVal)
  if not nx_is_valid(picturehead) then
    return
  end
  picturehead.Image = playerpic
end
function on_nextpage_click(btn)
  local form = btn.ParentForm
  form.curpage = form.curpage + 1
  show_team_member_list(form, form.curpage)
end
function on_prevpage_click(btn)
  local form = btn.ParentForm
  form.curpage = form.curpage - 1
  show_team_member_list(form, form.curpage)
end
function Get_TeamMemberList()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local item_row_num = client_player:GetRecordRows(team_rec)
  local Tm_list = ""
  if item_row_num <= 0 then
    local name = client_player:QueryProp("Name")
    return name
  end
  for i = 0, item_row_num - 1 do
    local playername = client_player:QueryRecord(team_rec, i, 0)
    Tm_list = nx_string(playername) .. nx_string(",")
  end
  return Tm_list
end
function get_escort_type()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local buffer_list = nx_function("get_buffer_list", client_player)
  local buffer_count = table.getn(buffer_list) / 2
  for i = 1, buffer_count do
    local find_buff_id = buffer_list[i * 2 - 1]
    if nx_string(find_buff_id) == nx_string("buff_yunbiao_heistbuff") then
      return ITT_JIEBIAO
    elseif nx_string(find_buff_id) == nx_string("buff_yunbiao_escortbuff") then
      return ITT_YUNBIAO
    end
  end
  return 0
end
function Init_escort_info(form)
  local type = get_escort_type()
  if 0 == type then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  if ITT_YUNBIAO == type then
    databinder:AddTableBind("escort_record", form, nx_current(), "on_escort_hp_update")
  end
  databinder:AddRolePropertyBind("EscortInteractInfo", "widestr", form, nx_current(), "Updtae_Escort_info")
  nx_execute("form_stage_main\\form_interact\\form_interact_manager", "send_escort_server_msg", type)
  if type == ITT_YUNBIAO then
    local goodsnum, time = nx_execute("form_stage_main\\form_school_war\\form_escort_time_limit", "get_goods_time_info")
    form.servertime = time
    form.lbl_res_2.Text = nx_widestr(goodsnum)
    init_timer(form)
    form.pbar_escort.Maximum = 100
  elseif type == ITT_JIEBIAO then
    form.pbar_escort.Visible = false
    form.lbl_escort_state.Visible = false
    form.lbl_td.Visible = false
    form.lbl_res_1.Visible = false
    form.lbl_1.Text = nx_widestr(util_text("ui_rob_goods"))
    form.lbl_res_2.Text = nx_widestr(nx_string(0))
  end
  set_hp_to_form()
end
function ParseEscortInfo(info)
  local string_table = util_split_string(nx_string(info), ",")
  local size = table.getn(string_table)
  local escort_info = ""
  for i = 0, size - 1 do
    escort_info = escort_info .. ParseSingleEscortInfo(string_table[i])
  end
  return escort_info
end
function ParseSingleEscortInfo(info)
  local escort_info = ""
  local string_table = util_split_string(nx_string(info), ":")
  if string_table[1] == escort_state then
    if string_table[2] == "0" then
      escort_info = util_text("ui_escort_bc_start") .. "<br>"
    elseif string_table[2] == "1" then
      escort_info = util_text("ui_escort_bc_stop") .. "<br>"
    else
      escort_info = util_text("ui_escort_bc_reapair") .. "<br>"
    end
  elseif string_table[1] == escort_rob then
    if string_table[2] == "0" then
      escort_info = util_text("ui_escort_rob") .. "<br>" .. string_table[3] .. "  " .. util_text("desc_" .. nx_string(nx_int(string_table[4]))) .. "<br>" .. "    " .. string_table[5] .. "  " .. string_table[6] .. "<br>"
    else
      escort_info = util_text("ui_escort_rob") .. "<br>" .. "    " .. string_table[3] .. "  " .. util_text("desc_" .. nx_string(nx_int(string_table[4]))) .. "<br>"
    end
  elseif string_table[1] == escort_mem_state then
    if string_table[3] == "0" then
      escort_info = string_table[2] .. util_text("ui_zudui0006") .. "<br>"
    elseif string_table[3] == "1" then
      escort_info = string_table[2] .. util_text("ui_guild_request_join") .. "<br>"
    end
  elseif string_table[1] == escort_rob_info then
    if string_table[2] == "0" then
      escort_info = util_text("ui_escort_rob_info") .. "<br>" .. "    " .. string_table[3] .. "  " .. util_text("desc_" .. nx_string(nx_int(string_table[4]))) .. "<br>" .. "    " .. string_table[5] .. "  " .. string_table[6] .. "<br>"
    else
      escort_info = util_text("ui_escort_rob_info") .. "<br>" .. "    " .. string_table[3] .. "  " .. util_text("desc_" .. nx_string(nx_int(string_table[4]))) .. "<br>"
    end
  elseif string_table[1] == escort_rob_kill_target then
    escort_info = string_table[2] .. util_text("ui_escort_kill_target") .. string_table[3] .. "<br>"
  elseif string_table[1] == escort_mem_killed then
    escort_info = string_table[2] .. util_text("ui_bei") .. string_table[3] .. util_text("ui_escort_kill_target") .. "<br>"
  elseif string_table[1] == escort_rob_goods then
    escort_info = string_table[2] .. util_text("ui_escort_rob_goods") .. string_table[3] .. "<br>"
  end
  return escort_info
end
function Updtae_Escort_info(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local escortinfo = client_player:QueryProp("EscortInteractInfo")
  if string.len(nx_string(escortinfo)) ~= 0 then
    local escort_info = ParseEscortInfo(escortinfo)
    form.mltbox_trace.HtmlText = nx_widestr(escort_info)
  end
end
function get_format_time_text(time)
  local format_time = ""
  local min = nx_int(time / 60)
  local sec = nx_int(math.mod(time, 60))
  format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  return nx_string(format_time)
end
function init_timer(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
end
function on_update_time(form)
  if nx_int(form.servertime) <= nx_int(0) then
    return
  end
  form.servertime = form.servertime - 1
  local format_time = get_format_time_text(form.servertime)
  form.lbl_res_1.Text = nx_widestr(format_time)
end
function ParseSingleKillNumInfo(kill_info)
  if string.len(nx_string(kill_info)) == 0 then
    return ""
  end
  local string_table = util_split_string(nx_string(kill_info), ",")
  return string_table
end
function init_member_result(groupform)
  for index = 0, 6 do
    local name = label_name .. nx_string(index)
    local player_kn = kn .. nx_string(index)
    local labelname = groupform:Find(name)
    local label_kn = groupform:Find(player_kn)
    if nx_is_valid(label_kn) then
      label_kn.Text = nx_widestr(nx_string(0))
    end
  end
end
function update_member_result(res_info)
  if 0 >= string.len(res_info) then
    return
  end
  local string_table = util_split_string(nx_string(res_info), ";")
  local size = table.getn(string_table)
  team_member_table = {}
  for i = 1, size - 1 do
    local mem_info = {}
    if 0 >= string.len(nx_string(string_table[i])) then
      return
    end
    mem_info = ParseSingleKillNumInfo(string_table[i])
    table.insert(team_member_table, mem_info)
  end
  show_member_result()
end
function show_member_result()
  local form = nx_value("form_stage_main\\form_school_war\\form_escort_interact_info")
  local groupform = form.groupbox_member
  if not nx_is_valid(form) then
    return
  end
  for index = 0, 5 do
    local name = label_name .. nx_string(index)
    local player_kn = kn .. nx_string(index)
    local labelname = groupform:Find(name)
    local label_kn = groupform:Find(player_kn)
    local res1, res2 = get_escort_result(nx_string(labelname.Text))
    label_kn.Text = nx_widestr(res2)
    if index == 0 then
      form.lbl_res_2.Text = nx_widestr(res1)
    end
  end
end
function get_escort_result(name)
  local size = table.getn(team_member_table)
  for i = 1, size do
    local mem_info = team_member_table[i]
    if name == mem_info[1] then
      return mem_info[3], mem_info[4]
    end
  end
  return 0, 0
end
function on_escort_hp_update(form, recordname, optype, row, clomn)
  if optype == "update" then
    set_hp_to_form()
  end
end
function set_hp_to_form()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local nTeamID = client_player:QueryProp("TeamID")
  local row = client_player:GetRecordRows("escort_record")
  if nx_int(row) < nx_int(0) then
    return false
  end
  local form = nx_value("form_stage_main\\form_school_war\\form_escort_interact_info")
  for i = 0, row - 1 do
    local team_id = client_player:QueryRecord("escort_record", i, 0)
    if nTeamID == team_id then
      local hp = client_player:QueryRecord("escort_record", i, 5)
      if nx_is_valid(form) then
        form.pbar_escort.Value = nx_int(hp)
      end
    end
  end
end
