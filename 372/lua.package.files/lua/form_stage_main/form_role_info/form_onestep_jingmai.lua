require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("tips_data")
require("custom_sender")
local FORM_ONESTEP_JINGMAI = "form_stage_main\\form_role_info\\form_onestep_jingmai"
local PREPARE_JINGMAI_REC = "PepareJingMaiRec"
local CLIENT_SUBMSG_PREPARE_JINGMAI_ACTIVE = 1
local CLIENT_SUBMSG_PREPARE_JINGMAI_CLOSE = 2
local CLIENT_SUBMSG_PREPARE_JINGMAI_USE = 3
local ONE_KEY_INDEX_NORMAL_MIN = 0
local ONE_KEY_INDEX_NORMAL_MAX = 3
local ONE_KEY_INDEX_WORLD_MIN = 100
local ONE_KEY_INDEX_WORLD_MAX = 103
function on_form_init(form)
  form.Fixed = true
  form.nKeyIndex = -1
  form.type_name = ""
  form.active_count = 0
end
function on_form_onestep_jingmai_open(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_JINGMAI, form, nx_current(), "on_jingmai_viewport_change")
    databinder:AddTableBind(PREPARE_JINGMAI_REC, form, nx_current(), "on_preparejingmai_record_change")
  end
  show_jingmai_type(form)
