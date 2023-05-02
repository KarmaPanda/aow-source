require("util_functions")
require("share\\client_custom_define")
require("util_gui")
require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("share\\view_define")
require("util_static_data")
require("define\\sysinfo_define")
local NOT_SPENT_ITEM = 0
local SPENT_ITEM = 1
function on_main_form_init(form)
  form.Fixed = false
  form.cur_gbox_count = 0
  form.cut_level = 0
  form.free_appoint = 0
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_choice_boss_info(level, nguan_id, free_appoint)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = util_get_form(FORM_TIGUAN_CHOICE_BOSS, true)
  if not nx_is_valid(form) then
    return 0
  end
  form.cut_level = nx_number(level)
  form.free_appoint = free_appoint
  if 0 < free_appoint then
    form.cbtn_spent_item.Visible = true
    form.mltbox_shuoming.Visible = true
  else
    form.cbtn_spent_item.Visible = false
    form.mltbox_shuoming.Visible = false
  end
  form.groupscrollbox_1:DeleteAll()
  local boss_list = get_boss_id_list(nx_string(nguan_id))
  if boss_list ~= nil then
    local boss_count = table.getn(boss_list)
    form.cur_gbox_count = boss_count
    for i = 1, boss_count do
      local groupbox = create_ctrl("GroupBox", "gbox_choice_boss_" .. nx_string(i), form.groupbox_template, form.groupscrollbox_1)
      local cbtn_select = create_ctrl("CheckButton", "cbtn_choice_boss_select_" .. nx_string(i), form.cbtn_tmp_select, groupbox)
      local lbl_name = create_ctrl("Label", "lbl_choice_boss_name_" .. nx_string(i), form.lbl_tmp_name, groupbox)
      cbtn_select.sort_id = i
      nx_bind_script(cbtn_select, nx_current())
      nx_callback(cbtn_select, "on_click", "on_cbtn_select_click")
      local boss_id = nx_string(boss_list[i])
      lbl_name.Text = gui.TextManager:GetText(boss_id)
    end
    if 0 < boss_count then
      local h = form.groupbox_template.Height
      form.groupscrollbox_1.Height = h * nx_number(boss_count)
      form.lbl_2.Top = 40 + h * nx_number(boss_count)
      form.btn_select.Top = 55 + h * nx_number(boss_count)
      form.mltbox_shuoming.Top = 90 + h * nx_number(boss_count)
      form.cbtn_spent_item.Top = 90 + h * nx_number(boss_count)
      if 0 < free_appoint then
        form.Height = 120 + h * nx_number(boss_count)
      else
        form.Height = 100 + h * nx_number(boss_count)
      end
    end
  end
  form.groupscrollbox_1:ResetChildrenYPos()
end
function on_cbtn_select_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  for i = 1, form.cur_gbox_count do
    local gbox = form.groupscrollbox_1:Find("gbox_choice_boss_" .. nx_string(i))
    if nx_is_valid(gbox) then
      local cbtn_select = gbox:Find("cbtn_choice_boss_select_" .. nx_string(i))
      if nx_is_valid(cbtn_select) and cbtn.sort_id ~= cbtn_select.sort_id then
        cbtn_select.Checked = false
      end
    end
  end
end
function on_btn_select_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local select_boss_item_id = get_item_id_for_choice_boss(form.cut_level)
  local item_count = goods_grid:GetItemCount(select_boss_item_id)
  if item_count <= 0 and 0 >= form.free_appoint then
    local item_name = gui.TextManager:GetText(select_boss_item_id)
    gui.TextManager:Format_SetIDName("ui_resethint2")
    gui.TextManager:Format_AddParam(nx_string(item_name))
    local text = gui.TextManager:Format_GetText()
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, CENTERINFO_PERSONAL_NO)
      return
    end
  end
  local boss_index = -1
  for i = 1, form.cur_gbox_count do
    local gbox = form.groupscrollbox_1:Find("gbox_choice_boss_" .. nx_string(i))
    if nx_is_valid(gbox) then
      local cbtn_select = gbox:Find("cbtn_choice_boss_select_" .. nx_string(i))
      if nx_is_valid(cbtn_select) and cbtn_select.Checked then
        boss_index = cbtn_select.sort_id
      end
    end
  end
  if boss_index == -1 then
    local text = get_desc_by_id("ui_danxuanzhe_2")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, CENTERINFO_PERSONAL_NO)
    end
  else
    if form.cbtn_spent_item.Checked then
      nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_APPOINT_BOSS, form.cut_level, boss_index, SPENT_ITEM)
    else
      nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_APPOINT_BOSS, form.cut_level, boss_index, NOT_SPENT_ITEM)
    end
    form:Close()
  end
end
function get_desc_by_id(text_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  return gui.TextManager:GetText(nx_string(text_id))
end
function get_boss_id_list(guan_id)
  local ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(ini) then
    return nil
  end
  local sec_index = ini:FindSectionIndex(nx_string(guan_id))
  local str_id = ini:ReadString(sec_index, "BossList", "")
  return util_split_string(str_id, ";")
end
