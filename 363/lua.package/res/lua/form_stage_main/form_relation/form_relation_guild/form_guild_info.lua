require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\form_relation_guild\\sub_command_define")
require("form_stage_main\\form_guildbuilding\\sub_command_define")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
require("util_functions")
local free_map_rec = {}
local map_with_domain_rec = {}
function main_form_init(self)
  self.Fixed = false
  self.check = false
  self.selectkengwei = ""
  self.selectmapid = nil
  self.selectdomainid = nil
  self.npc_info = nil
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.rbtn_guild_base_info.grid_page = self.groupbox_base_info
  self.rbtn_guild_domain_info.grid_page = self.groupbox_domain_info
  self.rbtn_guild_base_info.Checked = true
  self.rbtn_guild_domain_info.Checked = false
  self.rbtn_guild_base_info.grid_page.Visible = true
  self.groupbox_buildings.Visible = true
  self.groupbox_kengwei.Visible = false
  custom_request_domain_and_drawing_info()
  self.combobox_domain.OnlySelect = true
  self.combobox_domain.Text = nx_widestr(guild_util_get_text("ui_guild_domain_select"))
  self.combobox_drawings.OnlySelect = true
  self.combobox_drawings.Text = nx_widestr(guild_util_get_text("ui_guild_drawings_select"))
end
function on_main_form_close(self)
  if nx_find_custom(self, "npc_info") and nx_is_valid(self.npc_info) then
    nx_destroy(self.npc_info)
  end
  nx_destroy(self)
end
function on_rbtn_guild_checked_changed(r_btn)
  r_btn.grid_page.Visible = r_btn.Checked
