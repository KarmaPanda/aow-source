require("utils")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\form_tvt\\define")
local INI_FILE = "share\\Rule\\ActivityAward.ini"
local INI_NEW_AWARD_FILE = "share\\Rule\\ActivityNewAward.ini"
local CORNER_ICON_DEFAULT = "gui\\special\\huoyuedu\\tip_1.png"
local CAN_GET = 1
local YET_GOT = 2
local CANT_GET = 3
local RECOMMEND = 1
local TODAY = 2
local WEEK = 3
local WEEKEND = 4
local COL_COUNT = 5
local WEEK_INFO_COL_COUNT = 5
function main_form_init(form)
  form.Fixed = false
  form.recommend_count = 0
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(INI_FILE) then
    IniManager:LoadIniToManager(INI_FILE)
  end
  if not IniManager:IsIniLoadedToManager(INI_NEW_AWARD_FILE) then
    IniManager:LoadIniToManager(INI_NEW_AWARD_FILE)
  end
  form.max_day_var = get_max_day_var()
  form.max_week_var = get_max_week_var()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  refresh_box_pos(form)
  refresh_week_box_pos(form)
  form.rbtn_recommend.Checked = true
  form.cur_sel_info = RECOMMEND
  form.show_exp_ani = false
  form.show_rel_ani = false
  form.ani_rel.Visible = false
  form.ani_exp.Visible = false
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddRolePropertyBind("DayActivityValue", "int", form, nx_current(), "on_day_act_changed")
    data_binder:AddRolePropertyBind("WeekActivityValue", "int", form, nx_current(), "on_week_act_changed")
    data_binder:AddTableBind("ActivityRewardRec", form, nx_current(), "on_reward_rec_change")
    data_binder:AddTableBind("ActivityCompliteRec", form, nx_current(), "on_complete_rec_change")
    data_binder:AddRolePropertyBind("ExpertPoint", "int", form, nx_current(), "on_point_changed")
    data_binder:AddRolePropertyBind("RelaxationPoint", "int", form, nx_current(), "on_point_changed")
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local ST_FUNCTION_FILL_ACTIVITY = 699
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  form.btn_onekey.Visible = switch_manager:CheckSwitchEnable(ST_FUNCTION_FILL_ACTIVITY)
  local ST_FUNCTION_JIANGHU_GREAT_NEWS = 883
  form.btn_great_news.Visible = switch_manager:CheckSwitchEnable(ST_FUNCTION_JIANGHU_GREAT_NEWS)
  local ST_FUNCTION_ACTIVITY_NEW_AWARD = 2819
  form.rbtn_weekend.Visible = switch_manager:CheckSwitchEnable(ST_FUNCTION_ACTIVITY_NEW_AWARD)
  if not switch_manager:CheckSwitchEnable(685) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("ui_actreward_close"))
    return
  end
end
function on_main_form_close(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelRolePropertyBind("DayActivityValue", form)
    data_binder:DelRolePropertyBind("WeekActivityValue", form)
    data_binder:DelTableBind("ActivityRewardRec", form)
    data_binder:DelTableBind("ActivityAddValueRec", form)
  end
  nx_destroy(form)
end
function on_day_act_changed(form)
  if not nx_is_valid(form) then
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
  local cur_day_var = client_player:QueryProp("DayActivityValue")
  if not nx_find_custom(form, "max_day_var") then
    form.max_day_var = get_max_day_var()
  end
  form.lbl_v_day_act.Text = nx_widestr(cur_day_var)
  if nx_int(cur_day_var) > nx_int(form.max_day_var) then
    cur_day_var = form.max_day_var
  end
  form.pbar_1.Maximum = form.max_day_var
  form.pbar_1.Value = cur_day_var
  check_day_reward_state(form, client_player)
end
function on_week_act_changed(form)
  if not nx_is_valid(form) then
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
  local cur_week_var = client_player:QueryProp("WeekActivityValue")
  if not nx_find_custom(form, "max_week_var") then
    form.max_week_var = get_max_week_var()
  end
  form.lbl_v_week_act.Text = nx_widestr(cur_week_var)
  if nx_int(cur_week_var) > nx_int(form.max_week_var) then
    cur_week_var = form.max_week_var
  end
  form.pbar_2.Maximum = form.max_week_var
  form.pbar_2.Value = cur_week_var
  check_week_reward_state(form, client_player)
end
function on_reward_rec_change(self, recordname, optype, row, clomn)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local form = nx_value("form_stage_main\\form_dbomall\\form_dboactreward")
  if not nx_is_valid(form) then
    return
  end
  check_day_reward_state(form, client_player)
  check_week_reward_state(form, client_player)
end
function on_complete_rec_change(self, recordname, optype, row, clomn)
  local form = nx_value("form_stage_main\\form_dbomall\\form_dboactreward")
  if not nx_is_valid(form) then
    return
  end
  update_info(form)
end
function on_btn_week_reward_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  if not nx_is_valid(btn) then
    return
  end
  if not nx_find_custom(btn, "is_click") then
    return
  end
  if not btn.is_click then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_AWARD), nx_int(1), nx_int(2), nx_int(btn.DataSource))
end
function on_btn_rank_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rank_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if nx_is_valid(rank_form) then
    nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rank_form, "rank_WeekActivity")
  end
end
function on_btn_box_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  if not nx_is_valid(btn) then
    return
  end
  if not nx_find_custom(btn, "is_click") then
    return
  end
  if not btn.is_click then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_AWARD), nx_int(1), nx_int(1), nx_int(btn.DataSource))
