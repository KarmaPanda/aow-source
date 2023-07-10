require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_test\\form_trigger_show"
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.textgrid_con:ClearRow()
  form.textgrid_con:ClearSelect()
  set_rank_title(form)
  form.lbl_6.Text = nx_widestr(form.tbar_range.Value)
  on_rbtn_1_click(form.rbtn_1, 0)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(form)
  form.Fixed = false
  form.cur_flag = 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
end
function on_main_form_close(form)
  send_show_debug(0, 50, false)
  nx_destroy(form)
end
function on_btn_close_click(btn, mouse_type)
  if mouse_type ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_tbar_arph_value_changed(tbar, old_value)
  local form = tbar.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local new_blend_color = nx_string(tbar.Value) .. ",255,255,255"
  form.BlendColor = new_blend_color
  form.groupbox_con.BlendColor = new_blend_color
end
function on_tbar_range_value_changed(tbar, old_value)
  local form = tbar.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.lbl_6.Text = nx_widestr(tbar.Value)
end
function on_tbar_range_drag_leave(tbar)
  local form = tbar.ParentForm
  if not nx_is_valid(form) then
    return
  end
  send_range_debug(tbar.Value)
end
function on_btn_refresh_click(btn, mouse_type)
  if mouse_type ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  send_refresh_debug()
end
function on_cbtn_auto_checked_changed(cbtn)
  send_auto_debug(cbtn.Checked)
end
function on_rbtn_1_click(rbtn, mouse_type)
  if mouse_type ~= 0 then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_1.Checked = true
  form.rbtn_2.Checked = false
  form.rbtn_3.Checked = false
  form.rbtn_4.Checked = false
  form.rbtn_5.Checked = false
  form.cur_flag = 1
  send_show_debug(form.cur_flag, form.tbar_range.Value, form.cbtn_auto.Checked)
end
function on_rbtn_2_click(rbtn, mouse_type)
  if mouse_type ~= 0 then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_1.Checked = false
  form.rbtn_2.Checked = true
  form.rbtn_3.Checked = false
  form.rbtn_4.Checked = false
  form.rbtn_5.Checked = false
  form.cur_flag = 2
  send_show_debug(form.cur_flag, form.tbar_range.Value, form.cbtn_auto.Checked)
end
function on_rbtn_3_click(rbtn, mouse_type)
  if mouse_type ~= 0 then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_1.Checked = false
  form.rbtn_2.Checked = false
  form.rbtn_3.Checked = true
  form.rbtn_4.Checked = false
  form.rbtn_5.Checked = false
  form.cur_flag = 3
  send_show_debug(form.cur_flag, form.tbar_range.Value, form.cbtn_auto.Checked)
end
function on_rbtn_4_click(rbtn, mouse_type)
  if mouse_type ~= 0 then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_1.Checked = false
  form.rbtn_2.Checked = false
  form.rbtn_3.Checked = false
  form.rbtn_4.Checked = true
  form.rbtn_5.Checked = false
  form.cur_flag = 4
  send_show_debug(form.cur_flag, form.tbar_range.Value, form.cbtn_auto.Checked)
end
function on_rbtn_5_click(rbtn, mouse_type)
  if mouse_type ~= 0 then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_1.Checked = false
  form.rbtn_2.Checked = false
  form.rbtn_3.Checked = false
  form.rbtn_4.Checked = false
  form.rbtn_5.Checked = true
  form.cur_flag = 5
  send_show_debug(form.cur_flag, form.tbar_range.Value, form.cbtn_auto.Checked)
end
function on_textgrid_con_select_row(textgrid, row)
  return
end
function on_btn_select_click(btn, mouse_type)
  if mouse_type ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if 0 > form.textgrid_con.RowSelectIndex then
    return
  end
  local ident = form.textgrid_con:GetGridTag(form.textgrid_con.RowSelectIndex, 0)
  send_select_debug(ident)
end
function on_btn_gmtarget_click(btn, mouse_type)
  if mouse_type ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if 0 > form.textgrid_con.RowSelectIndex then
    return
  end
  local ident = form.textgrid_con:GetGridTag(form.textgrid_con.RowSelectIndex, 0)
  send_gmtarget_debug(ident)
