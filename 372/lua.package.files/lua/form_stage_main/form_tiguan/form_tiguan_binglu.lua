require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\view_define")
local BINGLU_RANK_REC = "binglu_rank_rec"
local BINGLU_REC_CUR_LEVEL = 0
local BINGLU_REC_VALUE_FILL = 1
local BINGLU_REC_MAX_LEVEL = 2
function open_form(...)
  nx_execute("util_gui", "util_show_form", nx_current(), true)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.item_id = arg[1]
  local max_num = get_item_total_num(arg[1])
  form.edit_binglu_num.Text = nx_widestr(max_num)
  disable_cant_use_type_ctrl(form)
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(form)
  form.rbtn_1.Checked = true
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  if nx_find_custom(form_main, "tiguan_binglu_top") and nx_find_custom(form_main, "tiguan_binglu_left") then
    form.Top = form_main.tiguan_binglu_top
    form.Left = form_main.tiguan_binglu_left
  end
end
function on_main_form_close(form)
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  form_main.tiguan_binglu_top = form.Top
  form_main.tiguan_binglu_left = form.Left
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_ok_click(btn)
  local name = "rbtn_1"
  local rbtn = nx_null()
  local form = btn.ParentForm
  modify_edit_binglu_num_value(btn)
  for i = 1, 11 do
    name = "rbtn_" .. nx_string(i)
    rbtn = nx_custom(form, name)
    if nx_is_valid(rbtn) and rbtn.Checked then
      local CUSTOMMSG_SUB_MODIFY_BINGLU_ADD_LEVEL = 1
      custom_modify_binglu(CUSTOMMSG_SUB_MODIFY_BINGLU_ADD_LEVEL, form.item_id, nx_number(rbtn.DataSource), nx_int(form.edit_binglu_num.Text))
      form:Close()
      return
    end
  end
end
function on_edit_binglu_num_changed(float_edit)
  modify_edit_binglu_num_value(float_edit)
end
function modify_edit_binglu_num_value(ctrl)
  local form = ctrl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "item_id") then
    return
  end
  local item_config = form.item_id
  local max_num = get_item_total_num(item_config)
  if nx_int(max_num) < nx_int(form.edit_binglu_num.Text) then
    form.edit_binglu_num.Text = nx_widestr(max_num)
  end
end
function get_item_total_num(config)
  game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local toolbox = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(toolbox) then
    return 0
  end
  local sum = 0
  local toolbox_objlist = toolbox:GetViewObjList()
  for i, obj in pairs(toolbox_objlist) do
    local config_id = obj:QueryProp("ConfigID")
    if nx_string(config_id) == nx_string(config) then
      sum = nx_int(sum) + nx_int(obj:QueryProp("Amount"))
    end
  end
  return sum
end
function disable_cant_use_type_ctrl(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local max_binglu_level = 0
  local item_query = nx_value("ItemQuery")
  if nx_is_valid(item_query) then
    max_binglu_level = item_query:GetItemPropByConfigID(nx_string(form.item_id), "MaxBingLuLevel")
  end
  if nx_int(max_binglu_level) <= nx_int(0) then
    return
  end
  local rowcount = client_player:GetRecordRows(BINGLU_RANK_REC)
  if rowcount <= 0 then
    return
  end
  for i = 1, 11 do
    name = "rbtn_" .. nx_string(i)
    rbtn = nx_custom(form, name)
    if nx_is_valid(rbtn) and nx_int(rbtn.DataSource - 100) >= nx_int(0) and nx_int(rbtn.DataSource - 100) < nx_int(rowcount) then
      local cur_level = client_player:QueryRecord(BINGLU_RANK_REC, nx_int(rbtn.DataSource - 100), BINGLU_REC_CUR_LEVEL)
      if nx_int(max_binglu_level) <= nx_int(cur_level) then
        rbtn.Enabled = false
      end
    end
  end
end