end
function on_rbtn_recommend_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_dbomall\\form_dboactreward")
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_recommend.Checked == false then
    return
  end
  form.cur_sel_info = RECOMMEND
  form.btn_up.Visible = true
  form.btn_down.Visible = true
  update_info(form)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_rbtn_day_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_dbomall\\form_dboactreward")
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_day.Checked == false then
    return
  end
  form.cur_sel_info = TODAY
  form.btn_up.Visible = false
  form.btn_down.Visible = false
  update_info(form)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_rbtn_week_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_dbomall\\form_dboactreward")
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_week.Checked == false then
    return
  end
  form.cur_sel_info = WEEK
  form.btn_up.Visible = false
  form.btn_down.Visible = false
  update_info(form)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_rbtn_weekend_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_dbomall\\form_dboactreward")
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_weekend.Checked == false then
    return
  end
  form.cur_sel_info = WEEKEND
  form.btn_up.Visible = false
  form.btn_down.Visible = false
  update_info(form)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function refresh_box_pos(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_find_custom(form, "max_day_var") then
    form.max_day_var = get_max_day_var()
  end
  local text = get_day_arrays()
  if text == "" then
    return
  end
  local text_array = util_split_string(nx_string(text), ",")
  if table.getn(text_array) < 1 then
    return
  end
  for i = 1, table.getn(text_array) do
    local infos = util_split_string(nx_string(text_array[i]), "_")
    if table.getn(infos) >= 2 then
      local button = gui:Create("Button")
      local need_var = nx_int(infos[1])
      local box_res = nx_string("gui\\special\\huoyuedu\\") .. nx_string(infos[2])
      if nx_is_valid(button) then
        button.Name = "btn_box_" .. nx_string(i)
        button.ForeColor = "255,255,255,255"
        button.DataSource = nx_string(i)
        button.DrawMode = "FitWindow"
        button.NormalImage = box_res .. nx_string("_c.png")
        button.FocusImage = box_res .. nx_string("_c_on.png")
        button.PushImage = box_res .. nx_string("_c_down.png")
        button.Visible = true
        button.Width = 55
        button.Height = 55
        button.Top = 0
        button.Left = form.pbar_1.Left - 27.5 + need_var / nx_int(form.max_day_var) * form.pbar_1.Width
        nx_bind_script(button, nx_current())
        nx_callback(button, "on_click", "on_btn_box_click")
        nx_callback(button, "on_get_capture", "on_btn_box_get_capture")
        nx_callback(button, "on_lost_capture", "on_btn_box_lost_capture")
        nx_set_custom(form, button.Name, button)
        form.groupbox_day:Add(button)
      end
      local bg_anim = gui:Create("Label")
      if nx_is_valid(bg_anim) then
        bg_anim.Name = "lbl_box_" .. nx_string(i)
        bg_anim.ForeColor = "255,255,255,255"
        bg_anim.DataSource = nx_string(i)
        bg_anim.DrawMode = "FitWindow"
        bg_anim.BackImage = "9yin_activity_flash"
        bg_anim.Visible = true
        bg_anim.Width = 55
        bg_anim.Height = 55
        bg_anim.Top = 0
        bg_anim.Left = form.pbar_1.Left - 27.5 + need_var / nx_int(form.max_day_var) * form.pbar_1.Width
        nx_set_custom(form, bg_anim.Name, bg_anim)
        form.groupbox_day:Add(bg_anim)
      end
      local lbl_need_var = gui:Create("Label")
      if nx_is_valid(lbl_need_var) then
        lbl_need_var.Name = "lbl_box_need_" .. nx_string(i)
        lbl_need_var.ForeColor = "255,255,255,255"
        lbl_need_var.DataSource = nx_string(i)
        lbl_need_var.DrawMode = "FitWindow"
        lbl_need_var.Visible = true
        lbl_need_var.Font = "font_text_chat"
        lbl_need_var.Text = nx_widestr(need_var)
        lbl_need_var.Width = 55
        lbl_need_var.Height = 20
        lbl_need_var.Top = form.lbl_begin_var.Top
        lbl_need_var.Left = form.pbar_1.Left - 15 + need_var / nx_int(form.max_day_var) * form.pbar_1.Width
        nx_set_custom(form, lbl_need_var.Name, lbl_need_var)
        form.groupbox_day:Add(lbl_need_var)
      end
    end
  end
end
function refresh_week_box_pos(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_find_custom(form, "max_week_var") then
    form.max_week_var = get_max_week_var()
  end
  local text = get_week_arrays()
  if text == "" then
    return
  end
  local text_array = util_split_string(nx_string(text), ",")
  if table.getn(text_array) < 1 then
    return
  end
  for i = 1, table.getn(text_array) do
    local infos = util_split_string(nx_string(text_array[i]), "_")
    if table.getn(infos) >= 2 then
      local button = gui:Create("Button")
      local need_var = nx_int(infos[1])
      local box_res = nx_string("gui\\special\\huoyuedu\\") .. nx_string(infos[2])
      if nx_is_valid(button) then
        button.Name = "btn_week_box_" .. nx_string(i)
        button.ForeColor = "255,255,255,255"
        button.DataSource = nx_string(i)
        button.DrawMode = "FitWindow"
        button.NormalImage = box_res .. nx_string("_c.png")
        button.FocusImage = box_res .. nx_string("_c_on.png")
        button.PushImage = box_res .. nx_string("_c_down.png")
        button.Visible = true
        button.Width = 55
        button.Height = 55
        button.Top = 10
        button.Left = form.pbar_2.Left - 27.5 + need_var / nx_int(form.max_week_var) * form.pbar_2.Width
        nx_bind_script(button, nx_current())
        nx_callback(button, "on_click", "on_btn_week_reward_click")
        nx_callback(button, "on_get_capture", "on_btn_box_get_capture")
        nx_callback(button, "on_lost_capture", "on_btn_box_lost_capture")
        nx_set_custom(form, button.Name, button)
        form.groupbox_week:Add(button)
      end
      local bg_anim = gui:Create("Label")
      if nx_is_valid(bg_anim) then
        bg_anim.Name = "lbl_week_box_" .. nx_string(i)
        bg_anim.ForeColor = "255,255,255,255"
        bg_anim.DataSource = nx_string(i)
        bg_anim.DrawMode = "FitWindow"
        bg_anim.BackImage = "9yin_activity_flash"
        bg_anim.Visible = true
        bg_anim.Width = 55
        bg_anim.Height = 55
        bg_anim.Top = 10
        bg_anim.Left = form.pbar_2.Left - 27.5 + need_var / nx_int(form.max_week_var) * form.pbar_2.Width
        nx_set_custom(form, bg_anim.Name, bg_anim)
        form.groupbox_week:Add(bg_anim)
      end
      local lbl_need_var = gui:Create("Label")
      if nx_is_valid(lbl_need_var) then
        lbl_need_var.Name = "lbl_week_box_need_" .. nx_string(i)
        lbl_need_var.ForeColor = "255,255,255,255"
        lbl_need_var.DataSource = nx_string(i)
        lbl_need_var.DrawMode = "FitWindow"
        lbl_need_var.Visible = true
        lbl_need_var.Font = "font_text_chat"
        lbl_need_var.Text = nx_widestr(need_var)
        lbl_need_var.Width = 55
        lbl_need_var.Height = 20
        lbl_need_var.Top = form.lbl_week_begin_var.Top
        lbl_need_var.Left = form.pbar_2.Left - 15 + need_var / nx_int(form.max_week_var) * form.pbar_2.Width
        nx_set_custom(form, lbl_need_var.Name, lbl_need_var)
        form.groupbox_week:Add(lbl_need_var)
      end
    end
  end
end
function get_day_arrays()
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string("AwardInfo"))
  if sec_index < 0 then
    return ""
  end
  local text = ini:ReadString(sec_index, nx_string("DayProgress"), "")
  if text == "" or text == nil then
    return ""
  end
  return text
end
function get_max_day_var()
  local text = get_day_arrays()
  if text == "" then
    return 0
  end
  local text_array = util_split_string(nx_string(text), ",")
  if table.getn(text_array) < 1 then
    return 0
  end
  local infos = util_split_string(nx_string(text_array[table.getn(text_array)]), "_")
  if table.getn(infos) < 1 then
    return 0
  end
  return nx_int(infos[1])
end
function get_week_arrays()
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string("AwardInfo"))
  if sec_index < 0 then
    return ""
  end
  local text = ini:ReadString(sec_index, nx_string("WeekProgress"), "")
  if text == "" or text == nil then
    return ""
  end
  return text
