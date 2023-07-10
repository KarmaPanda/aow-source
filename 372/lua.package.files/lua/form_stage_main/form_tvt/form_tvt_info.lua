require("util_gui")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
local g_page_items = 5
local g_form_name = "form_stage_main\\form_tvt\\form_tvt_info"
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  for i = 1, g_page_items do
    form["groupbox_phb_" .. nx_string(i)].Visible = false
  end
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    mgr = nx_create("InteractManager")
    nx_set_value("InteractManager", mgr)
  end
  if not nx_is_valid(mgr) then
    util_show_form(g_form_name, false)
    return
  end
  if is_show_trace() then
    form.cbtn_trace.Enabled = mgr:GetCurrentTvtType() >= 0
  else
    form.cbtn_trace.Enabled = false
    form.cbtn_trace.Checked = false
  end
  form.type = -1
  form.curpage = 1
  form.maxpage = 1
  check_form_page(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function on_city_selected(cbox)
  local form = cbox.ParentForm
  local box = cbox.DropListBox
  local type = form.type
  local hyper_type = cbox.hyper_type
  local mgr = nx_value("InteractManager")
  local info = mgr:GetTvtHyper(type, hyper_type, box.SelectString)
  local txtbox = form.mltbox_hyper
  txtbox:Clear()
  if table.getn(info) > 0 then
    for i, name in pairs(info) do
      txtbox:AddHtmlText(name, 0)
    end
  else
    txtbox:AddHtmlText(util_format_string("ui_morenxinxi"), 0)
  end
end
function on_accept_changed(rbtn)
  rbtn.ParentForm.combobox_city.InputEdit.Text = ""
  local txtbox = rbtn.ParentForm.mltbox_hyper
  txtbox:Clear()
  if rbtn.Checked then
    local box = rbtn.ParentForm.combobox_city.DropListBox
    local type = rbtn.ParentForm.type
    nx_set_custom(rbtn.ParentForm.combobox_city, "hyper_type", 0)
    local mgr = nx_value("InteractManager")
    local info = mgr:GetTvtHyperCity(type, 0)
    box:ClearString()
    for i, name in pairs(info) do
      box:AddString(name)
    end
    on_city_selected(rbtn.ParentForm.combobox_city)
  end
end
function on_giveup_changed(rbtn)
  local txtbox = rbtn.ParentForm.mltbox_hyper
  txtbox:Clear()
  if rbtn.Checked then
    local box = rbtn.ParentForm.combobox_city.DropListBox
    local type = rbtn.ParentForm.type
    nx_set_custom(rbtn.ParentForm.combobox_city, "hyper_type", 1)
    local mgr = nx_value("InteractManager")
    local info = mgr:GetTvtHyperCity(type, 1)
    box:ClearString()
    for i, name in pairs(info) do
      box:AddString(name)
    end
    on_city_selected(rbtn.ParentForm.combobox_city)
  end
end
function on_trace_checked_changed(cbtn)
  local mgr = nx_value("InteractManager")
  mgr.TraceFlag = cbtn.Checked
  if mgr.TraceFlag then
    open_trace()
  else
    close_trace()
  end
end
function open_trace()
  local mgr = nx_value("InteractManager")
  mgr.TraceFlag = true
  local form = nx_value(g_form_name)
  if nx_is_valid(form) and form.cbtn_trace.Enabled then
    form.cbtn_trace.Checked = true
  end
  nx_execute("form_stage_main\\form_tvt\\form_text_trace", "show_trace")
end
function close_trace()
  local mgr = nx_value("InteractManager")
  mgr.TraceFlag = false
  mgr.TraceInfo = 0
  local form = nx_value(g_form_name)
  if nx_is_valid(form) and form.cbtn_trace.Enabled then
    form.cbtn_trace.Checked = false
  end
  util_show_form("form_stage_main\\form_tvt\\form_text_trace", false)
  util_show_form("form_stage_main\\form_tvt\\form_trace", false)
end
function on_info_click(btn)
  local form_names = {
    [ITT_SPY_MENP] = nil,
    [ITT_SPY_CHAOTING] = nil,
    [ITT_FANGHUO] = "form_stage_main\\form_guild_fire\\form_fire_interact",
    [ITT_JIUHUO] = "form_stage_main\\form_guild_fire\\form_fire_interact",
    [ITT_YUNBIAO] = nil,
    [ITT_JIEBIAO] = "form_stage_main\\form_school_war\\form_escort_trace",
    [ITT_DUOSHU] = nil,
    [ITT_BANGFEI] = nil,
    [ITT_MENPAIZHAN] = "form_stage_main\\form_school_war\\form_school_fight_rank",
    [ITT_ARREST] = "form_stage_main\\form_arrest\\form_arrest_manage"
  }
  local name = form_names[btn.ParentForm.type]
  if name == nil then
    return
  end
  if not can_show_detail_info(btn.ParentForm.type) then
    return
  end
  util_show_form(name, true)
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
      return false
    end
    local rows = client_scene:FindRecordRow("Time_Limit_Form_Rec", 0, "schoolfight002")
    if rows < 0 then
      return false
    end
  end
  return true
end
function on_quit_tvt_click(btn)
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
function on_join_click(btn)
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
function show_tvt_info(type)
  util_show_form(g_form_name, true)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  form.type = type
  local mgr = nx_value("InteractManager")
  local info = mgr:GetTvtBaseInfo(type)
  form.lbl_name.Text = info[1]
  form.lbl_photo.BackImage = info[4]
  form.mltbox_desc.HtmlText = info[5]
  form.mltbox_rule.HtmlText = info[6]
  form.lbl_text_4.Text = info[7]
  form.btn_1.Visible = nx_string(info[10]) ~= ""
  form.btn_1.Text = info[10]
  form.btn_2.Visible = nx_string(info[11]) ~= ""
  form.btn_2.Text = info[11]
  form.btn_join.Visible = nx_string(info[12]) ~= ""
  form.btn_join.Text = info[12]
  local btn_names = mgr:GetAcceptGiveupButtonName(type)
  local count = table.getn(btn_names)
  form.rbtn_accept.Visible = nx_string(btn_names[1]) ~= ""
  form.rbtn_accept.Text = btn_names[1]
  form.rbtn_giveup.Visible = nx_string(btn_names[2]) ~= ""
  form.rbtn_giveup.Text = btn_names[2]
  form.rbtn_accept.Checked = true
  if form.cbtn_trace.Enabled then
    form.cbtn_trace.Checked = mgr.TraceFlag
  end
  form.combobox_city.Text = nx_widestr("")
  form.mltbox_hyper:Clear()
  form.mltbox_hyper:AddHtmlText(util_format_string("ui_morenxinxi"), 0)
end
function on_update_paihangbang()
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("InteractManager")
  local count = mgr:GetPlayerCount(form.type)
  form.maxpage = math.floor(count / g_page_items) + 1
  check_form_page(form)
  refresh_paihangbang()
end
function refresh_paihangbang()
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local g_control = {
    [1] = {
      group = form.groupbox_phb_1,
      img = form.lbl_phb_icon_1,
      name = form.lbl_phb_name_1,
      v1 = form.lbl_phb_value_11,
      v2 = form.lbl_phb_value_12
    },
    [2] = {
      group = form.groupbox_phb_2,
      img = form.lbl_phb_icon_2,
      name = form.lbl_phb_name_2,
      v1 = form.lbl_phb_value_21,
      v2 = form.lbl_phb_value_22
    },
    [3] = {
      group = form.groupbox_phb_3,
      img = form.lbl_phb_icon_3,
      name = form.lbl_phb_name_3,
      v1 = form.lbl_phb_value_31,
      v2 = form.lbl_phb_value_32
    },
    [4] = {
      group = form.groupbox_phb_4,
      img = form.lbl_phb_icon_4,
      name = form.lbl_phb_name_4,
      v1 = form.lbl_phb_value_41,
      v2 = form.lbl_phb_value_42
    },
    [5] = {
      group = form.groupbox_phb_5,
      img = form.lbl_phb_icon_5,
      name = form.lbl_phb_name_5,
      v1 = form.lbl_phb_value_51,
      v2 = form.lbl_phb_value_52
    }
  }
  for i, item in pairs(g_control) do
    item.group.Visible = false
  end
  local curpage = form.curpage
  local type = form.type
  local mgr = nx_value("InteractManager")
  local count = mgr:GetPlayerCount(type)
  if count <= 0 then
    return
  end
  local index_min = (curpage - 1) * g_page_items
  local index_max = index_min + g_page_items
  if count < index_max then
    index_max = count
  end
  local tvt_base = mgr:GetTvtBaseInfo(type)
  local item_index = 1
  for i = index_min, index_max - 1 do
    local item = g_control[item_index]
    item.group.Visible = true
    local info = mgr:GetPlayerInfo(type, i)
    item.img.BackImage = nx_string(info[2])
    item.name.Text = util_format_string("{@0:name}", info[1])
    item.v1.Text = util_format_string(tvt_base[8], info[3])
    item.v2.Text = util_format_string(tvt_base[9], info[4])
    item_index = item_index + 1
  end
end
function on_prepage_click(btn)
  local form = btn.ParentForm
  form.curpage = form.curpage - 1
  check_form_page(form)
  refresh_paihangbang()
end
function on_nextpage_click(btn)
  local form = btn.ParentForm
  form.curpage = form.curpage - 1
  check_form_page(form)
  refresh_paihangbang()
end
function check_form_page(form)
  local page = form.curpage
  local maxpage = form.maxpage
  if page < 1 then
    page = 1
  end
  if maxpage < page then
    page = maxpage
  end
  form.btn_3.Enabled = 1 < page
  form.btn_4.Enabled = maxpage > page
  form.lbl_1.Text = util_format_string("{@0:page}/{@1:max}", page, maxpage)
end
