require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\switch\\url_define")
require("form_stage_main\\form_tvt\\define")
local FORM = "form_stage_main\\form_tvt\\form_tvt_merge"
local TVT_LEVEL_MAX = 5
local EFFECT_ELAPSE = 0.3
local PAGE_NUM = 5
local rmd_page_count = 6
local act_page_count = 12
local task_page_count = 6
local temp_rmd_info = {}
local temp_act_info = {}
local INI_FILE = "ini\\power_guide.ini"
local INI_ACT_FILE = "share\\Rule\\ActivityAward.ini"
local INI_RMD_FILE = "share\\Rule\\InteractRecommend.ini"
local tvt_level_pic = {
  [1] = {
    on = "gui\\language\\ChineseS\\newtvt\\pt_on.png",
    nor = "gui\\language\\ChineseS\\newtvt\\pt_out.png",
    sel = "gui\\language\\ChineseS\\newtvt\\pt_down.png"
  },
  [2] = {
    on = "gui\\language\\ChineseS\\newtvt\\pt_2_on.png",
    nor = "gui\\language\\ChineseS\\newtvt\\pt_2_out.png",
    sel = "gui\\language\\ChineseS\\newtvt\\pt_2_down.png"
  },
  [3] = {
    on = "gui\\language\\ChineseS\\newtvt\\pt_3_on.png",
    nor = "gui\\language\\ChineseS\\newtvt\\pt_3_out.png",
    sel = "gui\\language\\ChineseS\\newtvt\\pt_3_down.png"
  },
  [4] = {
    on = "gui\\language\\ChineseS\\newtvt\\pt_4_on.png",
    nor = "gui\\language\\ChineseS\\newtvt\\pt_4_out.png",
    sel = "gui\\language\\ChineseS\\newtvt\\pt_4_down.png"
  },
  [5] = {
    on = "gui\\language\\ChineseS\\newtvt\\gaoji_on.png",
    nor = "gui\\language\\ChineseS\\newtvt\\gaoji_out.png",
    sel = "gui\\language\\ChineseS\\newtvt\\gaoji_down.png"
  }
}
local prize_image_t = {
  [0] = "gui\\language\\ChineseS\\tvt\\icon_1.png",
  [1] = "gui\\language\\ChineseS\\tvt\\icon_1.png",
  [2] = "gui\\language\\ChineseS\\tvt\\icon_13.png",
  [3] = "gui\\language\\ChineseS\\tvt\\icon_5.png",
  [4] = "gui\\language\\ChineseS\\tvt\\icon_14.png",
  [5] = "gui\\language\\ChineseS\\tvt\\icon_3.png",
  [6] = "gui\\language\\ChineseS\\tvt\\icon_6.png",
  [7] = "gui\\language\\ChineseS\\tvt\\icon_15.png"
}
local tvtclass_type = {
  [1] = "tianqi",
  [2] = "biwu",
  [3] = "tongxing",
  [4] = "Shenghuo",
  [5] = "jindi",
  [6] = "Richang",
  [7] = "Guild",
  [8] = "School"
}
function on_main_form_init(form)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(INI_FILE) then
    IniManager:LoadIniToManager(INI_FILE)
  end
  if not IniManager:IsIniLoadedToManager(INI_ACT_FILE) then
    IniManager:LoadIniToManager(INI_ACT_FILE)
  end
  if not IniManager:IsIniLoadedToManager(INI_RMD_FILE) then
    IniManager:LoadIniToManager(INI_RMD_FILE)
  end
  form.max_day_var = get_max_day_var()
  form.max_week_var = get_max_week_var()
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width + form.groupbox_sub.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.show_exp_ani = false
  form.show_rel_ani = false
  form.ani_rel.Visible = false
  form.ani_exp.Visible = false
  refresh_box_pos(form)
  refresh_week_box_pos(form)
  form.groupbox_sub.Visible = false
  form.sub_ani_over = true
  form.type = -1
  form.act_type = 1
  form.taskid = 0
  form.task_index = 0
  form.task_type = 0
  form.act_curpage = 1
  form.act_maxpage = 1
  form.rmd_curpage = 1
  form.rmd_maxpage = 1
  form.task_curpage = 1
  form.task_maxpage = 1
  form.sel_sub_form = ""
  form.tvt_time = 0
  form.rmd_tasktitle = ""
  form.rmd_taskid = 0
  form.rmd_taskimage = ""
  form.rmd_taskprize = ""
  form.rmd_taskintro = ""
  form.rmd_taskcondition = ""
  form.rmd_tasknpc = ""
  send_server_msg(g_msg_update_notice)
  send_server_msg(g_msg_base_info)
  send_server_msg(g_msg_recommend_info)
  send_server_msg(g_msg_new_act_info)
  form.tvt_rbtn_2.Checked = true
  form.btn_new_join.Enabled = false
  form.btn_quit.Enabled = false
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddRolePropertyBind("DayActivityValue", "int", form, nx_current(), "on_day_act_changed")
    data_binder:AddRolePropertyBind("WeekActivityValue", "int", form, nx_current(), "on_week_act_changed")
    data_binder:AddTableBind("ActivityRewardRec", form, nx_current(), "on_reward_rec_change")
    data_binder:AddRolePropertyBind("ExpertPoint", "int", form, nx_current(), "on_point_changed")
    data_binder:AddRolePropertyBind("RelaxationPoint", "int", form, nx_current(), "on_point_changed")
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local school = ""
  if client_player:FindProp("School") then
    school = nx_string(client_player:QueryProp("School"))
  end
  if (school == "" or school == "0") and client_player:FindProp("Force") then
    school = nx_string(client_player:QueryProp("Force"))
  end
  if (school == "" or school == "0") and client_player:FindProp("NewSchool") then
    school = nx_string(client_player:QueryProp("NewSchool"))
  end
  if school == "" then
    form.tvt_rbtn_3.Visible = false
  else
    form.tvt_rbtn_3.Visible = true
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function close_form()
  local form = nx_value(FORM)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function clone_control(form, control_name, aid)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local control = nx_custom(form, nx_string(control_name))
  local new_control = gui.Designer:Clone(control)
  if not nx_is_valid(new_control) then
    return nx_null()
  end
  nx_bind_script(new_control, nx_current())
  new_control.DesignMode = false
  new_control.Name = string.format("%s_%s", nx_string(control_name), nx_string(aid))
  new_control.Visible = true
  new_control.aid = aid
  local child_list = control:GetChildControlList()
  for _, child_control in pairs(child_list) do
    if nx_is_valid(child_control) then
      local new_child = gui.Designer:Clone(child_control)
      new_child.fatherctl = new_control
      new_child.DesignMode = false
      new_child.Name = string.format("%s_%s", nx_string(child_control.Name), nx_string(aid))
      new_child.aid = aid
      new_control:Add(new_child)
    end
  end
  return new_control
end
function on_tvt_rbtn_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.tvt_rbtn_1.Checked == true then
    form.rmd_box.Visible = true
    form.act_box.Visible = false
    form.groupbox_btns.Visible = false
    form.task_box.Visible = false
    refresh_rmd_form()
    close_sub_form(form, false)
  end
end
function on_tvt_rbtn_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.tvt_rbtn_2.Checked == true then
    form.rmd_box.Visible = false
    form.act_box.Visible = true
    form.groupbox_btns.Visible = false
    form.task_box.Visible = false
    form.act_rbtn_all.Checked = true
    close_sub_form(form, false)
  end
end
function on_tvt_rbtn_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.tvt_rbtn_3.Checked == true then
    form.rmd_box.Visible = false
    form.act_box.Visible = false
    form.groupbox_btns.Visible = false
    form.task_box.Visible = false
    refresh_strongbox()
    close_sub_form(form, false)
  end
end
function on_tvt_rbtn_4_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.tvt_rbtn_4.Checked == true then
    form.rmd_box.Visible = false
    form.act_box.Visible = false
    form.groupbox_btns.Visible = false
    form.task_box.Visible = true
    refresh_task_form()
    close_sub_form(form, false)
  end
end
function on_act_rbtn_all_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.act_rbtn_all.Checked == true then
    form.act_curpage = 1
    form.act_type = 1
    refresh_act_form()
  end
end
function on_act_rbtn_gz_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.act_rbtn_gz.Checked == true then
    form.act_curpage = 1
    form.act_type = 2
    refresh_act_form()
  end
end
function on_act_rbtn_xw_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.act_rbtn_xw.Checked == true then
    form.act_curpage = 1
    form.act_type = 3
    refresh_act_form()
  end
end
function on_act_rbtn_zq_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.act_rbtn_zq.Checked == true then
    form.act_curpage = 1
    form.act_type = 4
    refresh_act_form()
  end
end
function refresh_form(...)
  temp_rmd_info = arg
  refresh_rmd_form()
end
function refresh_actform(...)
  temp_act_info = arg
  refresh_act_form()