end
function get_max_week_var()
  local text = get_week_arrays()
  if text == "" then
    return 0
  end
  local text_array = util_split_string(nx_string(text), ",")
  if table.getn(text_array) < 1 then
    return 0
  end
  local infos = util_split_string(nx_string(text_array[table.getn(text_array)]), "_")
  if table.getn(infos) < 1 then
    return 0
  end
  return nx_int(infos[1])
end
function check_day_reward_state(form, player)
  if not nx_is_valid(player) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local text = get_day_arrays()
  if text == "" then
    return
  end
  local text_array = util_split_string(nx_string(text), ",")
  local cur_day_var = player:QueryProp("DayActivityValue")
  if cur_day_var == nil then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local is_open = switch_manager:CheckSwitchEnable(685)
  for i = 1, table.getn(text_array) do
    local ctrl_name = "btn_box_" .. nx_string(i)
    local bg_ctrl_name = "lbl_box_" .. nx_string(i)
    local lbl_ctrl_name = "lbl_box_need_" .. nx_string(i)
    if nx_find_custom(form, ctrl_name) and nx_find_custom(form, bg_ctrl_name) and nx_find_custom(form, lbl_ctrl_name) then
      local infos = util_split_string(nx_string(text_array[i]), "_")
      local btn = nx_custom(form, ctrl_name)
      local bg_lbl = nx_custom(form, bg_ctrl_name)
      local lbl_need = nx_custom(form, lbl_ctrl_name)
      local condition_id = get_day_award_id(i)
      if nx_is_valid(btn) and table.getn(infos) >= 2 and condition_id ~= nil and nx_is_valid(btn) and nx_is_valid(lbl_need) then
        local need_var = infos[1]
        local box_res = nx_string("gui\\special\\huoyuedu\\") .. nx_string(infos[2])
        if nx_int(cur_day_var) < nx_int(need_var) then
          btn.NormalImage = box_res .. "_c.png"
          btn.FocusImage = box_res .. "_c_on.png"
          btn.PushImage = box_res .. "_c_on.png"
          btn.is_click = false
          bg_lbl.Visible = false
          lbl_need.Text = nx_widestr(need_var)
        elseif box_is_got(player, condition_id) == YET_GOT then
          btn.NormalImage = box_res .. "_o.png"
          btn.FocusImage = box_res .. "_o_on.png"
          btn.PushImage = box_res .. "_o_on.png"
          btn.is_click = false
          bg_lbl.Visible = false
          lbl_need.Text = gui.TextManager:GetFormatText("ui_actreward_got")
        else
          btn.NormalImage = box_res .. "_c.png"
          btn.FocusImage = box_res .. "_c_on.png"
          btn.PushImage = box_res .. "_c_down.png"
          btn.is_click = true
          bg_lbl.Visible = true
          lbl_need.Text = gui.TextManager:GetFormatText("ui_actreward_can")
        end
        btn.Enabled = is_open
      end
    end
  end
end
function get_day_award_id(index)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("AwardInfo"))
  if sec_index < 0 then
    return
  end
  local text = ini:ReadString(sec_index, nx_string("DayAwardInfo"), "")
  if text == "" or text == nil then
    return
  end
  local text_array = util_split_string(nx_string(text), ";")
  if nx_int(index) > nx_int(table.getn(text_array)) then
    return
  end
  local infos = util_split_string(nx_string(text_array[nx_number(index)]), ",")
  if table.getn(infos) < 1 then
    return
  end
  return infos[1]
end
function get_week_award_id(index)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("AwardInfo"))
  if sec_index < 0 then
    return
  end
  local text = ini:ReadString(sec_index, nx_string("WeekAwardInfo"), "")
  if text == "" or text == nil then
    return
  end
  local text_array = util_split_string(nx_string(text), ";")
  if nx_int(index) > nx_int(table.getn(text_array)) then
    return
  end
  local infos = util_split_string(nx_string(text_array[nx_number(index)]), ",")
  if table.getn(infos) < 1 then
    return
  end
  return infos[1]
end
function box_is_got(player, condition_id)
  if not nx_is_valid(player) then
    return YET_GOT
  end
  local row = player:FindRecordRow("ActivityRewardRec", 0, nx_int(condition_id), 0)
  if row < 0 then
    return false
  end
  return YET_GOT
