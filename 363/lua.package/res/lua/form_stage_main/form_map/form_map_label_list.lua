require("util_functions")
require("define\\gamehand_type")
require("util_vip")
local label_control_name_table = {
  [0] = {},
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {},
  [7] = {}
}
local label_max = 7
local label_selected_backimage = "gui\\special\\mail\\bg_trade_open.png"
local label_normal_backimage = "gui\\special\\mail\\bg_trade_read.png"
local label_on_backimage = "gui\\special\\mail\\bg_trade_unread.png"
local label_selected_backcolor = "255,207,184,160"
local label_normal_backcolor = "0,255,255,255"
local label_on_backcolor = "255,207,184,169"
local label_forecolor_1 = "255,128,101,74"
local label_forecolor_2 = "255,197,184,159"
function main_form_init(self)
  self.Fixed = false
  self.cur_page_user = 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_MapLabel_tips1")
  self.mltbox_info:Clear()
  self.mltbox_info:AddHtmlText(nx_widestr(text), -1)
  init_label_control_name()
  fresh_page(self)
  update_label_groupbox(self)
end
function on_main_form_close(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.GameHand:ClearHand()
  end
  local form = self.ParentForm
  form.btn_label.Checked = false
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form.Visible = false
  form.btn_label.Checked = false
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.GameHand:ClearHand()
  end
  form:Close()
end
function on_btn_add_click(self)
end
function init_label_control_name()
  local num = table.getn(label_control_name_table)
  for i = 1, label_max do
    label_control_name_table[i][1] = nx_string("GroupBox") .. nx_string(i - 1)
    label_control_name_table[i][2] = nx_string("template") .. nx_string(i - 1)
    label_control_name_table[i][3] = nx_string("name") .. nx_string(i - 1)
    label_control_name_table[i][4] = nx_string("content") .. nx_string(i - 1)
    label_control_name_table[i][5] = nx_string("picture") .. nx_string(i - 1)
    label_control_name_table[i][6] = nx_string("select") .. nx_string(i - 1)
  end
end
function reset_label_control_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.cbtn_allselect.Checked = false
  for row = 1, label_max do
    local groupboxname = label_control_name_table[row][1]
    local groupboxobj = form:Find(nx_string(groupboxname))
    if nx_is_valid(groupboxobj) then
      groupboxobj.BackImage = ""
      groupboxobj.BackColor = label_normal_backcolor
      groupboxobj.Visible = false
      local select = groupboxobj:Find(nx_string(label_control_name_table[row][6]))
      select.Checked = false
    end
  end
end
function on_btn_label_checked_changed(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local text = ""
  if self.Checked then
    text = gui.TextManager:GetText("ui_MapLabel_tips2")
  else
    text = gui.TextManager:GetText("ui_MapLabel_tips1")
  end
  form.mltbox_info:Clear()
  form.mltbox_info:AddHtmlText(nx_widestr(text), -1)
  if self.Checked then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui.GameHand:SetHand(GHT_FUNC, "add", "", "", "", "")
    end
  else
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui.GameHand:ClearHand()
    end
  end
end
function update_label_groupbox(self)
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  reset_label_control_info(self)
  local gui = nx_value("gui")
  local ini = form_map.label_ini
  if not nx_is_valid(ini) then
    return
  end
  local sect = "MapLabel"
  local keys = ini:GetItemList(sect)
  local swapIndex = 1
  local swapValue = ""
  for i = 1, table.getn(keys) do
    local key = keys[i]
    if key ~= nil then
      local value = ini:ReadString(sect, key, "")
      local tuple = util_split_string(value, ",")
      if table.getn(tuple) > 0 then
        local secne_id = nx_string(tuple[1])
        if secne_id == nx_string(form_map.current_map) then
          swapValue = keys[swapIndex]
          keys[swapIndex] = keys[i]
          keys[i] = swapValue
          swapIndex = swapIndex + 1
        end
      end
    end
  end
  local cur_page = self.cur_page_user
  local showrownum = table.getn(keys)
  local max_page = math.ceil(showrownum / label_max)
  local start_index = (cur_page - 1) * label_max + 1
  local end_index = cur_page * label_max
  if showrownum > end_index then
    end_index = start_index + label_max - 1
  else
    end_index = showrownum
  end
  local index = 1
  for i = start_index, end_index do
    local key = keys[i]
    if key ~= nil then
      local value = ini:ReadString(sect, key, "")
      local tuple = util_split_string(value, ",")
      if table.getn(tuple) > 0 then
        local secne_id = nx_string(tuple[1])
        local npc_id = nx_string(tuple[2])
        local x = nx_number(tuple[3])
        local y = nx_number(tuple[4])
        local z = nx_number(tuple[5])
        local npc_type = nx_number(tuple[6])
        local groupboxname = label_control_name_table[index][1]
        local groupboxobj = self:Find(nx_string(groupboxname))
        if nx_is_valid(groupboxobj) then
          groupboxobj.Visible = true
          groupboxobj.pox_x = x
          groupboxobj.pox_y = y
          groupboxobj.pox_z = z
          groupboxobj.npc_id = npc_id
          groupboxobj.npc_key = key
          groupboxobj.secne_id = secne_id
          groupboxobj.npc_type = npc_type
          local lbl_name = groupboxobj:Find(nx_string(label_control_name_table[index][3]))
          local lbl_content = groupboxobj:Find(nx_string(label_control_name_table[index][4]))
          local lbl_picture = groupboxobj:Find(nx_string(label_control_name_table[index][5]))
          local show_npc_id = nx_widestr(npc_id)
          if 6 < nx_ws_length(show_npc_id) then
            show_npc_id = nx_function("ext_ws_substr", show_npc_id, 0, 6)
          end
          lbl_name.Text = nx_widestr(show_npc_id)
          lbl_content.Text = nx_widestr("")
          local scene_name = gui.TextManager:GetText("scene_" .. secne_id)
          local text = nx_widestr("") .. scene_name .. nx_widestr("   (") .. nx_widestr(nx_int(x)) .. nx_widestr(",") .. nx_widestr(nx_int(z)) .. nx_widestr(")")
          lbl_content.Text = nx_widestr(text)
          if npc_type == 1996 then
            lbl_picture.BackImage = "gui\\map\\npcicon\\label_1.png"
          elseif npc_type == 1997 then
            lbl_picture.BackImage = "gui\\map\\npcicon\\label_2.png"
          elseif npc_type == 1998 then
            lbl_picture.BackImage = "gui\\map\\npcicon\\label_3.png"
          elseif npc_type == 1999 then
            lbl_picture.BackImage = "gui\\map\\npcicon\\label_4.png"
          end
          if secne_id == form_map.current_map then
            lbl_content.ForeColor = label_forecolor_1
            lbl_name.ForeColor = label_forecolor_1
          else
            lbl_content.ForeColor = label_forecolor_2
            lbl_name.ForeColor = label_forecolor_2
          end
        end
        index = index + 1
      end
    end
  end
end
function add_map_label(key)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "show_npc_by_type", "1996", true)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "show_npc_by_type", "1997", true)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "show_npc_by_type", "1998", true)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "show_npc_by_type", "1999", true)
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local form = nx_value("form_stage_main\\form_map\\form_map_label_list")
  if not nx_is_valid(form) then
    return
  end
  fresh_page(form)
  update_label_groupbox(form)
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  form.cur_page_user = form.cur_page_user - 1
  fresh_page(form)
  update_label_groupbox(form)
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  form.cur_page_user = form.cur_page_user + 1
  fresh_page(form)
  update_label_groupbox(form)