end
function refresh_rmd_form()
  local form = nx_value(FORM)
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
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_ACT_FILE)
  if not nx_is_valid(ini) then
    return
  end
  local switch_open = {
    [ITT_MARRY_TASK] = ST_FUNCTION_MARRY
  }
  local group = form.recommendbox
  group:DeleteAll()
  local gui = nx_value("gui")
  local max_count = table.getn(temp_rmd_info)
  local index = 1
  local begin_index = (form.rmd_curpage - 1) * rmd_page_count + 1
  local end_index = form.rmd_curpage * rmd_page_count
  if max_count < end_index then
    end_index = max_count
  end
  for i = begin_index, end_index do
    local item_box = clone_control(form, "recommend_item", nx_string(index))
    item_box.Visible = true
    item_box.Top = nx_int((index - 1) / 2) * item_box.Height
    item_box.Left = nx_int((index - 1) % 2) * item_box.Width + 4
    if index % 2 == 0 then
      item_box.Left = item_box.Left + 4
    end
    item_box.Top = item_box.Top + 4 * nx_int((index - 1) / 2)
    group:Add(item_box)
    local tvt_type = nx_int(temp_rmd_info[i])
    local info = mgr:GetTvtBaseInfo(tvt_type)
    local child_name = string.format("%s_%s", nx_string("rmd_cbtn"), nx_string(index))
    local rbtn_control = item_box:Find(child_name)
    rbtn_control.tvt_type = tvt_type
    item_box.sel_rbtn = rbtn_control
    nx_bind_script(rbtn_control, nx_current())
    nx_callback(rbtn_control, "on_click", "on_rmditem_click")
    child_name = string.format("%s_%s", nx_string("rmd_back"), nx_string(index))
    local back_control = item_box:Find(child_name)
    back_control.BackImage = nx_string(mgr:GetTvtBackImage(tvt_type))
    child_name = string.format("%s_%s", nx_string("rmd_prize"), nx_string(index))
    local tmp_imagegrid = item_box:Find(child_name)
    tmp_imagegrid.type = tvt_type
    child_name = string.format("%s_%s", nx_string("rmd_prize_lbl"), nx_string(index))
    local prize_lbl = item_box:Find(child_name)
    prize_lbl.Visible = false
    if nx_int(tvt_type) == nx_int(ITT_HUASHAN_FIGHTER) then
      tmp_imagegrid:AddItem(nx_int(0), "gui\\language\\ChineseS\\tvt\\icon_2.png", "", 1, -1)
      tmp_imagegrid:AddItem(nx_int(1), "gui\\language\\ChineseS\\tvt\\icon_9.png", "", 1, -1)
      prize_lbl.Visible = true
    else
      local grid_index = 0
      local table_len = table.getn(prize_image_t)
      for j = 1, 9 do
        if mgr:IsHavePrizeType(nx_int(tvt_type), j - 1) and table_len >= j - 1 then
          local image = prize_image_t[j - 1]
          tmp_imagegrid:AddItem(grid_index, image, "", 1, -1)
          grid_index = grid_index + 1
          prize_lbl.Visible = true
        end
      end
    end
    nx_bind_script(tmp_imagegrid, nx_current())
    nx_callback(tmp_imagegrid, "on_mousein_grid", "on_imagegrid_2_get_capture")
    nx_callback(tmp_imagegrid, "on_mouseout_grid", "on_imagegrid_2_lost_capture")
    local is_zc = false
    local act_id = get_zcact_id(tvt_type)
    if act_id ~= "" then
      is_zc = true
    else
      act_id = get_act_id(tvt_type)
    end
    local sec_index = ini:FindSectionIndex(nx_string(act_id))
    child_name = string.format("%s_%s", nx_string("rmd_actcount"), nx_string(index))
    local actcount_control = item_box:Find(child_name)
    actcount_control.Visible = false
    child_name = string.format("%s_%s", nx_string("rmd_act_lbl"), nx_string(index))
    local act_lbl_control = item_box:Find(child_name)
    act_lbl_control.Visible = false
    local award = ini:ReadString(sec_index, nx_string("AwardValue"), "")
    if nx_number(award) > nx_number(0) then
      act_lbl_control.Visible = true
      actcount_control.Visible = true
      actcount_control.Text = nx_widestr(award)
    end
    child_name = string.format("%s_%s", nx_string("cmd_validnum"), nx_string(index))
    local validnum_control = item_box:Find(child_name)
    validnum_control.Visible = false
    child_name = string.format("%s_%s", nx_string("rmd_valid_lbl"), nx_string(index))
    local rmd_valid_lbl_control = item_box:Find(child_name)
    rmd_valid_lbl_control.Visible = false
    local cur_count = 0
    local rec_row = client_player:FindRecordRow("ActivityCompliteRec", 0, nx_int(act_id), 0)
    if 0 <= rec_row then
      cur_count = client_player:QueryRecord("ActivityCompliteRec", rec_row, 1)
    end
    local max_count = ini:ReadString(sec_index, nx_string("NeedTimes"), "")
    local need_text = nx_widestr(cur_count) .. nx_widestr("/") .. nx_widestr(max_count)
    if nx_int(max_count) > nx_int(0) then
      rmd_valid_lbl_control.Visible = true
      validnum_control.Visible = true
      validnum_control.Text = need_text
      if nx_int(cur_count) >= nx_int(max_count) then
        back_control.BlendColor = "250,255,255,255"
      else
        back_control.BlendColor = "255,255,255,255"
      end
    end
    child_name = string.format("%s_%s", nx_string("rmd_open"), nx_string(index))
    local open_control = item_box:Find(child_name)
    child_name = string.format("%s_%s", nx_string("rmd_close"), nx_string(index))
    local close_control = item_box:Find(child_name)
    local bopen = false
    if nx_int(tvt_type) < nx_int(1000) then
      if mgr:IsInteractOpen(tvt_type) then
        text = nx_widestr(info[16])
        bopen = true
      end
    else
      bopen = true
    end
    if bopen == true then
      open_control.Visible = true
      close_control.Visible = false
    else
      open_control.Visible = false
      close_control.Visible = true
    end
    child_name = string.format("%s_%s", nx_string("rmd_flag"), nx_string(index))
    local flag_control = item_box:Find(child_name)
    local pvp_info = mgr:GetTvtSugPic(tvt_type)
    flag_control.BackImage = pvp_info
    index = index + 1
  end
  form.rmd_maxpage = nx_int(max_count / rmd_page_count)
  if max_count % rmd_page_count ~= 0 then
    form.rmd_maxpage = form.rmd_maxpage + 1
  end
  form.lbl_rmd_curpage.Text = nx_widestr(form.rmd_curpage)
  form.lbl_rmd_maxpage.Text = nx_widestr(form.rmd_maxpage)
end
function refresh_act_form()
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local switch_open = {
    [ITT_MARRY_TASK] = ST_FUNCTION_MARRY
  }
  local group = form.activitybox
  group:DeleteAll()
  local gui = nx_value("gui")
  local index = 1
  local cur_index = 0
  local begin_index = (form.act_curpage - 1) * act_page_count + 1
  local end_index = form.act_curpage * act_page_count
  local temp_table = {}
  for i = 1, table.getn(temp_act_info) do
    local tvt_type = nx_int(temp_act_info[i])
    local switchopen = true
    if switch_open[nx_number(tvt_type)] ~= nil then
      switchopen = switch_manager:CheckSwitchEnable(switch_open[nx_number(tvt_type)])
    end
    if form.act_type == 1 then
      if switchopen then
        table.insert(temp_table, tvt_type)
        index = index + 1
      end
    elseif form.act_type == 2 then
      if (mgr:IsHavePrizeType(nx_int(tvt_type), 0) or mgr:IsHavePrizeType(nx_int(tvt_type), 1) or mgr:IsHavePrizeType(nx_int(tvt_type), 2)) and switchopen then
        table.insert(temp_table, tvt_type)
        index = index + 1
      end
    elseif form.act_type == 3 then
      if (mgr:IsHavePrizeType(nx_int(tvt_type), 4) or nx_int(tvt_type) == nx_int(ITT_HUASHAN_FIGHTER)) and switchopen then
        table.insert(temp_table, tvt_type)
        index = index + 1
      end
    elseif form.act_type == 4 and (mgr:IsHavePrizeType(nx_int(tvt_type), 7) or nx_int(tvt_type) == nx_int(ITT_HUASHAN_FIGHTER)) and switchopen then
      table.insert(temp_table, tvt_type)
      index = index + 1
    end
  end
  local temp_count = table.getn(temp_table)
  if end_index > temp_count then
    end_index = temp_count
  end
  local sub_index = 1
  for i = begin_index, end_index do
    local tvt_type = nx_int(temp_table[i])
    local switchopen = true
    if switch_open[nx_number(tvt_type)] ~= nil then
      switchopen = switch_manager:CheckSwitchEnable(switch_open[nx_number(tvt_type)])
    end
    if form.act_type == 1 then
      if switchopen then
        set_act_item(form, sub_index, tvt_type)
        sub_index = sub_index + 1
      end
    elseif form.act_type == 2 then
      if (mgr:IsHavePrizeType(nx_int(tvt_type), 0) or mgr:IsHavePrizeType(nx_int(tvt_type), 1) or mgr:IsHavePrizeType(nx_int(tvt_type), 2)) and switchopen then
        set_act_item(form, sub_index, tvt_type)
        sub_index = sub_index + 1
      end
    elseif form.act_type == 3 then
      if (mgr:IsHavePrizeType(nx_int(tvt_type), 4) or nx_int(tvt_type) == nx_int(ITT_HUASHAN_FIGHTER)) and switchopen then
        set_act_item(form, sub_index, tvt_type)
        sub_index = sub_index + 1
      end
    elseif form.act_type == 4 and (mgr:IsHavePrizeType(nx_int(tvt_type), 7) or nx_int(tvt_type) == nx_int(ITT_HUASHAN_FIGHTER)) and switchopen then
      set_act_item(form, sub_index, tvt_type)
      sub_index = sub_index + 1
    end
  end
  form.act_maxpage = nx_int(index / act_page_count)
  if index % act_page_count ~= 0 then
    form.act_maxpage = form.act_maxpage + 1
  end
  form.lbl_act_curpage.Text = nx_widestr(form.act_curpage)
  form.lbl_act_maxpage.Text = nx_widestr(form.act_maxpage)
end
function set_act_item(form, cur_index, tvt_type)
  local gui = nx_value("gui")
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_ACT_FILE)
  if not nx_is_valid(ini) then
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
  local group = form.activitybox
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local item_box = clone_control(form, "act_item", nx_string(cur_index))
  item_box.Visible = true
  item_box.Top = nx_int((cur_index - 1) / 2) * item_box.Height
  item_box.Left = nx_int((cur_index - 1) % 2) * item_box.Width + 3
  if cur_index % 2 == 0 then
    item_box.Left = item_box.Left + 3
  end
  item_box.Top = item_box.Top + 3 * nx_int((cur_index - 1) / 2)
  group:Add(item_box)
  local info = mgr:GetTvtBaseInfo(tvt_type)
  local child_name = string.format("%s_%s", nx_string("act_rbtn"), nx_string(cur_index))
  local rbtn_control = item_box:Find(child_name)
  rbtn_control.tvt_type = tvt_type
  item_box.sel_rbtn = rbtn_control
  nx_bind_script(rbtn_control, nx_current())
  nx_callback(rbtn_control, "on_click", "on_rmditem_click")
  child_name = string.format("%s_%s", nx_string("act_name"), nx_string(cur_index))
  local act_name_control = item_box:Find(child_name)
  act_name_control.Text = nx_widestr(info[1])
  child_name = string.format("%s_%s", nx_string("act_gz"), nx_string(cur_index))
  local act_gz_control = item_box:Find(child_name)
  act_gz_control.Visible = false
  child_name = string.format("%s_%s", nx_string("act_xw"), nx_string(cur_index))
  local act_xw_control = item_box:Find(child_name)
  act_xw_control.Visible = false
  child_name = string.format("%s_%s", nx_string("act_zq"), nx_string(cur_index))
  local act_zq_control = item_box:Find(child_name)
  act_zq_control.Visible = false
  local flag_count = 0
  if mgr:IsHavePrizeType(nx_int(tvt_type), 0) or mgr:IsHavePrizeType(nx_int(tvt_type), 1) or mgr:IsHavePrizeType(nx_int(tvt_type), 2) then
    act_gz_control.Visible = true
    act_gz_control.Left = 25
    flag_count = flag_count + 1
    rbtn_control.NormalImage = "gui\\special\\qingxiu_bqy\\bg_g_out.png"
    rbtn_control.FocusImage = "gui\\special\\qingxiu_bqy\\bg_g_on.png"
    rbtn_control.CheckedImage = "gui\\special\\qingxiu_bqy\\bg_g_down.png"
  end
  if mgr:IsHavePrizeType(nx_int(tvt_type), 4) or nx_int(tvt_type) == nx_int(ITT_HUASHAN_FIGHTER) then
    act_xw_control.Visible = true
    if flag_count == 0 then
      act_xw_control.Left = 25
    else
      act_xw_control.Left = 46
    end
    if flag_count ~= 1 then
      rbtn_control.NormalImage = "gui\\special\\qingxiu_bqy\\bg_b_out.png"
      rbtn_control.FocusImage = "gui\\special\\qingxiu_bqy\\bg_b_on.png"
      rbtn_control.CheckedImage = "gui\\special\\qingxiu_bqy\\bg_b_down.png"
    end
    flag_count = flag_count + 1
  end
  if mgr:IsHavePrizeType(nx_int(tvt_type), 7) then
    act_zq_control.Visible = true
    if flag_count == 0 then
      act_zq_control.Left = 25
    elseif flag_count == 1 then
      act_zq_control.Left = 46
    else
      act_zq_control.Left = 67
    end
  end
  local is_zc = false
  local act_id = get_zcact_id(tvt_type)
  if act_id ~= "" then
    is_zc = true
  else
    act_id = get_act_id(tvt_type)
  end
  local sec_index = ini:FindSectionIndex(nx_string(act_id))
  child_name = string.format("%s_%s", nx_string("act_value_lbl"), nx_string(cur_index))
  local act_value_lbl_control = item_box:Find(child_name)
  act_value_lbl_control.Visible = false
  child_name = string.format("%s_%s", nx_string("act_value_num"), nx_string(cur_index))
  local act_value_num_control = item_box:Find(child_name)
  act_value_num_control.Visible = false
  local award = ini:ReadString(sec_index, nx_string("AwardValue"), "")
  if nx_number(award) > nx_number(0) then
    act_value_lbl_control.Visible = true
    act_value_num_control.Visible = true
    act_value_num_control.Text = nx_widestr(award)
  end
  child_name = string.format("%s_%s", nx_string("act_valid_lbl"), nx_string(cur_index))
  local act_valid_lbl_control = item_box:Find(child_name)
  act_valid_lbl_control.Visible = false
  child_name = string.format("%s_%s", nx_string("act_valid_num"), nx_string(cur_index))
  local act_valid_num_control = item_box:Find(child_name)
  act_valid_num_control.Visible = false
  if is_zc == true then
    act_valid_lbl_control.Text = nx_widestr(gui.TextManager:GetText("qinxiu_bqy_week"))
  else
    act_valid_lbl_control.Text = nx_widestr(gui.TextManager:GetText("qinxiu_bqy_day"))
  end
  local cur_count = 0
  local rec_row = client_player:FindRecordRow("ActivityCompliteRec", 0, nx_int(act_id), 0)
  if 0 <= rec_row then
    cur_count = client_player:QueryRecord("ActivityCompliteRec", rec_row, 1)
  end
  local max_count = ini:ReadString(sec_index, nx_string("NeedTimes"), "")
  local need_text = nx_widestr(cur_count) .. nx_widestr("/") .. nx_widestr(max_count)
  if nx_int(max_count) > nx_int(0) then
    act_valid_lbl_control.Visible = true
    act_valid_num_control.Visible = true
    act_valid_num_control.Text = need_text
    if nx_int(cur_count) >= nx_int(max_count) then
      rbtn_control.BlendColor = "250,255,255,255"
      rbtn_control.FocusBlendColor = "250,255,255,255"
      rbtn_control.PushBlendColor = "250,255,255,255"
      act_gz_control.BlendColor = "250,255,255,255"
      act_xw_control.BlendColor = "250,255,255,255"
      act_zq_control.BlendColor = "250,255,255,255"
    else
      rbtn_control.BlendColor = "255,255,255,255"
      rbtn_control.FocusBlendColor = "255,255,255,255"
      rbtn_control.PushBlendColor = "255,255,255,255"
      act_gz_control.BlendColor = "255,255,255,255"
      act_xw_control.BlendColor = "255,255,255,255"
      act_zq_control.BlendColor = "255,255,255,255"
    end
  end