end
function check_week_reward_state(form, player)
  if not nx_is_valid(player) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local text = get_week_arrays()
  if text == "" then
    return
  end
  local text_array = util_split_string(nx_string(text), ",")
  local cur_week_var = player:QueryProp("WeekActivityValue")
  if cur_week_var == nil then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local is_open = switch_manager:CheckSwitchEnable(685)
  for i = 1, table.getn(text_array) do
    local ctrl_name = "btn_week_box_" .. nx_string(i)
    local bg_ctrl_name = "lbl_week_box_" .. nx_string(i)
    local lbl_ctrl_name = "lbl_week_box_need_" .. nx_string(i)
    if nx_find_custom(form, ctrl_name) and nx_find_custom(form, bg_ctrl_name) and nx_find_custom(form, lbl_ctrl_name) then
      local infos = util_split_string(nx_string(text_array[i]), "_")
      local btn = nx_custom(form, ctrl_name)
      local bg_lbl = nx_custom(form, bg_ctrl_name)
      local lbl_need = nx_custom(form, lbl_ctrl_name)
      local condition_id = get_week_award_id(i)
      if nx_is_valid(btn) and table.getn(infos) >= 2 and condition_id ~= nil and nx_is_valid(btn) and nx_is_valid(lbl_need) then
        local need_var = infos[1]
        local box_res = nx_string("gui\\special\\huoyuedu\\") .. nx_string(infos[2])
        if nx_int(cur_week_var) < nx_int(need_var) then
          btn.NormalImage = box_res .. "_c.png"
          btn.FocusImage = box_res .. "_c_on.png"
          btn.PushImage = box_res .. "_c_on.png"
          btn.is_click = false
          bg_lbl.Visible = false
          lbl_need.Text = nx_widestr(need_var)
        elseif box_is_got(player, condition_id) == YET_GOT then
          btn.NormalImage = box_res .. "_o.png"
          btn.FocusImage = box_res .. "_o_on.png"
          btn.PushImage = box_res .. "_o_on.png"
          btn.is_click = false
          bg_lbl.Visible = false
          lbl_need.Text = gui.TextManager:GetFormatText("ui_actreward_got")
        else
          btn.NormalImage = box_res .. "_c.png"
          btn.FocusImage = box_res .. "_c_on.png"
          btn.PushImage = box_res .. "_c_down.png"
          btn.is_click = true
          bg_lbl.Visible = true
          lbl_need.Text = gui.TextManager:GetFormatText("ui_actreward_can")
        end
        btn.Enabled = is_open
      end
    end
  end
end
function get_week_reward_info()
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("AwardInfo"))
  if sec_index < 0 then
    return
  end
  local text = ini:ReadString(sec_index, nx_string("WeekAwardInfo"), "")
  if text == "" or text == nil then
    return
  end
  local infos = util_split_string(nx_string(text), ",")
  if table.getn(infos) < 1 then
    return
  end
  return infos[1]
end
function get_week_reward_need_var()
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("AwardInfo"))
  if sec_index < 0 then
    return
  end
  local text = ini:ReadString(sec_index, nx_string("WeekNeedVar"), "")
  if text == "" or text == nil then
    return
  end
  return text
end
function update_info(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_sel_info") then
    return
  end
  if form.cur_sel_info ~= RECOMMEND and form.cur_sel_info ~= TODAY and form.cur_sel_info ~= WEEK and form.cur_sel_info ~= WEEKEND then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local condition_mgr = nx_value("ConditionManager")
  if not nx_is_valid(condition_mgr) then
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
  if form.cur_sel_info == RECOMMEND then
    form.grid_info.Visible = false
    form.groupbox_weekend_award.Visible = false
    form.gbox_visuallayer.Visible = true
  elseif form.cur_sel_info == WEEKEND then
    form.grid_info.Visible = false
    form.groupbox_weekend_award.Visible = true
    form.gbox_visuallayer.Visible = false
    fill_weeked_info(form)
    return
  else
    form.grid_info.Visible = true
    form.groupbox_weekend_award.Visible = false
    form.gbox_visuallayer.Visible = false
  end
  form.gbox_container:DeleteAll()
  form.recommend_count = 0
  form.grid_info:BeginUpdate()
  form.grid_info:ClearRow()
  form.grid_info.ColCount = COL_COUNT
  form.grid_info.HeaderBackColor = "0,255,255,255"
  form.grid_info.HeaderForeColor = "255,142,142,142"
  local col_list = {
    "ui_actinfo_name",
    "ui_actinfo_count",
    "ui_actinfo_act",
    "ui_actinfo_dest",
    "ui_actinfo_op"
  }
  for i = 1, COL_COUNT do
    local head_name = gui.TextManager:GetFormatText(col_list[i])
    form.grid_info:SetColTitle(i - 1, nx_widestr(head_name))
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return
  end
  local finished_act_index = {}
  local finished_new_act_index = {}
  local act_index = {}
  local new_act_index = {}
  local index = 1
  local sec_index = ini:FindSectionIndex(nx_string(index))
  while 0 <= sec_index do
    local condition_id = ini:ReadString(sec_index, nx_string("OpenCondition"), "")
    local is_condition = true
    if condition_id ~= "" and condition_id ~= nil and not condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(condition_id)) then
      is_condition = false
    end
    if is_condition and nx_int(ini:ReadString(sec_index, nx_string("Type"), "")) ~= nx_int(form.cur_sel_info) then
      is_condition = false
    end
    if is_condition then
      local cur_count = 0
      local rec_row = client_player:FindRecordRow("ActivityCompliteRec", 0, nx_int(index), 0)
      if 0 <= rec_row then
        cur_count = client_player:QueryRecord("ActivityCompliteRec", rec_row, 1)
      end
      local max_count = ini:ReadString(sec_index, nx_string("NeedTimes"), "")
      text = nx_widestr(cur_count) .. nx_widestr("/") .. nx_widestr(max_count)
      if nx_int(cur_count) >= nx_int(max_count) then
        if is_new_act(ini, sec_index) then
          table.insert(finished_new_act_index, sec_index)
        else
          table.insert(finished_act_index, sec_index)
        end
      elseif is_new_act(ini, sec_index) then
        table.insert(new_act_index, sec_index)
      else
        table.insert(act_index, sec_index)
      end
    end
    index = index + 1
    sec_index = ini:FindSectionIndex(nx_string(index))
  end
  for i = 1, table.getn(new_act_index) do
    fill_row(form, client_player, gui, ini, new_act_index[i])
  end
  for i = 1, table.getn(act_index) do
    fill_row(form, client_player, gui, ini, act_index[i])
  end
  for i = 1, table.getn(finished_new_act_index) do
    fill_row(form, client_player, gui, ini, finished_new_act_index[i])
  end
  for i = 1, table.getn(finished_act_index) do
    fill_row(form, client_player, gui, ini, finished_act_index[i])
  end
  form.grid_info:EndUpdate()