end
function fresh_page(form)
  if not nx_is_valid(form) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local gui = nx_value("gui")
  local ini = form_map.label_ini
  local sect = "MapLabel"
  local keys = ini:GetItemList(sect)
  local rownum = table.getn(keys)
  local max_page = math.ceil(rownum / label_max)
  if form.cur_page_user < 1 then
    form.cur_page_user = 1
  end
  if max_page < form.cur_page_user then
    form.cur_page_user = max_page
  end
  local cur_page = form.cur_page_user
  if rownum <= 0 then
    form.btn_left.Enabled = false
    form.btn_right.Enabled = false
    form.lbl_page.Text = nx_widestr(1) .. nx_widestr("/") .. nx_widestr(1)
    return
  end
  form.btn_left.Enabled = 1 < cur_page
  form.btn_right.Enabled = max_page > cur_page
  form.lbl_page.Text = nx_widestr(cur_page) .. nx_widestr("/") .. nx_widestr(max_page)
end
function get_on_mouse(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  if not nx_find_custom(self.Parent, "secne_id") then
    return
  end
  if form_map.current_map ~= self.Parent.secne_id then
    return
  end
  if self.Parent.BackColor == label_selected_backcolor then
    return
  end
  self.Parent.BackColor = label_on_backcolor
end
function lost_on_mouse(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if self.Parent.BackColor == label_selected_backcolor then
    return
  end
  self.Parent.BackColor = label_normal_backcolor
end
function reset_select_state(form)
  if not nx_is_valid(form) then
    return
  end
  for row = 1, label_max do
    local groupboxname = label_control_name_table[row][1]
    local groupboxobj = form:Find(nx_string(groupboxname))
    if nx_is_valid(groupboxobj) then
      groupboxobj.BackColor = label_normal_backcolor
    end
  end
end
function select_on_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  if not nx_find_custom(self.Parent, "secne_id") then
    return
  end
  if form_map.current_map ~= self.Parent.secne_id then
    return
  end
  reset_select_state(form)
  self.Parent.BackColor = label_selected_backcolor
  if not nx_find_custom(self.Parent, "npc_id") then
    return
  end
  local pos_x = self.Parent.pox_x
  local pos_z = self.Parent.pox_z
  local role = nx_value("role")
  if nx_is_valid(role) and nx_find_custom(role, "find_path_limit") and role.find_path_limit == true then
    return
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local cur_scene_id = client_scene:QueryProp("Resource")
  local player = game_client:GetPlayer()
  local is_vip = nx_execute("util_vip", "is_vip", player, VT_NORMAL)
  if not is_vip then
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  if cur_scene_id == form_map.current_map then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "set_trace_npc_id", "", pos_x, -10000, pos_z, cur_scene_id)
    if trace_flag == 1 or trace_flag == 2 then
      path_finding:FindPath(pos_x, -10000, pos_z, 0)
    end
  else
    nx_execute("form_stage_main\\form_map\\form_map_scene", "set_trace_npc_id", "", pos_x, -10000, pos_z, form_map.current_map)
    if trace_flag == 1 or trace_flag == 2 then
      path_finding:FindPathScene(form_map.current_map, pos_x, -10000, pos_z, 0)
    end
  end
end
function on_btn_del_click(btn)
  local form = nx_value("form_stage_main\\form_map\\form_map_label_list")
  if not nx_is_valid(form) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local ini = form_map.label_ini
  for row = 1, label_max do
    local groupboxname = label_control_name_table[row][1]
    local groupboxobj = form:Find(nx_string(groupboxname))
    if nx_is_valid(groupboxobj) and groupboxobj.Visible then
      local select = groupboxobj:Find(nx_string(label_control_name_table[row][6]))
      if select.Checked then
        local npc_key = groupboxobj.npc_key
        ini:DeleteItem("MapLabel", nx_string(npc_key))
        form_map.groupmap_objs:RemoveElement(nx_string(npc_key))
      end
    end
  end
  ini:SaveToFile()
  fresh_page(form)
  update_label_groupbox(form)
end
function on_cbtn_allselect_click(cbtn)
  local form = nx_value("form_stage_main\\form_map\\form_map_label_list")
  if not nx_is_valid(form) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local ini = form_map.label_ini
  local checkstate = cbtn.Checked
  for row = 1, label_max do
    local groupboxname = label_control_name_table[row][1]
    local groupboxobj = form:Find(nx_string(groupboxname))
    if nx_is_valid(groupboxobj) and groupboxobj.Visible then
      local select = groupboxobj:Find(nx_string(label_control_name_table[row][6]))
      select.Checked = checkstate
    end
  end
end
function on_btn_copy_click(btn)
  local form = nx_value("form_stage_main\\form_map\\form_map_label_list")
  if not nx_is_valid(form) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local htmltext = nx_widestr("")
  for row = 1, label_max do
    local groupboxname = label_control_name_table[row][1]
    local groupboxobj = form:Find(nx_string(groupboxname))
    if nx_is_valid(groupboxobj) and groupboxobj.Visible then
      local select = groupboxobj:Find(nx_string(label_control_name_table[row][6]))
      if select.Checked then
        local game_client = nx_value("game_client")
        local palyer = game_client:GetPlayer()
        local role_name = palyer:QueryProp("Name")
        local scene_name = gui.TextManager:GetText("scene_" .. nx_string(groupboxobj.secne_id))
        local sign_name = gui.TextManager:GetText("ui_MapLabel")
        local show_npc_id = nx_widestr(groupboxobj.npc_id)
        if 6 < nx_ws_length(show_npc_id) then
          show_npc_id = nx_function("ext_ws_substr", show_npc_id, 0, 6)
        end
        local sign_data = nx_widestr(show_npc_id) .. nx_widestr(",") .. nx_widestr(groupboxobj.secne_id) .. nx_widestr(",") .. nx_widestr(nx_int(groupboxobj.pox_x)) .. nx_widestr(",") .. nx_widestr(nx_int(groupboxobj.pox_z)) .. nx_widestr(",") .. nx_widestr(groupboxobj.npc_type)
        local text = nx_widestr("<a href=\"label,") .. sign_data .. nx_widestr("\" style=\"HLChatItem\"><") .. sign_name .. nx_widestr("></a>")
        htmltext = htmltext .. text
      end
    end
  end
  local form_chat_window = nx_value("form_stage_main\\form_chat_system\\form_chat_window")
  if nx_is_valid(form_chat_window) then
    nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "add_hyperlink", nx_widestr(htmltext))
  else
    local form_main_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
    if nx_is_valid(form_main_chat) then
      nx_execute("form_stage_main\\form_main\\form_main_chat", "add_item_to_chatedit", nx_widestr(htmltext))
    end
  end
end
function on_select_click(cbtn)
  local form = nx_value("form_stage_main\\form_map\\form_map_label_list")
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_allselect.Checked then
    form.cbtn_allselect.Checked = false
  end
end