end
function refresh_strongbox()
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local ST_FUNCTION_POWER_GUIDE = 858
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_POWER_GUIDE) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_powerguide_001"))
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
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
  if not condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(29413)) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_powerguide_002"))
    return
  end
  form.groupbox_btns.Visible = true
end
function refresh_task_form()
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
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
  local book = client_player:QueryProp("Book")
  local group = form.rmdtaskbox
  group:DeleteAll()
  local temp_table = {}
  local gui = nx_value("gui")
  local max_count = mgr:GetRmdTaskCount()
  local temp_count = 0
  for i = 1, max_count do
    local task_list = mgr:GetTaskid(i - 1)
    temp_count = 0
    for j = 1, table.getn(task_list) do
      local taskid = task_list[j]
      local completed = taskmgr:CompletedByRec(nx_string(taskid))
      if nx_int(completed) ~= nx_int(1) then
        table.insert(temp_table, j)
        break
      end
      temp_count = temp_count + 1
      if temp_count == table.getn(task_list) then
        table.insert(temp_table, j)
      end
    end
  end
  local task_list = mgr:GetDramaTaskid(book)
  temp_count = 0
  local is_have_book = false
  for j = 1, table.getn(task_list) do
    local taskid = task_list[j]
    local completed = taskmgr:CompletedByRec(nx_string(taskid))
    if nx_int(completed) ~= nx_int(1) then
      table.insert(temp_table, j)
      is_have_book = true
      break
    end
    temp_count = temp_count + 1
    if temp_count == table.getn(task_list) then
      table.insert(temp_table, j)
      is_have_book = true
    end
  end
  local maxcount = table.getn(temp_table)
  local index = 1
  local begin_index = (form.task_curpage - 1) * task_page_count + 1
  local end_index = form.task_curpage * task_page_count
  if maxcount < end_index then
    end_index = maxcount
  end
  for i = begin_index, end_index do
    local item_box = clone_control(form, "task_item", nx_string(index))
    item_box.Visible = true
    item_box.Top = nx_int((index - 1) / 2) * item_box.Height
    item_box.Left = nx_int((index - 1) % 2) * item_box.Width + 4
    if index % 2 == 0 then
      item_box.Left = item_box.Left + 4
    end
    item_box.Top = item_box.Top + 4 * nx_int((index - 1) / 2)
    group:Add(item_box)
    local title_list = {}
    local taskid_list = {}
    local image_list = {}
    local prize_list = {}
    local intro_list = {}
    local condition_list = {}
    local npc_list = {}
    local task_index = nx_number(temp_table[i])
    if is_have_book == true and i == maxcount then
      title_list = mgr:GetDramaTaskTitle(book)
      taskid_list = mgr:GetDramaTaskid(book)
      image_list = mgr:GetDramaTaskImage(book)
      prize_list = mgr:GetDramaTaskPrize(book)
      intro_list = mgr:GetDramaTaskIntro(book)
      condition_list = mgr:GetDramaTaskCondition(book)
      npc_list = mgr:GetDramaTaskNpc(book)
    else
      title_list = mgr:GetTaskTitle(i - 1)
      taskid_list = mgr:GetTaskid(i - 1)
      image_list = mgr:GetTaskImage(i - 1)
      prize_list = mgr:GetTaskPrize(i - 1)
      intro_list = mgr:GetTaskIntro(i - 1)
      condition_list = mgr:GetTaskCondition(i - 1)
      npc_list = mgr:GetTaskNpc(i - 1)
    end
    local title = nx_widestr(gui.TextManager:GetText(nx_string(title_list[task_index])))
    local taskid = nx_int(taskid_list[task_index])
    local image = nx_string(image_list[task_index])
    local prize = nx_string(prize_list[task_index])
    local intro = nx_string(intro_list[task_index])
    local condition = nx_string(condition_list[task_index])
    local npc = nx_string(npc_list[task_index])
    local child_name = string.format("%s_%s", nx_string("task_cbtn"), nx_string(index))
    local rbtn_control = item_box:Find(child_name)
    rbtn_control.task_type = i
    rbtn_control.task_index = task_index
    rbtn_control.taskid = taskid
    rbtn_control.rmd_tasktitle = title
    rbtn_control.rmd_taskimage = image
    rbtn_control.rmd_taskprize = prize
    rbtn_control.rmd_taskintro = intro
    rbtn_control.rmd_taskcondition = condition
    rbtn_control.rmd_tasknpc = npc
    item_box.sel_rbtn = rbtn_control
    nx_bind_script(rbtn_control, nx_current())
    nx_callback(rbtn_control, "on_click", "on_taskitem_click")
    child_name = string.format("%s_%s", nx_string("task_back"), nx_string(index))
    local back_control = item_box:Find(child_name)
    back_control.BackImage = nx_string(image)
    local completed = taskmgr:CompletedByRec(nx_string(taskid))
    if nx_int(completed) == nx_int(1) then
      back_control.BlendColor = "250,255,255,255"
    else
      back_control.BlendColor = "255,255,255,255"
    end
    child_name = string.format("%s_%s", nx_string("task_prize"), nx_string(index))
    local tmp_imagegrid = item_box:Find(child_name)
    tmp_imagegrid.taskid = taskid
    local str_prize = util_split_string(prize, ",")
    for j = 1, table.getn(str_prize) do
      local sub_prize = str_prize[j]
      local photo = ItemQuery:GetItemPropByConfigID(sub_prize, "Photo")
      tmp_imagegrid:AddItem(j - 1, photo, nx_widestr(sub_prize), 1, 0)
    end
    nx_bind_script(tmp_imagegrid, nx_current())
    nx_callback(tmp_imagegrid, "on_mousein_grid", "on_taskprize_get_capture")
    nx_callback(tmp_imagegrid, "on_mouseout_grid", "on_taskprize_lost_capture")
    index = index + 1
  end
  form.task_maxpage = nx_int(maxcount / task_page_count)
  if maxcount % task_page_count ~= 0 then
    form.task_maxpage = form.task_maxpage + 1
  end
  form.lbl_task_curpage.Text = nx_widestr(form.task_curpage)
  form.lbl_task_maxpage.Text = nx_widestr(form.task_maxpage)
end
function on_taskitem_click(rbtn)
  local form = rbtn.ParentForm
  form.groupbox_jianghu.Visible = false
  form.groupbox_strong.Visible = false
  form.groupbox_task.Visible = true
  change_all_rbtn(rbtn)
  if form.groupbox_sub.Visible == true then
    if nx_int(form.taskid) == nx_int(rbtn.taskid) then
      close_sub_form(form, false)
    else
      form.task_index = rbtn.task_index
      form.task_type = rbtn.task_type
      form.taskid = rbtn.taskid
      form.rmd_tasktitle = rbtn.rmd_tasktitle
      form.rmd_taskid = rbtn.taskid
      form.rmd_taskimage = rbtn.rmd_taskimage
      form.rmd_taskprize = rbtn.rmd_taskprize
      form.rmd_taskintro = rbtn.rmd_taskintro
      form.rmd_taskcondition = rbtn.rmd_taskcondition
      form.rmd_tasknpc = rbtn.rmd_tasknpc
      close_sub_form(form, true)
    end
  else
    form.task_index = rbtn.task_index
    form.task_type = rbtn.task_type
    form.taskid = rbtn.taskid
    form.rmd_tasktitle = rbtn.rmd_tasktitle
    form.rmd_taskid = rbtn.taskid
    form.rmd_taskimage = rbtn.rmd_taskimage
    form.rmd_taskprize = rbtn.rmd_taskprize
    form.rmd_taskintro = rbtn.rmd_taskintro
    form.rmd_taskcondition = rbtn.rmd_taskcondition
    form.rmd_tasknpc = rbtn.rmd_tasknpc
    on_refresh_subtask_form(form)
  end
end
function on_refresh_subtask_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_task_intro:Clear()
  form.mltbox_task_condition:Clear()
  form.mltbox_task_npc:Clear()
  form.imagegrid_task_prize:Clear()
  local gui = nx_value("gui")
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local task_index = nx_number(form.task_index)
  local task_type = form.task_type
  form.mltbox_task_intro.HtmlText = nx_widestr(gui.TextManager:GetText(form.rmd_taskintro))
  form.mltbox_task_condition.HtmlText = nx_widestr(gui.TextManager:GetText(form.rmd_taskcondition))
  form.mltbox_task_npc.HtmlText = nx_widestr(gui.TextManager:GetText(form.rmd_tasknpc))
  local prize = form.rmd_taskprize
  local str_prize = util_split_string(prize, ",")
  for j = 1, table.getn(str_prize) do
    local sub_prize = str_prize[j]
    local photo = ItemQuery:GetItemPropByConfigID(sub_prize, "Photo")
    form.imagegrid_task_prize:AddItem(j, photo, nx_widestr(sub_prize), 1, 0)
  end
  begin_move(form)