end
function on_form_onestep_jingmai_close(form)
  nx_execute("tips_game", "hide_tip", form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
    databinder:DelTableBind(PREPARE_JINGMAI_REC, form)
  end
  nx_destroy(form)
end
function on_jingmai_viewport_change(form, optype, view_ident, index)
  if not nx_is_valid(form) then
    return 0
  end
  if nx_string(optype) == "updateitem" then
    local timer = nx_value("timer_game")
    timer:Register(CALLBACK_WAIT_TIME, 1, nx_current(), "show_jingmai_data", form, -1, -1)
  elseif nx_string(optype) == "additem" then
    show_jingmai_type(form)
  end
end
function on_preparejingmai_record_change(form, tablename, op, row, col)
  show_jingmai_data(form)
end
function on_tree_types_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  form.type_name = sel_node.type_name
  show_jingmai_data(self.ParentForm)
end
function on_btn_jingmai_active_click(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "nKeyIndex") then
    return 0
  end
  if not nx_find_custom(self, "jingmai_id") then
    return 0
  end
  local nKeyIndex = form.nKeyIndex
  local jingmai_id = self.jingmai_id
  if check_jingmai_prepare_active(form.nKeyIndex, jingmai_id) then
    custom_prepare_jingmai_active(CLIENT_SUBMSG_PREPARE_JINGMAI_CLOSE, nKeyIndex, jingmai_id)
  else
    local total_num = get_player_prop("jmActCount")
    if nx_number(total_num) <= nx_number(form.active_count) then
      return 0
    end
    custom_prepare_jingmai_active(CLIENT_SUBMSG_PREPARE_JINGMAI_ACTIVE, nKeyIndex, jingmai_id)
  end
end
function on_btn_jingmai_active_get_capture(self)
  local form = self.ParentForm
  if not nx_find_custom(self, "jingmai_id") then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local jingmai = wuxue_query:GetLearnID_JingMai(nx_string(self.jingmai_id))
  if not nx_is_valid(jingmai) then
    return 0
  end
  nx_execute("tips_game", "show_goods_tip", jingmai, self.AbsLeft, self.AbsTop, 32, 32, self.ParentForm)
end
function on_btn_jingmai_active_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function show_jingmai_type(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local type_tab = wuxue_query:GetMainNames(WUXUE_JINGMAI)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local rButton = gui:Create("RadioButton")
    if check_type_is_show(type_name) and nx_is_valid(rButton) then
      rButton.NormalImage = "gui\\special\\sns_new\\jh_explore\\fenye-out.png"
      rButton.FocusImage = "gui\\special\\sns_new\\jh_explore\\fenye-on.png"
      rButton.CheckedImage = "gui\\special\\sns_new\\jh_explore\\fenye-down.png"
      rButton.Font = "font_text_title1"
      rButton.Text = util_text(type_name)
      rButton.Width = 90
      rButton.Height = 35
      rButton.Left = (i - 1) * 92
      rButton.Top = 5
      rButton.Align = center
      rButton.ForeColor = "255,255,255,255"
      rButton.type_name = type_name
      if form.type_name == "" or form.type_name == type_name then
        form.type_name = type_name
        rButton.Checked = true
      end
      nx_bind_script(rButton, nx_current())
      nx_callback(rButton, "on_checked_changed", "on_jingmai_changed")
      form.gbox_jingmai_name:Add(rButton)
    end
  end
end
function show_jingmai_data(form)
  local gui = nx_value("gui")
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return false
  end
  if not nx_find_custom(form, "nKeyIndex") then
    return 0
  end
  if nx_number(form.nKeyIndex) == -1 then
    return 0
  end
  form.gpsbox_jingmai:DeleteAll()
  form.active_count = get_active_count_by_key(form.nKeyIndex)
  local total_num = get_player_prop("jmActCount")
  form.mltbox_tips.HtmlText = gui.TextManager:GetFormatText("tips_jingmai_active_num", nx_int(form.active_count), nx_int(total_num))
  local jingmai_tab = wuxue_query:GetSubNames(WUXUE_JINGMAI, form.type_name)
  for i = 1, table.getn(jingmai_tab) do
    local jingmai_id = jingmai_tab[i]
    if check_jingmai_is_show(jingmai_id) then
      local gbox_jingmai = create_ctrl("GroupBox", "gbox_jingmai_" .. nx_string(i), form.gbox_jingmai, form.gpsbox_jingmai)
      if not nx_is_valid(gbox_jingmai) then
        return false
      end
      local lbl_jingmai_name = create_ctrl("Label", "lbl_jingmai_name" .. nx_string(i), form.lbl_jingmai_name, gbox_jingmai)
      local lbl_jingmai_level_z = create_ctrl("Label", "lbl_jingmai_level_z" .. nx_string(i), form.lbl_jingmai_level_z, gbox_jingmai)
      local lbl_jingmai_level_n = create_ctrl("Label", "lbl_jingmai_level_n" .. nx_string(i), form.lbl_jingmai_level_n, gbox_jingmai)
      local btn_jingmai_active_z = create_ctrl("Button", "btn_jingmai_active_z" .. nx_string(i), form.btn_jingmai_active_z, gbox_jingmai)
      local btn_jingmai_active_n = create_ctrl("Button", "btn_jingmai_active_n" .. nx_string(i), form.btn_jingmai_active_n, gbox_jingmai)
      if not (nx_is_valid(lbl_jingmai_name) and nx_is_valid(lbl_jingmai_level_z) and nx_is_valid(lbl_jingmai_level_n) and nx_is_valid(btn_jingmai_active_z)) or not nx_is_valid(btn_jingmai_active_n) then
        return false
      end
      nx_bind_script(btn_jingmai_active_z, nx_current())
      nx_callback(btn_jingmai_active_z, "on_click", "on_btn_jingmai_active_click")
      nx_callback(btn_jingmai_active_z, "on_get_capture", "on_btn_jingmai_active_get_capture")
      nx_callback(btn_jingmai_active_z, "on_lost_capture", "on_btn_jingmai_active_lost_capture")
      nx_bind_script(btn_jingmai_active_n, nx_current())
      nx_callback(btn_jingmai_active_n, "on_click", "on_btn_jingmai_active_click")
      nx_callback(btn_jingmai_active_n, "on_get_capture", "on_btn_jingmai_active_get_capture")
      nx_callback(btn_jingmai_active_n, "on_lost_capture", "on_btn_jingmai_active_lost_capture")
      lbl_jingmai_name.Text = util_text(jingmai_id)
      local jingmai_z = wuxue_query:GetLearnID_JingMai(nx_string(jingmai_id))
      if nx_is_valid(jingmai_z) then
        local canLevel = get_maxlevel_by_conditions(jingmai_z)
        local curLevel = jingmai_z:QueryProp("Level")
        lbl_jingmai_level_z.Text = nx_widestr(nx_string(curLevel) .. "/" .. nx_string(canLevel)) .. util_text("ui_cycle_day")
        btn_jingmai_active_z.jingmai_id = jingmai_id
        btn_jingmai_active_z.Enabled = true
        if check_jingmai_prepare_active(form.nKeyIndex, jingmai_id) then
          btn_jingmai_active_z.Text = util_text("ui_jm_guanbi")
        else
          btn_jingmai_active_z.Text = util_text("ui_jm_jihuo")
        end
      else
        lbl_jingmai_level_z.Text = util_text("ui_wuxue_level_0")
        btn_jingmai_active_z.jingmai_id = jingmai_id
        btn_jingmai_active_z.Enabled = false
        btn_jingmai_active_z.Text = util_text("ui_jm_jihuo")
      end
      local jingmai_id_n = jingmai_query:GetConvertJingMai(jingmai_id)
      if jingmai_id_n ~= "" then
        local jingmai_n = wuxue_query:GetLearnID_JingMai(jingmai_id_n)
        if nx_is_valid(jingmai_n) then
          local canLevel = get_maxlevel_by_conditions(jingmai_n)
          local curLevel = jingmai_n:QueryProp("Level")
          lbl_jingmai_level_n.Text = nx_widestr(nx_string(curLevel) .. "/" .. nx_string(canLevel)) .. util_text("ui_cycle_day")
          btn_jingmai_active_n.jingmai_id = jingmai_id_n
          btn_jingmai_active_n.Enabled = true
          if check_jingmai_prepare_active(form.nKeyIndex, jingmai_id_n) then
            btn_jingmai_active_n.Text = util_text("ui_jm_guanbi")
          else
            btn_jingmai_active_n.Text = util_text("ui_jm_jihuo")
          end
        else
          lbl_jingmai_level_n.Text = util_text("ui_wuxue_level_0")
          btn_jingmai_active_n.jingmai_id = jingmai_id_n
          btn_jingmai_active_n.Enabled = false
          btn_jingmai_active_n.Text = util_text("ui_jm_jihuo")
        end
      else
        lbl_jingmai_level_n.Visible = false
        btn_jingmai_active_n.Visible = false
      end
    end
  end
  form.gpsbox_jingmai:ResetChildrenYPos()
end
function get_active_count_by_key(nKeyIndex)
  local active_count = 0
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return active_count
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return active_count
  end
  local col = nx_number(nKeyIndex)
  if col >= ONE_KEY_INDEX_WORLD_MIN and col <= ONE_KEY_INDEX_WORLD_MAX then
    col = col - ONE_KEY_INDEX_WORLD_MIN + client_player:GetRecordCols(PREPARE_JINGMAI_REC) / 2
  end
  local rows = client_player:GetRecordRows(PREPARE_JINGMAI_REC)
  for i = 0, rows - 1 do
    local jingmai_id = client_player:QueryRecord(PREPARE_JINGMAI_REC, i, col)
    if nx_string(jingmai_id) ~= "" then
      active_count = active_count + 1
    end
  end
  return active_count
end
function on_jingmai_changed(btn)
  local form = btn.ParentForm
  if not btn.Checked then
    return
  end
  if not nx_find_custom(form, "type_name") then
    return 0
  end
  form.type_name = btn.type_name
  show_jingmai_data(form)
end
function check_type_is_show(jingmai_type)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return false
  end
  local jingmai_tab = wuxue_query:GetSubNames(WUXUE_JINGMAI, jingmai_type)
  for i = 1, table.getn(jingmai_tab) do
    local jingmai_id = jingmai_tab[i]
    if check_jingmai_is_show(jingmai_id) then
      return true
    end
  end
  return false
end
function check_jingmai_is_show(jingmai_id)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return false
  end
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return false
  end
  if jingmai_query:CheckJingMaiZhengNi(jingmai_id, false) then
    return false
  end
  local item_z = wuxue_query:GetLearnID_JingMai(jingmai_id)
  if nx_is_valid(item_z) then
    return true
  end
  local jingmai_id_n = jingmai_query:GetConvertJingMai(jingmai_id)
  if jingmai_id_n == "" then
    return false
  end
  local item_n = wuxue_query:GetLearnID_JingMai(jingmai_id_n)
  if nx_is_valid(item_n) then
    return true
  end
  return false
end
function check_jingmai_prepare_active(nKeyIndex, jingmai_id)
  if jingmai_id == nil or nx_string(jingmai_id) == "" then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local col = nx_number(nKeyIndex)
  if col >= ONE_KEY_INDEX_WORLD_MIN and col <= ONE_KEY_INDEX_WORLD_MAX then
    col = col - ONE_KEY_INDEX_WORLD_MIN + client_player:GetRecordCols(PREPARE_JINGMAI_REC) / 2
  end
  local row = client_player:FindRecordRow(PREPARE_JINGMAI_REC, nx_int(col), nx_string(jingmai_id), 0)
  if nx_int(row) >= nx_int(0) then
    return true
  end
  return false
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function set_one_key_index(nKeyIndex)
  local form = nx_value(FORM_ONESTEP_JINGMAI)
  if not nx_is_valid(form) then
    return 0
  end
  form.nKeyIndex = nx_number(nKeyIndex)
  show_jingmai_data(form)
end
function one_key_active_jingmai(nKeyIndex)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return 0
  end
  if not game_config.one_key_active_jingmai then
    return 0
  end
  custom_prepare_jingmai_active(CLIENT_SUBMSG_PREPARE_JINGMAI_USE, nKeyIndex)
end