end
function on_recv_basic_info(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_info")
  if not nx_is_valid(form) or table.getn(arg) ~= 14 then
    return
  end
  local html_text = nx_string("")
  html_text = html_text .. nx_string(guild_util_get_text("ui_guild_name"))
  html_text = html_text .. nx_string("\163\186") .. nx_string(arg[1])
  html_text = html_text .. "<br>"
  html_text = html_text .. nx_string(guild_util_get_text("ui_guild_level_no"))
  html_text = html_text .. nx_string("\163\186") .. nx_string(arg[2])
  html_text = html_text .. "<br>"
  html_text = html_text .. nx_string(guild_util_get_text("ui_guild_founder"))
  html_text = html_text .. nx_string("\163\186") .. nx_string(arg[4])
  html_text = html_text .. "<br>"
  html_text = html_text .. nx_string(guild_util_get_text("ui_guild_found_date"))
  html_text = html_text .. nx_string("\163\186") .. "<br>" .. nx_string(transform_date(arg[5]))
  html_text = html_text .. "<br>"
  local capital = nx_int64(arg[10])
  local ding = nx_int(capital / 10000)
  local liang = nx_int((capital - 10000 * ding) / 100)
  local wen = nx_int(capital - 10000 * ding - 100 * liang)
  local capital = guild_util_get_text("ui_guild_capital1", nx_int(ding), nx_int(liang), nx_int(wen))
  html_text = html_text .. nx_string(capital)
  html_text = html_text .. "<img src=\"gui\\common\\money\\liang.png\" valign=\"center\" only=\"line\" data=\"\" />" .. "<br>"
  html_text = html_text .. nx_string(guild_util_get_text("ui_guild_location"))
  html_text = html_text .. nx_string("\163\186") .. "<br>" .. nx_string(guild_util_get_text("ui_dipanmiaoshu_" .. nx_string(arg[12])))
  html_text = html_text .. "<br>"
  form.mltbox_base_info.HtmlText = nx_widestr(html_text)
  form.lbl_guild_intro.Text = nx_widestr(guild_util_get_text("ui_guild_purpose"))
  form.mltbox_guild_intro.HtmlText = nx_widestr(arg[7])
end
function on_pic_kengwei_left_down(self, x, y)
  nx_msgbox(nx_string(x) .. nx_string(",") .. nx_string(y))
end
function on_building_left_down(self, x, y)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_info", false)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_guild_base_info.Checked = false
  form.rbtn_guild_domain_info.Checked = true
  form.rbtn_guild_base_info.grid_page.Visible = false
  form.rbtn_guild_domain_info.grid_page.Visible = true
  local npc_info = form.npc_info
  if not nx_is_valid(npc_info) then
    return
  end
  local strKey = nx_string(self.Context)
  local node = npc_info:GetChild(strKey)
  if not nx_is_valid(node) then
    form.mltbox_domain_info.HtmlText = nx_widestr("undefine builidng " .. strKey)
    return
  end
  if node.level == 0 then
    local building_name = nx_widestr("<font color='#ff0000'>") .. guild_util_get_text("ui_guildbuilding_drawings_" .. strKey) .. nx_widestr(":</font>")
    form.mltbox_domain_info.HtmlText = building_name .. guild_util_get_text("ui_guildbuilding_drawings_not_activation")
    return
  end
  local html_text = get_html_text(node)
  form.mltbox_domain_info.HtmlText = nx_widestr(html_text)
  form.selectkengwei = strKey
end
function refresh_guild_info_kengwei(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_info", false)
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(arg)
  local npc_info = form.npc_info
  if not nx_is_valid(npc_info) then
    return false
  end
  local strKey = nx_string(arg[1])
  local node = npc_info:GetChild(strKey)
  if not nx_is_valid(node) then
    form.mltbox_domain_info.HtmlText = nx_widestr("undefine builidng " .. strKey)
    return false
  end
  local revert_num = nx_int(arg[2])
  local KengweiDetail = nx_string(guild_util_get_text("ui_guildbuilding_drawings_kengwei_detail"))
  KengweiDetail = KengweiDetail .. nx_string("<br>")
  KengweiDetail = KengweiDetail .. nx_string(guild_util_get_text("ui_guildbuilding_drawings_kengwei_building_level"))
  KengweiDetail = KengweiDetail .. nx_string(node.level)
  KengweiDetail = KengweiDetail .. "<br>"
  KengweiDetail = KengweiDetail .. nx_string(guild_util_get_text("ui_guildbuilding_drawings_kengwei_num")) .. "\163\186"
  KengweiDetail = KengweiDetail .. nx_string(node.kengwei)
  KengweiDetail = KengweiDetail .. "<br>"
  for i = 3, count do
    KengweiDetail = KengweiDetail .. nx_string(i)
    KengweiDetail = KengweiDetail .. nx_string(guild_util_get_text("ui_guildbuilding_drawings_kengwei_level"))
    KengweiDetail = KengweiDetail .. nx_string(arg[i])
    KengweiDetail = KengweiDetail .. nx_string(guild_util_get_text("ui_guildbuilding_drawings_kengwei_unit"))
    KengweiDetail = KengweiDetail .. "<br>"
  end
  form.mltbox_domain_info.HtmlText = nx_widestr(KengweiDetail)
end
function refresh_guild_info_juanzhou(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_info", false)
  if not nx_is_valid(form) then
    return
  end
end
function refresh_guild_info(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_info", false)
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(arg) / 5
  if count == 0 then
    form.mltbox_domain_info.HtmlText = nx_widestr(guild_util_get_text("ui_guildbuilding_drawings_no_domain"))
    return
  end
  local config_id_index = 1
  local level_index = 2
  local cur_level_index = 3
  local kengwei_index = 4
  local book_index = 5
  local config_id = ""
  local level = 0
  local cur_level = 0
  local kengwei = -1
  local book = -1
  for i = 1, count do
    config_id = arg[config_id_index]
    level = arg[level_index]
    cur_level = arg[cur_level_index]
    kengwei = arg[kengwei_index]
    book = arg[book_index]
    local str_lst = util_split_string(config_id, "_")
    if nx_int(str_lst[1]) ~= nx_int(1) then
      kengwei = -1
      book = -1
    end
    set_gulid_data(config_id, level, cur_level_index, kengwei, book)
    config_id_index = config_id_index + 5
    level_index = level_index + 5
    cur_level_index = cur_level_index + 5
    kengwei_index = kengwei_index + 5
    book_index = book_index + 5
  end
  refresh_guild_form(form)
end
function set_gulid_data(config_id, level, cur_level_index, kengwei, book)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_info")
  if not nx_is_valid(form) then
    return false
  end
  local node = get_npc_info(form, config_id)
  if not nx_is_valid(node) then
    return false
  end
  node.level = nx_int(level)
  node.cur_level = nx_int(cur_level_index)
  node.kengwei = nx_int(kengwei)
  node.book = nx_int(book)
  return true
end
function get_npc_info(form, config_id)
  local npc_info = nx_null()
  if nx_find_custom(form, "npc_info") and nx_is_valid(form.npc_info) then
    npc_info = form.npc_info
  else
    npc_info = nx_call("util_gui", "get_arraylist", "npc_info")
    form.npc_info = npc_info
  end
  if not nx_is_valid(npc_info) then
    return nil
  end
  local node = npc_info:GetChild(config_id)
  if not nx_is_valid(node) then
    npc_info:CreateChild(config_id)
  else
    return node
  end
  node = npc_info:GetChild(config_id)
  if nx_is_valid(node) then
    node.level = nx_int(0)
    node.cur_level = nx_int(-1)
    node.kengwei = nx_int(-1)
    node.book = nx_int(-1)
  end
  return node
end
function refresh_guild_form(form)
  local npc_info = form.npc_info
  if not nx_is_valid(npc_info) then
    return false
  end
  local child_list = npc_info:GetChildList()
  local html_text = ""
  for i, node in ipairs(child_list) do
    html_text = html_text .. get_html_text(node)
    html_text = html_text .. "<br>"
  end
  if html_text == "" then
    return false
  end
  form.mltbox_domain_info.HtmlText = nx_widestr(html_text)
  form.mltbox_domain_info.Visable = true
end
function get_html_text(node)
  if not nx_is_valid(node) then
    return nx_widestr("")
  end
  local gui = nx_value("gui")
  local html_text = nx_widestr(gui.TextManager:GetText("ui_guildbuilding_drawings_building_name")) .. nx_widestr("\163\186")
  local str = nx_widestr(guild_util_get_text("ui_guildbuilding_drawings_" .. node.Name))
  if str ~= nx_string("") then
    html_text = html_text .. str
  else
    html_text = html_text .. node.Name
  end
  html_text = html_text .. nx_widestr("<br>")
  html_text = html_text .. nx_widestr(gui.TextManager:GetText("ui_guildbuilding_drawings_building_level")) .. nx_widestr("\163\186")
  html_text = html_text .. nx_widestr(node.level)
  html_text = html_text .. nx_widestr("<br>")
  if node.kengwei ~= -1 then
    html_text = html_text .. nx_widestr(gui.TextManager:GetText("ui_guildbuilding_drawings_kengwei_num")) .. nx_widestr("\163\186")
    html_text = html_text .. nx_widestr(node.kengwei)
    html_text = html_text .. nx_widestr("<br>")
  end
  if node.book ~= -1 then
    html_text = html_text .. nx_widestr(gui.TextManager:GetText("ui_guildbuilding_drawings_book_num")) .. nx_widestr("\163\186")
    html_text = html_text .. nx_widestr(node.book)
    html_text = html_text .. nx_widestr("<br>")
  end
  return html_text
end
function on_btn_kengwei_info_click()
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_info", false)
  if not nx_is_valid(form) then
    return
  end
  if not form.check then
    form.groupbox_buildings.Visible = false
    form.groupbox_kengwei.Visible = true
    form.check = true
  else
    form.groupbox_buildings.Visible = true
    form.groupbox_kengwei.Visible = false
    form.check = false
  end
  custom_request_darwings_kengwei_info(form.selectmapid, form.selectkengwei)
end
function on_btn_binding_click(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = self.ParentForm
  local domain_id = form.selectdomainid
  local map_id = form.selectmapid
  if form.combobox_drawings.DropListBox.ItemCount == 0 then
    local text = nx_widestr(gui.TextManager:GetText("19418"))
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(text, 1, 0)
    end
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local is_captain = client_player:QueryProp("IsGuildCaptain")
  if is_captain ~= nx_int(2) then
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(util_text("19423"), 0, 0)
    end
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  text = nx_widestr(gui.TextManager:GetText("19294"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_BINDING_DOMAIN_AND_DRAWING), nx_int(domain_id), nx_int(map_id))
  end
end
function on_combobox_drawings_selected(combobox)
  local form = combobox.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local select_index = combobox.DropListBox.SelectIndex
  local id = combobox.DropListBox:GetString(select_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_ZHENFA_XUEXI), from.npc_id, nx_string(self.zhenfaid))
end
function draw_kengwei_map(cont)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local center_x = cont.Width / 2
  local center_z = cont.Height / 2
  local designer = gui.Designer
  nx_msgbox(nx_string(designer.DefaultPath))
  local gb_manager = nx_value("GuildbuildingManager")
  local kengwei = gb_manager:GetKengWeiInfo(2, 5, 2)
  if kengwei == nil then
    return
  end
  local x = 0
  local y = 0
  local id = 1
  local count = table.getn(kengwei) / 2
  for i = 1, count do
    x = kengwei[id]
    id = id + 1
    y = kengwei[id]
    id = id + 1
    local control = designer:Create("Picture")
    if control == nil then
      nx_msgbox(get_msg_str("msg_172"))
      return 0
    end
    control.Name = "Picture1"
    control.Text = nx_widestr("Picture1")
    control.Left = center_x + x * 20
    control.Top = center_z + x * 20
    control.Width = 15
    control.Height = 15
    control.HintText = nx_widestr("Picture1:") .. nx_widestr(x) .. nx_widestr(",") .. nx_widestr(y)
    nx_bind_script(control, "form_stage_main\\form_relation\\form_relation_guild\\form_guild_info")
    nx_callback(control, "on_left_down", "on_pic_kengwei_left_down")
    cont:Add(control)
  end
end
function get_and_save_infos(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_info", false)
  if not nx_is_valid(form) then
    return
  end
  free_map_rec = {}
  map_with_domain_rec = {}
  local para_count = table.getn(arg)
  local domain_count = arg[1]
  if para_count <= 1 then
    return false
  end
  local domain_para_count = domain_count * 2
  local free_drawing_count = para_count - 1 - domain_para_count
  if free_drawing_count < 0 then
    return false
  end
  local gui = nx_value("gui")
  for i = 1, domain_count do
    local drawing_row = arg[2 * i]
    local domain_id = arg[2 * i + 1]
    form.combobox_domain.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_dipan_" .. nx_string(domain_id))))
    map_with_domain_rec[i] = {drawing_row, domain_id}
  end
  for k = 2 + domain_para_count, para_count do
    local free_drawing_row = arg[k]
    form.combobox_drawings.DropListBox:AddString(nx_widestr(free_drawing_row))
    table.insert(free_map_rec, free_drawing_row)
  end
  local domain_num = table.getn(map_with_domain_rec)
  if 0 < domain_num then
    form.combobox_domain.DropListBox.SelectIndex = 0
    form.combobox_domain.Text = form.combobox_domain.DropListBox:GetString(0)
    form.selectmapid = map_with_domain_rec[1][1]
    form.selectdomainid = map_with_domain_rec[1][2]
    custom_request_darwings_info(form.selectmapid)
  end
  local idle_map_num = table.getn(free_map_rec)
  if 0 < idle_map_num then
    form.combobox_drawings.Visible = true
    form.lbl_drawings.Visible = true
    form.btn_binding.Visible = true
    if domain_num == 0 then
      form.combobox_drawings.DropListBox.SelectIndex = 0
      form.combobox_drawings.Text = form.combobox_drawings.DropListBox:GetString(0)
      form.selectmapid = free_map_rec[1]
      custom_request_darwings_info(form.selectmapid)
    end
  else
    form.combobox_drawings.Visible = false
    form.lbl_drawings.Visible = false
    form.btn_binding.Visible = false
  end
  return true
end
function custom_request_domain_and_drawing_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DOMAIN_AND_DRAWING))
end
function custom_request_darwings_info(map_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local npc_info = nx_value("npc_info")
  if nx_is_valid(npc_info) then
    npc_info:ClearChild()
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DARWINGS_INFO), nx_int(map_id))
end
function custom_request_darwings_kengwei_info(domain, key)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DARWINGS_KENGWEI), nx_string(key), nx_int(domain))
end
function custom_request_darwings_juanzhou_info(domain, key)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DARWINGS_JUANZHOU), nx_string(key), nx_int(domain))
end
function on_combobox_domain_selected(combobox)
  local form = combobox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local select_index = combobox.DropListBox.SelectIndex
  if select_index + 1 > table.getn(map_with_domain_rec) then
    return
  end
  form.selectdomainid = map_with_domain_rec[select_index + 1][2]
  form.selectmapid = map_with_domain_rec[select_index + 1][1]
  custom_request_darwings_info(form.selectmapid)
end
function on_combobox_drawings_selected(combobox)
  local form = combobox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local select_index = combobox.DropListBox.SelectIndex
  form.selectmapid = nx_int(combobox.DropListBox:GetString(select_index))
  custom_request_darwings_info(form.selectmapid)
end
function on_return_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_request_darwings_info(form.selectmapid)
end