end
function on_rmditem_click(rbtn)
  local form = rbtn.ParentForm
  local child_gb = rbtn.Parent
  form.groupbox_jianghu.Visible = true
  form.groupbox_strong.Visible = false
  form.groupbox_task.Visible = false
  change_all_rbtn(rbtn)
  if form.groupbox_sub.Visible == true then
    if nx_int(form.type) == nx_int(rbtn.tvt_type) then
      close_sub_form(form, false)
    else
      form.type = rbtn.tvt_type
      close_sub_form(form, true)
    end
  else
    form.type = rbtn.tvt_type
    refresh_jianghu_info(form)
  end
end
function refresh_jianghu_info(form)
  local gui = nx_value("gui")
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  form.mltbox_rule:Clear()
  form.mltbox_need:Clear()
  form.mltbox_prize:Clear()
  form.mltbox_23:Clear()
  form.imagegrid_2:Clear()
  local tvt_type = form.type
  local info = mgr:GetTvtBaseInfo(tvt_type)
  form.lbl_23.Text = nx_widestr(info[1])
  local text = util_text("TVT_name_098")
  if nx_ws_equal(nx_widestr(info[1]), nx_widestr(text)) then
    form.lbl_23.Font = "font_title"
  else
    form.lbl_23.Font = "font_sns_name"
  end
  local text = gui.TextManager:GetText("form_newtvt_002")
  if 1000 <= tvt_type or mgr:IsInteractOpen(tvt_type) then
    text = gui.TextManager:GetText("form_newtvt_001")
  end
  form.lbl_253.Text = text
  form.mltbox_5.HtmlText = nx_widestr(info[5])
  form.lbl_diff.Text = nx_widestr(info[13])
  local base_info = get_interact_base_info(tvt_type)
  local btn_left = form.btn_quit.Left
  local btn_wd = form.btn_quit.Width
  form.btn_quit.Visible = nx_string(info[11]) ~= ""
  form.btn_quit.Text = info[11]
  if form.btn_quit.Visible then
    btn_left = btn_left - btn_wd
  end
  form.btn_new_join.Left = btn_left
  form.btn_new_join.Visible = nx_string(info[12]) ~= ""
  form.btn_new_join.Text = info[12]
  if form.btn_new_join.Visible then
    btn_left = btn_left - btn_wd
  end
  form.btn_info.Left = btn_left
  form.btn_info.Visible = nx_string(info[10]) ~= ""
  form.btn_info.Text = info[10]
  local text = util_text("ui_dc_infos")
  if form.btn_info.Visible and nx_ws_equal(form.btn_info.Text, nx_widestr(text)) then
    local lbl = nx_custom(form, "dynamic_lbl")
    if nx_is_valid(lbl) then
      form.groupbox_jianghu:Remove(lbl)
      gui:Delete(lbl)
    end
    lbl = gui:Create("Label")
    if nx_is_valid(lbl) then
      lbl.Width = form.btn_info.Width
      lbl.Height = form.btn_info.Height
      lbl.Left = form.btn_info.Left
      lbl.Top = form.btn_info.Top
      lbl.ShadowColor = "0,0,0,0"
      lbl.BackImage = "neigongkuang"
      form.groupbox_jianghu:Add(lbl)
      gui.Desktop:ToFront(form.btn_info)
      nx_set_custom(form, "dynamic_lbl", lbl)
    end
  elseif nx_find_custom(form, "dynamic_lbl") then
    local lbl = nx_custom(form, "dynamic_lbl")
    if nx_is_valid(lbl) then
      form.groupbox_jianghu:Remove(lbl)
      gui:Delete(lbl)
    end
  end
  if base_info[3] == nil or base_info[3] == "0" then
  else
  end
  form.lbl_count.Text = util_format_string("@wuxianzhi")
  form.lbl_26.Text = nx_widestr("")
  local showprg = {
    [25] = "@ui_huashankaifang",
    [33] = "@ui_huashankaifang",
    [116] = "@ui_menpaicisha",
    [117] = "@ui_damoduobao",
    [118] = "@ui_panjungongcheng",
    [119] = "@ui_anqizhiwang",
    [120] = "@ui_jinlingrishi",
    [122] = "@ui_zhaozijitucheng",
    [123] = "@ui_dajieluoyangfu"
  }
  if base_info[5] == nil or base_info[5] == "" then
    if tvt_type == 25 or tvt_type == 33 or tvt_type == 116 or tvt_type == 117 or tvt_type == 118 or tvt_type == 119 or tvt_type == 120 or tvt_type == 122 or tvt_type == 123 then
      form.lbl_26.Text = util_format_string(showprg[tvt_type])
    end
    form.lbl_26.Visible = true
    form.btn_63.Visible = false
  else
    form.lbl_26.Visible = false
    form.btn_63.Visible = true
    nx_set_custom(form, "tvt_time", base_info[5])
  end
  local next_time = mgr:GetNextOpen(tvt_type)
  if table.getn(next_time) == 3 and next_time[2] ~= nil and next_time[3] ~= nil then
    nx_set_custom(form, "col_time", nx_number(next_time[2]))
    nx_set_custom(form, "row_time", nx_number(next_time[3]))
  end
  local times = get_tvt_times(tvt_type)
  if times == -1 then
  else
  end
  form.lbl_times.Text = util_format_string("@wuxianzhi")
  form.mltbox_rule.HtmlText = nx_widestr(info[6])
  form.mltbox_need.HtmlText = nx_widestr(info[15])
  form.mltbox_date.HtmlText = util_text(nx_string(info[18]))
  form.lbl_star.BackImage = nx_string(info[17])
  local is_show = is_need_show(tvt_type)
  form.groupbox_prize.Visible = is_show
  form.mltbox_prize.Visible = not is_show
  if is_show then
    local tmp_imagegrid = form.imagegrid_2
    tmp_imagegrid.type = tvt_type
    if nx_int(tvt_type) == nx_int(ITT_HUASHAN_FIGHTER) then
      tmp_imagegrid:AddItem(nx_int(0), "gui\\language\\ChineseS\\tvt\\icon_2.png", "", 1, -1)
      tmp_imagegrid:AddItem(nx_int(1), "gui\\language\\ChineseS\\tvt\\icon_9.png", "", 1, -1)
    else
      local grid_index = 0
      local table_len = table.getn(prize_image_t)
      for i = 1, 9 do
        if mgr:IsHavePrizeType(nx_int(tvt_type), i - 1) and table_len >= i - 1 then
          local image = prize_image_t[i - 1]
          tmp_imagegrid:AddItem(grid_index, image, "", 1, -1)
          grid_index = grid_index + 1
        end
      end
    end
  else
    form.mltbox_prize.HtmlText = nx_widestr(info[14])
  end
  form.rbtn_13.Checked = false
  form.rbtn_13.Checked = true
  on_new_join_place(form, tvt_type)
  send_server_msg(g_msg_test_accept, tvt_type)
  begin_move(form)
end
function begin_move(form)
  form.sub_ani_over = true
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  if common_execute:FindExecute("ControlMove", form.groupbox_sub) then
    return
  end
  form.groupbox_sub.Top = form.groupbox_main.Top
  form.groupbox_sub.Left = 0 - form.groupbox_sub.Width
  form.groupbox_sub.Visible = true
  local top = form.groupbox_main.Top
  local left = 0
  form.groupbox_sub.callback_sp = FORM
  form.groupbox_sub.callback_func = "mark_effect_finish"
  form.groupbox_sub.is_visible = true
  common_execute:AddExecute("ControlMove", form.groupbox_sub, nx_float(0), nx_float(left), nx_float(top), nx_float(EFFECT_ELAPSE), "")
end
function on_btn_sub_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  close_sub_form(form, false)
end
function close_sub_form(form, reopen)
  if not nx_is_valid(form) then
    return
  end
  if not form.sub_ani_over then
    return
  end
  form.sub_ani_over = false
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  if common_execute:FindExecute("ControlMove", form.groupbox_sub) then
    return
  end
  local top = form.groupbox_main.Top
  local left = 0 - form.groupbox_sub.Width
  local func_name = ""
  if not reopen then
    func_name = nx_string("mark_effect_finish")
    form.groupbox_sub.is_visible = false
  else
    func_name = nx_string("check_finish_and_open")
  end
  form.groupbox_sub.callback_sp = FORM
  form.groupbox_sub.callback_func = func_name
  common_execute:AddExecute("ControlMove", form.groupbox_sub, nx_float(0), nx_float(left), nx_float(top), nx_float(EFFECT_ELAPSE), "")
end
function mark_effect_finish()
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  form.sub_ani_over = true
  form.groupbox_sub.Visible = form.groupbox_sub.is_visible
end
function check_finish_and_open()
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  if form.groupbox_btns.Visible == true then
    timer:UnRegister(FORM, "on_refresh_sub_form", form)
    timer:Register(200, 1, FORM, "on_refresh_sub_form", form, -1, -1)
  elseif form.groupbox_jianghu.Visible == true then
    timer:UnRegister(FORM, "refresh_jianghu_info", form)
    timer:Register(200, 1, FORM, "refresh_jianghu_info", form, -1, -1)
  elseif form.groupbox_task.Visible == true then
    timer:UnRegister(FORM, "on_refresh_subtask_form", form)
    timer:Register(200, 1, FORM, "on_refresh_subtask_form", form, -1, -1)
  end
end
function hide_tvt_time()
  util_show_form("form_stage_main\\form_tvt\\form_tvt_time", false)
end
function on_btn_63_get_capture(btn)
  local form = btn.ParentForm
  if nx_find_custom(form, "tvt_time") then
    show_tvt_time(form.tvt_time, form.col_time, form.row_time, btn.AbsLeft + btn.Width / 2, btn.AbsTop + btn.Height)
  end
end
function on_btn_63_lost_capture(btn)
  hide_tvt_time()
end
function show_tvt_time(str, col, row, x, y)
  local time_from = util_get_form("form_stage_main\\form_tvt\\form_tvt_time", true)
  time_from.Fixed = false
  if not nx_is_valid(time_from) then
    return
  end
  time_from.AbsLeft = x - time_from.Width * 2 / 3
  time_from.AbsTop = y
  local textgd = time_from.textgrid_1
  textgd.ColWidth = nx_int(textgd.Width / 7) - 1
  textgd.ColCount = 7
  textgd.RowCount = 5
  textgd.CanSelectCol = true
  local buff_lst = util_split_string(str, ",")
  local size = table.getn(buff_lst)
  for i = 1, size, 2 do
    local day = nx_number(buff_lst[i])
    if day == 0 then
      day = 7
    end
    local day_str = buff_lst[i + 1]
    local day_lst = util_split_string(day_str, "#")
    local count = table.getn(day_lst)
    for j = 1, count do
      textgd:SetGridText(j - 1, day - 1, util_format_string(day_lst[j]))
    end
  end
  textgd:ClearSelect()
  if col ~= -1 and row ~= -1 then
    if col == 0 then
      col = 7
    end
    textgd:SelectGrid(row, col - 1)
  end
  util_show_form("form_stage_main\\form_tvt\\form_tvt_time", true)
