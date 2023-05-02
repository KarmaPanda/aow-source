require("util_gui")
require("util_functions")
local ST_FUNCTION_NEW_GUILDWAR = 219
local ssmanager_table = {
  "city01",
  "city02",
  "city04",
  "city05",
  "born01",
  "born02",
  "born03",
  "born04"
}
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.mltbox_area_map.scene_id = 1
  local count = #ssmanager_table
  for i = 1, count do
    form.combobox_ssmanager.DropListBox:AddString(nx_widestr(util_text(nx_string(ssmanager_table[i]))))
  end
  form.combobox_ssmanager.DropListBox.SelectIndex = 0
  form.combobox_ssmanager.Text = nx_widestr(form.combobox_ssmanager.DropListBox.SelectString)
  on_combobox_ssmanager_selected(form.combobox_ssmanager)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_mltbox_origin_tips_click_hyperlink(mltbox)
  nx_execute("form_stage_main\\form_origin\\form_origin", "open_origin_form_by_id", 2101)
  local form_origin = nx_value("form_stage_main\\form_origin\\form_origin")
  if not nx_is_valid(form_origin) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.Desktop:ToFront(form_origin)
  end
end
function on_mltbox_shuishou_click_hyperlink(mltbox)
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", "jhqb,jianghuzd02,bangpaipian03,bangpaizhangaoshi04")
end
function on_mltbox_area_map_click_hyperlink(mltbox)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  local target_scene = map_query:GetSceneName(nx_string(mltbox.scene_id))
  if not map_query:IsSceneVisited(nx_string(target_scene)) then
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(util_text("90365"), 1, 0)
    end
    return
  end
  nx_execute("form_stage_main\\form_map\\form_map_scene", "auto_show_hide_map_scene")
  local form_map_scene = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_is_valid(form_map_scene) and form_map_scene.Visible and nx_find_custom(form_map_scene, "cbtn_guild_pk_arena") then
    for i = 1, 10 do
      nx_pause(0.1)
      if nx_is_valid(form_map_scene) and nx_find_custom(form_map_scene.cbtn_guild_pk_arena, "NpcTypes") then
        break
      end
      if i == 10 then
        return
      end
    end
    nx_execute("form_stage_main\\form_map\\form_map_scene", "turn_to_scene_map", form_map_scene, nx_string(target_scene))
    form_map_scene.cbtn_guild_pk_arena.Checked = true
  end
end
function on_combobox_ssmanager_selected(combobox)
  local form = combobox.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local select_index = combobox.DropListBox.SelectIndex
  if select_index < 0 or select_index >= #ssmanager_table then
    form.mltbox_ssmanager.HtmlText = ""
    return
  end
  form.mltbox_ssmanager.HtmlText = nx_widestr("<a href=\"findnpc_new," .. nx_string(ssmanager_table[select_index + 1]) .. ",Guildtaxnpc001\" style=\"HLStype1\">") .. nx_widestr(util_text("ui_map_gongneng_tax")) .. nx_widestr("</a>")
end
function updata_domain_area_info(...)
  if #arg < 4 then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local form_guild_domain_map
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  else
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  local form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_area")
  if not nx_is_valid(form) or not nx_is_valid(form_guild_domain_map) then
    return
  end
  local guild_name = arg[2]
  local player_name = arg[3]
  local revenue_status = arg[4]
  local revenue_value = arg[5]
  local scene_id = arg[6]
  if nx_ws_length(guild_name) == 0 then
    guild_name = util_text("ui_guild_kongque")
  end
  if nx_ws_length(player_name) == 0 then
    player_name = util_text("ui_guild_kongque")
  end
  form.lbl_owner_guild.Text = nx_widestr(guild_name)
  form.lbl_scene_name.Text = nx_widestr(util_text("ui_scene_" .. nx_string(scene_id)))
  form.lbl_text_2.Text = nx_widestr(util_text("ui_guildtitle_" .. nx_string(scene_id) .. "_1"))
  form.lbl_sendu.Text = nx_widestr(player_name)
  form.lbl_revenue.Text = nx_widestr(util_format_string("ui_revenue_status_" .. nx_string(revenue_status), nx_int64(revenue_value)))
  form.mltbox_special_area.HtmlText = nx_widestr(util_text("ui_guild_special_area_" .. nx_string(scene_id)))
  form.mltbox_area_map.scene_id = scene_id
end
function clear_form_info(form)
  form.lbl_owner_guild.Text = ""
  form.lbl_scene_name.Text = ""
  form.lbl_text_2.Text = ""
  form.lbl_sendu.Text = ""
  form.lbl_revenue.Text = ""
  form.mltbox_special_area:Clear()
  form.mltbox_area_map.scene_id = 0
end
