require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
require("share\\client_custom_define")
require("form_stage_main\\form_tvt\\define")
local g_form_name = "form_stage_main\\form_tvt\\form_tvt_main"
local CLIENT_SUBMSG_LEITAI_ENABLE_REQUEST = 12
local g_spy_name = ""
local FORM_TVT_TIGUAN_GUAN = "form_stage_main\\form_tvt\\form_tvt_tiguan_guan"
local SUB_FORM = {
  exchange = "form_stage_main\\form_tvt\\form_tvt_exchange"
}
local prize_image_t = {
  [0] = "gui\\language\\ChineseS\\tvt\\icon_1.png",
  [1] = "gui\\language\\ChineseS\\tvt\\icon_1.png",
  [2] = "gui\\language\\ChineseS\\tvt\\icon_1.png",
  [3] = "gui\\language\\ChineseS\\tvt\\icon_5.png",
  [4] = "gui\\language\\ChineseS\\tvt\\icon_2.png",
  [5] = "gui\\language\\ChineseS\\tvt\\icon_3.png",
  [6] = "gui\\language\\ChineseS\\tvt\\icon_6.png"
}
local PAGE_NUM = 5
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
local tvt_disable = {
  on = "gui\\language\\ChineseS\\newtvt\\noplay_on.png",
  nor = "gui\\language\\ChineseS\\newtvt\\noplay_out.png",
  sel = "gui\\language\\ChineseS\\newtvt\\noplay_down.png"
}
local TVT_LEVEL_MAX = 5
g_join_filt = {
  [ITT_SPY_MENP] = {3},
  [ITT_PATROL] = {4, 6},
  [ITT_FANGHUO] = {},
  [ITT_JIUHUO] = {},
  [ITT_YUNBIAO] = {},
  [ITT_JIEBIAO] = {},
  [ITT_DUOSHU] = {4, 6},
  [ITT_HUSHU] = {4, 6},
  [ITT_BANGFEI] = {},
  [ITT_XIASHI] = {},
  [ITT_PATROL_CHAOTING] = {},
  [ITT_SHOULEI] = {},
  [ITT_DALEI] = {},
  [ITT_BANGPAIZHAN] = {},
  [ITT_BANGPAIZHAN_2] = {},
  [ITT_MENPAIZHAN] = {},
  [ITT_MENPAIZHAN_2] = {},
  [ITT_ARREST] = {},
  [ITT_WORLDLEITAI] = {},
  [ITT_WORLDLEITAI_RANDOM] = {},
  [ITT_SCHOOLMOOT] = {},
  [ITT_TEAMFACULTY] = {},
  [ITT_YUNBIAO_ACTIVE] = {},
  [ITT_JHHJ] = {},
  [ITT_HUASHAN_FIGHTER] = {},
  [ITT_WORLDWAR] = {},
  [ITT_AVATAR] = {},
  [ITT_SUPERBOOK] = {},
  [ITT_WORLDBOSS] = {},
  [ITT_MARRY_TASK] = {},
  [ITT_ESCORT_SHENGZHU_GOLD] = {},
  [ITT_TIGUAN_DANSHUA] = {},
  [ITT_MATCH_RIVERS] = {},
  [ITT_MATCH_SCHOOL] = {},
  [ITT_SCHOOL_DANCE] = {},
  [ITT_DAMO_REPENT] = {}
}
g_submit_filt = {
  [ITT_SPY_MENP] = {4, 6},
  [ITT_PATROL] = {4, 6},
  [ITT_FANGHUO] = {},
  [ITT_JIUHUO] = {},
  [ITT_YUNBIAO] = {},
  [ITT_JIEBIAO] = {},
  [ITT_DUOSHU] = {4, 6},
  [ITT_HUSHU] = {4, 6},
  [ITT_BANGFEI] = {},
  [ITT_XIASHI] = {},
  [ITT_PATROL_CHAOTING] = {},
  [ITT_SHOULEI] = {},
  [ITT_DALEI] = {},
  [ITT_BANGPAIZHAN] = {},
  [ITT_BANGPAIZHAN_2] = {},
  [ITT_MENPAIZHAN] = {},
  [ITT_MENPAIZHAN_2] = {},
  [ITT_ARREST] = {},
  [ITT_WORLDLEITAI] = {},
  [ITT_WORLDLEITAI_RANDOM] = {},
  [ITT_SCHOOLMOOT] = {},
  [ITT_TEAMFACULTY] = {},
  [ITT_YUNBIAO_ACTIVE] = {},
  [ITT_JHHJ] = {},
  [ITT_HUASHAN_FIGHTER] = {},
  [ITT_WORLDWAR] = {},
  [ITT_AVATAR] = {},
  [ITT_SUPERBOOK] = {},
  [ITT_WORLDBOSS] = {},
  [ITT_MARRY_TASK] = {},
  [ITT_ESCORT_SHENGZHU_GOLD] = {},
  [ITT_TIGUAN_DANSHUA] = {},
  [ITT_MATCH_RIVERS] = {},
  [ITT_MATCH_SCHOOL] = {},
  [ITT_SCHOOL_DANCE] = {},
  [ITT_DAMO_REPENT] = {}
}
function open_form(tvt_tag, tvt_name)
  util_auto_show_hide_form(nx_current())
  if tvt_tag ~= nil and tvt_name ~= nil then
    goto_tvt_info(tvt_tag, tvt_name)
  end