end
function change_all_rbtn(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  local form = rbtn.ParentForm
  local groupbox = ""
  if form.rmd_box.Visible == true then
    groupbox = form.recommendbox
  elseif form.act_box.Visible == true then
    groupbox = form.activitybox
  elseif form.task_box.Visible == true then
    groupbox = form.rmdtaskbox
  end
  local child_list = groupbox:GetChildControlList()
  local count = table.getn(child_list)
  for i = 1, count do
    local child_gb = child_list[i]
    if nx_is_valid(child_gb) and nx_is_valid(child_gb.sel_rbtn) then
      local cbtn_other = child_gb.sel_rbtn
      if nx_string(cbtn_other.Name) ~= nx_string(rbtn.Name) then
        cbtn_other.Checked = false
      else
        cbtn_other.Checked = true
      end
    end
  end
end
function get_tvt_times(type)
  local mgr = nx_value("InteractManager")
  local notshow = {
    [3] = 1,
    [4] = 1,
    [9] = 1,
    [10] = 1,
    [13] = 1,
    [14] = 1,
    [16] = 1,
    [18] = 1,
    [20] = 1,
    [21] = 1,
    [22] = 1,
    [24] = 1,
    [25] = 1,
    [29] = 1,
    [30] = 1,
    [31] = 1,
    [32] = 1,
    [33] = 1,
    [34] = 1,
    [39] = 1,
    [ITT_TIGUAN_DANSHUA] = 1,
    [ITT_MATCH_RIVERS] = 1,
    [ITT_MATCH_SCHOOL] = 1,
    [ITT_WORLDWAR_LXC] = 1
  }
  if notshow[type] ~= nil then
    return -1
  end
  return mgr:GetInteractTime(type)
end
function is_need_show(tvt_type)
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return false
  end
  for i = 0, 8 do
    local is_need = mgr:IsHavePrizeType(nx_int(tvt_type), i)
    if is_need then
      return true
    end
  end
  return false
end
function on_new_join_place(form, tvt_type)
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local table_join = mgr:GetTvtHyperCity(tvt_type, 0)
  local count = table.getn(table_join)
  form.min_page = 0
  form.max_page = math.ceil(count / PAGE_NUM)
  form.groupbox_133.Visible = false
  form.btn_pre.Visible = false
  form.btn_pre.Enabled = false
  form.btn_next.Visible = false
  form.btn_next.Enabled = true
  if count > PAGE_NUM then
    form.btn_pre.Visible = true
    form.btn_next.Visible = true
  end
  form.select = 0
  show_join_place(form, tvt_type, 0)
  local rbtn_default = nx_null()
  local groupbox = form.groupbox_133
  for i = 1, PAGE_NUM do
    local rbtn = groupbox:Find("rbtn_place_" .. nx_string(i))
    if nx_is_valid(rbtn) and rbtn.Visible and not nx_is_valid(rbtn_default) then
      rbtn_default = rbtn
    end
  end
  if nx_is_valid(rbtn_default) then
    rbtn_default.Checked = true
  elseif not is_show_join_place(form.type) then
    form.mltbox_23:Clear()
    show_join_tips(form.mltbox_23, form.type)
  end
end
function is_show_join_place(type)
  local mgr = nx_value("InteractManager")
  local info = mgr:GetTvtHyperCity(type, 0)
  if 0 < table.getn(info) then
    return true
  end
  return false
end
function show_join_place(form, tvt_type, page)
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local table_join = mgr:GetTvtHyperCity(tvt_type, form.select)
  local count = table.getn(table_join)
  form.rbtn_place_1.Visible = false
  form.rbtn_place_2.Visible = false
  form.rbtn_place_3.Visible = false
  form.rbtn_place_4.Visible = false
  form.rbtn_place_5.Visible = false
  local begin_pos = page * PAGE_NUM + 1
  if count < begin_pos then
    return
  end
  local groupbox = form.groupbox_133
  groupbox.Visible = true
  local count = 0
  for i = 1, PAGE_NUM do
    local rbtn = groupbox:Find("rbtn_place_" .. nx_string(i))
    if nx_is_valid(rbtn) then
      if table_join[begin_pos] ~= nil then
        rbtn.Visible = true
        rbtn.Text = nx_widestr(table_join[begin_pos])
      else
        rbtn.Visible = false
      end
      begin_pos = begin_pos + 1
    end
  end
  form.rbtn_place_1.Checked = false
  form.rbtn_place_2.Checked = false
  form.rbtn_place_3.Checked = false
  form.rbtn_place_4.Checked = false
  form.rbtn_place_5.Checked = false
end
function show_join_tips(mltbox, type)
  local join_tips = {
    [ITT_SPY_MENP] = "@show_join_tips0",
    [ITT_PATROL] = "@show_join_tips1",
    [ITT_FANGHUO] = "@show_join_tips2",
    [ITT_JIUHUO] = "@show_join_tips3",
    [ITT_YUNBIAO] = "@show_join_tips4",
    [ITT_JIEBIAO] = "@show_join_tips5",
    [ITT_DUOSHU] = "@show_join_tips6",
    [ITT_HUSHU] = "@show_join_tips7",
    [ITT_BANGFEI] = "@show_join_tips8",
    [ITT_XIASHI] = "@show_join_tips9",
    [ITT_PATROL_CHAOTING] = "@show_join_tips10",
    [ITT_SHOULEI] = "@show_join_tips11",
    [ITT_DALEI] = "@show_join_tips12",
    [ITT_BANGPAIZHAN] = "@show_join_tips13",
    [ITT_BANGPAIZHAN_2] = "@show_join_tips14",
    [ITT_MENPAIZHAN] = "@show_join_tips15",
    [ITT_MENPAIZHAN_2] = "@show_join_tips16",
    [ITT_ARREST] = "@show_join_tips17",
    [ITT_WORLDLEITAI] = "@show_join_tips18",
    [ITT_WORLDLEITAI_RANDOM] = "@show_join_tips19",
    [ITT_SCHOOLMOOT] = "@show_join_tips21",
    [ITT_TEAMFACULTY] = "@show_join_tips22",
    [ITT_YUNBIAO_ACTIVE] = "@show_join_tips23",
    [ITT_JHHJ] = "@show_join_tips24",
    [ITT_HUASHAN_FIGHTER] = "@show_join_tips25",
    [ITT_WORLDWAR] = "@show_join_tips29",
    [ITT_AVATAR] = "@show_join_tips30",
    [ITT_SUPERBOOK] = "@show_join_tips31",
    [ITT_WORLDBOSS] = "@show_join_tips32",
    [ITT_MARRY_TASK] = "@show_join_tips33",
    [ITT_ESCORT_SHENGZHU_GOLD] = "@show_join_tips34",
    [ITT_TIGUAN_DANSHUA] = "@show_join_tips35",
    [ITT_EGWAR] = "@show_join_tips34",
    [ITT_MATCH_RIVERS] = "@show_join_tips37",
    [ITT_MATCH_SCHOOL] = "@show_join_tips38",
    [ITT_SCHOOL_DANCE] = "@show_join_tips39",
    [ITT_ZJTX] = "@show_join_tips097",
    [ITT_KH_TREASURE] = "@show_join_tips098",
    [ITT_QIECUO] = "@show_join_tips099",
    [ITT_TTLEITAI] = "@show_join_tips100",
    [ITT_LIFE_JOB] = "@show_join_tips101",
    [ITT_HOME_SYSTEM] = "@show_join_tips102",
    [ITT_SHUZHUANGGE] = "@show_join_tips103",
    [ITT_ZADAN_GIFT] = "@show_join_tips104",
    [ITT_MARRY_SYSTEM] = "@show_join_tips105",
    [ITT_JIANGHU_BATTLE] = "@show_join_tips107",
    [ITT_SCHOOL_KILL] = "@show_join_tips116",
    [ITT_DESERT_DB] = "@show_join_tips117",
    [ITT_BETRYARMY_ATTACK] = "@show_join_tips118",
    [ITT_TC_ZZJ] = "@show_join_tips122",
    [ITT_DAMO_REPENT] = "@show_join_tips129",
    [ITT_DIG_TREASURE] = "@show_join_tips142",
    [ITT_BALANCE_WAR] = "@show_join_tips152",
    [ITT_LUAN_DOU] = "@show_join_tips155",
    [ITT_TAOSHA] = "@show_join_tips157",
    [ITT_APEX] = "@show_join_tips172",
    [SPECIAL_ITT_YANWU] = "@show_join_tips1001",
    [SPECIAL_ITT_KUAIHUODAO] = "@show_join_tips1002",
    [SPECIAL_ITT_JIANGHUJINDI] = "@show_join_tips1003",
    [SPECIAL_ITT_SHITU] = "@show_join_tips1004",
    [SPECIAL_ITT_JIAYUANXIULIAN] = "@show_join_tips1005",
    [SPECIAL_ITT_JIANGHUSHILI] = "@show_join_tips1006",
    [SPECIAL_ITT_SHIDASHIJIA] = "@show_join_tips1007",
    [SPECIAL_ITT_JIANGHUSHASHOU] = "@show_join_tips1008",
    [SPECIAL_ITT_SANMENGZHENGBA] = "@show_join_tips1009",
    [SPECIAL_ITT_SHUANGRENLONGTOU] = "@show_join_tips1010",
    [SPECIAL_ITT_WAIYUWULIN] = "@show_join_tips1011",
    [SPECIAL_ITT_ZHUISHA] = "@show_join_tips1012",
    [SPECIAL_ITT_BAGUATIANMENZHEN] = "@show_join_tips1013",
    [SPECIAL_ITT_TONGTIANFU] = "@show_join_tips1014",
    [SPECIAL_ITT_SIDASHIJIAZC] = "@show_join_tips1015",
    [SPECIAL_ITT_DAZAOTAI] = "@show_join_tips1016"
  }
  local tips = join_tips[type]
  if tips == nil then
    return
  end
  if type == ITT_KH_TREASURE then
    mltbox.Font = "font_text_figure"
  else
    mltbox.Font = "font_main"
  end
  mltbox.HtmlText = util_format_string(tips)
end
function on_new_prize_place(form, tvt_type)
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local table_join = mgr:GetTvtHyperCity(tvt_type, 1)
  local count = table.getn(table_join)
  form.min_page = 0
  form.max_page = math.ceil(count / PAGE_NUM)
  form.groupbox_133.Visible = false
  form.btn_pre.Visible = false
  form.btn_pre.Enabled = false
  form.btn_next.Visible = false
  form.btn_next.Enabled = true
  if count > PAGE_NUM then
    form.btn_pre.Visible = true
    form.btn_next.Visible = true
  end
  form.select = 1
  show_join_place(form, tvt_type, 0)
  local rbtn_default = nx_null()
  local groupbox = form.groupbox_133
  for i = 1, PAGE_NUM do
    local rbtn = groupbox:Find("rbtn_place_" .. nx_string(i))
    if nx_is_valid(rbtn) and rbtn.Visible and not nx_is_valid(rbtn_default) then
      rbtn_default = rbtn
    end
  end
  if nx_is_valid(rbtn_default) then
    rbtn_default.Checked = true
  elseif not is_show_submit_place(form.type) then
    form.mltbox_23:Clear()
    show_submit_tips(form.mltbox_23, form.type)
  end
end
function show_submit_tips(mltbox, type)
  local join_tips = {
    [ITT_SPY_MENP] = "@show_submit_tips0",
    [ITT_PATROL] = "@show_submit_tips1",
    [ITT_FANGHUO] = "@show_submit_tips2",
    [ITT_JIUHUO] = "@show_submit_tips3",
    [ITT_YUNBIAO] = "@show_submit_tips4",
    [ITT_JIEBIAO] = "@show_submit_tips5",
    [ITT_DUOSHU] = "@show_submit_tips6",
    [ITT_HUSHU] = "@show_submit_tips7",
    [ITT_BANGFEI] = "@show_submit_tips8",
    [ITT_XIASHI] = "@show_submit_tips9",
    [ITT_PATROL_CHAOTING] = "@show_submit_tips10",
    [ITT_SHOULEI] = "@show_submit_tips11",
    [ITT_DALEI] = "@show_submit_tips12",
    [ITT_BANGPAIZHAN] = "@show_submit_tips13",
    [ITT_BANGPAIZHAN_2] = "@show_submit_tips14",
    [ITT_MENPAIZHAN] = "@show_submit_tips15",
    [ITT_MENPAIZHAN_2] = "@show_submit_tips16",
    [ITT_ARREST] = "@show_submit_tips17",
    [ITT_WORLDLEITAI] = "@show_submit_tips18",
    [ITT_WORLDLEITAI_RANDOM] = "@show_submit_tips19",
    [ITT_SCHOOLMOOT] = "@show_submit_tips21",
    [ITT_TEAMFACULTY] = "@show_submit_tips22",
    [ITT_YUNBIAO_ACTIVE] = "@show_submit_tips23",
    [ITT_JHHJ] = "@show_submit_tips24",
    [ITT_HUASHAN_FIGHTER] = "@show_submit_tips25",
    [ITT_WORLDWAR] = "@show_submit_tips29",
    [ITT_AVATAR] = "@show_submit_tips30",
    [ITT_SUPERBOOK] = "@show_submit_tips31",
    [ITT_WORLDBOSS] = "@show_submit_tips32",
    [ITT_MARRY_TASK] = "@show_submit_tips33",
    [ITT_ESCORT_SHENGZHU_GOLD] = "@show_submit_tips34",
    [ITT_TIGUAN_DANSHUA] = "@show_submit_tips35",
    [ITT_EGWAR] = "@show_submit_tips36",
    [ITT_MATCH_RIVERS] = "@show_submit_tips37",
    [ITT_MATCH_SCHOOL] = "@show_submit_tips38",
    [ITT_SCHOOL_DANCE] = "@show_submit_tips39",
    [ITT_NLHH] = "@show_submit_tips40",
    [ITT_KH_TREASURE] = "@show_submit_tips098",
    [ITT_QIECUO] = "@show_submit_tips099",
    [ITT_LIFE_JOB] = "@show_submit_tips101",
    [ITT_HOME_SYSTEM] = "@show_submit_tips102",
    [ITT_SHUZHUANGGE] = "@show_submit_tips103",
    [ITT_ZADAN_GIFT] = "@show_submit_tips104",
    [ITT_MARRY_SYSTEM] = "@show_submit_tips105",
    [ITT_MUSE_COUNTRY] = "@show_submit_tips108",
    [ITT_QINGYUNBU] = "@show_submit_tips109",
    [ITT_KONGQUE] = "@show_submit_tips110",
    [ITT_LONGMEN_HOTEL] = "@show_submit_tips111",
    [ITT_YANMENGUAN] = "@show_submit_tips112",
    [ITT_YINGOUFANG] = "@show_submit_tips113",
    [ITT_JINLINGBIAN] = "@show_submit_tips114",
    [ITT_QINGYAOGONG] = "@show_submit_tips115",
    [ITT_SCHOOL_KILL] = "@show_submit_tips116",
    [ITT_BETRYARMY_ATTACK] = "@show_submit_tips118",
    [ITT_JINDI] = "@show_submit_tips121",
    [ITT_DAMO_REPENT] = "@show_submit_tips129",
    [ITT_DIG_TREASURE] = "@show_submit_tips142",
    [ITT_BALANCE_WAR] = "@show_submit_tips152",
    [ITT_LUAN_DOU] = "@show_submit_tips155",
    [ITT_TAOSHA] = "@show_submit_tips157",
    [ITT_APEX] = "@show_join_tips172",
    [SPECIAL_ITT_YANWU] = "@show_submit_tips1001",
    [SPECIAL_ITT_KUAIHUODAO] = "@show_submit_tips1002",
    [SPECIAL_ITT_JIANGHUJINDI] = "@show_submit_tips1003",
    [SPECIAL_ITT_SHITU] = "@show_submit_tips1004",
    [SPECIAL_ITT_JIAYUANXIULIAN] = "@show_submit_tips1005",
    [SPECIAL_ITT_JIANGHUSHILI] = "@show_submit_tips1006",
    [SPECIAL_ITT_SHIDASHIJIA] = "@show_submit_tips1007",
    [SPECIAL_ITT_JIANGHUSHASHOU] = "@show_submit_tips1008",
    [SPECIAL_ITT_SANMENGZHENGBA] = "@show_submit_tips1009",
    [SPECIAL_ITT_SHUANGRENLONGTOU] = "@show_submit_tips1010",
    [SPECIAL_ITT_WAIYUWULIN] = "@show_submit_tips1011",
    [SPECIAL_ITT_ZHUISHA] = "@show_submit_tips1012",
    [SPECIAL_ITT_BAGUATIANMENZHEN] = "@show_submit_tips1013",
    [SPECIAL_ITT_TONGTIANFU] = "@show_submit_tips1014",
    [SPECIAL_ITT_SIDASHIJIAZC] = "@show_submit_tips1015",
    [SPECIAL_ITT_DAZAOTAI] = "@show_submit_tips1016"
  }
  local tips = join_tips[type]
  if tips == nil then
    return
  end
  if type == ITT_KH_TREASURE then
    mltbox.Font = "font_text_figure"
  else
    mltbox.Font = "font_main"
  end
  mltbox.HtmlText = util_format_string(tips)
end
function is_show_submit_place(type)
  local mgr = nx_value("InteractManager")
  local info = mgr:GetTvtHyperCity(type, 1)
  if table.getn(info) > 0 then
    return true
  end
  return false
end
function on_rbtn_13_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    on_new_join_place(form, form.type)
  end
end
function on_rbtn_14_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    on_new_prize_place(form, form.type)
  end
end
function on_rbtn_1_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  change_all_palce(rbtn)
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local form = rbtn.ParentForm
  local city = nx_widestr(rbtn.Text)
  local info = mgr:GetTvtHyper(form.type, form.select, city)
  local txtbox = form.mltbox_23
  if table.getn(info) > 0 then
    txtbox.Font = "font_main"
    txtbox:Clear()
    for i, name in pairs(info) do
      txtbox:AddHtmlText(name, 0)
    end
  end
end
function change_all_palce(rbtn)
  local form = rbtn.ParentForm
  local groupbox = form.groupbox_133
  local child_list = groupbox:GetChildControlList()
  local count = table.getn(child_list)
  for i = 1, count do
    local child_rbtn = child_list[i]
    if nx_is_valid(child_rbtn) and nx_string(child_rbtn.Name) ~= nx_string(rbtn.Name) then
      child_rbtn.Checked = false
    end
  end
end
function on_btn_pre_click(btn)
  local form = btn.ParentForm
  if form.min_page <= 0 then
    btn.Enabled = false
    return
  end
  form.btn_next.Enabled = true
  form.min_page = form.min_page - 1
  show_join_place(form, form.type, form.min_page)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if form.min_page >= form.max_page then
    btn.Enabled = false
    return
  end
  form.btn_pre.Enabled = true
  form.min_page = form.min_page + 1
  show_join_place(form, form.type, form.min_page)
end
function on_imagegrid_2_lost_capture(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_2_get_capture(grid, index)
  local form = grid.ParentForm
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local gui = nx_value("gui")
  nx_execute("tips_game", "hide_tip")
  local ui_tips = mgr:GetPrizeTips(grid.type)
  local x, y = gui:GetCursorClientPos()
  nx_execute("tips_game", "show_text_tip", nx_widestr(ui_tips), x, y)
end
function on_btn_actnext_click(btn)
  local form = btn.ParentForm
  if form.act_curpage >= form.act_maxpage then
    return
  end
  form.act_curpage = form.act_curpage + 1
  refresh_act_form()
end
function on_btn_actpre_click(btn)
  local form = btn.ParentForm
  if form.act_curpage <= 1 then
    return
  end
  form.act_curpage = form.act_curpage - 1
  refresh_act_form()
end
function on_btn_rmdnext_click(btn)
  local form = btn.ParentForm
  if form.rmd_curpage >= form.rmd_maxpage then
    return
  end
  form.rmd_curpage = form.rmd_curpage + 1
  refresh_rmd_form()
end
function on_btn_rmdpre_click(btn)
  local form = btn.ParentForm
  if form.rmd_curpage <= 1 then
    return
  end
  form.rmd_curpage = form.rmd_curpage - 1
  refresh_rmd_form()
end
function on_btn_tasknext_click(btn)
  local form = btn.ParentForm
  if form.task_curpage >= form.task_maxpage then
    return
  end
  form.task_curpage = form.task_curpage + 1
  refresh_task_form()
end
function on_btn_taskpre_click(btn)
  local form = btn.ParentForm
  if form.task_curpage <= 1 then
    return
  end
  form.task_curpage = form.task_curpage - 1
  refresh_task_form()
end
function on_btn_guide_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.sub_ani_over then
    return
  end
  if form.groupbox_sub.Visible == true then
    if nx_string(form.sel_sub_form) == nx_string(btn.Name) then
      close_sub_form(form, false)
    else
      form.sel_sub_form = nx_string(btn.Name)
      close_sub_form(form, true)
    end
  else
    form.sel_sub_form = nx_string(btn.Name)
    on_refresh_sub_form(form)
  end
end
function on_refresh_sub_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_jianghu.Visible = false
  form.groupbox_strong.Visible = true
  form.groupbox_task.Visible = false
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = get_text_ids(form)
  local text_array = util_split_string(nx_string(text), ",")
  refresh_sub_form_title(form)
  form.gsbox_desc:DeleteAll()
  form.gsbox_desc.IsEditMode = true
  for i = 1, table.getn(text_array) do
    local lbl_partition = gui:Create("Label")
    lbl_partition.NoFrame = true
    lbl_partition.Top = 0
    lbl_partition.Left = 0
    lbl_partition.Width = form.gsbox_desc.Width - 35
    lbl_partition.Height = 5
    lbl_partition.DrawMode = "FitWindow"
    form.gsbox_desc:Add(lbl_partition)
    local text = gui.TextManager:GetFormatText(text_array[i])
    local mltbox = gui:Create("MultiTextBox")
    mltbox.NoFrame = true
    mltbox.Font = "font_conten_tasktrace"
    mltbox.TextColor = "255,197,184,159"
    mltbox.SelectBarColor = "0,0,0,0"
    mltbox.MouseInBarColor = "0,0,0,0"
    mltbox.DrawMode = "FitWindow"
    mltbox.Top = form.gsbox_desc.Top
    mltbox.Left = form.gsbox_desc.Left
    mltbox.Width = form.gsbox_desc.Width - 35
    mltbox.ViewRect = "5,5" .. nx_string(mltbox.Width - 10) .. "," .. nx_string(mltbox:GetContentHeight() - 10)
    mltbox:AddHtmlText(text, -1)
    mltbox.ViewRect = "5,5" .. nx_string(mltbox.Width - 10) .. "," .. nx_string(mltbox:GetContentHeight() - 10)
    mltbox.Height = mltbox:GetContentHeight()
    nx_bind_script(mltbox, nx_current())
    nx_callback(mltbox, "on_click_hyperlink", "on_click_hyperlink")
    form.gsbox_desc:Add(mltbox)
  end
  form.gsbox_desc.IsEditMode = false
  form.gsbox_desc:ResetChildrenYPos()
  begin_move(form)
end
function on_click_hyperlink(mltbox, index, data)
  data = nx_string(data)
  local str_lst = nx_function("ext_split_string", data, ",")
  if "open_form" == str_lst[1] then
    if nil ~= str_lst[2] and "" ~= str_lst[2] then
      util_auto_show_hide_form(str_lst[2])
    end
  elseif "search_auction" == str_lst[1] and nil ~= str_lst[2] and "" ~= str_lst[2] then
    nx_execute("form_stage_main\\form_market\\form_market", "open_form_and_search", str_lst[2])
  end
end
function get_text_ids(form)
  if not nx_is_valid(form) then
    return ""
  end
  if nx_string(form.sel_sub_form) == nx_string("") then
    return ""
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if not nx_is_valid(ini) then
    return ""
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local playerschool = client_player:QueryProp("School")
  if nx_string(playerschool) == nx_string("") or nx_string(playerschool) == nx_string("0") then
    playerschool = client_player:QueryProp("NewSchool")
    if nx_string(playerschool) == nx_string("") or nx_string(playerschool) == nx_string("0") then
      playerschool = client_player:QueryProp("Force")
    end
  end
  local key = form.sel_sub_form
  if nx_string(playerschool) ~= nx_string("") and nx_string(playerschool) ~= nx_string("0") then
    key = nx_string(key) .. nx_string(",") .. nx_string(playerschool)
  end
  local ini_step_index = ini:FindSectionIndex(nx_string("step"))
  if ini_step_index < 0 then
    return ""
  end
  local ini_desc_index = ini:FindSectionIndex(nx_string("desc"))
  if ini_desc_index < 0 then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string("link_desc"))
  if sec_index < 0 then
    return ""
  end
  local var = ini:ReadString(sec_index, nx_string(key), "")
  if nx_string(var) == nx_string("") then
    key = form.sel_sub_form
    var = ini:ReadString(sec_index, nx_string(key), "")
    if nx_string(var) == nx_string("") then
      return ""
    end
  end
  local main_step, sub_step = get_game_step()
  if main_step == nil or main_step <= 0 then
    return ""
  end
  local var_array = util_split_string(nx_string(var), ";")
  for i = 1, table.getn(var_array) do
    local tv = var_array[i]
    local tv_array = util_split_string(nx_string(tv), ",")
    if table.getn(tv_array) >= 2 then
      local step_index = tv_array[1]
      local step_var = ini:ReadString(ini_step_index, nx_string(step_index), "")
      local step_condition = false
      local step_var_array = util_split_string(nx_string(step_var), ",")
      if table.getn(step_var_array) == 1 then
        if nx_int(main_step) >= nx_int(step_var_array[1]) then
          step_condition = true
        end
      elseif table.getn(step_var_array) == 2 and step_var_array[2] ~= nil and (nx_int(main_step) > nx_int(step_var_array[1]) or nx_int(step_var_array[1]) == nx_int(main_step) and nx_int(sub_step) >= nx_int(step_var_array[2])) then
        step_condition = true
      end
      if step_condition then
        local tips_index = tv_array[2]
        return ini:ReadString(ini_desc_index, nx_string(tips_index), "")
      end
    end
  end
  return ""
end
function refresh_sub_form_title(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("form_title"))
  if sec_index < 0 then
    return
  end
  local var = ini:ReadString(sec_index, nx_string(form.sel_sub_form), "")
  if nx_string(var) == nx_string("") then
    return
  end
  local text_array = util_split_string(nx_string(var), ",")
  local var_len = table.getn(text_array)
  if 1 <= var_len then
    local text = gui.TextManager:GetFormatText(text_array[1])
  end
  if 2 <= var_len then
    form.lbl_sub_icon.BackImage = nx_string(text_array[2])
  end
end
function get_game_step()
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return nil, nil
  end
  local MainGameStep = SwitchManager:GetMainGameStep()
  local SubGameStep = SwitchManager:GetSubGameStep()
  return MainGameStep, SubGameStep
end
function can_show_detail_info(interact_type)
  if ITT_MENPAIZHAN == interact_type then
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return false
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return false
    end
    local is_in_fight = client_player:QueryProp("IsInSchoolFight")
    if nx_int(is_in_fight) ~= nx_int(1) then
      return false
    end
    local client_scene = game_client:GetScene()
    if not nx_is_valid(client_scene) then
      return false
    end
    if not client_scene:FindRecord("Time_Limit_Form_Rec") then
    end
    local rows = client_scene:FindRecordRow("Time_Limit_Form_Rec", 0, "schoolfight002")
    if rows < 0 then
    end
  end
  return true
end
function on_info_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.type == ITT_WORLDLEITAI_RANDOM then
    EnableRecvRandamReqest()
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local form_names = {
    [ITT_SPY_MENP] = nil,
    [ITT_SPY_CHAOTING] = nil,
    [ITT_FANGHUO] = "form_stage_main\\form_guild_fire\\form_fire_interact",
    [ITT_JIUHUO] = "form_stage_main\\form_guild_fire\\form_fire_interact",
    [ITT_YUNBIAO] = nil,
    [ITT_JIEBIAO] = "form_stage_main\\form_school_war\\form_escort_trace",
    [ITT_DUOSHU] = "form_stage_main\\form_tvt\\form_tvt_snatchbook_map",
    [ITT_HUSHU] = "form_stage_main\\form_tvt\\form_tvt_snatchbook_map",
    [ITT_BANGFEI] = nil,
    [ITT_MENPAIZHAN] = "form_stage_main\\form_school_war\\form_school_fight_rank",
    [ITT_ARREST] = "form_stage_main\\form_arrest\\form_arrest_manage",
    [ITT_WORLDBOSS] = "form_stage_main\\form_world_boss_general",
    [ITT_MUSE_COUNTRY] = "form_stage_main\\form_clone\\form_clone_main",
    [ITT_QINGYUNBU] = "form_stage_main\\form_clone\\form_clone_main",
    [ITT_KONGQUE] = "form_stage_main\\form_clone\\form_clone_main",
    [ITT_LONGMEN_HOTEL] = "form_stage_main\\form_clone\\form_clone_main",
    [ITT_YANMENGUAN] = "form_stage_main\\form_clone\\form_clone_main",
    [ITT_YINGOUFANG] = "form_stage_main\\form_clone\\form_clone_main",
    [ITT_JINLINGBIAN] = "form_stage_main\\form_clone\\form_clone_main",
    [ITT_QINGYAOGONG] = "form_stage_main\\form_clone\\form_clone_main",
    [ITT_JINDI] = "form_stage_main\\form_clone\\form_clone_main",
    [SPECIAL_ITT_JIANGHUSHASHOU] = "form_stage_main\\form_clone\\form_clone_main"
  }
  if SPECIAL_ITT_ZHUISHA == form.type then
    util_show_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", true)
  end
  if SPECIAL_ITT_WAIYUWULIN == form.type and switch_manager:CheckSwitchEnable(605) then
    util_show_form("form_stage_main\\form_outland\\form_outland_main", true)
  end
  if SPECIAL_ITT_SHUANGRENLONGTOU == form.type and switch_manager:CheckSwitchEnable(859) then
    util_show_form("form_stage_main\\form_tiguan\\form_tiguan_dual_play", true)
  end
  if SPECIAL_ITT_SANMENGZHENGBA == form.type and switch_manager:CheckSwitchEnable(663) then
    util_show_form("form_stage_main\\form_match\\form_match_sanmeng", true)
  end
  if SPECIAL_ITT_JIANGHUJINDI == form.type or SPECIAL_ITT_TONGTIANFU == form.type then
    util_show_form("form_stage_main\\form_clone\\form_clone_main", true)
  end
  if (SPECIAL_ITT_SHIDASHIJIA == form.type or SPECIAL_ITT_SIDASHIJIAZC == form.type) and switch_manager:CheckSwitchEnable(661) then
    util_show_form("form_stage_main\\form_shijia\\form_shijia_guide", true)
  end
  if SPECIAL_ITT_JIANGHUSHILI == form.type then
    util_show_form("form_stage_main\\form_tvt\\form_tvt_tiguan", true)
  end
  if SPECIAL_ITT_SHITU == form.type then
    util_show_form("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_msg_new", true)
  end
  if ITT_BALANCE_WAR == form.type or ITT_LUAN_DOU == form.type or ITT_TAOSHA == form.type or ITT_APEX == form.type then
    util_show_form("form_stage_main\\form_war_scuffle\\form_balance_total", true)
  end
  if ITT_DIG_TREASURE == form.type then
    local dbomall_path = "form_stage_main\\form_dbomall\\form_dbomall"
    local dbomall_form = util_get_form(dbomall_path, true)
    if dbomall_form.Visible == false then
      dbomall_form:Show()
      dbomall_form.Visible = true
    end
    nx_execute(dbomall_path, "open_form", "form_stage_main\\form_dbomall\\form_dbortreasure")
  end
  if ITT_TEAMFACULTY == form.type or SPECIAL_ITT_YANWU == form.type then
    util_show_form("form_stage_main\\form_wuxue\\form_wuxue_faculty", true)
  end
  if ITT_TIGUAN_DANSHUA == form.type then
    util_auto_show_hide_form("form_stage_main\\form_tiguan\\form_tiguan_one")
  end
  if ITT_ZJTX == form.type then
    local form_activity = nx_value("form_stage_main\\form_activity\\form_activity_partner")
    if not nx_is_valid(form_activity) then
      nx_execute("form_stage_main\\form_activity\\form_activity_partner", "show_form")
    else
      util_auto_show_hide_form("form_stage_main\\form_activity\\form_activity_partner")
    end
  end
  if ITT_TTLEITAI == form.type then
    util_auto_show_hide_form("form_stage_main\\form_general_info\\form_general_info_main")
  end
  if ITT_HOME_SYSTEM == form.type or SPECIAL_ITT_JIAYUANXIULIAN == form.type then
    local form_home = nx_value("form_stage_main\\form_home\\form_home")
    if not nx_is_valid(form_home) then
      nx_execute("form_stage_main\\form_home\\form_home", "open_form")
    else
      util_auto_show_hide_form("form_stage_main\\form_home\\form_home")
    end
  end
  if ITT_MARRY_SYSTEM == form.type then
    nx_execute("form_stage_main\\form_marry\\form_marry_sns", "open_form")
  end
  if ITT_JIANGHU_BATTLE == form.type then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_join", "open_form")
  end
  if ITT_SHUZHUANGGE == form.type then
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "open_form")
  end
  if ITT_KH_TREASURE == form.type then
    local form_dbomall = nx_value("form_stage_main\\form_dbomall\\form_dbomall")
    if not nx_is_valid(form_dbomall) then
      nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "open_form", "form_stage_main\\form_task\\form_seek_mine")
    else
      util_auto_show_hide_form("form_stage_main\\form_dbomall\\form_dbomall")
    end
  end
  if ITT_ZADAN_GIFT == form.type then
    local form_dbomall = nx_value("form_stage_main\\form_dbomall\\form_dbomall")
    if not nx_is_valid(form_dbomall) then
      nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "open_form", "form_stage_main\\puzzle_quest\\form_select_egg")
    else
      util_auto_show_hide_form("form_stage_main\\form_dbomall\\form_dbomall")
    end
  end
  if ITT_LIFE_JOB == form.type then
    local form_main = nx_value("form_stage_main\\form_main\\form_main")
    if nx_is_valid(form_main) then
      if form_main.rbtn_life.Enabled == true and form_main.rbtn_life.Checked == false then
        form_main.rbtn_life.Checked = true
      elseif form_main.rbtn_fight.Enabled == true and form_main.rbtn_fight.Checked == false then
        form_main.rbtn_fight.Checked = true
      end
    end
  end
  if ITT_WORLDWAR_LXC == form.type then
    util_auto_show_hide_form("form_stage_main\\form_world_war\\form_world_war_join")
    local form_join = nx_value("form_stage_main\\form_world_war\\form_world_war_join")
    if nx_is_valid(form_join) then
      form_join.rbtn_scene_2.Checked = true
    end
  end
  if ITT_JHHJ == form.type then
    util_auto_show_hide_form("form_stage_main\\form_map\\form_map_scene")
    local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
    if nx_is_valid(form_map) then
      local gui = nx_value("gui")
      gui.Desktop:ToFront(form_map)
      nx_execute("form_stage_main\\form_map\\form_map_scene", "open_XinShiLi_node")
    end
  end
  if ITT_WORLDWAR == form.type then
    util_auto_show_hide_form("form_stage_main\\form_world_war\\form_world_war_join")
  end
  if ITT_HUASHAN_FIGHTER == form.type then
    util_auto_show_hide_form("form_stage_main\\form_huashan\\form_huashan_main")
  end
  if ITT_MATCH_RIVERS == form.type then
    util_auto_show_hide_form("form_stage_main\\form_general_info\\form_general_info_main")
  end
  if ITT_MATCH_SCHOOL == form.type then
    util_auto_show_hide_form("form_stage_main\\form_general_info\\form_general_info_main")
  end
  if ITT_AVATAR == form.type then
    util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
    local form_help = util_get_form("form_stage_main\\form_helper\\form_theme_helper", false)
    if nx_is_valid(form_help) then
      nx_execute("form_stage_main\\form_helper\\form_theme_helper", "click_hyperlink", form_help, "jhqb,jianghuqy02,xinmo03_03,intro04")
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
  end
  if ITT_SUPERBOOK == form.type then
    util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
    local form_help = util_get_form("form_stage_main\\form_helper\\form_theme_helper", false)
    if nx_is_valid(form_help) then
      nx_execute("form_stage_main\\form_helper\\form_theme_helper", "click_hyperlink", form_help, "jhqb,jianghuzd02,jhzhibao03,jhzhibaojj04")
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
  end
  local name = form_names[form.type]
  if name == nil then
    return
  end
  if not can_show_detail_info(form.type) then
    return
  end
  util_auto_show_hide_form(name)
  if form.type == ITT_DUOSHU and (form.btn_new_join.Enabled or form.btn_quit.Enabled) then
    nx_execute("custom_sender", "custom_send_interact_msg", g_msg_school_request_book_info)
  elseif form.type == ITT_HUSHU and (form.btn_new_join.Enabled or form.btn_quit.Enabled) then
    nx_execute("custom_sender", "custom_send_interact_msg", g_msg_school_request_book_info)
  end