end
function server_msg_handle(...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_msg = arg[1]
  if nx_number(0) == nx_number(sub_msg) then
    local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
    if not nx_is_valid(form) then
      send_show_debug(0, 50, false)
      return
    end
    if table.getn(arg) < 7 then
      return
    end
    local cur_flag = arg[2]
    if nx_int(form.cur_flag) ~= nx_int(cur_flag) then
      return
    end
    local player_info = nx_widestr(arg[3])
    local npc_info = nx_widestr(arg[4])
    local scene_info = nx_widestr(arg[5])
    local buff_info = nx_widestr(arg[6])
    local ident_info = nx_string(arg[7])
    update_grid_con(form, player_info, npc_info, scene_info, buff_info, ident_info)
  elseif nx_number(1) == nx_number(sub_msg) then
    local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
    if not nx_is_valid(form) then
      open_form()
    end
  end
end
function send_show_debug(cur_flag, range, checked)
  local auto = 0
  if checked then
    auto = 1
  end
  local gm_info = nx_widestr("show_trigger_debug ") .. nx_widestr(cur_flag) .. nx_widestr(" ") .. nx_widestr(range) .. nx_widestr(" ") .. nx_widestr(auto)
  nx_execute("custom_sender", "custom_gminfo", gm_info)
end
function send_refresh_debug()
  local gm_info = nx_widestr("refresh_trigger_debug")
  nx_execute("custom_sender", "custom_gminfo", gm_info)
end
function send_auto_debug(checked)
  local auto = 0
  if checked then
    auto = 1
  end
  local gm_info = nx_widestr("auto_trigger_debug ") .. nx_widestr(auto)
  nx_execute("custom_sender", "custom_gminfo", gm_info)
end
function send_range_debug(range)
  local gm_info = nx_widestr("range_trigger_debug ") .. nx_widestr(range)
  nx_execute("custom_sender", "custom_gminfo", gm_info)
end
function send_gmtarget_debug(target)
  local gm_info = nx_widestr("gmtarget_trigger_debug ") .. nx_widestr(target)
  nx_execute("custom_sender", "custom_gminfo", gm_info)
end
function send_select_debug(target)
  local gm_info = nx_widestr("select_trigger_debug ") .. nx_widestr(target)
  nx_execute("custom_sender", "custom_gminfo", gm_info)
end
function set_rank_title(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.textgrid_con:SetColTitle(0, nx_widestr("\212\216\204\229\182\212\207\243"))
  form.textgrid_con:SetColTitle(1, nx_widestr("\180\165\183\162\202\194\188\254"))
  form.textgrid_con:SetColTitle(2, nx_widestr("\208\208\206\170\188\175\206\196\188\254\195\251"))
end
function update_grid_con(form, player_info, npc_info, scene_info, buff_info, ident_info)
  form.textgrid_con:ClearRow()
  form.textgrid_con:ClearSelect()
  local ident_tab = {}
  ident_tab = util_split_string(nx_string(ident_info), "|")
  local cur_index = 1
  if (nx_int(form.cur_flag) == nx_int(1) or nx_int(form.cur_flag) == nx_int(2)) and nx_widestr(player_info) ~= nx_widestr("") then
    local p_all_tab = {}
    p_all_tab = util_split_wstring(nx_widestr(player_info), "|")
    for i = 1, table.getn(p_all_tab) - 1 do
      local b_first = true
      local p_tab = {}
      p_tab = util_split_wstring(nx_widestr(p_all_tab[i]), ";")
      for m = 1, table.getn(p_tab) - 1 do
        local t_info_tab = {}
        t_info_tab = util_split_wstring(nx_widestr(p_tab[m]), ",")
        if table.getn(t_info_tab) >= 3 then
          local row = form.textgrid_con:InsertRow(-1)
          if b_first then
            b_first = false
            form.textgrid_con:SetGridText(row, 0, nx_widestr(t_info_tab[1]))
          else
            form.textgrid_con:SetGridText(row, 0, nx_widestr(""))
          end
          form.textgrid_con:SetGridText(row, 1, nx_widestr(util_text(nx_string(t_info_tab[2]))))
          form.textgrid_con:SetGridText(row, 2, nx_widestr(t_info_tab[3]))
          form.textgrid_con:SetGridTag(row, 0, nx_object(ident_tab[cur_index]))
        end
      end
      cur_index = cur_index + 1
    end
  end
  if (nx_int(form.cur_flag) == nx_int(1) or nx_int(form.cur_flag) == nx_int(3)) and nx_widestr(npc_info) ~= nx_widestr("") then
    local p_all_tab = {}
    p_all_tab = util_split_wstring(nx_widestr(npc_info), "|")
    for i = 1, table.getn(p_all_tab) - 1 do
      local b_first = true
      local p_tab = {}
      p_tab = util_split_wstring(nx_widestr(p_all_tab[i]), ";")
      for m = 1, table.getn(p_tab) - 1 do
        local t_info_tab = {}
        t_info_tab = util_split_wstring(nx_widestr(p_tab[m]), ",")
        if table.getn(t_info_tab) >= 3 then
          local row = form.textgrid_con:InsertRow(-1)
          if b_first then
            b_first = false
            if nx_string(t_info_tab[1]) == nx_string("") then
              form.textgrid_con:SetGridText(row, 0, nx_widestr("\191\213ID"))
            else
              form.textgrid_con:SetGridText(row, 0, nx_widestr(util_text(nx_string(t_info_tab[1]))))
            end
          else
            form.textgrid_con:SetGridText(row, 0, nx_widestr(""))
          end
          form.textgrid_con:SetGridText(row, 1, nx_widestr(util_text(nx_string(t_info_tab[2]))))
          form.textgrid_con:SetGridText(row, 2, nx_widestr(t_info_tab[3]))
          form.textgrid_con:SetGridTag(row, 0, nx_object(ident_tab[cur_index]))
        end
      end
      cur_index = cur_index + 1
    end
  end
  if (nx_int(form.cur_flag) == nx_int(1) or nx_int(form.cur_flag) == nx_int(4)) and nx_widestr(scene_info) ~= nx_widestr("") then
    local p_all_tab = {}
    p_all_tab = util_split_wstring(nx_widestr(scene_info), "|")
    for i = 1, table.getn(p_all_tab) - 1 do
      local b_first = true
      local p_tab = {}
      p_tab = util_split_wstring(nx_widestr(p_all_tab[i]), ";")
      for m = 1, table.getn(p_tab) - 1 do
        local t_info_tab = {}
        t_info_tab = util_split_wstring(nx_widestr(p_tab[m]), ",")
        if table.getn(t_info_tab) >= 3 then
          local row = form.textgrid_con:InsertRow(-1)
          if b_first then
            b_first = false
            form.textgrid_con:SetGridText(row, 0, nx_widestr(t_info_tab[1]))
          else
            form.textgrid_con:SetGridText(row, 0, nx_widestr(""))
          end
          form.textgrid_con:SetGridText(row, 1, nx_widestr(util_text(nx_string(t_info_tab[2]))))
          form.textgrid_con:SetGridText(row, 2, nx_widestr(t_info_tab[3]))
          form.textgrid_con:SetGridTag(row, 0, nx_object(ident_tab[cur_index]))
        end
      end
      cur_index = cur_index + 1
    end
  end
  if (nx_int(form.cur_flag) == nx_int(1) or nx_int(form.cur_flag) == nx_int(5)) and nx_widestr(buff_info) ~= nx_widestr("") then
    local p_all_tab = {}
    p_all_tab = util_split_wstring(nx_widestr(buff_info), "|")
    for i = 1, table.getn(p_all_tab) - 1 do
      local b_first = true
      local p_tab = {}
      p_tab = util_split_wstring(nx_widestr(p_all_tab[i]), ";")
      for m = 1, table.getn(p_tab) - 1 do
        local t_info_tab = {}
        t_info_tab = util_split_wstring(nx_widestr(p_tab[m]), ",")
        if table.getn(t_info_tab) >= 5 then
          local row = form.textgrid_con:InsertRow(-1)
          if b_first then
            b_first = false
            local self_name = nx_widestr("")
            if nx_widestr(t_info_tab[1]) ~= nx_widestr("") then
              self_name = self_name .. nx_widestr(t_info_tab[1])
            elseif nx_string(t_info_tab[2]) == nx_string("") then
              self_name = self_name .. nx_widestr("\191\213ID")
            else
              self_name = self_name .. nx_widestr(util_text(nx_string(t_info_tab[2])))
            end
            if nx_string(t_info_tab[3]) == nx_string("") then
              self_name = self_name .. nx_widestr(":\191\213ID")
            else
              self_name = self_name .. nx_widestr(":") .. nx_widestr(util_text(nx_string(t_info_tab[3])))
            end
            form.textgrid_con:SetGridText(row, 0, self_name)
          else
            form.textgrid_con:SetGridText(row, 0, nx_widestr(""))
          end
          form.textgrid_con:SetGridText(row, 1, nx_widestr(util_text(nx_string(t_info_tab[4]))))
          form.textgrid_con:SetGridText(row, 2, nx_widestr(t_info_tab[5]))
          form.textgrid_con:SetGridTag(row, 0, nx_object(ident_tab[cur_index]))
        end
      end
      cur_index = cur_index + 1
    end
  end
end