end
function fill_weeked_info(form)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_NEW_AWARD_FILE)
  if ini == nil then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return
  end
  local time_ctrl_name, point_ctrl_name, item_ctrl_name, time_ctrl, point_ctrl, time_text, item_ctrl
  local photo = ItemsQuery:GetItemPropByConfigID("additem_0020_4", "Photo")
  local item_id
  local sect_index = ini:FindSectionIndex("NewAwardInfo")
  if 0 <= sect_index then
    local item_count = ini:GetSectionItemCount(sect_index)
    for i = 1, item_count do
      local value = nx_string(ini:GetSectionItemValue(sect_index, i - 1))
      local value_list = util_split_string(value, ",")
      if table.getn(value_list) == 1 then
        item_ctrl_name = "img_award_"
        item_ctrl_name = item_ctrl_name .. nx_string(4)
        if nx_find_custom(form, item_ctrl_name) then
          item_ctrl = nx_custom(form, item_ctrl_name)
          if nx_is_valid(item_ctrl) then
            item_id = nx_string(value_list[1])
            photo = ItemsQuery:GetItemPropByConfigID(item_id, "Photo")
            item_ctrl:AddItem(0, photo, util_text(item_id), 1, -1)
            item_ctrl.binditemid = item_id
          end
        end
      elseif table.getn(value_list) == 4 then
        time_ctrl_name = "lbl_award_time_"
        point_ctrl_name = "lbl_award_point_"
        item_ctrl_name = "img_award_"
        time_ctrl_name = time_ctrl_name .. nx_string(i - 1)
        if nx_find_custom(form, time_ctrl_name) then
          time_ctrl = nx_custom(form, time_ctrl_name)
          if nx_is_valid(time_ctrl) then
            time_text = "ui_award_time"
            time_text = time_text .. nx_string(value_list[1])
            time_ctrl.Text = gui.TextManager:GetText(time_text)
          end
        end
        point_ctrl_name = point_ctrl_name .. nx_string(i - 1)
        if nx_find_custom(form, point_ctrl_name) then
          point_ctrl = nx_custom(form, point_ctrl_name)
          if nx_is_valid(point_ctrl) then
            point_ctrl.Text = nx_widestr(value_list[2])
          end
        end
        item_ctrl_name = item_ctrl_name .. nx_string(i - 1)
        if nx_find_custom(form, item_ctrl_name) then
          item_ctrl = nx_custom(form, item_ctrl_name)
          if nx_is_valid(item_ctrl) then
            item_id = nx_string(value_list[3])
            photo = ItemsQuery:GetItemPropByConfigID(item_id, "Photo")
            item_ctrl:AddItem(0, photo, util_text(item_id), 1, -1)
            item_ctrl.binditemid = item_id
          end
        end
      end
    end
  end
end
function on_imagegrid_mouseout_grid(self)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_mousein_grid(self)
  local index = self.DataSource
  if self:IsEmpty(0) then
    return
  end
  if not nx_find_custom(self, "binditemid") then
    return
  end
  local ConfigID = self.binditemid
  nx_execute("tips_game", "show_tips_by_config", ConfigID, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), self.ParentForm)
end
function is_new_act(ini, sect_index)
  return ini:ReadString(sect_index, nx_string("Icon"), "") ~= ""