end
function filtrate_scene(info, type, sort)
  if table.getn(info) == 0 then
    return
  end
  local school_scene = {
    "school_wudang",
    "school_shaolin",
    "school_jinyiwei",
    "school_emei",
    "school_gaibang",
    "school_junzitang",
    "school_jilegu",
    "school_tangmen"
  }
  local type_showtips = {
    [5] = 1
  }
  local temp_info = {}
  for i, name in pairs(info) do
    table.insert(temp_info, i, name)
  end
  local filt_tab
  if sort == 0 then
    filt_tab = g_join_filt[type]
  else
    filt_tab = g_submit_filt[type]
  end
  if filt_tab == nil then
    return
  end
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  local school = player_obj:QueryProp("School")
  local school_name = util_format_string(school)
  local scene_name = get_cur_scene_name()
  local breset = true
  local count = table.getn(filt_tab)
  for i, cell in pairs(filt_tab) do
    if type_showtips[cell] ~= nil and type_showtips[cell] == 1 then
      breset = false
    end
    if cell == 1 then
      for j = table.getn(info), 1, -1 do
        local is_school = false
        for k, name in pairs(school_scene) do
          if info[j] == util_format_string(name) then
            is_school = true
            break
          end
        end
        if not is_school then
          table.remove(info, j)
        end
      end
    elseif cell == 2 then
      local scene_name = get_cur_scene_name()
      for j = table.getn(info), 1, -1 do
        if info[j] ~= scene_name then
          table.remove(info, j)
        end
      end
    elseif cell == 3 then
      for j = table.getn(info), 1, -1 do
        if info[j] == school_name then
          table.remove(info, j)
        end
      end
    elseif cell == 4 then
      if school ~= nil and school ~= 0 and school ~= "" then
        for j = table.getn(info), 1, -1 do
          if info[j] ~= school_name then
            table.remove(info, j)
          end
        end
      end
    elseif cell == 5 then
      if school == nil or school == 0 then
        for j = table.getn(info), 1, -1 do
          table.remove(info, j)
        end
      end
    elseif cell == 6 and (school == nil or school == 0 or school == "") then
      for j = table.getn(info), 1, -1 do
        local is_school = false
        for k, name in pairs(school_scene) do
          if info[j] == util_format_string(name) then
            is_school = true
            break
          end
        end
        if is_school then
          table.remove(info, j)
        end
      end
    end
  end
  if breset and table.getn(info) == 0 then
    for i, name in pairs(temp_info) do
      table.insert(info, i, name)
    end
  end
end
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function on_main_form_init(form)
  form.Fixed = false
  form.cur_form = nx_null()
  form.select = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  send_server_msg(g_msg_update_notice)
  send_server_msg(g_msg_base_info)
  form.rbtn_12.tvtclass = "Richang"
  form.rbtn_12.Name = "Richang"
  form.rbtn_3.tvtclass = "tongxing"
  form.rbtn_3.Name = "tongxing"
  form.rbtn_4.tvtclass = "jindi"
  form.rbtn_4.Name = "jindi"
  form.rbtn_5.tvtclass = "tianqi"
  form.rbtn_5.Name = "tianqi"
  form.rbtn_7.tvtclass = "biwu"
  form.rbtn_7.Name = "biwu"
  form.rbtn_8.tvtclass = "Shenghuo"
  form.rbtn_8.Name = "Shenghuo"
  form.rbtn_11.tvtclass = "exchange"
  form.rbtn_11.Name = "exchange"
  form.rbtn_15.tvtclass = "Guild"
  form.rbtn_16.tvtclass = "School"
  form.rbtn_10.Visible = false
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    mgr = nx_create("InteractManager")
    if not nx_is_valid(mgr) then
      return
    end
    nx_set_value("InteractManager", mgr)
  end
  form.btn_new_join.Enabled = false
  form.btn_quit.Enabled = false
  nx_set_custom(form, "tvtclass", "TuiJian")
  nx_set_custom(form, "type", 0)
  form.groupbox_main.Visible = false
  form.rbtn_12.Checked = true
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, 1, g_form_name, "request_weather_data", form, -1, -1)
  end
end
function request_weather_data(form)
  send_server_msg(g_msg_weather_open)
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
  local ui_tips = mgr:GetPrizeTips(form.type)
  local x, y = gui:GetCursorClientPos()
  nx_execute("tips_game", "show_text_tip", nx_widestr(ui_tips), x, y)
