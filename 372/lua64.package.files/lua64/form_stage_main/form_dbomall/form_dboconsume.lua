require("util_gui")
require("util_functions")
require("util_static_data")
local FORM_DBOCONSUME = "form_stage_main\\form_dbomall\\form_dboconsume"
local CLIENT_SUBMSG_REFRESH_FORM = 0
local CLIENT_SUBMSG_GET_REWARD = 1
local SERVER_SUBMSG_ACTIVITY_CONFIG = 0
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.groupbox_template_item.Visible = false
  form.cur_select_need = -1
  nx_execute("custom_sender", "custom_online_purchase_rebate", CLIENT_SUBMSG_REFRESH_FORM)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_imagegrid_item_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  local item_id = grid:GetItemName(index)
  if item_id == nx_widestr("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_id, x, y, form)
end
function on_imagegrid_item_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_get_reward_click(btn)
  local form = btn.ParentForm
  if nx_find_custom(form, "cur_select_need") and nx_int(form.cur_select_need) > nx_int(0) then
    nx_execute("custom_sender", "custom_online_purchase_rebate", CLIENT_SUBMSG_GET_REWARD, nx_int(form.cur_select_need))
  end
end
function on_rbtn_consume_changed(rbtn)
  if not nx_boolean(rbtn.Checked) then
    return
  end
  local form = rbtn.ParentForm
  if nx_find_custom(rbtn, "silvercard_need") then
    form.cur_select_need = rbtn.silvercard_need
  else
    form.cur_select_need = -1
  end
  if nx_find_custom(rbtn, "b_flag") then
    form.btn_get_reward.Enabled = rbtn.b_flag
  else
    form.btn_get_reward.Enabled = false
  end
  create_item_gbox(rbtn)
end
function on_btn_page_click(btn)
  local form = btn.ParentForm
  local direction = btn.TabIndex
  local max_count = nx_int(nx_int(form.gbox_info.Width) / nx_int(form.groupbox_template_item.Width + 25))
  local list = form.gbox_info:GetChildControlList()
  local gbox_count = table.getn(list)
  if max_count >= nx_int(gbox_count) then
    return
  end
  if direction == 2 then
    local gbox_end = nx_custom(form, "gbox_iteminfo_" .. nx_string(gbox_count))
    if nx_is_valid(gbox_end) and nx_int(gbox_end.Left) <= nx_int(form.groupbox_template_item.Width * (max_count - 1)) then
      return
    end
  elseif btn.TabIndex == 1 then
    local gbox_first = nx_custom(form, "gbox_iteminfo_" .. nx_string(1))
    if nx_is_valid(gbox_first) and nx_int(gbox_first.Left) == nx_int(0) then
      return
    end
  end
  local gbox = nx_null()
  for i = 1, gbox_count do
    gbox = nx_custom(form, "gbox_iteminfo_" .. nx_string(i))
    if not nx_is_valid(gbox) then
      return
    end
    if direction == 2 then
      gbox.Left = gbox.Left - (gbox.Width + 25)
    elseif btn.TabIndex == 1 then
      gbox.Left = gbox.Left + (gbox.Width + 25)
    end
  end
end
function open_form()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local form = util_show_form(FORM_DBOCONSUME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  nx_execute("custom_sender", "custom_online_purchase_rebate", CLIENT_SUBMSG_REFRESH_FORM)
end
function on_refresh(sub_msg, ...)
  local arg_count = table.getn(arg)
  if nx_int(sub_msg) == nx_int(SERVER_SUBMSG_ACTIVITY_CONFIG) then
    local form = nx_value(FORM_DBOCONSUME)
    if not nx_is_valid(form) then
      return
    end
    refresh_form_info(unpack(arg))
  end
end
function refresh_form_info(...)
  local form = nx_value(FORM_DBOCONSUME)
  if not nx_is_valid(form) then
    return
  end
  local arg_count = table.getn(arg)
  if nx_int(arg_count) < nx_int(17) then
    return
  end
  local arg_start_year = nx_int(arg[1])
  local arg_start_month = nx_int(arg[2])
  local arg_start_day = nx_int(arg[3])
  local arg_start_hour = nx_int(arg[4])
  local arg_start_min = nx_int(arg[5])
  local arg_end_year = nx_int(arg[6])
  local arg_end_month = nx_int(arg[7])
  local arg_end_day = nx_int(arg[8])
  local arg_end_hour = nx_int(arg[9])
  local arg_end_min = nx_int(arg[10])
  local arg_consume_count = nx_int64(arg[18])
  local arg_iteminfo_start = 19
  form.lbl_7.Text = util_format_string("ui_online_dboconsume_text_02", arg_start_year, arg_start_month, arg_start_day, get_format_time(arg_start_hour), get_format_time(arg_start_min), arg_end_year, arg_end_month, arg_end_day, get_format_time(arg_end_hour), get_format_time(arg_end_min))
  form.mltbox_consume_count.HtmlText = get_capital_string(arg_consume_count)
  local rbtn = nx_null()
  local rbtn_index = 1
  local select_rbtn = 0
  local rbtn_max_count = 0
  for i = arg_iteminfo_start, arg_count, 3 do
    if arg[i] == nil or arg[i + 1] == nil or arg[i + 2] == nil then
      break
    end
    local rbtn = nx_custom(form, "rbtn_" .. nx_string(rbtn_index))
    if not nx_is_valid(rbtn) then
      break
    end
    rbtn.silvercard_need = nx_int(arg[i])
    rbtn_max_count = rbtn_max_count + 1
    rbtn.item_info = nx_string(arg[i + 2])
    local flag, b_flag = 1, false
    local hint_text = "tips_online_dboconsume_01"
    if nx_int(arg[i + 1]) >= nx_int(0) then
      flag = 3
      hint_text = "tips_online_dboconsume_02"
      select_rbtn = rbtn_index
    elseif arg_consume_count >= nx_int64(arg[i] * 1000) then
      flag = 2
      b_flag = true
    end
    rbtn.FocusImage, rbtn.CheckedImage, rbtn.NormalImage = get_rbtn_pic_path(rbtn_index, flag)
    rbtn.b_flag = b_flag
    rbtn.HintText = util_text(hint_text)
    rbtn_index = rbtn_index + 1
  end
  rbtn = nx_custom(form, "rbtn_" .. nx_string(select_rbtn))
  if nx_is_valid(rbtn) then
    rbtn.Checked = true
  else
    form.rbtn_0.Checked = true
  end
  if nx_int(rbtn_max_count) >= nx_int(0) then
    refresh_rbtn_info(rbtn_max_count)
    refresh_progress(arg_consume_count, rbtn_max_count)
  end
  form.Visible = true
end
function create_item_gbox(rbtn)
  local form = nx_value(FORM_DBOCONSUME)
  if not nx_is_valid(form) or not nx_is_valid(form) then
    return
  end
  form.gbox_info:DeleteAll()
  if not nx_find_custom(rbtn, "item_info") or not nx_find_custom(rbtn, "item_info") then
    return
  end
  local item_info = nx_string(rbtn.item_info)
  local items_list = util_split_string(item_info, ";")
  local items_count = table.getn(items_list)
  if nx_int(items_count) < nx_int(1) then
    return
  end
  local gbox, imggrid, lbl_name, lbl_count
  for i = 1, items_count do
    if nx_string(items_list[i]) == "" then
      break
    end
    gbox = clone_control("GroupBox", "gbox_iteminfo_" .. nx_string(i), form.groupbox_template_item, form.gbox_info)
    if nx_is_valid(gbox) then
      gbox.Top = 0
      gbox.Left = nx_int(gbox.Width + 25) * nx_int(i - 1)
      gbox.Visible = true
      imggrid = clone_control("ImageGrid", "imagegrid_" .. nx_string(i), form.imagegrid_template_item, gbox)
      lbl_name = clone_control("Label", "lbl_itemname_" .. nx_string(i), form.lbl_template_itemname, gbox)
      lbl_count = clone_control("Label", "lbl_count_" .. nx_string(i), form.lbl_template_count, gbox)
      if nx_is_valid(imggrid) and nx_is_valid(lbl_name) and nx_is_valid(lbl_count) then
        load_item_info(imggrid, lbl_count, lbl_name, items_list[i])
      end
    end
  end
end
function load_item_info(imagegrid, lbl_count, lbl_name, iteminfo)
  if not (nx_is_valid(imagegrid) and nx_is_valid(lbl_count)) or not nx_is_valid(lbl_name) then
    return
  end
  local item_list = util_split_string(nx_string(iteminfo), ":")
  local items_count = table.getn(item_list)
  if nx_int(items_count) ~= nx_int(2) then
    return
  end
  local item_id = nx_string(item_list[1])
  local item_count = nx_int(item_list[2])
  if item_id == "" or item_count <= nx_int(0) then
    return
  end
  nx_bind_script(imagegrid, nx_current())
  nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_item_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_item_mouseout_grid")
  local photo = item_query_ArtPack_by_id(item_id, "Photo")
  imagegrid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
  imagegrid:CoverItem(0, true)
  lbl_count.Text = util_format_string("ui_online_dboconsume_text_01", item_count)
  lbl_name.Text = util_text(item_id)
end
function clone_control(ctrl_type, name, refer_ctrl, parent_ctrl)
  if not (nx_is_valid(refer_ctrl) and nx_is_valid(parent_ctrl)) or ctrl_type == "" or name == "" then
    return nx_null()
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local cloned_ctrl = gui:Create(ctrl_type)
  if not nx_is_valid(cloned_ctrl) then
    return nx_null()
  end
  local prop_list = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_list) do
    nx_set_property(cloned_ctrl, prop_list[i], nx_property(refer_ctrl, prop_list[i]))
  end
  cloned_ctrl.Left = refer_ctrl.Left
  cloned_ctrl.Top = refer_ctrl.Top
  nx_set_custom(parent_ctrl.ParentForm, name, cloned_ctrl)
  cloned_ctrl.Name = name
  parent_ctrl:Add(cloned_ctrl)
  return cloned_ctrl
end
function get_capital_string(consume_count)
  local consume_string = nx_widestr("")
  local capital = nx_number(consume_count)
  if capital == 0 then
    return nx_widestr(0) .. util_text("ui_wen")
  end
  local ding = math.floor(capital / 1000000)
  if 0 < ding then
    consume_string = consume_string .. nx_widestr(ding) .. util_text("ui_ding")
  end
  local liang = math.floor(capital % 1000000 / 1000)
  if 0 < liang then
    consume_string = consume_string .. nx_widestr(liang) .. util_text("ui_liang")
  end
  local wen = math.floor(capital % 1000)
  if 0 < wen then
    consume_string = consume_string .. nx_widestr(wen) .. util_text("ui_wen")
  end
  return consume_string
end
function refresh_progress(consume_count, rbtn_max_count)
  local form = nx_value(FORM_DBOCONSUME)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(rbtn_max_count) < nx_int(1) then
    return
  end
  local all = nx_number(consume_count)
  if all < 0 then
    return
  end
  local max_count = rbtn_max_count * 1000
  form.pbar_1.Minimum = 0
  form.pbar_1.Maximum = max_count
  local last_need = 0
  for i = 1, rbtn_max_count do
    local rbtn = nx_custom(form, "rbtn_" .. nx_string(i))
    if nx_is_valid(rbtn) and nx_find_custom(rbtn, "silvercard_need") then
      local need_count = nx_number(rbtn.silvercard_need) * 1000
      if all <= need_count and last_need < need_count then
        form.pbar_1.Value = (i - 1) * 1000 + (all - last_need) * 1000 / (need_count - last_need)
        return
      end
      if i == rbtn_max_count then
        form.pbar_1.Value = max_count
      end
      last_need = need_count
    end
  end
end
function refresh_rbtn_info(rbtn_max_count)
  local form = nx_value(FORM_DBOCONSUME)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(rbtn_max_count) < nx_int(1) then
    return
  end
  for i = 1, 6 do
    local rbtn = nx_custom(form, "rbtn_" .. nx_string(i))
    local lbl = nx_custom(form, "lbl_var" .. nx_string(i))
    if nx_is_valid(rbtn) and nx_is_valid(lbl) then
      if not nx_find_custom(rbtn, "silvercard_need") then
        rbtn.Visible = false
        lbl.Visible = false
      else
        rbtn.Visible = true
        lbl.Visible = true
        rbtn.Left = form.pbar_1.Left + (i * (form.pbar_1.Width / rbtn_max_count) - rbtn.Width / 2 - 10)
        lbl.Left = rbtn.Left - 10
        local capital_count = nx_int(rbtn.silvercard_need) * 1000
        lbl.Text = get_capital_string(capital_count)
      end
    end
  end
end
function get_rbtn_pic_path(rbtn_index, flag)
  local pic_path = "gui\\special\\dboconsume\\baoxiang_" .. nx_string(rbtn_index) .. "_"
  local on_pic = "on.png"
  local down_pic = "down.png"
  local out_pic = "out.png"
  if flag == 1 then
    return pic_path .. on_pic, pic_path .. "full_" .. down_pic, pic_path .. out_pic
  elseif flag == 2 then
    return pic_path .. "full_" .. on_pic, pic_path .. "full_" .. down_pic, pic_path .. "full_" .. out_pic
  elseif flag == 3 then
    return pic_path .. "kq_" .. on_pic, pic_path .. "kq_" .. down_pic, pic_path .. "kq_" .. out_pic
  end
end
function get_format_time(number)
  local num = nx_int(number)
  if num < nx_int(10) then
    return "0" .. nx_string(num)
  else
    return nx_string(num)
  end
end