end
function fill_row(form, client_player, gui, ini, sec_index)
  local row = form.grid_info:InsertRow(-1)
  local index = ini:GetSectionByIndex(sec_index)
  local text = gui.TextManager:GetFormatText("ui_actinfo_desc_name_" .. index)
  local cur_count = 0
  local rec_row = client_player:FindRecordRow("ActivityCompliteRec", 0, nx_int(index), 0)
  if 0 <= rec_row then
    cur_count = client_player:QueryRecord("ActivityCompliteRec", rec_row, 1)
  end
  local max_count = ini:ReadString(sec_index, nx_string("NeedTimes"), "")
  local need_text = nx_widestr(cur_count) .. nx_widestr("/") .. nx_widestr(max_count)
  local award = ini:ReadString(sec_index, nx_string("AwardValue"), "")
  local dest_text = gui.TextManager:GetFormatText("ui_actinfo_desc_" .. index)
  local button
  local link_info = ini:ReadString(sec_index, nx_string("LinkClose"), "")
  if link_info ~= nil and link_info ~= "1" then
    button = gui:Create("Button")
    if nx_is_valid(button) then
      button.Name = "btn_link_" .. nx_string(index)
      button.ForeColor = "255,255,255,255"
      button.DataSource = nx_string(index)
      button.DrawMode = "FitWindow"
      button.NormalImage = nx_string("gui\\special\\huoyuedu\\btn_s_out.png")
      button.FocusImage = nx_string("gui\\special\\huoyuedu\\btn_s_on.png")
      button.PushImage = nx_string("gui\\special\\huoyuedu\\btn_s_down.png")
      button.Visible = true
      button.Width = 73
      button.Height = 32
      button.Text = gui.TextManager:GetFormatText("ui_actreward_goto")
      nx_bind_script(button, nx_current())
      nx_callback(button, "on_click", "on_btn_link_click")
    end
  end
  if form.cur_sel_info ~= RECOMMEND then
    form.grid_info:SetGridText(row, 0, text)
    form.grid_info:SetGridText(row, 1, need_text)
    form.grid_info:SetGridForeColor(row, 2, "255,255,204,0")
    form.grid_info:SetGridText(row, 2, nx_widestr(award))
    form.grid_info:SetGridText(row, 3, dest_text)
    if button ~= nil and nx_is_valid(button) then
      form.grid_info:SetGridControl(row, 4, button)
    end
    if nx_int(cur_count) >= nx_int(max_count) then
      form.grid_info:SetGridForeColor(row, 0, "255,130,130,130")
      form.grid_info:SetGridForeColor(row, 1, "255,130,130,130")
      form.grid_info:SetGridForeColor(row, 2, "255,130,130,130")
      form.grid_info:SetGridForeColor(row, 3, "255,130,130,130")
    end
  else
    local groupbox = gui:Create("GroupBox")
    groupbox.BackColor = "0,255,255,255"
    groupbox.NoFrame = true
    groupbox.Width = form.gbox_visuallayer.Width / 4
    groupbox.Height = 254
    groupbox.Top = 8
    groupbox.Left = nx_int(form.recommend_count * groupbox.Width)
    groupbox.Name = "gbox_recommend_" .. nx_string(form.recommend_count)
    groupbox.DrawMode = "FitWindow"
    groupbox.BackImage = "gui\\special\\huoyuedu\\kuang.png"
    form.gbox_container:Add(groupbox)
    form.gbox_container.Width = (nx_int(form.recommend_count / 4) + 1) * form.gbox_visuallayer.Width
    nx_set_custom(form, nx_string(groupbox.Name), groupbox)
    form.recommend_count = form.recommend_count + 1
    local lbl_flag = gui:Create("Label")
    lbl_flag.NoFrame = true
    lbl_flag.Top = 0
    lbl_flag.Left = 0
    lbl_flag.Width = 62
    lbl_flag.Height = 62
    lbl_flag.DrawMode = "FitWindow"
    local corner_icon_path = ini:ReadString(sec_index, nx_string("Icon"), "")
    if corner_icon_path == "" then
      corner_icon_path = CORNER_ICON_DEFAULT
    end
    lbl_flag.BackImage = corner_icon_path
    groupbox:Add(lbl_flag)
    local lbl_pic = gui:Create("Label")
    lbl_pic.NoFrame = true
    lbl_pic.Width = 40
    lbl_pic.Height = 35
    lbl_pic.DrawMode = "Center"
    local cfg_pic = ini:ReadString(sec_index, nx_string("Pic"), "")
    local pic = get_act_pic(cfg_pic)
    lbl_pic.BackImage = nx_string(pic)
    lbl_pic.Top = 30
    lbl_pic.Left = (groupbox.Width - lbl_pic.Width) / 5 - 10
    groupbox:Add(lbl_pic)
    local lbl_name = gui:Create("Label")
    lbl_name.NoFrame = true
    lbl_name.ForeColor = "255,255,255,255"
    lbl_name.Font = "font_main"
    lbl_name.Text = text
    lbl_name.Width = groupbox.Width / 5 * 4 - 35
    lbl_name.Height = 30
    lbl_name.LblLimitWidth = true
    lbl_name.Top = lbl_pic.Top + (lbl_pic.Height - lbl_name.Height) / 2
    lbl_name.Left = lbl_pic.Left + lbl_pic.Width
    groupbox:Add(lbl_name)
    local lbl_need_desc = gui:Create("Label")
    lbl_need_desc.NoFrame = true
    lbl_need_desc.ForeColor = "255,209,209,209"
    lbl_need_desc.Font = "font_main"
    lbl_need_desc.Text = gui.TextManager:GetFormatText("ui_actinfo_count")
    lbl_need_desc.Top = lbl_name.Top + lbl_name.Height + 10
    lbl_need_desc.Left = 15
    lbl_need_desc.Width = groupbox.Width / 2
    lbl_need_desc.Height = 20
    lbl_name.LblLimitWidth = true
    groupbox:Add(lbl_need_desc)
    local lbl_need = gui:Create("Label")
    lbl_need.NoFrame = true
    lbl_need.ForeColor = "255,255,204,0"
    lbl_need.Font = "font_main"
    lbl_need.Text = need_text
    lbl_need.Top = lbl_need_desc.Top
    lbl_need.Left = lbl_need_desc.Left + lbl_need_desc.Width + 30
    lbl_need.Width = lbl_need_desc.Width
    lbl_need.Height = 20
    groupbox:Add(lbl_need)
    local lbl_act_desc = gui:Create("Label")
    lbl_act_desc.NoFrame = true
    lbl_act_desc.ForeColor = "255,209,209,209"
    lbl_act_desc.Font = "font_main"
    lbl_act_desc.Text = gui.TextManager:GetFormatText("ui_actinfo_act")
    lbl_act_desc.Top = lbl_need_desc.Top + lbl_need_desc.Height + 10
    lbl_act_desc.Left = lbl_need_desc.Left
    lbl_act_desc.Width = lbl_need_desc.Width
    lbl_act_desc.Height = lbl_need.Height
    lbl_name.LblLimitWidth = true
    groupbox:Add(lbl_act_desc)
    local lbl_act_var = gui:Create("Label")
    lbl_act_var.NoFrame = true
    lbl_act_var.ForeColor = "255,255,204,0"
    lbl_act_var.Font = "font_main"
    lbl_act_var.Text = nx_widestr(award)
    lbl_act_var.Top = lbl_act_desc.Top
    lbl_act_var.Left = lbl_act_desc.Left + lbl_act_desc.Width + 30
    lbl_act_var.Width = lbl_act_desc.Width
    lbl_act_var.Height = lbl_act_desc.Height
    groupbox:Add(lbl_act_var)
    local mltbox = gui:Create("MultiTextBox")
    mltbox.Transparent = true
    mltbox.NoFrame = true
    mltbox.Font = "font_main"
    local name = nx_widestr("<font color=\"#d1d1d1\" >") .. nx_widestr(dest_text) .. nx_widestr("</font>")
    mltbox:AddHtmlText(name, -1)
    local height = mltbox:GetContentHeight()
    local width = mltbox:GetContentWidth()
    mltbox.Top = lbl_act_var.Top + lbl_act_var.Height + 10
    mltbox.Left = (groupbox.Width - width) / 2
    mltbox.Width = width + 40
    mltbox.Height = height + 20
    groupbox:Add(mltbox)
    if button ~= nil and nx_is_valid(button) then
      button.Font = "font_main"
      button.Height = button.Height
      button.Width = button.Width
      button.Top = groupbox.Height - button.Height - 20
      button.Left = groupbox.Width / 2 - button.Width / 2
      groupbox:Add(button)
    end
    if nx_int(cur_count) >= nx_int(max_count) then
      local color = "255,200,200,200"
      groupbox.BlendColor = color
      lbl_flag.BlendColor = color
      lbl_pic.BlendColor = color
      lbl_name.ForeColor = color
      lbl_need_desc.ForeColor = color
      lbl_need.ForeColor = color
      lbl_act_desc.ForeColor = color
      lbl_act_var.ForeColor = color
      button.BlendColor = color
      button.FocusBlendColor = color
      button.PushBlendColor = color
      local lbl_finished = gui:Create("Label")
      lbl_finished.NoFrame = true
      lbl_finished.BlendColor = "255,255,255,255"
      lbl_finished.Width = 82
      lbl_finished.Height = 83
      lbl_finished.Top = (groupbox.Height - lbl_finished.Height) / 2
      lbl_finished.Left = (groupbox.Width - lbl_finished.Width) / 2
      lbl_finished.DrawMode = "FitWindow"
      lbl_finished.BackImage = "gui\\special\\huoyuedu\\com.png"
      groupbox:Add(lbl_finished)
    end
  end