end
function on_main_form_close(form)
  for key, value in pairs(SUB_FORM) do
    if nx_find_custom(form, nx_string(key)) then
      local sub_form = nx_custom(form, nx_string(key))
      if nx_is_valid(sub_form) then
        sub_form:Close()
      end
    end
  end
  local tmform = nx_value("form_stage_main\\form_tvt\\form_tvt_time")
  if nx_is_valid(tmform) then
    nx_destroy(tmform)
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(g_form_name, "request_weather_data", form)
  end
  nx_destroy(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function refresh_tj(rbtn)
  local form = rbtn.ParentForm
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  form.groupbox_jianghu.Visible = true
  local table_tvt = mgr:GetSuggestTvt()
  local group = form.groupscrollbox_1
  group:DeleteAll()
  local switch_open = {
    [ITT_MARRY_TASK] = ST_FUNCTION_MARRY
  }
  local gui = nx_value("gui")
  local rbtn_default = nx_null()
  local switch_close_num = 0
  for i, name in pairs(table_tvt) do
    local _sort = nx_int(name)
    local switchopen = true
    if switch_open[nx_number(_sort)] ~= nil then
      switchopen = switch_manager:CheckSwitchEnable(switch_open[nx_number(_sort)])
    end
    if not switchopen then
      switch_close_num = switch_close_num + 1
    end
    if switchopen then
      local groupbox = create_tvt_ctl(_sort)
      if nx_is_valid(groupbox) then
        group:Add(groupbox)
      end
      if not nx_is_valid(rbtn_default) then
        rbtn_default = groupbox.sel_rbtn
      end
    end
  end
  group:ResetChildrenYPos()
  if nx_is_valid(rbtn_default) then
    rbtn_default.Checked = true
  end
end
function refresh_group(rbtn)
  local form = rbtn.ParentForm
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  form.groupbox_jianghu.Visible = true
  form.groupbox_tuijian.Visible = false
  local switch_open = {
    [ITT_MARRY_TASK] = ST_FUNCTION_MARRY
  }
  local sorts = mgr:GetGroupTvts(rbtn.tvtclass)
  local group = form.groupscrollbox_1
  group:DeleteAll()
  local gui = nx_value("gui")
  local rbtn_default = nx_null()
  local switch_close_num = 0
  for i, name in pairs(sorts) do
    local _sort = nx_int(name)
    local switchopen = true
    if switch_open[nx_number(_sort)] ~= nil then
      switchopen = switch_manager:CheckSwitchEnable(switch_open[nx_number(_sort)])
    end
    if not switchopen then
      switch_close_num = switch_close_num + 1
    end
    if switchopen then
      local groupbox = create_tvt_ctl(_sort)
      if nx_is_valid(groupbox) then
        group:Add(groupbox)
      end
      if not nx_is_valid(rbtn_default) then
        rbtn_default = groupbox.sel_rbtn
      end
    end
  end
  group:ResetChildrenYPos()
  if nx_is_valid(rbtn_default) then
    rbtn_default.Checked = true
  end
end
function create_tvt_ctl(tvt_type)
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return nx_null()
  end
  local SchoolExtinct = nx_value("SchoolExtinct")
  if not nx_is_valid(SchoolExtinct) then
    return nx_null()
  end
  local gui = nx_value("gui")
  local info = mgr:GetTvtBaseInfo(tvt_type)
  local groupbox = gui:Create("GroupBox")
  if not nx_is_valid(groupbox) then
    return nx_null()
  end
  local rbtn = gui:Create("CheckButton")
  local multext = gui:Create("MultiTextBox")
  local lbl_name = gui:Create("Label")
  local lbl_tvt_pic = gui:Create("Label")
  local lbl_pvp_pic = gui:Create("Label")
  groupbox:Add(rbtn)
  groupbox:Add(multext)
  groupbox:Add(lbl_name)
  groupbox:Add(lbl_tvt_pic)
  groupbox:Add(lbl_pvp_pic)
  groupbox.Left = -3
  groupbox.Top = -3
  groupbox.Width = 279
  groupbox.Height = 113
  groupbox.BackColor = "0,255,255,255"
  groupbox.NoFrame = true
  local text = gui.TextManager:GetText("form_newtvt_ts_wkq")
  local bopen = false
  if mgr:IsInteractOpen(tvt_type) then
    text = nx_widestr(info[16])
    bopen = true
  end
  local is_extincted = SchoolExtinct:IsPlayerSchoolExtincted()
  local extincted_school = SchoolExtinct:GetExtinctSchool()
  if is_extincted and nx_number(tvt_type) == nx_number(ITT_SCHOOLMOOT) then
    text = gui.TextManager:GetFormatText("ui_wywl_mm_001", extincted_school)
  end
  is_extincted = is_extincted or SchoolExtinct:IsRelatedSchoolExtinct()
  if is_extincted and (nx_number(tvt_type) == nx_number(ITT_SPY_MENP) or nx_number(tvt_type) == nx_number(ITT_PATROL)) then
    text = gui.TextManager:GetFormatText("ui_wywl_mm_001", extincted_school)
  end
  local tvt_image = {}
  if not bopen then
    tvt_image = tvt_disable
  else
    local lv = mgr:GetTvtLevel(tvt_type)
    if lv >= TVT_LEVEL_MAX then
      lv = TVT_LEVEL_MAX
    elseif lv <= 0 then
      lv = 1
    end
    tvt_image = tvt_level_pic[lv]
  end
  if nx_is_valid(multext) then
    multext:Clear()
    multext.Transparent = true
    multext.Left = 15
    multext.Top = 36
    multext.Width = 190
    multext.Height = 62
    multext.Font = "font_text_chat"
    multext.TextColor = "255,255,255,255"
    multext.SelectBarColor = "0,0,0,255"
    multext.MouseInBarColor = "0,0,0,255"
    multext.NoFrame = true
    multext.ViewRect = "0,2,200,62"
    multext.HtmlText = text
  end
  if nx_is_valid(rbtn) then
    rbtn.NormalImage = tvt_image.nor
    rbtn.FocusImage = tvt_image.on
    rbtn.CheckedImage = tvt_image.sel
    rbtn.Width = 279
    rbtn.Height = 118
    rbtn.Left = 0
    rbtn.Top = 0
    rbtn.Name = "sort" .. nx_string(tvt_type)
    nx_bind_script(rbtn, nx_current())
    nx_callback(rbtn, "on_checked_changed", "on_type_new_changed")
    nx_set_custom(rbtn, "type", tvt_type)
    groupbox.sel_rbtn = rbtn
  end
  if nx_is_valid(lbl_name) then
    lbl_name.Left = 89
    lbl_name.Top = 8
    lbl_name.Width = 102
    lbl_name.Height = 16
    lbl_name.ForeColor = "255,216,203,55"
    lbl_name.Font = "font_title"
    lbl_name.Align = "Center"
    lbl_name.Text = info[1]
  end
  if nx_is_valid(lbl_tvt_pic) then
    lbl_tvt_pic.Left = 208
    lbl_tvt_pic.Top = 43
    lbl_tvt_pic.Width = 90
    lbl_tvt_pic.Height = 90
    lbl_tvt_pic.AutoSize = true
    lbl_tvt_pic.BackImage = info[4]
  end
  local pvp_info = mgr:GetTvtSugPic(tvt_type)
  if nx_is_valid(lbl_pvp_pic) then
    lbl_pvp_pic.Left = 0
    lbl_pvp_pic.Top = -3
    lbl_pvp_pic.Width = 38
    lbl_pvp_pic.Height = 16
    lbl_pvp_pic.AutoSize = true
    if pvp_info ~= "" then
      lbl_pvp_pic.BackImage = pvp_info
    else
      lbl_pvp_pic.Visible = false
    end
  end
  return groupbox
end
function on_tvttype_changed(rbtn)
  if not rbtn.Checked then
    return 0
  end
  local form = rbtn.ParentForm
  form.tvtclass = rbtn.tvtclass
  if nx_find_custom(form, "cur_form") and nx_is_valid(form.cur_form) then
    form.cur_form.Visible = false
  end
  if rbtn.tvtclass == "tianqi" or rbtn.tvtclass == "tongxing" or rbtn.tvtclass == "jindi" or rbtn.tvtclass == "Shenghuo" or rbtn.tvtclass == "biwu" or rbtn.tvtclass == "Guild" or rbtn.tvtclass == "School" or rbtn.tvtclass == "Richang" then
    form.groupbox_main.Visible = false
    refresh_group(rbtn)
  else
    form.groupbox_jianghu.Visible = false
    form.groupbox_tuijian.Visible = false
    if not nx_find_custom(form, nx_string(rbtn.tvtclass)) then
      return 0
    end
    local sub_form = nx_custom(form, nx_string(rbtn.tvtclass))
    if not nx_is_valid(sub_form) then
      return 0
    end
    sub_form.Visible = true
    form.cur_form = sub_form
  end
  nx_execute("tips_game", "hide_tip")
  if nx_string(rbtn.Name) == nx_string("Jindi") then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_join_place_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.listbox_join_place.Visible = true
  form.listbox_join_place:ClearString()
  form.mltbox_container:Clear()
  form.mltbox_container.Left = 130
  form.mltbox_container.ViewRect = "0,0,366,110"
  form.mltbox_container.Width = 380
  local mgr = nx_value("InteractManager")
  local info = mgr:GetTvtHyperCity(form.type, 0)
  form.select = 0
  if 0 < table.getn(info) then
    filtrate_scene(info, form.type, 0)
    local list_box = form.listbox_join_place
    for i, name in pairs(info) do
      list_box:AddString(name)
    end
    list_box.SelectIndex = 0
    on_city_select_click(list_box)
  end
  if not is_show_join_place(form.type) then
    show_join_tips(form.mltbox_container, form.type)
  elseif 0 >= table.getn(info) then
  end
end
function on_city_select_click(listbox)
  local form = listbox.ParentForm
  local mgr = nx_value("InteractManager")
  local info = mgr:GetTvtHyper(form.type, form.select, listbox.SelectString)
  local txtbox = form.mltbox_container
  txtbox:Clear()
  if table.getn(info) > 0 then
    for i, name in pairs(info) do
      txtbox:AddHtmlText(name, 0)
    end
  end
end
function on_show_prize_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.listbox_join_place.Visible = true
  form.listbox_join_place:ClearString()
  form.mltbox_container:Clear()
  form.mltbox_container.Left = 130
  form.mltbox_container.ViewRect = "0,0,366,110"
  form.mltbox_container.Width = 380
  local mgr = nx_value("InteractManager")
  local info = mgr:GetTvtHyperCity(form.type, 1)
  form.select = 1
  if table.getn(info) > 0 then
    filtrate_scene(info, form.type, 1)
    local list_box = form.listbox_join_place
    for i, name in pairs(info) do
      list_box:AddString(name)
    end
    list_box.SelectIndex = 0
    on_city_select_click(list_box)
  end
  if not is_show_submit_place(form.type) then
    show_submit_tips(form.mltbox_container, form.type)
  end
end
function on_show_rule_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.mltbox_container:Clear()
  form.listbox_join_place.Visible = false
  form.mltbox_container.Left = 0
  form.mltbox_container.ViewRect = "10,0,480,110"
  form.mltbox_container.Width = 510
  local mgr = nx_value("InteractManager")
  local info = mgr:GetTvtBaseInfo(form.type)
  form.mltbox_container.HtmlText = nx_widestr(info[6])
end
function on_info_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
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
    [ITT_JINDI] = "form_stage_main\\form_clone\\form_clone_main"
  }
  if ITT_TIGUAN_DANSHUA == btn.ParentForm.type then
    util_auto_show_hide_form("form_stage_main\\form_tiguan\\form_tiguan_one")
  end
  if ITT_ZJTX == btn.ParentForm.type then
    local form_activity = nx_value("form_stage_main\\form_activity\\form_activity_partner")
    if not nx_is_valid(form_activity) then
      nx_execute("form_stage_main\\form_activity\\form_activity_partner", "show_form")
    else
      util_auto_show_hide_form("form_stage_main\\form_activity\\form_activity_partner")
    end
  end
  if ITT_TTLEITAI == btn.ParentForm.type then
    util_auto_show_hide_form("form_stage_main\\form_general_info\\form_general_info_main")
  end
  if ITT_HOME_SYSTEM == btn.ParentForm.type then
    local form_home = nx_value("form_stage_main\\form_home\\form_home")
    if not nx_is_valid(form_home) then
      nx_execute("form_stage_main\\form_home\\form_home", "open_form")
    else
      util_auto_show_hide_form("form_stage_main\\form_home\\form_home")
    end
  end
  if ITT_MARRY_SYSTEM == btn.ParentForm.type then
    nx_execute("form_stage_main\\form_marry\\form_marry_sns", "open_form")
  end
  if ITT_JIANGHU_BATTLE == btn.ParentForm.type then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_join", "open_form")
  end
  if ITT_SHUZHUANGGE == btn.ParentForm.type then
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "open_form")
  end
  if ITT_KH_TREASURE == btn.ParentForm.type then
    local form_dbomall = nx_value("form_stage_main\\form_dbomall\\form_dbomall")
    if not nx_is_valid(form_dbomall) then
      nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "open_form", "form_stage_main\\form_task\\form_seek_mine")
    else
      util_auto_show_hide_form("form_stage_main\\form_dbomall\\form_dbomall")
    end
  end
  if ITT_ZADAN_GIFT == btn.ParentForm.type then
    local form_dbomall = nx_value("form_stage_main\\form_dbomall\\form_dbomall")
    if not nx_is_valid(form_dbomall) then
      nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "open_form", "form_stage_main\\puzzle_quest\\form_select_egg")
    else
      util_auto_show_hide_form("form_stage_main\\form_dbomall\\form_dbomall")
    end
  end
  if ITT_LIFE_JOB == btn.ParentForm.type then
    local form_main = nx_value("form_stage_main\\form_main\\form_main")
    if nx_is_valid(form_main) then
      if form_main.rbtn_life.Enabled == true and form_main.rbtn_life.Checked == false then
        form_main.rbtn_life.Checked = true
      elseif form_main.rbtn_fight.Enabled == true and form_main.rbtn_fight.Checked == false then
        form_main.rbtn_fight.Checked = true
      end
    end
  end
  if ITT_WORLDWAR_LXC == btn.ParentForm.type then
    util_auto_show_hide_form("form_stage_main\\form_world_war\\form_world_war_join")
    local form_join = nx_value("form_stage_main\\form_world_war\\form_world_war_join")
    if nx_is_valid(form_join) then
      form_join.rbtn_scene_2.Checked = true
    end
  end
  if ITT_JHHJ == btn.ParentForm.type then
    util_auto_show_hide_form("form_stage_main\\form_map\\form_map_scene")
    local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
    if nx_is_valid(form_map) then
      local gui = nx_value("gui")
      gui.Desktop:ToFront(form_map)
      nx_execute("form_stage_main\\form_map\\form_map_scene", "open_XinShiLi_node")
    end
  end
  if ITT_WORLDWAR == btn.ParentForm.type then
    util_auto_show_hide_form("form_stage_main\\form_world_war\\form_world_war_join")
  end
  if ITT_HUASHAN_FIGHTER == btn.ParentForm.type then
    util_auto_show_hide_form("form_stage_main\\form_huashan\\form_huashan_main")
  end
  if ITT_MATCH_RIVERS == btn.ParentForm.type then
    util_auto_show_hide_form("form_stage_main\\form_general_info\\form_general_info_main")
  end
  if ITT_MATCH_SCHOOL == btn.ParentForm.type then
    util_auto_show_hide_form("form_stage_main\\form_general_info\\form_general_info_main")
  end
  if ITT_AVATAR == btn.ParentForm.type then
    util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
    local form_help = util_get_form("form_stage_main\\form_helper\\form_theme_helper", false)
    if nx_is_valid(form_help) then
      nx_execute("form_stage_main\\form_helper\\form_theme_helper", "click_hyperlink", form_help, "jhqb,jianghuqy02,xinmo03_03,intro04")
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
  end
  if ITT_SUPERBOOK == btn.ParentForm.type then
    util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
    local form_help = util_get_form("form_stage_main\\form_helper\\form_theme_helper", false)
    if nx_is_valid(form_help) then
      nx_execute("form_stage_main\\form_helper\\form_theme_helper", "click_hyperlink", form_help, "jhqb,jianghuzd02,jhzhibao03,jhzhibaojj04")
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
  end
  local name = form_names[btn.ParentForm.type]
  if name == nil then
    return
  end
  if not can_show_detail_info(btn.ParentForm.type) then
    return
  end
  util_auto_show_hide_form(name)
  if btn.ParentForm.type == ITT_DUOSHU and (form.btn_new_join.Enabled or form.btn_quit.Enabled) then
    nx_execute("custom_sender", "custom_send_interact_msg", g_msg_school_request_book_info)
  elseif btn.ParentForm.type == ITT_HUSHU and (form.btn_new_join.Enabled or form.btn_quit.Enabled) then
    nx_execute("custom_sender", "custom_send_interact_msg", g_msg_school_request_book_info)
  end
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
function refresh_tips(form)
  local switch_open = {
    [ITT_MARRY_TASK] = ST_FUNCTION_MARRY
  }
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local mgr = nx_value("InteractManager")
  local sorts = mgr:GetGroupInfo(form.tvtclass)
  local group = form.groupbox_2
  group:DeleteAll()
  local gui = nx_value("gui")
  local switch_close_num = 0
  for i, name in pairs(sorts) do
    if nx_int(i) ~= nx_int(1) then
      local _sort = nx_int(name)
      local switchopen = true
      if switch_open[nx_number(_sort)] ~= nil then
        switchopen = switch_manager:CheckSwitchEnable(switch_open[nx_number(_sort)])
      end
      if not switchopen then
        switch_close_num = switch_close_num + 1
      end
      if switchopen then
        local info = mgr:GetTvtBaseInfo(_sort)
        local rbtn = gui:Create("RadioButton")
        group:Add(rbtn)
        rbtn.NormalImage = "gui\\common\\treeview\\tree_1_out.png"
        rbtn.FocusImage = "gui\\common\\treeview\\tree_1_out.png"
        rbtn.CheckedImage = "gui\\common\\treeview\\tree_4_on.png"
        rbtn.Width = 150
        rbtn.Height = 30
        rbtn.Left = 10
        rbtn.Top = 10 + (i - 2 - switch_close_num) * 32
        rbtn.DrawMode = "ExpandH"
        rbtn.Name = "sort" .. nx_string(name)
        rbtn.Text = info[1]
        rbtn.Font = "font_main"
        rbtn.NormalColor = "255,197,184,159"
        rbtn.FocusColor = "255,255,255,255"
        rbtn.PushColor = "255,255,255,255"
        nx_bind_script(rbtn, nx_current())
        nx_callback(rbtn, "on_checked_changed", "on_type_changed")
        nx_set_custom(rbtn, "type", _sort)
      end
    end
  end
  group:ResetChildrenYPos()
