require("util_gui")
require("const_define")
local region_limit = {
  "permit_challenge",
  "forbid_PVP",
  "forbid_PVE",
  "forbid_sword",
  "forbid_qinggong",
  "forbid_run",
  "forbid_ride",
  "forbid_chat",
  "forbid_trade",
  "forbid_mail",
  "forbid_offline",
  "forbid_tool",
  "forbid_bigmap",
  "forbid_smallmap",
  "forbid_sit",
  "forbid_HP",
  "forbid_recover_skill",
  "forbid_life_skill",
  "forbid_damage_skill",
  "forbid_skill",
  "forbid_drop_down_hurt",
  "forbid_otherplayer"
}
local area_limit = {
  {
    limit_name = "find_path",
    region_name = "forbid_find_path"
  },
  {
    limit_name = "dive",
    region_name = "forbid_dive"
  },
  {
    limit_name = "offline",
    region_name = "forbid_offline"
  },
  {
    limit_name = "stall",
    region_name = "permit_stall"
  },
  {
    limit_name = "plant",
    region_name = "permit_plant"
  },
  {
    limit_name = "sound",
    region_name = "permit_sound"
  },
  {
    limit_name = "leitai",
    region_name = "permit_world_leitai"
  }
}
local UNNAMED_AREA = {
  "area_unnamed_river",
  "area_unnamed_dead",
  ""
}
function init_form(self)
  self.Fixed = false
  self.ini = nx_null()
  self.ini_info = nx_null()
  self.ini_scene = nx_null()
  set_form_pos(self)
  self.old_area_name = ""
end
function on_main_form_open(form)
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return
  end
  form.ini = IniManager:GetIniDocument("share\\area\\AreaType.ini")
  if not nx_is_valid(form.ini) then
    form.ini = IniManager:LoadIniToManager("share\\area\\AreaType.ini")
  end
  form.ini_info = IniManager:GetIniDocument("share\\area\\AreaInfo.ini")
  if not nx_is_valid(form.ini_info) then
    form.ini_info = IniManager:LoadIniToManager("share\\area\\AreaInfo.ini")
  end
  form.ini_scene = IniManager:GetIniDocument("share\\area\\AreaScene.ini")
  if not nx_is_valid(form.ini_scene) then
    form.ini_scene = IniManager:LoadIniToManager("share\\area\\AreaScene.ini")
  end
  if not nx_is_valid(form.ini) then
    nx_msgbox("share\\area\\AreaType.ini " .. get_msg_str("msg_120"))
  end
  if not nx_is_valid(form.ini_info) then
    nx_msgbox("share\\area\\AreaInfo.ini " .. get_msg_str("msg_120"))
  end
  if not nx_is_valid(form.ini_scene) then
    nx_msgbox("share\\area\\AreaScene.ini " .. get_msg_str("msg_120"))
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function set_form_pos(form)
  local gui = nx_value("gui")
  if nx_is_valid(form) then
    form.AbsLeft = gui.Width * 0.6
    form.AbsTop = gui.Height * 0.2
  end
end
function show_area_info(role)
  if not nx_is_valid(role) then
    return
  end
  if not nx_find_custom(role, "cur_area_name") then
    return
  end
  local new_area_name = role.cur_area_name
  local form = nx_value("form_stage_main\\form_main\\form_area_info")
  if not nx_is_valid(form) then
    return
  end
  if form.old_area_name == new_area_name then
    return
  end
  form.old_area_name = new_area_name
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  local gui = nx_value("gui")
  local wide_area_name = nx_widestr("")
  if can_show_area_info(new_area_name) then
    wide_area_name = gui.TextManager:GetText(new_area_name)
  end
  local scene_name = get_scene_name()
  form.lbl_title.Text = gui.TextManager:GetFormatText("ui_bugaolan", scene_name)
  form.lbl_area_name.Text = wide_area_name
  form.mltbox_area_limit:Clear()
  local b_no_limit = true
  for _, v in ipairs(area_limit) do
    local region_enable = terrain:GetRegionEnable(v.region_name, role.PositionX, role.PositionZ)
    if v.limit_name == "stall" or v.limit_name == "plant" or v.limit_name == "leitai" then
      if region_enable then
        local wide_str = gui.TextManager:GetText("desc_area_y_" .. nx_string(v.limit_name))
        form.mltbox_area_limit:AddHtmlText(wide_str, -1)
        b_no_limit = false
      end
    elseif region_enable then
      local str = gui.TextManager:GetText("desc_area_" .. nx_string(v.limit_name))
      str = nx_widestr("<img src=\"gui\\language\\ChineseS\\areainfo\\bg_jin.png\" />") .. str
      form.mltbox_area_limit:AddHtmlText(str, -1)
      b_no_limit = false
    end
  end
  if nx_is_valid(form.ini_info) and nx_is_valid(form.ini_scene) then
    for i = 1, table.maxn(region_limit) do
      local limit_name = region_limit[i]
      local scene_index = form.ini_scene:FindSectionIndex(new_area_name)
      if 0 <= scene_index then
        local info_str = form.ini_scene:ReadString(scene_index, "info", "")
        local info_index = form.ini_info:FindSectionIndex(info_str)
        if 0 <= info_index then
          local enable_str = form.ini_info:ReadString(info_index, limit_name, "")
          if limit_name == "permit_challenge" then
            if nx_string(enable_str) == "N" then
              local str = gui.TextManager:GetText("desc_area_" .. nx_string(limit_name))
              str = nx_widestr("<img src=\"gui\\language\\ChineseS\\areainfo\\bg_jin.png\" />") .. str
              form.mltbox_area_limit:AddHtmlText(str, -1)
              b_no_limit = false
            end
          elseif nx_string(enable_str) == "Y" then
            local str = gui.TextManager:GetText("desc_area_" .. nx_string(limit_name))
            str = nx_widestr("<img src=\"gui\\language\\ChineseS\\areainfo\\bg_jin.png\" />") .. str
            form.mltbox_area_limit:AddHtmlText(str, -1)
            b_no_limit = false
          end
        end
      end
    end
  end
  if b_no_limit then
    local wide_str = gui.TextManager:GetText("ui_area_no")
    form.mltbox_area_limit:AddHtmlText(wide_str, -1)
  end
  form.mltbox_area_desc:Clear()
  local area_desc = ""
  if nx_is_valid(form.ini) then
    local sec_index = form.ini:FindSectionIndex(new_area_name)
    if 0 <= sec_index then
      area_desc = form.ini:ReadString(sec_index, "desc", "")
    end
  end
  if area_desc == "" then
    area_desc = "ui_warning_1"
  end
  local wide_str = gui.TextManager:GetText(area_desc)
  form.mltbox_area_desc:AddHtmlText(wide_str, -1)
end
function on_region_change(info_id)
end
function on_size_change()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_main\\form_area_info")
  if nx_is_valid(form) then
    set_form_pos(form)
  end
end
function on_btn_min_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  form:Close()
end
function can_show_area_info(area_name)
  for i = 1, table.getn(UNNAMED_AREA) do
    if nx_string(area_name) == UNNAMED_AREA[i] then
      return false
    end
  end
  return true
end
function get_scene_name()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return ""
  end
  local gui = nx_value("gui")
  local scene_config = client_scene:QueryProp("ConfigID")
  local scene_name = gui.TextManager:GetFormatText(scene_config)
  return scene_name
end