end
function on_btn_link_click(button)
  if nx_number(button.DataSource) == nx_number(1) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Richang", ITT_SCHOOL_DANCE)
  elseif nx_number(button.DataSource) == nx_number(2) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Richang", ITT_TEAMFACULTY)
  elseif nx_number(button.DataSource) == nx_number(3) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Richang", ITT_AVATAR)
  elseif nx_number(button.DataSource) == nx_number(4) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Richang", ITT_ZJTX)
  elseif nx_number(button.DataSource) == nx_number(5) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "School", ITT_SPY_MENP)
  elseif nx_number(button.DataSource) == nx_number(6) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Shenghuo", ITT_ZADAN_GIFT)
  elseif nx_number(button.DataSource) == nx_number(7) then
    util_show_form("form_stage_main\\form_tvt\\form_tvt_tiguan", true)
  elseif nx_number(button.DataSource) == nx_number(8) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Shenghuo", ITT_LIFE_JOB)
  elseif nx_number(button.DataSource) == nx_number(9) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Guild", ITT_ACTIVE_ESCORT)
  elseif nx_number(button.DataSource) == nx_number(10) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "School", ITT_DUOSHU)
  elseif nx_number(button.DataSource) == nx_number(11) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "School", ITT_HUSHU)
  elseif nx_number(button.DataSource) == nx_number(12) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "biwu", ITT_TTLEITAI)
  elseif nx_number(button.DataSource) == nx_number(13) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "School", ITT_PATROL)
  elseif nx_number(button.DataSource) == nx_number(14) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Richang", ITT_JHHJ)
  elseif nx_number(button.DataSource) == nx_number(15) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Richang", ITT_KH_TREASURE)
  elseif nx_number(button.DataSource) == nx_number(16) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Richang", ITT_BANGFEI)
  elseif nx_number(button.DataSource) == nx_number(17) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "biwu", ITT_WORLDLEITAI)
  elseif nx_number(button.DataSource) == nx_number(18) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "biwu", ITT_QIECUO)
  elseif nx_number(button.DataSource) == nx_number(19) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Guild", ITT_YUNBIAO_ACTIVE)
  elseif nx_number(button.DataSource) == nx_number(20) then
    nx_execute("form_stage_main\\form_outland\\form_outland_main", "open_form")
  elseif nx_number(button.DataSource) == nx_number(21) then
    nx_execute("form_stage_main\\form_shijia\\form_shijia_guide", "open_form")
  elseif nx_number(button.DataSource) == nx_number(22) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "jindi", 0)
  elseif nx_number(button.DataSource) == nx_number(23) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "Richang", ITT_TIGUAN_DANSHUA)
  elseif nx_number(button.DataSource) == nx_number(24) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "School", ITT_MENPAIZHAN)
  elseif nx_number(button.DataSource) == nx_number(25) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "tongxing", ITT_JIANGHU_BATTLE)
  elseif nx_number(button.DataSource) == nx_number(26) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "biwu", ITT_MATCH_RIVERS)
  elseif nx_number(button.DataSource) == nx_number(27) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "biwu", ITT_MATCH_SCHOOL)
  elseif nx_number(button.DataSource) == nx_number(28) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "School", ITT_SCHOOL_KILL)
  elseif nx_number(button.DataSource) == nx_number(29) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "tianqi", ITT_DESERT_DB)
  elseif nx_number(button.DataSource) == nx_number(30) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "tianqi", ITT_JINLING_RS)
  elseif nx_number(button.DataSource) == nx_number(31) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "tianqi", ITT_TC_ZZJ)
  elseif nx_number(button.DataSource) == nx_number(32) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "tianqi", ITT_LUOYANG_DJ)
  elseif nx_number(button.DataSource) == nx_number(33) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "School", ITT_SCHOOLMOOT)
  elseif nx_number(button.DataSource) == nx_number(34) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "tongxing", ITT_KHD)
  elseif nx_number(button.DataSource) == nx_number(35) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "open_form", "tongxing", ITT_NLHH)
  elseif nx_number(button.DataSource) == nx_number(36) then
    nx_execute("form_stage_main\\form_clone\\form_clone_main", "open_form")
    nx_execute("form_stage_main\\form_clone\\form_clone_main", "goto_shashou")
  elseif nx_number(button.DataSource) == nx_number(37) then
  elseif nx_number(button.DataSource) == nx_number(38) then
    nx_execute("form_stage_main\\form_clone\\form_clone_main", "open_form")
    nx_execute("form_stage_main\\form_clone\\form_clone_main", "goto_tongtianfeng")
  elseif nx_number(button.DataSource) == nx_number(39) then
    nx_execute("form_stage_main\\form_school_destroy\\form_school_destroy_main", "open_form")
  elseif nx_number(button.DataSource) == nx_number(40) then
    nx_execute("form_stage_main\\form_shijia\\form_shijia_guide", "open_form")
  elseif nx_number(button.DataSource) == nx_number(41) then
    nx_execute("form_stage_main\\form_match\\form_match_sanmeng", "open_form")
  elseif nx_number(button.DataSource) == nx_number(42) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", "switch_to_sub_form", "rbtn_diplomacy", "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "rbtn_chase")
  elseif nx_number(button.DataSource) == nx_number(44) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", "switch_to_sub_form", "rbtn_diplomacy", "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "rbtn_guild_war")
  elseif nx_number(button.DataSource) == nx_number(45) then
    local switch_manager = nx_value("SwitchManager")
    if not nx_is_valid(switch_manager) then
      return
    end
    if not switch_manager:CheckSwitchEnable(812) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_wangchaobaozang_notopen"))
      return
    end
    local dbomall_path = "form_stage_main\\form_dbomall\\form_dbomall"
    local dbomall_form = util_get_form(dbomall_path)
    if nx_is_valid(dbomall_form) and dbomall_form.Visible ~= false then
      dbomall_form.Visible = false
      dbomall_form:Close()
    else
      util_auto_show_hide_form(dbomall_path)
      nx_execute(dbomall_path, "open_form", "form_stage_main\\form_dbomall\\form_dbortreasure")
    end
  elseif nx_number(button.DataSource) == nx_number(46) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "open_form")
  end
end
function on_btn_up_click(button)
  local form = button.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.gbox_container.Left >= 0 then
    return
  end
  local t_x = form.gbox_container.Left + form.gbox_visuallayer.Width
  local t_y = form.gbox_container.Top
  local common_execute = nx_value("common_execute")
  if common_execute:FindExecute("ControlMove", form.gbox_container) then
    return
  end
  common_execute:AddExecute("ControlMove", form.gbox_container, nx_float(0), nx_float(t_x), nx_float(t_y), nx_float(0.3), "")