end
function find_tvt_rbtn(groupbox, tvt_type)
  if not nx_is_valid(groupbox) then
    return nx_null()
  end
  local child_list = groupbox:GetChildControlList()
  local count = table.getn(child_list)
  for i = 1, count do
    local child_gb = child_list[i]
    if nx_is_valid(child_gb) and nx_is_valid(child_gb.sel_rbtn) and child_gb.sel_rbtn.type == tvt_type then
      return child_gb.sel_rbtn
    end
  end
  return nx_null()
end
function on_btn_tj_click(btn)
  if not nx_find_custom(btn, "tvt_type") then
    return
  end
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local table_group = {
    tongxing = "rbtn_jh",
    tianqi = "rbtn_bh",
    jindi = "rbtn_mp"
  }
  local index = ""
  for name, _v in pairs(table_group) do
    if mgr:IsTvtInGroup(name, btn.tvt_type) then
      index = name
      break
    end
  end
  local show_group = false
  if table_group[name] ~= nil then
    local rbtn = nx_custom(form, table_group[name])
    if nx_is_valid(rbtn) then
      rbtn.Checked = true
      show_group = true
    end
  end
  if show_group ~= true then
    return
  end
  local tvt_rbtn = find_tvt_rbtn(form.groupscrollbox_1, btn.tvt_type)
  if nx_is_valid(tvt_rbtn) then
    tvt_rbtn.Checked = true
  end
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
function show_type_info(type)
  util_show_form(g_form_name, true)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  if 80 == type then
  elseif 81 == type then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_tiguan", "open_form")
    return
  end
  local direction = {
    "tongxing",
    "jindi",
    "tianqi"
  }
  local mgr = nx_value("InteractManager")
  for i, name in pairs(direction) do
    if mgr:IsTvtInGroup(name, type) then
      local rbtn = form.groupbox_3:Find(name)
      if rbtn ~= nil then
        rbtn.Checked = true
        break
      end
    end
  end
  local tvt_rbtn = find_tvt_rbtn(form.groupscrollbox_1, type)
  if nx_is_valid(tvt_rbtn) then
    tvt_rbtn.Checked = true
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
    [61] = 1,
    [ITT_TIGUAN_DANSHUA] = 1,
    [ITT_MATCH_RIVERS] = 1,
    [ITT_MATCH_SCHOOL] = 1,
    [ITT_WORLDWAR_LXC] = 1,
    [ITT_NLHH] = 1
  }
  if nx_int(type) >= nx_int(ITT_ZJTX) and nx_int(type) <= nx_int(ITT_LUOYANG_DJ) then
    return -1
  end
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
function change_all_rbtn(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  local form = rbtn.ParentForm
  local groupbox = form.groupscrollbox_1
  local child_list = groupbox:GetChildControlList()
  local count = table.getn(child_list)
  for i = 1, count do
    local child_gb = child_list[i]
    if nx_is_valid(child_gb) and nx_is_valid(child_gb.sel_rbtn) then
      local cbtn_other = child_gb.sel_rbtn
      if nx_string(cbtn_other.Name) ~= nx_string(rbtn.Name) then
        cbtn_other.Checked = false
      end
    end
  end
end
function on_type_new_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local gui = nx_value("gui")
  change_all_rbtn(rbtn)
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local form = rbtn.ParentForm
  form.mltbox_rule:Clear()
  form.mltbox_need:Clear()
  form.mltbox_prize:Clear()
  form.mltbox_23:Clear()
  form.imagegrid_2:Clear()
  local type = rbtn.type
  form.type = type
  local info = mgr:GetTvtBaseInfo(type)
  form.lbl_23.Text = nx_widestr(info[1])
  local text = util_text("TVT_name_098")
  if nx_ws_equal(nx_widestr(info[1]), nx_widestr(text)) then
    form.lbl_23.Font = "font_title"
  else
    form.lbl_23.Font = "font_sns_name"
  end
  local text = gui.TextManager:GetText("form_newtvt_002")
  if mgr:IsInteractOpen(type) then
    text = gui.TextManager:GetText("form_newtvt_001")
  end
  form.lbl_253.Text = text
  form.mltbox_5.HtmlText = nx_widestr(info[5])
  form.lbl_diff.Text = nx_widestr(info[13])
  local base_info = get_interact_base_info(type)
  local btn_left = form.btn_quit.Left
  local btn_wd = form.btn_quit.Width
  form.btn_quit.Visible = nx_string(info[11]) ~= ""
  form.btn_quit.Text = info[11]
  if form.btn_quit.Visible then
    btn_left = btn_left - btn_wd + 27
  end
  form.btn_new_join.Left = btn_left
  form.btn_new_join.Visible = nx_string(info[12]) ~= ""
  form.btn_new_join.Text = info[12]
  if form.btn_new_join.Visible then
    btn_left = btn_left - btn_wd + 27
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
      lbl.Width = 120
      lbl.Height = 32
      lbl.Left = form.btn_info.Left - 2
      lbl.Top = form.btn_info.Top + 8
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
    form.lbl_count.Text = util_format_string("@wuxianzhi")
  else
    form.lbl_count.Text = nx_widestr(base_info[3])
  end
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
  if base_info[5] == nil or base_info[5] == "" or base_info[5] == "0" then
    form.lbl_26.Visible = true
    form.btn_63.Visible = false
    form.lbl_26.Text = util_format_string(showprg[type])
  else
    form.lbl_26.Visible = false
    form.btn_63.Visible = true
    nx_set_custom(form, "tvt_time", base_info[5])
  end
  local next_time = mgr:GetNextOpen(type)
  if table.getn(next_time) == 3 and next_time[2] ~= nil and next_time[3] ~= nil then
    nx_set_custom(form, "col_time", nx_number(next_time[2]))
    nx_set_custom(form, "row_time", nx_number(next_time[3]))
  end
  local times = get_tvt_times(type)
  if times == -1 then
    form.lbl_times.Text = util_format_string("@wuxianzhi")
  else
    form.lbl_times.Text = nx_widestr(times)
  end
  form.mltbox_rule.HtmlText = nx_widestr(info[6])
  form.mltbox_need.HtmlText = nx_widestr(info[15])
  form.mltbox_date.HtmlText = util_text(nx_string(info[18]))
  form.lbl_star.BackImage = nx_string(info[17])
  local is_show = is_need_show(type)
  form.groupbox_prize.Visible = is_show
  form.mltbox_prize.Visible = not is_show
  if is_show then
    local tmp_imagegrid = form.imagegrid_2
    if nx_int(type) == nx_int(ITT_HUASHAN_FIGHTER) then
      tmp_imagegrid:AddItem(nx_int(0), "gui\\language\\ChineseS\\tvt\\icon_2.png", "", 1, -1)
      tmp_imagegrid:AddItem(nx_int(1), "gui\\language\\ChineseS\\tvt\\icon_9.png", "", 1, -1)
    else
      local grid_index = 0
      local table_len = table.getn(prize_image_t)
      for i = 1, 9 do
        if mgr:IsHavePrizeType(nx_int(type), i - 1) and table_len >= i - 1 then
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
  on_new_join_place(form, type)
  send_server_msg(g_msg_test_accept, type)
end
function on_type_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local type = rbtn.type
  form.type = type
  local mgr = nx_value("InteractManager")
  local info = mgr:GetTvtBaseInfo(type)
  form.lbl_name.Text = info[1]
  form.lbl_photo.BackImage = info[4]
  form.mltbox_desc.HtmlText = info[5]
  form.lbl_11.Text = nx_widestr(info[13])
  form.lbl_15:Clear()
  form.lbl_15:AddHtmlText(nx_widestr(info[14]), -1)
  local btn_left = form.btn_2.Left
  local btn_wd = form.btn_2.Width
  form.btn_2.Visible = nx_string(info[11]) ~= ""
  form.btn_2.Text = info[11]
  if form.btn_2.Visible then
    btn_left = btn_left - btn_wd
  end
  form.btn_join.Left = btn_left
  form.btn_join.Visible = nx_string(info[12]) ~= ""
  form.btn_join.Text = info[12]
  if form.btn_join.Visible then
    btn_left = btn_left - btn_wd
  end
  form.btn_1.Left = btn_left
  form.btn_1.Visible = nx_string(info[10]) ~= ""
  form.btn_1.Text = info[10]
  local base_info = get_interact_base_info(type)
  if base_info[3] == nil or base_info[3] == "0" then
    form.lbl_17.Text = util_format_string("@wuxianzhi")
  else
    form.lbl_17.Text = nx_widestr(base_info[3])
  end
  if base_info[5] == nil or base_info[5] == "0" then
    form.lbl_3.Visible = true
    form.btn_3.Visible = false
  else
    form.lbl_3.Visible = false
    form.btn_3.Visible = true
    nx_set_custom(form, "tvt_time", base_info[5])
  end
  local next_time = mgr:GetNextOpen(type)
  if table.getn(next_time) == 3 then
    if next_time[1] == nil or next_time[1] == "" then
      form.lbl_13.Text = util_format_string("@nextopen")
    else
      form.lbl_13.Text = util_format_string(next_time[1])
    end
    if next_time[2] ~= nil and next_time[3] ~= nil then
      nx_set_custom(form, "col_time", nx_number(next_time[2]))
      nx_set_custom(form, "row_time", nx_number(next_time[3]))
    end
  end
  local times = get_tvt_times(type)
  if times == -1 then
    form.lbl_14.Text = util_format_string("@wuxianzhi")
  else
    form.lbl_14.Text = nx_widestr(times)
  end
  send_server_msg(g_msg_test_accept, type)
  form.rbtn_9.Checked = true
  form.rbtn_7.Checked = true
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
function on_recv_server_msg(cmd, ...)
  local manager = nx_value("InteractManager")
  if not nx_is_valid(manager) then
    manager = nx_create("InteractManager")
    nx_set_value("InteractManager", manager)
  end
  if cmd == g_msg_base_info then
    local count = nx_number(arg[1])
    for i = 2, count + 1 do
      manager:ParseInfo(nx_int(i - 2), nx_string(arg[i]))
    end
  elseif cmd == g_msg_player_list then
    local type = nx_int(arg[1])
    manager:ParsePlayerList(type, arg[2])
    nx_execute("form_stage_main\\form_tvt\\form_tvt_info", "refresh_paihangbang")
  elseif cmd == g_msg_update_playerinfo then
    nx_execute("form_stage_main\\form_school_war\\form_escort_interact_info", "update_member_result", arg[2])
  elseif cmd == g_msg_useskill then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_skill", "cool_btn", arg[1])
  elseif cmd == g_msg_spyval or cmd == g_msg_steal_in_findval then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_skill", "add_spy_val", arg[1])
  elseif cmd == g_msg_test_accept then
    local form = nx_value(g_form_name)
    if not nx_is_valid(form) then
      form = nx_value("form_stage_main\\form_tvt\\form_tvt_merge")
      if not nx_is_valid(form) then
        return
      end
    end
    local type = arg[1]
    if type ~= form.type then
      return
    end
    local msg = arg[2]
    if msg == EAI_SUCCEED then
      local succeed_tab = {
        [ITT_TIGUAN_DANSHUA] = "@show_now_35"
      }
      form.btn_quit.Enabled = false
      if is_show_join_btn(type) then
        form.btn_new_join.Enabled = true
      else
        form.btn_new_join.Enabled = false
      end
    else
      error_tab = {
        [EAI_OTHER] = "@not_can_accept",
        [EAI_ERROR_TIME] = "@not_can_accept1",
        [EAI_ERROR_WEEK] = "@not_can_accept2",
        [EAI_ERROR_SCHOOL] = "@not_can_accept3",
        [EAI_ERROR_CONDITION] = "@not_can_accept4",
        [EAI_ERROR_MAX_TIMES] = "@not_can_accept5",
        [EAI_ERROR_JOIN] = "@not_can_accept6",
        [EAI_COOL_DOWN] = "@not_can_accept7",
        [EAI_FRESH_MEN] = "@not_can_accept8",
        [EAI_INARENA] = "@not_can_accept9",
        [EAI_ERROR_GUILD] = "@not_can_accept10",
        [EAI_ERROR_LEVEL] = "@not_can_accept29"
      }
      notshow_tab = {
        [25] = "@show_now_25"
      }
      if error_tab[msg] ~= nil then
        form.btn_new_join.Enabled = false
        if is_show_giveup_btn(type) then
          form.btn_quit.Enabled = true
        else
          form.btn_quit.Enabled = false
        end
      end
    end
    if nx_number(type) == nx_number(ITT_MENPAIZHAN) or nx_number(type) == nx_number(ITT_SUPERBOOK) then
      form.btn_new_join.Enabled = true
      form.btn_quit.Enabled = true
    end
  elseif cmd == g_msg_tvt_status_change then
    local type = nx_int(arg[1])
    local ntype = manager:GetCurrentTvtType()
    util_show_form(g_form_name, false)
    if type ~= nx_int(ntype) and ntype ~= -1 and type ~= -1 then
      return
    end
    local bStatus = false
    if is_show_trace() then
      bStatus = nx_int(arg[2]) == nx_int(1)
    end
    manager.TraceFlag = bStatus
    util_show_form("form_stage_main\\form_tvt\\form_tvt_skill", bStatus)
    if bStatus then
      nx_execute("form_stage_main\\form_single_notice", "show_tvt_trace_info")
    else
      nx_execute("form_stage_main\\form_single_notice", "clear_tvt_trace_info", nx_number(type))
    end
  elseif cmd == g_msg_choose_snatch_target then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_snatch_target", "show_form", unpack(arg))
  elseif cmd == g_msg_school_result_book_info then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_snatchbook_map", "show_school_book_info", unpack(arg))
  elseif cmd == g_msg_call_patrol then
    local type = manager:GetCurrentTvtType()
    if type == ITT_PATROL then
      nx_execute("form_stage_main\\form_main\\form_main_request_right", "add_request_item", 67, "")
      g_spy_name = nx_widestr(arg[1])
    end
  elseif cmd == g_msg_recommend_info then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_merge", "refresh_form", unpack(arg))
  elseif cmd == g_msg_new_act_info then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_merge", "refresh_actform", unpack(arg))
  end
end
function on_weather_msg(...)
  local list = util_split_string(nx_string(arg[1]), ",")
  local count = table.getn(list) - 1
  if nx_int(count % 2) ~= nx_int(0) then
    return
  end
  local interact_manager = nx_value("InteractManager")
  if not nx_is_valid(interact_manager) then
    return
  end
  interact_manager:ClearWeatherWarStateData()
  for i = 1, count, 2 do
    local type = list[i]
    local state = list[i + 1]
    interact_manager:AddWeatherWarStateData(nx_int(type), nx_int(state))
  end
end
function show_call_form()
  local gui = nx_value("gui")
  local text = ""
  text = util_format_string("ui_spy_trans1", g_spy_name)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_to_spy", g_msg_call_patrol, g_spy_name)
  end
end
function on_ready()
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    mgr = nx_create("InteractManager")
    nx_set_value("InteractManager", mgr)
  end
  local type = mgr:GetCurrentTvtType()
  if type ~= -1 then
    util_show_form("form_stage_main\\form_tvt\\form_tvt_skill", true)
    nx_execute("form_stage_main\\form_single_notice", "show_tvt_trace_info")
  else
    util_show_form("form_stage_main\\form_tvt\\form_tvt_skill", false)
  end
end
function on_continue()
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    mgr = nx_create("InteractManager")
    nx_set_value("InteractManager", mgr)
  end
  local type = mgr:GetCurrentTvtType()
  if nx_number(type) ~= -1 then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_skill", "show_tvt_skill")
    nx_execute("form_stage_main\\form_single_notice", "show_tvt_trace_info")
  end
end
function is_show_join_btn(type)
  local join_btn = {
    [ITT_SPY_MENP] = true,
    [ITT_PATROL] = true,
    [ITT_SPY_CHAOTING] = true,
    [ITT_DUOSHU] = true,
    [ITT_HUSHU] = true,
    [ITT_WORLDLEITAI] = true,
    [ITT_WORLDLEITAI_RANDOM] = true
  }
  if join_btn[type] ~= nil and join_btn[type] then
    return true
  end
  return false
end
function is_show_giveup_btn(type)
  local mgr = nx_value("InteractManager")
  local exit_btn = {
    [ITT_YUNBIAO] = 1,
    [ITT_JIEBIAO] = 1
  }
  if exit_btn[type] ~= nil then
    return false
  end
  local tvtstate = mgr:GetInteractStatus(type)
  if tvtstate == PIS_IN_GAME then
    return true
  end
  return false
end
function is_show_join_place(type)
  local mgr = nx_value("InteractManager")
  local info = mgr:GetTvtHyperCity(type, 0)
  if 0 < table.getn(info) then
    return true
  end
  return false
end
function show_join_tips(mltbox, type)
  local join_tips = {
    [ITT_SPY_MENP] = "@show_jion_tips0",
    [ITT_PATROL] = "@show_jion_tips1",
    [ITT_FANGHUO] = "@show_jion_tips2",
    [ITT_JIUHUO] = "@show_jion_tips3",
    [ITT_YUNBIAO] = "@show_jion_tips4",
    [ITT_JIEBIAO] = "@show_jion_tips5",
    [ITT_DUOSHU] = "@show_jion_tips6",
    [ITT_HUSHU] = "@show_jion_tips7",
    [ITT_BANGFEI] = "@show_jion_tips8",
    [ITT_XIASHI] = "@show_jion_tips9",
    [ITT_PATROL_CHAOTING] = "@show_jion_tips10",
    [ITT_SHOULEI] = "@show_jion_tips11",
    [ITT_DALEI] = "@show_jion_tips12",
    [ITT_BANGPAIZHAN] = "@show_jion_tips13",
    [ITT_BANGPAIZHAN_2] = "@show_jion_tips14",
    [ITT_MENPAIZHAN] = "@show_jion_tips15",
    [ITT_MENPAIZHAN_2] = "@show_jion_tips16",
    [ITT_ARREST] = "@show_jion_tips17",
    [ITT_WORLDLEITAI] = "@show_jion_tips18",
    [ITT_WORLDLEITAI_RANDOM] = "@show_jion_tips19",
    [ITT_SCHOOLMOOT] = "@show_jion_tips21",
    [ITT_TEAMFACULTY] = "@show_jion_tips22",
    [ITT_YUNBIAO_ACTIVE] = "@show_jion_tips23",
    [ITT_JHHJ] = "@show_jion_tips24",
    [ITT_HUASHAN_FIGHTER] = "@show_jion_tips25",
    [ITT_WORLDWAR] = "@show_jion_tips29",
    [ITT_AVATAR] = "@show_jion_tips30",
    [ITT_SUPERBOOK] = "@show_jion_tips31",
    [ITT_WORLDBOSS] = "@show_jion_tips32",
    [ITT_MARRY_TASK] = "@show_join_tips33",
    [ITT_ESCORT_SHENGZHU_GOLD] = "@show_join_tips34",
    [ITT_TIGUAN_DANSHUA] = "@show_jion_tips35",
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
    [ITT_DAMO_REPENT] = "@show_join_tips129"
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
    [ITT_DAMO_REPENT] = "@show_submit_tips129"
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
function get_cur_scene_name()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return ""
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  local scene_config = client_scene:QueryProp("ConfigID")
  local scene_name = gui.TextManager:GetFormatText(scene_config)
  return scene_name
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
  form.max_page = math.ceil(count / PAGE_NUM) - 1
  if 0 > form.max_page then
    form.max_page = 0
  end
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
  form.max_page = math.ceil(count / PAGE_NUM) - 1
  if 0 > form.max_page then
    form.max_page = 0
  end
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
function on_btn_15_click(rbtn)
  local form_dbomall = nx_value("form_stage_main\\form_dbomall\\form_dbomall")
  if nx_is_valid(form_dbomall) then
    form_dbomall:Close()
  else
    local dbomall_manager = nx_value("dbomall_manager")
    if nx_is_valid(dbomall_manager) and dbomall_manager:IsAllConditionClosed() then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("96088"))
      return
    end
    util_show_form("form_stage_main\\form_dbomall\\form_dbomall", true)
  end
end
function on_btn_4_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_tvt\\form_tvt_exchange")
end
function goto_tvt_info(tvt_tag, tvt_name)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible == false then
    return
  end
  if form.groupbox_main.Visible ~= false then
    return
  end
  local rbtn
  if tvt_tag == "tianqi" then
    rbtn = form.rbtn_5
  elseif tvt_tag == "tongxing" then
    rbtn = form.rbtn_3
  elseif tvt_tag == "jindi" then
    rbtn = form.rbtn_4
  elseif tvt_tag == "Shenghuo" then
    rbtn = form.rbtn_8
  elseif tvt_tag == "biwu" then
    rbtn = form.rbtn_7
  elseif tvt_tag == "Guild" then
    rbtn = form.rbtn_15
  elseif tvt_tag == "School" then
    rbtn = form.rbtn_16
  elseif tvt_tag == "Richang" then
    rbtn = form.rbtn_12
  else
    return
  end
  rbtn.Checked = true
  on_tvttype_changed(rbtn)
  local control_list = form.groupscrollbox_1:GetChildControlList()
  for i = 1, table.getn(control_list) do
    local control = control_list[i]
    if nx_number(control.sel_rbtn.type) == nx_number(tvt_name) then
      control.sel_rbtn.Checked = true
      on_type_new_changed(control.sel_rbtn)
      return
    end
  end
end
