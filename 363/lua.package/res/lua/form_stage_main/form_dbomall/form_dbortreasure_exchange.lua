require("tips_data")
require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_dbomall\\form_dbortreasure_exchange"
local INI_FILE = "share\\Item\\royal_treasure_map.ini"
function open_form()
  local form = util_get_form(FORM_NAME, true, true)
  if nx_is_valid(form) then
    form.Visible = true
    form:Show()
  end
end
function on_main_form_init(form)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(INI_FILE) then
    IniManager:LoadIniToManager(INI_FILE)
  end
  form.Fixed = false
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
function on_btn_exchange1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(236), 4, nx_int(form.sel_cfg_id))
  form:Close()
end
function show_exchange_item_info(item_id, item_index)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) or form.Visible == false then
    return
  end
  form.sel_cfg_id = item_index
  form.imagegrid_tmp_pic.item_id = item_id
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_id, "Photo")
  form.imagegrid_tmp_pic:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_tmp_name.Text = nx_widestr(gui.TextManager:GetText(item_id))
  if need_desc ~= nil then
    form.lbl_tmp_score.Text = nx_widestr(need_desc)
  end
end
function on_imagegrid_tmp_pic_mousein_grid(self, index)
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.is_static = true
    item.ConfigID = nx_string(self.item_id)
    item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", nx_string(self.item_id), "ItemType", "0")
    nx_execute("tips_game", "show_goods_tip", item, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 40, 40, self.ParentForm)
  end
end
function on_imagegrid_tmp_pic_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function show_exchange_item_info_rtm(item_id, item_index)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) or form.Visible == false then
    return
  end
  form.sel_cfg_id = item_index
  form.imagegrid_tmp_pic.item_id = item_id
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_id, "Photo")
  form.imagegrid_tmp_pic:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_tmp_name.Text = nx_widestr(gui.TextManager:GetText(item_id))
  local desc_tips_id, need_tips_id = get_tips_desc_by_index(item_index)
  if need_tips_id ~= nil then
    form.lbl_tmp_score.Text = nx_widestr(gui.TextManager:GetFormatText(need_tips_id))
  end
  if desc_tips_id ~= nil then
    form.lbl_tmp_condition.Text = nx_widestr(gui.TextManager:GetFormatText(desc_tips_id))
  end
end
function get_tips_desc_by_index(index)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return "", ""
  end
  local sec_index = ini:FindSectionIndex("exchange_desc")
  if sec_index < 0 then
    return "", ""
  end
  local var = ini:ReadString(sec_index, nx_string(index), "")
  if nx_string(var) == nx_string("") then
    return "", ""
  end
  local vars = util_split_string(var, ",")
  return vars[1], vars[2]
end