end
function on_btn_down_click(button)
  local form = button.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if -form.gbox_container.Left >= form.gbox_container.Width - form.gbox_visuallayer.Width then
    return
  end
  local t_x = form.gbox_container.Left - form.gbox_visuallayer.Width
  local t_y = form.gbox_container.Top
  local common_execute = nx_value("common_execute")
  if common_execute:FindExecute("ControlMove", form.gbox_container) then
    return
  end
  common_execute:AddExecute("ControlMove", form.gbox_container, nx_float(0), nx_float(t_x), nx_float(t_y), nx_float(0.3), "")
end
function get_act_pic(text)
  if text == nil or text == "" then
    return ""
  end
  local text_array = util_split_string(nx_string(text), ":")
  if table.getn(text_array) < 2 then
    return ""
  end
  if text_array[1] == "tvt" then
    local mgr = nx_value("InteractManager")
    if not nx_is_valid(mgr) then
      return ""
    end
    return mgr:GetTvtPhoto(nx_int(text_array[2]))
  elseif text_array[1] == "single" then
    return text_array[2]
  end
  return ""
end
function check_get_day_state()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local text = get_day_arrays()
  if text == "" then
    return false
  end
  local text_array = util_split_string(nx_string(text), ",")
  local cur_day_var = player:QueryProp("DayActivityValue")
  if cur_day_var == nil then
    return false
  end
  for i = 1, table.getn(text_array) do
    local infos = util_split_string(nx_string(text_array[i]), "_")
    local condition_id = get_day_award_id(i)
    if table.getn(infos) >= 2 and condition_id ~= nil then
      local need_var = infos[1]
      if nx_int(cur_day_var) >= nx_int(need_var) and not box_is_got(player, condition_id) then
        return true
      end
    end
  end
  return false
end
function check_get_week_state()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local text = get_week_arrays()
  if text == "" then
    return false
  end
  local text_array = util_split_string(nx_string(text), ",")
  local cur_week_var = player:QueryProp("WeekActivityValue")
  if cur_week_var == nil then
    return false
  end
  for i = 1, table.getn(text_array) do
    local infos = util_split_string(nx_string(text_array[i]), "_")
    local condition_id = get_week_award_id(i)
    if table.getn(infos) >= 2 and condition_id ~= nil then
      local need_var = infos[1]
      if nx_int(cur_week_var) >= nx_int(need_var) and not box_is_got(player, condition_id) then
        return true
      end
    end
  end
  return false
end
function is_can_reward()
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(INI_FILE) then
    IniManager:LoadIniToManager(INI_FILE)
  end
  return check_get_day_state() or check_get_week_state()
end
function on_btn_onekey_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(699) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("ui_actreward_onekey_switch"))
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
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
  local cur_day_var = client_player:QueryProp("DayActivityValue")
  local need_consume = calc_fill_consume(cur_day_var)
  if nx_int(need_consume) == nx_int(0) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("ui_actreward_onekey_max"))
    return
  end
  local capital = client_player:QueryProp("CapitalType2")
  if need_consume >= capital then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("ui_actreward_onekey_qiong"))
    return
  end
  local text = gui.TextManager:GetFormatText("ui_actreward_onekey_need", need_consume)
  if ShowTipDialog(text) then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_AWARD), nx_int(2))
  end
end
function calc_fill_consume(cur_var)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("FillAwardValueCost"))
  if sec_index < 0 then
    return
  end
  local text = ini:ReadString(sec_index, nx_string("CostInfo"), "")
  if text == "" or text == nil then
    return
  end
  local text_array = util_split_string(nx_string(text), ";")
  if table.getn(text_array) < 1 then
    return
  end
  local step
  local need_var = 0
  for i = 1, table.getn(text_array) do
    local text_info = util_split_string(nx_string(text_array[i]), ",")
    if table.getn(text_info) >= 3 then
      local min_var = nx_int(nx_int(text_info[1]) - 1)
      local max_var = nx_int(text_info[2])
      local consume = nx_int(text_info[3])
      if step ~= nil then
        need_var = need_var + (max_var - min_var) * consume
      end
      if min_var <= nx_int(cur_var) and max_var >= nx_int(cur_var) then
        step = i
        need_var = (max_var - nx_int(cur_var)) * consume
      end
    end
  end
  return need_var
end
function ShowTipDialog(content)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, content)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  end
  return false
end
function on_grid_info_select_row(self, row)
  self:SetGridForeColor(row, 0, "255,197,184,159")
  self:SetGridForeColor(row, 1, "255,197,184,159")
  self:SetGridForeColor(row, 2, "255,255,255,0")
  self:SetGridForeColor(row, 3, "255,197,184,159")
end
function on_point_changed(form, prop_name, type, value)
  if nx_string(prop_name) == "ExpertPoint" then
    form.lbl_exp_point.Text = nx_widestr(math.floor(value / 1000))
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      if not form.show_exp_ani then
        form.show_exp_ani = true
      else
        form.ani_exp.Visible = true
        form.ani_exp.PlayMode = 0
        timer:Register(500, 1, nx_current(), "on_animation_end", form.ani_exp, -1, -1)
      end
    end
  elseif nx_string(prop_name) == "RelaxationPoint" then
    form.lbl_rel_point.Text = nx_widestr(math.floor(value / 1000))
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      if not form.show_rel_ani then
        form.show_rel_ani = true
      else
        form.ani_rel.Visible = true
        form.ani_rel.PlayMode = 0
        timer:Register(500, 1, nx_current(), "on_animation_end", form.ani_rel, -1, -1)
      end
    end
  end
end
function on_animation_end(ani)
  ani.Visible = false
end
function on_btn_exp_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_tvt\\form_tvt_exchange")
end
function on_btn_close_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_dbomall\\form_dboactreward")
end
function on_btn_box_get_capture(btn)
  local gui = nx_value("gui")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local text = ""
  local ctrl_name = btn.Name
  if ctrl_name == "btn_box_" .. btn.DataSource then
    text = gui.TextManager:GetText("tips_actreward_box_" .. btn.DataSource)
  elseif ctrl_name == "btn_week_box_" .. btn.DataSource then
    text = gui.TextManager:GetText("tips_actreward_week_box_" .. btn.DataSource)
  else
    return
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
end
function on_btn_box_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_great_news_click(btn)
  util_show_form("form_stage_main\\form_relation\\form_relation_news", true)
end
function close_form()
  local form = nx_value("form_stage_main\\form_dbomall\\form_dboactreward")
  if nx_is_valid(form) then
    form:Close()
  end
end