end
function EnableRecvRandamReqest()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(CLIENT_SUBMSG_LEITAI_ENABLE_REQUEST))
end
function on_btn_new_join_click(btn)
  local form = btn.ParentForm
  local type = form.type
  if type == 19 then
    nx_execute("form_stage_main\\form_leitai\\form_leitai", "open_form_by_func_type", 4)
    return
  elseif type == 20 then
    nx_execute("form_stage_main\\form_leitai\\form_leitai", "open_form_by_func_type", 5)
    return
  end
  if 0 <= type then
    send_server_msg(g_msg_accept, type, 0)
  end
end
function on_btn_quit_click(btn)
  local type = btn.ParentForm.type
  send_server_msg(g_msg_giveup, type)
  local g_func = {
    [ITT_SPY_MENP] = {src = nil, funcname = nil},
    [ITT_BANGFEI] = {
      src = "form_stage_main\\form_offline\\form_offline_abduct_tip",
      funcname = "GiveupAbduct"
    },
    [ITT_FANGHUO] = {
      src = "form_stage_main\\form_guild_fire\\form_fire_info",
      funcname = "GiveupFireTask"
    },
    [ITT_JIUHUO] = {
      src = "form_stage_main\\form_guild_fire\\form_fire_info",
      funcname = "GiveupWaterTask"
    },
    [ITT_MENPAIZHAN] = {
      src = "form_stage_main\\form_school_war\\form_school_fight_info",
      funcname = "request_open_form"
    },
    [ITT_SUPERBOOK] = {
      src = "form_stage_main\\form_relation\\form_relation_enchou",
      funcname = "open_by_tvt"
    }
  }
  local cfg = g_func[type]
  if cfg == nil then
    return
  end
  if cfg.src ~= nil and cfg.funcname ~= nil then
    nx_execute(cfg.src, cfg.funcname, type)
  end
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
  check_day_reward_state(self, client_player)
  check_week_reward_state(self, client_player)
end
function get_day_arrays()
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_ACT_FILE)
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
  local ini = IniManager:GetIniDocument(INI_ACT_FILE)
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
        btn.AutoSize = true
        if nx_int(cur_day_var) < nx_int(need_var) then
          btn.NormalImage = box_res .. "_c.png"
          btn.FocusImage = box_res .. "_c_on.png"
          btn.PushImage = box_res .. "_c_on.png"
          btn.is_click = false
          bg_lbl.Visible = false
          lbl_need.Text = nx_widestr(need_var)
        else
          if box_is_got(player, condition_id) == YET_GOT then
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
          lbl_need.Left = lbl_need.Left - 4
        end
        btn.Enabled = is_open
      end
    end
  end
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
        else
          if box_is_got(player, condition_id) == YET_GOT then
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
          lbl_need.Left = lbl_need.Left - 3
        end
        btn.Enabled = is_open
      end
    end
  end
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
        button.Top = 20
        button.Left = form.pbar_1.Left - 27.5 + need_var / nx_int(form.max_day_var) * form.pbar_1.Width
        nx_bind_script(button, nx_current())
        nx_callback(button, "on_click", "on_btn_box_click")
        nx_callback(button, "on_get_capture", "on_btn_box_get_capture")
        nx_callback(button, "on_lost_capture", "on_btn_box_lost_capture")
        nx_set_custom(form, button.Name, button)
        form.groupbox_act:Add(button)
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
        bg_anim.Top = 20
        bg_anim.Left = form.pbar_1.Left - 27.5 + need_var / nx_int(form.max_day_var) * form.pbar_1.Width
        nx_set_custom(form, bg_anim.Name, bg_anim)
        form.groupbox_act:Add(bg_anim)
      end
      local lbl_need_var = gui:Create("Label")
      if nx_is_valid(lbl_need_var) then
        lbl_need_var.Name = "lbl_box_need_" .. nx_string(i)
        lbl_need_var.ForeColor = "255,255,255,255"
        lbl_need_var.DataSource = nx_string(i)
        lbl_need_var.DrawMode = "FitWindow"
        lbl_need_var.Visible = true
        lbl_need_var.Font = form.lbl_begin_var.Font
        lbl_need_var.ForeColor = form.lbl_begin_var.ForeColor
        lbl_need_var.Text = nx_widestr(need_var)
        lbl_need_var.Width = 30
        lbl_need_var.Height = 20
        lbl_need_var.Top = form.lbl_begin_var.Top
        lbl_need_var.Left = form.pbar_1.Left - 12 + need_var / nx_int(form.max_day_var) * form.pbar_1.Width
        nx_set_custom(form, lbl_need_var.Name, lbl_need_var)
        form.groupbox_act:Add(lbl_need_var)
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
        button.Top = form.pbar_2.Top - 30
        button.Left = form.pbar_2.Left - 27.5 + need_var / nx_int(form.max_week_var) * form.pbar_2.Width
        nx_bind_script(button, nx_current())
        nx_callback(button, "on_click", "on_btn_week_reward_click")
        nx_callback(button, "on_get_capture", "on_btn_box_get_capture")
        nx_callback(button, "on_lost_capture", "on_btn_box_lost_capture")
        nx_set_custom(form, button.Name, button)
        form.groupbox_act:Add(button)
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
        bg_anim.Top = form.pbar_2.Top - 30
        bg_anim.Left = form.pbar_2.Left - 27.5 + need_var / nx_int(form.max_week_var) * form.pbar_2.Width
        nx_set_custom(form, bg_anim.Name, bg_anim)
        form.groupbox_act:Add(bg_anim)
      end
      local lbl_need_var = gui:Create("Label")
      if nx_is_valid(lbl_need_var) then
        lbl_need_var.Name = "lbl_week_box_need_" .. nx_string(i)
        lbl_need_var.ForeColor = "255,255,255,255"
        lbl_need_var.DataSource = nx_string(i)
        lbl_need_var.DrawMode = "FitWindow"
        lbl_need_var.Visible = true
        lbl_need_var.Font = form.lbl_week_begin_var.Font
        lbl_need_var.ForeColor = form.lbl_week_begin_var.ForeColor
        lbl_need_var.Text = nx_widestr(need_var)
        lbl_need_var.Width = 55
        lbl_need_var.Height = 20
        lbl_need_var.Top = form.lbl_week_begin_var.Top
        lbl_need_var.Left = form.pbar_2.Left - 15 + need_var / nx_int(form.max_week_var) * form.pbar_2.Width
        nx_set_custom(form, lbl_need_var.Name, lbl_need_var)
        form.groupbox_act:Add(lbl_need_var)
      end
    end
  end
end
function get_day_award_id(index)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_ACT_FILE)
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
  local ini = IniManager:GetIniDocument(INI_ACT_FILE)
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
function on_taskprize_get_capture(grid, index)
  show_prize_tips(grid, index)
end
function on_taskprize_lost_capture(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
  if 0 >= table.getn(table_prop_name) then
    return
  end
  table_prop_value.ConfigID = nx_string(prize_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", "task_grid_data")
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_set_custom(grid.Data, "is_static", true)
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
  grid.Data:ClearChild()
end
function get_act_id(tvt_type)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_RMD_FILE)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("ActivityMapConfig")
  local act_id = ini:ReadString(index, nx_string(tvt_type), "")
  return act_id
end
function get_zcact_id(tvt_type)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_RMD_FILE)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("ZCActivityMapConfig")
  local act_id = ini:ReadString(index, nx_string(tvt_type), "")
  return act_id
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
