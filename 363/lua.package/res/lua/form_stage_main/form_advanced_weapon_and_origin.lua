require("util_gui")
require("util_functions")
require("role_composite")
require("util_static_data")
require("form_stage_main\\form_huashan\\huashan_define")
require("define\\request_type")
require("define\\star_module_define")
FORM_NAME = "form_stage_main\\form_advanced_weapon_and_origin"
SHOW_WUJUE = 1
SHOW_WUDU = 2
SHOW_WS = 3
local FORM_WUXUEGE = "form_stage_main\\form_wuxue\\form_wuxuege_show_skill"
local weapon_type = {}
local origin_type = {}
local book_type = {}
local weapon_name_image = {
  blade_leader_jyw_001 = "gui\\language\\ChineseS\\yulan\\jyw_b.png",
  sblade_leader_jlg_001 = "gui\\language\\ChineseS\\yulan\\jlg_b.png",
  sword_leader_wd_001 = "gui\\language\\ChineseS\\yulan\\wd_b.png",
  sword_leader_jzt_001 = "gui\\language\\ChineseS\\yulan\\jzt_b.png",
  thorn_leader_tm_001 = "gui\\language\\ChineseS\\yulan\\tm_b.png",
  sthorn_leader_em_001 = "gui\\language\\ChineseS\\yulan\\em_b.png",
  cosh_leader_gb_001 = "gui\\language\\ChineseS\\yulan\\gb_b.png",
  lstuff_leader_sl_001 = "gui\\language\\ChineseS\\yulan\\sl_b.png",
  bow_leader_mj_001 = "gui\\language\\ChineseS\\yulan\\mj_b.png",
  sword_leader_ts_001 = "gui\\language\\ChineseS\\yulan\\ts_b.png",
  sword_ytj_001 = "gui\\language\\ChineseS\\yulan\\yitianjian.png"
}
local weapon_get_desc = {
  zpsb = "ui_zhangmen_tips",
  hslj = "ui_huashanlunjian_tips_1"
}
local origin_name_image = {
  ["2020"] = "gui\\language\\ChineseS\\yulan\\dong.png",
  ["2021"] = "gui\\language\\ChineseS\\yulan\\xi.png",
  ["2022"] = "gui\\language\\ChineseS\\yulan\\nan.png",
  ["2023"] = "gui\\language\\ChineseS\\yulan\\bei.png",
  ["2024"] = "gui\\language\\ChineseS\\yulan\\zhong.png",
  ["1020"] = "gui\\language\\ChineseS\\yulan\\dfbb.png",
  ["1030"] = "gui\\language\\ChineseS\\yulan\\rysm.png",
  ["3000"] = "gui\\language\\ChineseS\\yulan\\dgqb.png",
  ["99999"] = "gui\\language\\ChineseS\\yulan\\szsj.png"
}
local origin_clothes_male_model = {
  ["2020"] = "obj\\char\\b_origin_hua_1_1\\b_cloth_1_1",
  ["2021"] = "obj\\char\\b_origin_hua_1_2\\b_cloth_1_2",
  ["2022"] = "obj\\char\\b_origin_hua_1_3\\b_cloth_1_3",
  ["2023"] = "obj\\char\\b_origin_hua_1_4\\b_cloth_1_4",
  ["2024"] = "obj\\char\\b_origin_hua_1_5\\b_cloth_1_5",
  ["1020"] = "obj\\char\\b_origin_jia_3_2\\b_cloth_3_2",
  ["1030"] = "obj\\char\\b_origin_jia_4_1\\b_cloth_4_1",
  ["3000"] = "obj\\char\\b_origin_dgqb_1_1\\b_cloth_1_1",
  ["99999"] = "obj\\char\\b_origin_arena_1_1\\b_origin_arena_1_1"
}
local origin_clothes_famale_model = {
  ["2020"] = "obj\\char\\g_origin_hua_1_1\\g_cloth_1_1",
  ["2021"] = "obj\\char\\g_origin_hua_1_2\\g_cloth_1_2",
  ["2022"] = "obj\\char\\g_origin_hua_1_3\\g_cloth_1_3",
  ["2023"] = "obj\\char\\g_origin_hua_1_4\\g_cloth_1_4",
  ["2024"] = "obj\\char\\g_origin_hua_1_5\\g_cloth_1_5",
  ["1020"] = "obj\\char\\g_origin_jia_3_2\\g_cloth_3_2",
  ["1030"] = "obj\\char\\g_origin_jia_4_1\\g_cloth_4_1",
  ["3000"] = "obj\\char\\g_origin_dgqb_1_1\\g_cloth_1_1",
  ["99999"] = "obj\\char\\g_origin_arena_1_1\\g_origin_arena_1_1"
}
local origin_desc = {
  ["2020"] = "desc1_origin_hua_1_1",
  ["2021"] = "desc1_origin_hua_1_2",
  ["2022"] = "desc1_origin_hua_1_3",
  ["2023"] = "desc1_origin_hua_1_4",
  ["2024"] = "desc1_origin_hua_1_5",
  ["1020"] = "ui_jhzb_dfbb",
  ["1030"] = "ui_jhzb_rysm",
  ["3000"] = "desc1_origin_dgqb_1_1",
  ["99999"] = "desc1_origin_arena_00001"
}
local origin_wudu_rank_name = {
  ["1020"] = "rank_1_khbd",
  ["1030"] = "rank_1_xxdf"
}
local origin_ws_rank_name = {
  ["3000"] = "rank_1_RevengeIntegral"
}
local book_model = {
  ng_book_jh_507_s2 = "obj\\itemnpc\\ypg_khbd1\\ypg_khbd1",
  ng_book_jh_306_s2 = "obj\\itemnpc\\ypg_xxdf1\\ypg_xxdf1"
}
local book_name_image = {
  ng_book_jh_507_s2 = "gui\\language\\ChineseS\\yulan\\khbd.png",
  ng_book_jh_306_s2 = "gui\\language\\ChineseS\\yulan\\xxdf.png"
}
local book_desc = {
  ng_book_jh_507_s2 = "ui_jhzb_mj_khbd",
  ng_book_jh_306_s2 = "ui_jhzb_mj_xxdf"
}
function open_form()
  util_auto_show_hide_form(nx_current())
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  init_scene(form)
  init_form(form)
  init_weapon_info(form)
  init_origin_info(form)
  init_book_info(form)
  init_visible(form)
  nx_execute("util_gui", "util_get_form", FORM_WUXUEGE, true, false)
  local form_wuxuege = nx_value(FORM_WUXUEGE)
  if nx_is_valid(form_wuxuege) then
    form.groupbox_wuxuege_info:Add(form_wuxuege)
  end
  form.groupbox_wuxuege_info.Visible = false
  change_form_size()
  form.scenebox_origin_wujue_ower.first_show_origin = true
  form.scenebox_origin_wudu_ower.first_show_origin = true
  form.scenebox_origin_ws_ower.first_show_origin = true
  form.scenebox_origin_wujue_ower.first_show_origin_ride = true
  form.scenebox_origin_wudu_ower.first_show_origin_ride = true
  form.scenebox_origin_ws_ower.first_show_origin_ride = true
  nx_execute("custom_sender", "custom_get_schoolleader_info")
end
function on_rbtn_zpsb_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  if nx_find_custom(btn, "id") and nx_find_custom(btn, "school_leader") then
    local form = nx_value(FORM_NAME)
    if not nx_is_valid(form) then
      return
    end
    local itemQuery = nx_value("ItemQuery")
    if not nx_is_valid(itemQuery) then
      return
    end
    local str_type = itemQuery:GetItemPropByConfigID(nx_string(btn.id), nx_string("ItemType"))
    local item_type = nx_number(str_type)
    set_weapon_info(form, btn.id, item_type)
    set_weapon_owner_info(form, btn.school_leader)
    set_weapon_model(form, btn.id, item_type)
    form.groupbox_weapon_prop.Visible = true
    form.scenebox_weapon.Visible = true
    form.groupbox_weapon_owner_info.Visible = true
  end
end
function on_rbtn_hslj_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  if nx_find_custom(btn, "id") then
    local form = nx_value(FORM_NAME)
    if not nx_is_valid(form) then
      return
    end
    local itemQuery = nx_value("ItemQuery")
    if not nx_is_valid(itemQuery) then
      return
    end
    local str_type = itemQuery:GetItemPropByConfigID(nx_string(btn.id), nx_string("ItemType"))
    local item_type = nx_number(str_type)
    set_weapon_info(form, btn.id, item_type)
    set_weapon_model(form, btn.id, item_type)
    form.groupbox_weapon_prop.Visible = true
    form.scenebox_weapon.Visible = true
    form.groupbox_weapon_owner_info.Visible = true
  end
end
function on_btn_left_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "show_weapon_index") then
    return
  end
  form.show_weapon_index = form.show_weapon_index - 1
  refresh_switch_control(form)
end
function on_btn_right_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "show_weapon_index") then
    return
  end
  form.show_weapon_index = form.show_weapon_index + 1
  refresh_switch_control(form)
end
function on_btn_origin_left_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "show_origin_index") then
    return
  end
  form.show_origin_index = form.show_origin_index - 1
  refresh_origin_switch_control(form)
end
function on_btn_origin_right_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "show_origin_index") then
    return
  end
  form.show_origin_index = form.show_origin_index + 1
  refresh_origin_switch_control(form)
end
function on_rbtn_wuxuege_checked_changed(btn)
  if btn.Checked == true then
    local form = nx_value(FORM_NAME)
    if not nx_is_valid(form) then
      return
    end
    form.groupbox_weapon_info.Visible = false
    form.groupbox_book_info.Visible = false
    form.groupbox_origin_info.Visible = false
    form.groupbox_wuxuege_info.Visible = true
  end
end
function on_rbtn_origin_checked_changed(btn)
  if btn.Checked == true then
    local form = nx_value(FORM_NAME)
    if not nx_is_valid(form) then
      return
    end
    form.groupbox_weapon_info.Visible = false
    form.groupbox_book_info.Visible = false
    form.groupbox_origin_info.Visible = true
    form.groupbox_wuxuege_info.Visible = false
  end
end
function on_rbtn_weapon_checked_changed(btn)
  if btn.Checked == true then
    local form = nx_value(FORM_NAME)
    if not nx_is_valid(form) then
      return
    end
    form.groupbox_weapon_info.Visible = true
    form.groupbox_book_info.Visible = false
    form.groupbox_origin_info.Visible = false
    nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_GetNoOne)
    form.groupbox_wuxuege_info.Visible = false
  end
end
function on_rbtn_book_checked_changed(btn)
  if btn.Checked == true then
    local form = nx_value(FORM_NAME)
    if not nx_is_valid(form) then
      return
    end
    form.groupbox_weapon_info.Visible = false
    form.groupbox_book_info.Visible = true
    form.groupbox_origin_info.Visible = false
    form.groupbox_wuxuege_info.Visible = false
  end
end
function on_rbtn_mj_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  if nx_find_custom(btn, "id") then
    local form = nx_value(FORM_NAME)
    if not nx_is_valid(form) then
      return
    end
    local itemQuery = nx_value("ItemQuery")
    if not nx_is_valid(itemQuery) then
      return
    end
    local str_type = itemQuery:GetItemPropByConfigID(nx_string(btn.id), nx_string("ItemType"))
    local item_type = nx_number(str_type)
    set_book_info(form, btn.id)
    set_book_model(form, btn.id)
  end
end
function on_btn_owner_info_click(btn)
  if nx_find_custom(btn, "id") then
    nx_execute("custom_sender", "custom_send_get_player_game_info", nx_widestr(btn.id))
  end
end
function on_main_form_close(form)
  if nx_find_custom(form.scenebox.Scene, "game_effect") and nx_is_valid(form.scenebox.Scene.game_effect) then
    nx_destroy(form.scenebox.Scene.game_effect)
  end
  if nx_find_custom(form.scenebox.Scene, "sky") and nx_is_valid(form.scenebox.Scene.sky) then
    form.scenebox.Scene:Delete(form.scenebox.Scene.sky)
  end
  local form_wuxuege = nx_value(FORM_WUXUEGE)
  if nx_is_valid(form_wuxuege) then
    form_wuxuege:Close()
  end
  nx_destroy(form)
end
function on_btn_exit_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_up_click(btn)
  refresh_scroll(1)
end
function on_btn_down_click(btn)
  refresh_scroll(-1)
end
function refresh_scroll(direction)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "weapon_show_groupbox") then
    return
  end
  local groupbox = form.weapon_show_groupbox
  if not nx_is_valid(groupbox) then
    return
  end
  if groupbox.Height <= form.groupbox_weapon.Height then
    form.btn_down.Visible = false
    form.btn_up.Visible = false
    return
  end
  local top = groupbox.Top
  top = top + direction * 132
  if 0 < top or top < form.groupbox_weapon.Height - groupbox.Height then
    return
  end
  groupbox.Top = top
  if groupbox.Top == 0 then
    form.btn_up.Visible = false
    form.btn_down.Visible = true
    return
  elseif groupbox.Top < 0 then
    if groupbox.Top + groupbox.Height <= form.groupbox_weapon.Height then
      form.btn_up.Visible = true
      form.btn_down.Visible = false
    else
      form.btn_up.Visible = true
      form.btn_down.Visible = true
    end
  end
end
function on_rbtn_origin_wujue_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  if nx_find_custom(btn, "id") then
    local form = nx_value(FORM_NAME)
    if not nx_is_valid(form) then
      return
    end
    local gui = nx_value("gui")
    if not nx_is_valid(form) then
      return
    end
    form.btn_get_origin.id = btn.id
    nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_ReqBest5, nx_int(btn.id))
    form.lbl_origin_name.BackImage = origin_name_image[nx_string(btn.id)]
    form.mltbox_origin_ower_info:Clear()
    form.mltbox_origin_ower_info:AddHtmlText(gui.TextManager:GetText(origin_desc[nx_string(btn.id)]), nx_int(-1))
    form.scenebox_origin_wujue_ower.Visible = true
    form.scenebox_origin_wudu_ower.Visible = false
    form.scenebox_origin_ws_ower.Visible = false
    form.scenebox_origin_ws_ower_special.Visible = false
    form.groupbox_3.Visible = false
    form.groupbox_2.Visible = true
    form.groupbox_origin_owner_info.Visible = true
  end
end
function on_rbtn_origin_wudu_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  if nx_find_custom(btn, "id") then
    local form = nx_value(FORM_NAME)
    if not nx_is_valid(form) then
      return
    end
    local gui = nx_value("gui")
    if not nx_is_valid(form) then
      return
    end
    form.btn_get_origin.id = btn.id
    form.lbl_origin_name.BackImage = origin_name_image[nx_string(btn.id)]
    form.mltbox_origin_ower_info:Clear()
    form.mltbox_origin_ower_info:AddHtmlText(gui.TextManager:GetText(origin_desc[nx_string(btn.id)]), nx_int(-1))
    nx_execute("custom_sender", "custom_query_star_info", STAR_RANK, origin_wudu_rank_name[nx_string(btn.id)])
    form.scenebox_origin_wujue_ower.Visible = false
    form.scenebox_origin_wudu_ower.Visible = true
    form.scenebox_origin_ws_ower.Visible = false
    form.scenebox_origin_ws_ower_special.Visible = false
    form.groupbox_3.Visible = false
    form.groupbox_2.Visible = true
    form.groupbox_origin_owner_info.Visible = true
  end
end
function on_rbtn_origin_ws_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  if nx_find_custom(btn, "id") then
    local form = nx_value(FORM_NAME)
    if not nx_is_valid(form) then
      return
    end
    local gui = nx_value("gui")
    if not nx_is_valid(form) then
      return
    end
    form.btn_get_origin.id = btn.id
    form.lbl_origin_name.BackImage = origin_name_image[nx_string(btn.id)]
    form.mltbox_origin_ower_info:Clear()
    form.mltbox_origin_ower_info:AddHtmlText(gui.TextManager:GetText(origin_desc[nx_string(btn.id)]), nx_int(-1))
    form.scenebox_origin_wujue_ower.Visible = false
    form.scenebox_origin_wudu_ower.Visible = false
    if nx_string(btn.id) == "99999" then
      form.scenebox_origin_ws_ower.Visible = false
      form.scenebox_origin_ws_ower_special.Visible = true
      form.groupbox_3.Visible = true
      form.groupbox_2.Visible = false
      form.groupbox_origin_owner_info.Visible = false
      if not nx_find_custom(form, "show_special") or not form.show_special then
        for i = 1, 10 do
          local rank_string = "rank_1_RevengeIntegral," .. nx_string(i)
          nx_execute("custom_sender", "custom_query_star_info", STAR_COMMON, rank_string)
        end
      end
      form.show_special = true
    else
      nx_execute("custom_sender", "custom_query_star_info", STAR_COMMON, "rank_1_RevengeIntegral,1")
      form.scenebox_origin_ws_ower.Visible = true
      form.scenebox_origin_ws_ower_special.Visible = false
      form.groupbox_3.Visible = false
      form.groupbox_2.Visible = true
      form.groupbox_origin_owner_info.Visible = true
    end
  end
end
function on_btn_get_origin_click(btn)
  if nx_find_custom(btn, "id") then
    nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_ChooseTitle, nx_int(btn.id))
  end
end
function on_btn_show_wudu_origin_help_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
  local form_help = util_get_form("form_stage_main\\form_helper\\form_theme_helper", false)
  if nx_is_valid(form_help) then
    nx_execute("form_stage_main\\form_helper\\form_theme_helper", "click_hyperlink", form_help, "jhqb,jianghuzd02,jhzhibao03,jhzhibaojj04")
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_show_miji_help_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
  local form_help = util_get_form("form_stage_main\\form_helper\\form_theme_helper", false)
  if nx_is_valid(form_help) then
    nx_execute("form_stage_main\\form_helper\\form_theme_helper", "click_hyperlink", form_help, "jhqb,jianghuzd02,jhzhibao03,jhzhibaojl04")
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function init_form(form)
  local ini = nx_execute("util_functions", "get_ini", "ini\\advanced_weapon_and_origin.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex("weapon_type")
    if sec_index < 0 then
      return
    end
    for i = 1, ini:GetSectionItemCount(sec_index) do
      weapon_type[i] = ini:ReadString(sec_index, nx_string(i), "")
    end
    local title_sec_index = ini:FindSectionIndex("origin_type")
    if title_sec_index < 0 then
      return
    end
    for i = 1, ini:GetSectionItemCount(title_sec_index) do
      origin_type[i] = ini:ReadString(title_sec_index, nx_string(i), "")
    end
    local book_sec_index = ini:FindSectionIndex("book_type")
    if book_sec_index < 0 then
      return
    end
    for i = 1, ini:GetSectionItemCount(book_sec_index) do
      book_type[i] = ini:ReadString(book_sec_index, nx_string(i), "")
    end
  end
  form.show_weapon_index = 1
  form.show_origin_index = 1
  form.groupbox_weapon_info.Left = 0
  form.groupbox_weapon_info.Top = 0
  form.groupbox_origin_info.Left = 0
  form.groupbox_origin_info.Top = 0
  form.groupbox_book_info.Left = 0
  form.groupbox_book_info.Top = 0
  form.groupbox_wuxuege_info.Left = 0
  form.groupbox_wuxuege_info.Top = 0
  local gui = nx_value("gui")
  for i = 1, table.getn(weapon_type) do
    local lbl = gui:Create("Label")
    lbl.Name = "lbl_weapon_mark_" .. nx_string(i)
    lbl.AutpSize = true
    lbl.BackImage = "gui\\special\\yulan\\point_2.png"
    lbl.Left = (i - 1) * 12
    lbl.Top = 0
    lbl.Height = 12
    lbl.Width = 12
    lbl.NoFrame = false
    form.groupbox_mark:Add(lbl)
    form.groupbox_mark:ToFront(lbl)
  end
  form.groupbox_mark.Width = 12 * table.getn(weapon_type)
  form.groupbox_mark.Height = 12
  form.groupbox_mark.Left = form.groupbox_weapon_switch.Width / 2 - form.groupbox_mark.Width / 2
  for i = 1, table.getn(origin_type) do
    local lbl = gui:Create("Label")
    lbl.Name = "lbl_origin_mark_" .. nx_string(i)
    lbl.AutpSize = true
    lbl.BackImage = "gui\\special\\yulan\\point_2.png"
    lbl.Left = (i - 1) * 12
    lbl.Top = 0
    lbl.Height = 12
    lbl.Width = 12
    lbl.NoFrame = false
    form.groupbox_origin_mark:Add(lbl)
    form.groupbox_origin_mark:ToFront(lbl)
  end
  form.groupbox_origin_mark.Width = 12 * table.getn(origin_type)
  form.groupbox_origin_mark.Height = 12
  form.groupbox_origin_mark.Left = form.groupbox_origin_switch.Width / 2 - form.groupbox_origin_mark.Width / 2
end
function init_weapon_info(form)
  for i = 1, table.getn(weapon_type) do
    local groupbox = form.groupbox_weapon:Find("groupbox_" .. nx_string(weapon_type[i]))
    if nx_is_valid(groupbox) then
      local table_info = {}
      local ini = nx_execute("util_functions", "get_ini", "ini\\advanced_weapon_and_origin.ini")
      if nx_is_valid(ini) then
        local sec_index = ini:FindSectionIndex(weapon_type[i])
        if sec_index < 0 then
          return
        end
        for i = 1, ini:GetSectionItemCount(sec_index) do
          table_info[i] = ini:ReadString(sec_index, nx_string(i), "")
        end
      end
      for j = 1, table.getn(table_info) do
        local btn = groupbox:Find("rbtn_" .. weapon_type[i] .. "_" .. nx_string(j))
        if nx_is_valid(btn) then
          btn.id = table_info[j]
          if weapon_type[i] == "zpsb" then
            btn.school_leader = nx_widestr("")
          end
        end
      end
    end
  end
end
function init_origin_info(form)
  for i = 1, table.getn(origin_type) do
    local groupbox = form.groupbox_origin:Find("groupbox_" .. nx_string(origin_type[i]))
    if nx_is_valid(groupbox) then
      local table_info = {}
      local ini = nx_execute("util_functions", "get_ini", "ini\\advanced_weapon_and_origin.ini")
      if nx_is_valid(ini) then
        local sec_index = ini:FindSectionIndex(origin_type[i])
        if sec_index < 0 then
          return
        end
        for i = 1, ini:GetSectionItemCount(sec_index) do
          table_info[i] = ini:ReadString(sec_index, nx_string(i), "")
        end
      end
      for j = 1, table.getn(table_info) do
        local btn = groupbox:Find("rbtn_" .. origin_type[i] .. "_" .. nx_string(j))
        if nx_is_valid(btn) then
          btn.id = table_info[j]
        end
      end
    end
  end
end
function init_book_info(form)
  for i = 1, table.getn(book_type) do
    local groupbox = form.groupbox_book:Find("groupbox_" .. nx_string(book_type[i]))
    if nx_is_valid(groupbox) then
      local table_info = {}
      local ini = nx_execute("util_functions", "get_ini", "ini\\advanced_weapon_and_origin.ini")
      if nx_is_valid(ini) then
        local sec_index = ini:FindSectionIndex(book_type[i])
        if sec_index < 0 then
          return
        end
        for i = 1, ini:GetSectionItemCount(sec_index) do
          table_info[i] = ini:ReadString(sec_index, nx_string(i), "")
        end
      end
      for j = 1, table.getn(table_info) do
        local btn = groupbox:Find("rbtn_" .. book_type[i] .. "_" .. nx_string(j))
        if nx_is_valid(btn) then
          btn.id = table_info[j]
        end
      end
    end
  end
end
function on_server_schoolleader_msg(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(arg)
  if count ~= 10 then
    return
  end
  local groupbox = form.groupbox_weapon:Find("groupbox_zpsb")
  if nx_is_valid(groupbox) then
    for i = 1, count do
      local btn = groupbox:Find("rbtn_zpsb_" .. nx_string(i))
      if nx_is_valid(btn) and nx_find_custom(btn, "school_leader") then
        btn.school_leader = nx_widestr(arg[i])
      end
    end
  end
end
function init_visible(form)
  form.rbtn_weapon.Visible = false
  form.rbtn_origin.Visible = false
  form.rbtn_book.Visible = false
  local ini = nx_execute("util_functions", "get_ini", "ini\\advanced_weapon_and_origin.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex("show_type")
    if sec_index < 0 then
      return
    end
    if ini:GetSectionItemCount(sec_index) == 3 then
      for i = 1, ini:GetSectionItemCount(sec_index) do
        local name = ini:ReadString(sec_index, nx_string(i), "")
        local rbtn = form.groupbox_1:Find("rbtn_" .. name)
        if nx_is_valid(rbtn) then
          rbtn.Visible = true
          if i == 1 then
            rbtn.Left = -586
            rbtn.Checked = true
          elseif i == 2 then
            rbtn.Left = -345
          elseif i == 3 then
            rbtn.Left = -30
          end
        end
      end
    elseif ini:GetSectionItemCount(sec_index) == 2 then
      for i = 1, ini:GetSectionItemCount(sec_index) do
        local name = ini:ReadString(sec_index, nx_string(i), "")
        local rbtn = form.groupbox_1:Find("rbtn_" .. name)
        if nx_is_valid(rbtn) then
          rbtn.Visible = true
          if i == 1 then
            rbtn.Left = -149
            rbtn.Checked = true
          elseif i == 2 then
            rbtn.Left = 65
          end
        end
      end
    elseif ini:GetSectionItemCount(sec_index) == 1 then
      local name = ini:ReadString(sec_index, nx_string(i), "")
      local rbtn = form.groupbox_1:Find("rbtn_" .. name)
      if nx_is_valid(rbtn) then
        rbtn.Visible = true
        rbtn.Left = -49
        rbtn.Checked = true
      end
    end
  end
  if nx_find_custom(form, "show_weapon_index") then
    if weapon_type[form.show_weapon_index] == "hslj" then
      form.rbtn_zpsb_1.Checked = true
      form.rbtn_hslj_1.Checked = true
    elseif weapon_type[form.show_weapon_index] == "zpsb" then
      form.rbtn_hslj_1.Checked = true
      form.rbtn_zpsb_1.Checked = true
    end
  end
  if nx_find_custom(form, "show_origin_index") then
    if origin_type[form.show_origin_index] == "wujue" then
      form.rbtn_ws_1.Checked = true
      form.rbtn_wudu_1.Checked = true
      form.rbtn_wujue_1.Checked = true
    elseif origin_type[form.show_origin_index] == "wudu" then
      form.rbtn_wujue_1.Checked = true
      form.rbtn_ws_1.Checked = true
      form.rbtn_wudu_1.Checked = true
    elseif origin_type[form.show_origin_index] == "ws" then
      form.rbtn_wujue_1.Checked = true
      form.rbtn_wudu_1.Checked = true
      form.rbtn_ws_1.Checked = true
    end
  end
  form.rbtn_mj_1.Checked = true
  refresh_switch_control(form)
  refresh_origin_switch_control(form)
end
function init_scene(form)
  util_addscene_to_scenebox(form.scenebox)
  local scene = form.scenebox.Scene
  local particle_man = nx_null()
  if not nx_is_valid(particle_man) then
    particle_man = scene:Create("ParticleManager")
    particle_man.TexturePath = "map\\tex\\particles\\"
    particle_man:Load()
    particle_man.EnableCacheIni = true
    scene:AddObject(particle_man, 100)
    scene.particle_man = particle_man
  end
  local sky = create_sky(scene)
  sky:Load()
  scene:AddObject(sky, 2)
  scene.sky = sky
  create_terrain(scene, 1, 4, 100, 100)
  local game_effect = nx_create("GameEffect")
  nx_bind_script(game_effect, "game_effect", "game_effect_init", scene)
  scene.game_effect = game_effect
  set_visual_radius(scene, 20)
  scene.ClearZBuffer = true
  scene.camera:SetPosition(3, 4, 0)
  scene.camera:SetAngle(0, 0, 0)
end
function change_form_size()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.scenebox.Width = form.Width
  form.scenebox.Height = form.Height
  form.groupbox_weapon_info.Width = form.Width
  form.groupbox_weapon_info.Height = form.Height
  form.groupbox_origin_info.Width = form.Width
  form.groupbox_origin_info.Height = form.Height
  form.groupbox_book_info.Width = form.Width
  form.groupbox_book_info.Height = form.Height
  form.groupbox_wuxuege_info.Width = form.Width
  form.groupbox_wuxuege_info.Height = form.Height
  nx_execute(FORM_WUXUEGE, "change_form_size", form)
  form.groupbox_1.Width = form.Width
end
function util_addscene_to_scenebox(scenebox)
  local ini = nx_execute("util_functions", "get_ini", "ini\\sns\\sns_weather.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local ambient_red = ini:ReadInteger("light", "ambient_red", 0)
  local ambient_green = ini:ReadInteger("light", "ambient_green", 0)
  local ambient_blue = ini:ReadInteger("light", "ambient_blue", 0)
  local ambient_intensity = ini:ReadFloat("light", "ambient_intensity", 0)
  local sunglow_red = ini:ReadInteger("light", "sunglow_red", 0)
  local sunglow_green = ini:ReadInteger("light", "sunglow_green", 0)
  local sunglow_blue = ini:ReadInteger("light", "sunglow_blue", 0)
  local sunglow_intensity = ini:ReadFloat("light", "sunglow_intensity", 0)
  local sun_height = ini:ReadInteger("light", "sun_height", 0)
  local sun_azimuth = ini:ReadInteger("light", "sun_azimuth", 0)
  local point_light_red = ini:ReadInteger("light", "point_light_red", 0)
  local point_light_green = ini:ReadInteger("light", "point_light_green", 0)
  local point_light_blue = ini:ReadInteger("light", "point_light_blue", 0)
  local point_light_range = ini:ReadFloat("light", "point_light_range", 0)
  local point_light_intensity = ini:ReadFloat("light", "point_light_intensity", 0)
  local point_light_pos_x = ini:ReadFloat("light", "point_light_pos_x", 0)
  local point_light_pos_y = ini:ReadFloat("light", "point_light_pos_y", 0)
  local point_light_pos_z = ini:ReadFloat("light", "point_light_pos_z", 0)
  local scene = scenebox.Scene
  if not nx_is_valid(scene) then
    local world = nx_value("world")
    scene = world:Create("Scene")
    scenebox.Scene = scene
    nx_call("scene", "support_physics", world, scene)
    local weather = scene.Weather
    weather.FogEnable = false
    weather.AmbientColor = "255," .. nx_string(ambient_red) .. "," .. nx_string(ambient_green) .. "," .. nx_string(ambient_blue)
    weather.SunGlowColor = "255," .. nx_string(sunglow_red) .. "," .. nx_string(sunglow_green) .. "," .. nx_string(sunglow_blue)
    weather.SpecularColor = "255,196,196,196"
    weather.AmbientIntensity = ambient_intensity
    weather.SunGlowIntensity = sunglow_intensity
    weather.SpecularIntensity = 2
    local sun_height_rad = sun_height / 360 * math.pi * 2
    local sun_azimuth_rad = sun_azimuth / 360 * math.pi * 2
    scenebox.sun_height_rad = sun_height_rad
    scenebox.sun_azimuth_rad = sun_azimuth_rad
    weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
    scene.BackColor = scenebox.BackColor
    scene.EnableRealizeTempRT = false
    local camera = scene:Create("Camera")
    camera.AllowControl = false
    camera.Fov = 0.10416666666666667 * math.pi * 2
    scene.camera = camera
    scene:AddObject(camera, 0)
    local light_man = scene:Create("LightManager")
    scene.light_man = light_man
    scene.light_man = light_man
    scene:AddObject(light_man, 1)
    light_man.SunLighting = true
    local light = light_man:Create()
    scene.light = light
    light.Color = "255," .. nx_string(point_light_red) .. "," .. nx_string(point_light_green) .. "," .. nx_string(point_light_blue)
    light.Range = point_light_range
    light.Intensity = point_light_intensity
    light.Attenu0 = 0
    light.Attenu1 = 1
    light.Attenu2 = 0
    light:SetPosition(point_light_pos_x, point_light_pos_y, point_light_pos_z)
    local radius = 1.5
    scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
    scene.camera:SetAngle(0, 0, 0)
    scene:Load()
  end
  return true
end
function create_terrain(scene, unit_size, tex_units, zone_rows, zone_cols)
  local terrain = scene:Create("Terrain")
  if unit_size == 1 then
    terrain:SetParameter(256, 32, 256, tex_units, 2, 2)
    terrain.UnitSize = 1
    terrain.LightPerUnit = 2
  else
    terrain:SetParameter(128, 16, 256, tex_units, 4, 4)
    terrain.UnitSize = 2
    terrain.LightPerUnit = 4
  end
  terrain.DesignMode = true
  terrain.InitHeight = 0
  terrain.ShowDesignLine = false
  local dev_caps = nx_value("device_caps")
  if 2 < dev_caps.MaxTextures then
    terrain.TexStage2 = false
  else
    terrain.TexStage2 = true
  end
  terrain.ZoneLightPath = "lzone"
  terrain.ModelLightPath = "lmodel"
  terrain.WalkablePath = "walk"
  terrain:AddBaseTex("base1", terrain.AppendPath .. "map\\tex\\dibiao_03")
  terrain:AddTexturePath("map\\tex\\model\\")
  local gui = nx_value("gui")
  terrain:Load()
  scene:AddObject(terrain, 20)
  scene.terrain = terrain
  nx_set_value("terrain", terrain)
  terrain:InitZones(zone_rows, zone_cols, zone_rows / 2, zone_cols / 2, 2)
  return terrain
end
function create_sky(scene)
  local sky = scene:Create("SkyBox")
  if not nx_is_valid(sky) then
    disp_error("\180\180\189\168\204\236\191\213\186\208\202\167\176\220")
    return nil
  end
  local asyncLoad = true
  sky.AsyncLoad = nx_boolean(asyncLoad)
  local yawSpeed = 0.01
  sky.YawSpeed = yawSpeed
  local mulFactor = 500
  sky.MulFactor = mulFactor
  local visible = true
  sky.Visible = nx_boolean(visible)
  sky.UpTex = "map\\tex\\sky.dds"
  sky.SideTex = "map\\tex\\sky.dds"
  return sky
end
function set_visual_radius(scene, radius)
  local far_clip = 1000
  scene.FarClipDistance = far_clip
  local weather = scene.Weather
  if nx_is_valid(weather) then
    weather.FogStart = 100
    weather.FogEnd = 200
    weather.FogLinear = true
    weather.FogColor = "255,79,112,172"
    weather.FogExpColor = "255,79,112,172"
    weather.FogHeight = 300
    weather.FogHeightExp = 1
    weather.FogExp = true
    weather.FogDensity = 0.07
    scene.BackColor = "255,79,112,172"
    weather.FogEnable = true
  end
end
function create_model_1(scenebox, modelpath, offsetY, mode_angleX, scale)
  local mode_1 = nx_execute("util_functions", "util_create_model", nx_string(modelpath) .. ".xmod", "", "", "", "", false, scenebox.Scene)
  if isuccess == false then
    return
  end
  scenebox.Scene:AddObject(mode_1, 20)
  scenebox.Scene.model_1 = mode_1
  mode_1:SetPosition(0, offsetY, 0)
  mode_1:SetAngle(mode_angleX, 0, 0)
  mode_1:SetScale(scale, scale, scale)
end
function rotate_y(mode, rotate_y)
  local angle = 0
  while nx_is_valid(mode) do
    angle = rotate_y * nx_pause(0)
    if nx_is_valid(mode) then
      mode:SetAngle(mode.AngleX, mode.AngleY + angle, mode.AngleZ)
    end
  end
end
function set_book_info(form, id)
  local gui = nx_value("gui")
  form.lbl_book_name.BackImage = book_name_image[id]
  form.mltbox_book:Clear()
  form.mltbox_book:AddHtmlText(gui.TextManager:GetText(book_desc[id]), nx_int(-1))
end
function set_book_model(form, id)
  local modelpath = book_model[id]
  if modelpath == "" or modelpath == nil then
    return
  end
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_book)
  if not nx_is_valid(form.scenebox_book.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_book)
  end
  local mode = nx_execute("util_functions", "util_create_model", nx_string(modelpath) .. ".xmod", "", "", "", "", false, form.scenebox_book.Scene)
  if not nx_is_valid(mode) then
    return
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_book, mode)
  nx_execute(nx_current(), "rotate_y", mode, math.pi / 3)
  local radius = mode.Radius
  local offsetY = 0
  local scale = 1
  local Camera_z = -radius * 3
  local mode_angleX = math.pi / 3
  if id == "ng_book_jh_507_s2" then
    scale = 2.2
    mode_angleX = 0
    offsetY = 0.35
  elseif id == "ng_book_jh_306_s2" then
    scale = 2.5
    offsetY = 1
    mode_angleX = -math.pi / 2 + math.pi / 4
  end
  mode:SetAngle(mode_angleX, 0, 0)
  mode:SetPosition(0, offsetY, 0)
  mode:SetScale(scale, scale, scale)
end
function set_weapon_model(form, id, item_type)
  local modelpath = get_weaponmode_path_by_name(id, "MaleModel")
  if modelpath == "" or modelpath == nil then
    return
  end
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_weapon)
  if not nx_is_valid(form.scenebox_weapon.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_weapon)
  end
  local mode
  if item_type == ITEMTYPE_WEAPON_BOW then
    local id_len = nx_number(string.len(nx_string(id)))
    local path_len = nx_number(string.len(nx_string(modelpath)))
    if nx_number(path_len) > nx_number(id_len) and string.sub(nx_string(modelpath), path_len - id_len + 1) == nx_string(id) then
      modelpath = string.sub(nx_string(modelpath), 1, path_len - id_len)
    end
    local role_composite = nx_value("role_composite")
    if not nx_is_valid(role_composite) then
      return false
    end
    mode = create_actor2(form.scenebox_weapon.Scene)
    mode.AsyncLoad = true
    mode.scene = form.scenebox_weapon.Scene
    local ok = role_composite:CreateSceneObjectFromIni(mode, modelpath .. "\\composite.ini")
    while true do
      if not nx_is_valid(mode) or mode.LoadFinish then
        break
      end
      nx_pause(0.1)
    end
    if not ok or not nx_is_valid(mode) then
      form.scenebox_weapon.Scene:Delete(mode)
      return false
    end
  else
    mode = nx_execute("util_functions", "util_create_model", nx_string(modelpath) .. ".xmod", "", "", "", "", false, form.scenebox_weapon.Scene)
  end
  if not nx_is_valid(mode) then
    return
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_weapon, mode)
  local radius = mode.Radius
  local offsetY = 0
  local scale = 1
  local Camera_z = -radius * 3
  local mode_angleX = math.pi / 3
  if item_type == ITEMTYPE_WEAPON_BLADE then
    offsetY = offsetY - 0.2
    Camera_z = Camera_z + 0.4
    mode_angleX = -mode_angleX
    scale = 0.86
  elseif item_type == ITEMTYPE_WEAPON_COSH then
    offsetY = offsetY - 0.65
    Camera_z = Camera_z + 0.4
  elseif item_type == ITEMTYPE_WEAPON_STUFF then
    offsetY = offsetY - 0.9
    Camera_z = Camera_z + 0.4
  elseif item_type == ITEMTYPE_WEAPON_SWORD then
    offsetY = offsetY - 0.1
    mode_angleX = -mode_angleX
    if id == "sword_ytj_001" then
      scale = 1.5
    end
  elseif item_type == ITEMTYPE_WEAPON_THORN then
    offsetY = offsetY - 0.15
    Camera_z = Camera_z + 0.3
    scale = 0.86
  elseif item_type == ITEMTYPE_WEAPON_STHORN then
    offsetY = offsetY - 0.35
    Camera_z = Camera_z + 0.3
    create_model_1(form.scenebox_weapon, modelpath, offsetY, mode_angleX * 2, scale)
  elseif item_type >= ITEMTYPE_WEAPON_HIDDEN and item_type <= ITEMTYPE_WEAPON_ARROR then
    offsetY = offsetY - 0.15
  elseif item_type == ITEMTYPE_WEAPON_SSWORD then
    offsetY = offsetY - 0.9
    create_model_1(form.scenebox_weapon, modelpath, offsetY, mode_angleX * 2, scale)
  elseif item_type == ITEMTYPE_WEAPON_SBLADE then
    offsetY = offsetY - 0.8
    create_model_1(form.scenebox_weapon, modelpath, offsetY, mode_angleX * 2, scale)
  elseif item_type == ITEMTYPE_WEAPON_BOW then
    offsetY = offsetY - 0.02
    Camera_z = Camera_z - 0.6
    scale = 0.21
  end
  mode:SetAngle(mode_angleX, 0, 0)
  mode:SetPosition(0, offsetY, 0)
  mode:SetScale(scale, scale, scale)
  form.scenebox_weapon.Scene.BackColor = "0,0,0,0"
  form.scenebox_weapon.Scene.camera.Fov = 0.125 * math.pi * 2
  form.scenebox_weapon.Scene.camera:SetPosition(0, -radius * 2 / 2.5, Camera_z)
  nx_execute(nx_current(), "rotate_y", mode, math.pi / 2)
  if nx_find_custom(form.scenebox_weapon.Scene, nx_string("model_1")) then
    nx_execute(nx_current(), "rotate_y", form.scenebox_weapon.Scene.model_1, math.pi / 2)
  end
end
function set_weapon_info(form, id, item_type)
  form.lbl_weapon_name.BackImage = weapon_name_image[id]
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  local item = tips_manager:GetArrayList()
  if not nx_is_valid(item) then
    return
  end
  nx_function("ext_clear_custom_list", item)
  item.is_translate = true
  item.is_static = true
  item.ConfigID = id
  item.ItemType = item_type
  local text = tips_manager:GetWeaponSpecialInfo(id, item, nx_int(item_type))
  form.mltbox_weapon:Clear()
  form.mltbox_weapon:AddHtmlText(text, nx_int(-1))
  form.lbl_line_1.Top = form.mltbox_weapon.Height + form.mltbox_weapon.Top
  form.mltbox_weapon_desc.Top = form.lbl_line_1.Height + form.lbl_line_1.Top
  form.mltbox_weapon_desc:Clear()
  form.mltbox_weapon_desc:AddHtmlText(gui.TextManager:GetText("desc1_" .. nx_string(id)), nx_int(-1))
  form.lbl_line_2.Top = form.mltbox_weapon_desc.Height + form.mltbox_weapon_desc.Top
  form.mltbox_weapon_get_method.Top = form.lbl_line_2.Height + form.lbl_line_2.Top
  form.mltbox_weapon_get_method:Clear()
  form.mltbox_weapon_get_method:AddHtmlText(gui.TextManager:GetText(weapon_get_desc[weapon_type[form.show_weapon_index]]), nx_int(-1))
  form.groupbox_weapon_prop.Height = 80 + form.mltbox_weapon.Height + form.lbl_line_1.Height * 2 + form.mltbox_weapon_desc.Height + form.mltbox_weapon_get_method.Height + 100
end
function set_weapon_owner_info(form, school_leader, is_enabled)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if is_enabled == nil then
    if nx_ws_equal(school_leader, nx_widestr("")) then
      form.lbl_weapon_owner.Text = gui.TextManager:GetText("ui_huashanlunjian_no")
      form.btn_look_weapon_owner_info.Enabled = false
    else
      form.lbl_weapon_owner.Text = school_leader
      form.btn_look_weapon_owner_info.Enabled = true
      form.btn_look_weapon_owner_info.id = school_leader
    end
  else
    form.lbl_weapon_owner.Text = school_leader
    form.btn_look_weapon_owner_info.Enabled = is_enabled
    if is_enabled then
      form.btn_look_weapon_owner_info.id = school_leader
    end
  end
end
function set_origin_owner_info(form, origin_owner)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  if nx_ws_equal(origin_owner, nx_widestr("")) then
    form.lbl_origin_owner.Text = gui.TextManager:GetText("ui_huashanlunjian_no")
    form.btn_look_origin_owner_info.Enabled = false
  else
    form.lbl_origin_owner.Text = origin_owner
    form.btn_look_origin_owner_info.Enabled = true
    form.btn_look_origin_owner_info.id = origin_owner
  end
end
function set_origin_info_self(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sex = nx_number(client_player:QueryProp("Sex"))
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if not nx_find_custom(form, "scenebox_origin_ower") or not nx_is_valid(form.scenebox_origin_ower) then
    return
  end
  if not nx_is_valid(form.scenebox_origin_ower.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_origin_ower)
  end
  local old_actor2
  if nx_find_custom(form.scenebox_origin_ower, "origin_owenr_roles_actor2") then
    old_actor2 = form.scenebox_origin_ower.origin_owenr_roles_actor2
    form.scenebox_origin_ower.first_show_origin = false
  end
  if old_actor2 ~= nil and nx_is_valid(old_actor2) then
    form.scenebox_origin_ower.Scene:Delete(old_actor2)
  elseif not form.scenebox_origin_ower.first_show_origin then
    while not nx_is_valid(old_actor2) do
      nx_pause(0.1)
    end
    if not nx_is_valid(form) or not nx_is_valid(form.scenebox_origin_ower) then
      return
    end
    form.scenebox_origin_ower.Scene:Delete(old_actor2)
  end
  local actor2 = create_role_composite(form.scenebox_origin_ower.Scene, false, client_player:QueryProp("Sex"))
  if nx_is_valid(game_visual) then
    game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  end
  form.scenebox_origin_ower.origin_owenr_roles_actor2 = actor2
  while nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(actor2) then
    return
  end
  local face_actor2 = get_role_face(actor2)
  while nx_is_valid(actor2) and not nx_is_valid(face_actor2) do
    nx_pause(0.1)
    if not nx_is_valid(actor2) then
      return
    end
    face_actor2 = get_role_face(actor2)
  end
  if not nx_is_valid(face_actor2) then
    return false
  end
  while nx_is_valid(face_actor2) and not face_actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not (nx_is_valid(form) and nx_find_custom(form, "scenebox_origin_ower")) or not nx_is_valid(form.scenebox_origin_ower) then
    del_actor(actor2)
    return
  end
  if arg[1] == 1 then
    role_composite:CreateRideBase(actor2, "npc\\ride_hawk_0201")
  end
  if nx_find_custom(form, "btn_get_origin") and nx_find_custom(form.btn_get_origin, "id") then
    local origin_id = nx_string(form.btn_get_origin.id)
    local mode_path = ""
    if sex == 0 then
      mode_path = origin_clothes_male_model[origin_id]
    else
      mode_path = origin_clothes_famale_model[origin_id]
    end
    if mode_path ~= "" and mode_path ~= nil then
      nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
      nx_execute("role_composite", "unlink_skin", actor2, "Hat")
      nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
      nx_execute("role_composite", "unlink_skin", actor2, "Pants")
      nx_execute("role_composite", "unlink_skin", actor2, "Cloth_h")
      nx_execute("role_composite", "link_skin", actor2, "Cloth", mode_path .. ".xmod")
      nx_execute("role_composite", "link_skin", actor2, "Cloth_h", mode_path .. "_h" .. ".xmod")
    end
  end
  if arg[1] == 1 then
    while nx_is_valid(actor2) and not role_composite:GetPlayerMountLoadFinish(actor2) do
      if not (nx_is_valid(form) and nx_find_custom(form, "scenebox_origin_ower") and nx_is_valid(form.scenebox_origin_ower) and nx_find_custom(form.scenebox_origin_ower, "origin_owenr_roles_actor2")) or not nx_id_equal(actor2, form.scenebox_origin_ower.origin_owenr_roles_actor2) then
        return
      end
      nx_pause(0.1)
    end
    if not nx_is_valid(actor2) then
      return
    end
  end
  if arg[1] == 1 then
    doPossAction(actor2, "hawk_stand")
  end
  if not nx_is_valid(form) then
    return
  end
  nx_function("ext_set_model_single_color", actor2, "0.05,0.05,0.05")
  nx_function("ext_set_model_around_color", actor2, "0.69,0.825,0.996", "0.005")
  set_origin_owner_info(form, nx_widestr(""))
  util_add_model_to_scenebox(form.scenebox_origin_ower, actor2)
  if nx_is_valid(form.scenebox_origin_ower.Scene) then
    local camera = form.scenebox_origin_ower.Scene.camera
    if nx_is_valid(camera) then
      actor2.t_time = 5
      actor2.s_time = 0
      local x = 0
      local y = 1.2
      local z = -3.357
      local angle_y = 8
      if arg[1] == 1 then
        actor2:SetPosition(0, -2.2, 2)
        actor2:SetScale(0.7, 0.7, 0.7)
      else
        actor2:SetPosition(0, -0.2, 0)
      end
      local asynor = nx_value("common_execute")
      asynor:AddExecute("MoveCamera", camera, nx_float(0), actor2, nx_float(camera.PositionX), nx_float(camera.PositionY), nx_float(camera.PositionZ), nx_float(camera.AngleX), nx_float(x), nx_float(y), nx_float(z), nx_float(get_pi(angle_y)))
    end
  end
end
function set_origin_info_self_special(scenebox, custom_name, pos_x, pos_y, pos_z, action_name, role_info)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if not nx_is_valid(scenebox.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scenebox)
  end
  local old_actor2
  if nx_find_custom(scenebox, custom_name) then
    old_actor2 = nx_custom(scenebox, custom_name)
  end
  if old_actor2 ~= nil and nx_is_valid(old_actor2) then
    scenebox.Scene:Delete(old_actor2)
  end
  local use_role_info = false
  local sex, offset, face, modify_face
  if role_info ~= nil and role_info ~= nx_widestr("") then
    local role_info_table = nx_function("ext_split_string", nx_string(role_info), ",")
    sex = nx_number(role_info_table[1])
    offset = 0
    face, offset = get_face(role_info_table)
    if table.getn(role_info_table) >= 36 + offset then
      modify_face = role_info_table[36 + offset]
    else
      modify_face = ""
    end
    use_role_info = true
  else
    sex = nx_number(client_player:QueryProp("Sex"))
  end
  local actor2
  if use_role_info then
    actor2 = create_role_composite(scenebox.Scene, false, sex)
  else
    actor2 = create_role_composite(scenebox.Scene, false, client_player:QueryProp("Sex"))
  end
  nx_set_custom(scenebox, custom_name, actor2)
  while nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(actor2) then
    return
  end
  local face_actor2 = get_role_face(actor2)
  while nx_is_valid(actor2) and not nx_is_valid(face_actor2) do
    nx_pause(0.1)
    if not nx_is_valid(actor2) then
      return
    end
    face_actor2 = get_role_face(actor2)
  end
  if not nx_is_valid(face_actor2) then
    return false
  end
  while nx_is_valid(face_actor2) and not face_actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(scenebox) then
    return
  end
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    del_actor(actor2)
    return false
  end
  local actor2_face = game_visual:QueryActFace(actor2)
  if not nx_is_valid(actor2_face) then
    actor2_face = actor_role:GetLinkObject("actor_role_face")
  end
  actor2.modify_face = modify_face
  local role_face = ""
  if use_role_info then
    role_face = face
  elseif client_player:FindProp("Face") then
    role_face = client_player:QueryProp("Face")
  end
  set_player_face_ex(actor2_face, role_face, sex, actor2)
  local origin_id = nx_string(form.btn_get_origin.id)
  local mode_path = ""
  if sex == 0 then
    mode_path = origin_clothes_male_model[origin_id]
  else
    mode_path = origin_clothes_famale_model[origin_id]
  end
  if mode_path ~= "" and mode_path ~= nil then
    nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
    nx_execute("role_composite", "unlink_skin", actor2, "Hat")
    nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
    nx_execute("role_composite", "unlink_skin", actor2, "Pants")
    nx_execute("role_composite", "unlink_skin", actor2, "Cloth_h")
    nx_execute("role_composite", "link_skin", actor2, "Cloth", mode_path .. ".xmod")
    nx_execute("role_composite", "link_skin", actor2, "Cloth_h", mode_path .. "_h" .. ".xmod")
  end
  if not use_role_info then
    nx_function("ext_set_model_single_color", actor2, "0.05,0.05,0.05")
    nx_function("ext_set_model_around_color", actor2, "0.69,0.825,0.996", "0.005")
  end
  doPossAction(actor2, action_name)
  util_add_model_to_scenebox(scenebox, actor2)
  actor2:SetPosition(pos_x, pos_y, pos_z)
  local radius = 2
  scenebox.Scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
end
function set_origin_info(type, ...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local name = nx_widestr("")
  local role_info = ""
  local show_mount = false
  if type == SHOW_WUJUE then
    form.scenebox_origin_ower = form.scenebox_origin_wujue_ower
    if table.getn(arg) ~= 4 then
      set_origin_info_self()
      return
    end
    name = nx_widestr(arg[2])
    role_info = nx_string(arg[3])
    local title_id = nx_string(arg[4])
    if title_id ~= nx_string(form.btn_get_origin.id) then
      return
    end
  elseif type == SHOW_WUDU then
    form.scenebox_origin_ower = form.scenebox_origin_wudu_ower
    if table.getn(arg) ~= 5 then
      set_origin_info_self()
      return
    end
    local rank_name = arg[3]
    name = arg[4]
    role_info = arg[5]
    if rank_name ~= nx_string(origin_wudu_rank_name[form.btn_get_origin.id]) then
      return
    end
    if role_info == nx_widestr("") then
      set_origin_info_self()
      set_origin_owner_info(form, name)
      return
    end
  elseif type == SHOW_WS then
    form.scenebox_origin_ower = form.scenebox_origin_ws_ower
    show_mount = true
    local rank_name = arg[3]
    if nx_string(form.btn_get_origin.id) == "99999" then
      local rank_string = nx_function("ext_split_string", nx_string(rank_name), ",")
      local star_pos = get_ini_key_data("ini\\advanced_weapon_and_origin.ini", "star_pos", rank_string[2], "string")
      local star_pos_list = nx_function("ext_split_string", nx_string(star_pos), ",")
      local star_action = get_ini_key_data("ini\\advanced_weapon_and_origin.ini", "star_action", rank_string[2], "string")
      if table.getn(arg) ~= 5 or arg[5] == nx_widestr("") then
        nx_execute(nx_current(), "set_origin_info_self_special", form.scenebox_origin_ws_ower_special, "rank_role_" .. nx_string(rank_string[2]), nx_number(star_pos_list[1]), nx_number(star_pos_list[2]), nx_number(star_pos_list[3]), star_action)
        local lable_name = form.groupbox_3:Find("lbl_star_" .. nx_string(rank_string[2]))
        if nx_is_valid(lable_name) then
          lable_name.Visible = false
        end
        return
      else
        nx_execute(nx_current(), "set_origin_info_self_special", form.scenebox_origin_ws_ower_special, "rank_role_" .. nx_string(rank_string[2]), nx_number(star_pos_list[1]), nx_number(star_pos_list[2]), nx_number(star_pos_list[3]), star_action, arg[5])
        local lable_name = form.groupbox_3:Find("lbl_star_" .. nx_string(rank_string[2]))
        if nx_is_valid(lable_name) then
          lable_name.Visible = true
          lable_name.Text = nx_widestr(arg[4])
        end
      end
    else
      if table.getn(arg) ~= 5 then
        set_origin_info_self(1)
        return
      end
      name = arg[4]
      role_info = arg[5]
      if role_info == nx_widestr("") then
        set_origin_info_self(1)
        set_origin_owner_info(form, name)
        return
      end
    end
  end
  if role_info == "" or role_info == nil then
    return
  end
  local role_info_table = nx_function("ext_split_string", nx_string(role_info), ",")
  form.sex = nx_number(role_info_table[1])
  local offset = 0
  form.face, offset = get_face(role_info_table)
  form.show_equip_type = role_info_table[7 + offset]
  form.hat = role_info_table[8 + offset]
  form.mask = role_info_table[9 + offset]
  form.cloth = role_info_table[10 + offset]
  form.pants = role_info_table[11 + offset]
  form.shoes = role_info_table[12 + offset]
  form.weapon = role_info_table[13 + offset]
  form.mantle = role_info_table[14 + offset]
  form.hateffect = role_info_table[15 + offset]
  form.maskeffect = role_info_table[16 + offset]
  form.clotheffect = role_info_table[17 + offset]
  form.pantseffect = role_info_table[18 + offset]
  form.shoeseffect = role_info_table[19 + offset]
  form.weaponeffect = role_info_table[20 + offset]
  form.mantleeffect = role_info_table[21 + offset]
  form.action_set = role_info_table[22 + offset]
  if table.getn(role_info_table) >= 36 + offset then
    form.modify_face = role_info_table[36 + offset]
  else
    form.modify_face = ""
  end
  show_role_model(form, show_mount)
  set_origin_owner_info(form, name)
end
function show_role_model(form, show_mount)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local world = nx_value("world")
  if not nx_find_custom(form, "scenebox_origin_ower") or not nx_is_valid(form.scenebox_origin_ower) then
    return
  end
  nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_origin_ower)
  local scene = form.scenebox_origin_ower.Scene
  if not nx_is_valid(scene) then
    return false
  end
  local old_actor2
  if nx_find_custom(form.scenebox_origin_ower, "origin_owenr_roles_actor2") then
    old_actor2 = form.scenebox_origin_ower.origin_owenr_roles_actor2
    form.scenebox_origin_ower.first_show_origin = false
  end
  if old_actor2 ~= nil and nx_is_valid(old_actor2) then
    form.scenebox_origin_ower.Scene:Delete(old_actor2)
  elseif not form.scenebox_origin_ower.first_show_origin then
    while not nx_is_valid(old_actor2) do
      nx_pause(0.1)
    end
    scene:Delete(old_actor2)
  end
  if show_mount then
    local old_ride_actor2
    if nx_find_custom(form.scenebox_origin_ower, "origin_owenr_roles_ride_actor2") then
      old_ride_actor2 = form.scenebox_origin_ower.origin_owenr_roles_ride_actor2
      form.scenebox_origin_ower.first_show_origin_ride = false
    end
    if old_ride_actor2 ~= nil and nx_is_valid(old_ride_actor2) then
      form.scenebox_origin_ower.Scene:Delete(old_ride_actor2)
    elseif not form.scenebox_origin_ower.first_show_origin_ride then
      while not nx_is_valid(old_ride_actor2) do
        nx_pause(0.1)
      end
      scene:Delete(old_ride_actor2)
    end
  end
  local actor2 = create_role_composite(scene, false, form.sex)
  form.role_actor2 = actor2
  if not nx_is_valid(actor2) then
    return false
  end
  actor2.Name = "origin_owenr_roles_actor2"
  form.scenebox_origin_ower.origin_owenr_roles_actor2 = actor2
  while nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(actor2) then
    return
  end
  local face_actor2 = get_role_face(actor2)
  while nx_is_valid(actor2) and not nx_is_valid(face_actor2) do
    nx_pause(0.1)
    if not nx_is_valid(actor2) then
      return
    end
    face_actor2 = get_role_face(actor2)
  end
  if not nx_is_valid(face_actor2) then
    return false
  end
  while nx_is_valid(face_actor2) and not face_actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(form) then
    return false
  end
  local ride_actor2
  if show_mount then
    ride_actor2 = create_actor2(scene)
    local result = role_composite:CreateSceneObjectFromIni(ride_actor2, "ini\\npc\\ride_hawk_0201.ini")
    while nx_is_valid(ride_actor2) and not role_composite:GetNpcLoadFinish(ride_actor2) do
      nx_pause(0.1)
    end
    if not nx_is_valid(form) then
      return false
    end
    ride_actor2:LinkToPoint("actor_role", "mount::Point01", actor2)
    form.scenebox_origin_ower.origin_owenr_roles_ride_actor2 = ride_actor2
  end
  if nx_find_custom(form, "btn_get_origin") and nx_find_custom(form.btn_get_origin, "id") then
    local origin_id = nx_string(form.btn_get_origin.id)
    local mode_path = ""
    if form.sex == 0 then
      mode_path = origin_clothes_male_model[origin_id]
    else
      mode_path = origin_clothes_famale_model[origin_id]
    end
    if mode_path ~= "" and mode_path ~= nil then
      nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
      nx_execute("role_composite", "unlink_skin", actor2, "Hat")
      nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
      nx_execute("role_composite", "unlink_skin", actor2, "Pants")
      nx_execute("role_composite", "unlink_skin", actor2, "Cloth_h")
      nx_execute("role_composite", "link_skin", actor2, "Cloth", mode_path .. ".xmod")
      nx_execute("role_composite", "link_skin", actor2, "Cloth_h", mode_path .. "_h" .. ".xmod")
    end
  end
  if form.action_set ~= nil and form.action_set ~= "" then
    game_visual:SetRoleActionSet(actor2, form.action_set)
  end
  if show_mount then
    doPossAction(actor2, "hawk_stand")
    doPossAction(ride_actor2, "hawk_stand")
    actor2 = ride_actor2
  else
    doPossAction(actor2, "logoin_stand")
  end
  if form.weapon ~= "" then
    actor2.weapon_name = form.weapon
    refresh_weapon_position(actor2)
  end
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    del_actor(actor2)
    return false
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  actor2.modify_face = form.modify_face
  set_player_face_ex(actor2_face, form.face, form.sex, actor2)
  if not nx_is_valid(actor_role) then
    del_actor(actor2)
    return false
  end
  if not (nx_is_valid(form) and nx_find_custom(form, "scenebox_origin_ower")) or not nx_is_valid(form.scenebox_origin_ower) then
    del_actor(actor2)
    return false
  end
  if nx_is_valid(form.scenebox_origin_ower.Scene) then
    util_add_model_to_scenebox(form.scenebox_origin_ower, actor2)
    local camera = form.scenebox_origin_ower.Scene.camera
    if nx_is_valid(camera) then
      actor2.t_time = 5
      actor2.s_time = 0
      local x = 0
      local y = 1.2
      local z = -3.357
      local angle_y = 8
      if show_mount then
        actor2:SetPosition(0, -2.2, 2)
        actor2:SetScale(0.7, 0.7, 0.7)
      else
        actor2:SetPosition(0, -0.2, 0)
      end
      local asynor = nx_value("common_execute")
      asynor:AddExecute("MoveCamera", camera, nx_float(0), actor2, nx_float(camera.PositionX), nx_float(camera.PositionY), nx_float(camera.PositionZ), nx_float(camera.AngleX), nx_float(x), nx_float(y), nx_float(z), nx_float(get_pi(angle_y)))
      player_face_random_action(form)
    end
  end
  return true
end
function player_face_random_action(form)
  local asynor = nx_value("common_execute")
  if not nx_is_valid(form) or not nx_find_custom(form, "role_actor2") then
    return nil
  end
  if not nx_is_valid(form.role_actor2) then
    return nil
  end
  local role_actor2 = form.role_actor2
  role_actor2.random_eyes_time = math.random(2) + 4
  asynor:AddExecute("FaceRandomAction", role_actor2, nx_float(0))
end
function del_actor(actor2)
  local world = nx_value("world")
  if nx_is_valid(world) and nx_is_valid(actor2) then
    world:Delete(actor2)
  end
end
function get_pi(degree)
  return math.pi * degree / 180
end
function doPossAction(actor2, aciton)
  local action_module = nx_value("action_module")
  if nx_is_valid(action_module) and nx_is_valid(actor2) then
    actor2.cur_action = aciton
    local isExists = action_module:ActionExists(actor2, nx_string(aciton))
    if isExists then
      local is_in_list = action_module:ActionBlended(actor2, nx_string(aciton))
      if not is_in_list then
        action_module:BlendAction(actor2, nx_string(aciton), true, true)
      end
    end
  end
end
function get_role_face(role_actor2)
  if not nx_is_valid(role_actor2) then
    return nil
  end
  local actor_role = role_actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  return actor2_face
end
function get_face(role_info_table)
  local face = role_info_table[6]
  local count = table.getn(role_info_table)
  local offset = 0
  for i = 7, count do
    if string.len(face) > 46 or string.len(face) == 46 then
      return face, offset
    end
    face = face .. string.char(44) .. role_info_table[i]
    offset = offset + 1
  end
  return face, offset
end
function refresh_switch_control(form)
  local control_list = form.groupbox_weapon:GetChildControlList()
  for i = 1, table.getn(control_list) do
    local control = control_list[i]
    control.Visible = false
  end
  form.groupbox_weapon_prop.Visible = false
  form.scenebox_weapon.Visible = false
  if not nx_find_custom(form, "show_weapon_index") then
    return
  end
  if table.getn(weapon_type) == 0 then
    return
  end
  local str = weapon_type[form.show_weapon_index]
  if str == nil then
    return
  end
  local groupbox = form.groupbox_weapon:Find("groupbox_" .. nx_string(str))
  if nx_is_valid(groupbox) then
    groupbox.Visible = true
    form.weapon_show_groupbox = groupbox
    local rbtn_list = groupbox:GetChildControlList()
    for i = 1, table.getn(rbtn_list) do
      local control = rbtn_list[i]
      if nx_is_kind(control, "RadioButton") and control.Checked then
        if str == "zpsb" then
          on_rbtn_zpsb_checked_changed(control)
        elseif str == "hslj" then
          on_rbtn_hslj_checked_changed(control)
        end
      end
    end
  end
  form.lbl_title.BackImage = "gui\\language\\ChineseS\\yulan\\" .. str .. "_down.png"
  if form.show_weapon_index + 1 > table.getn(weapon_type) then
    form.btn_right.Visible = false
  else
    local str_1 = weapon_type[form.show_weapon_index + 1]
    form.btn_right.Visible = true
    form.btn_right.NormalImage = "gui\\language\\ChineseS\\yulan\\" .. str_1 .. "_out.png"
    form.btn_right.PushImage = "gui\\language\\ChineseS\\yulan\\" .. str_1 .. "_on.png"
  end
  if form.show_weapon_index - 1 > 0 then
    local str_1 = weapon_type[form.show_weapon_index - 1]
    form.btn_left.Visible = true
    form.btn_left.NormalImage = "gui\\language\\ChineseS\\yulan\\" .. str_1 .. "_out.png"
    form.btn_left.PushImage = "gui\\language\\ChineseS\\yulan\\" .. str_1 .. "_on.png"
  else
    form.btn_left.Visible = false
  end
  local lbl_list = form.groupbox_mark:GetChildControlList()
  for i = 1, table.getn(lbl_list) do
    local control = lbl_list[i]
    control.BackImage = "gui\\special\\yulan\\point_2.png"
  end
  local lbl_mark = form.groupbox_mark:Find("lbl_weapon_mark_" .. nx_string(form.show_weapon_index))
  if nx_is_valid(lbl_mark) then
    lbl_mark.BackImage = "gui\\special\\yulan\\point_1.png"
  end
  refresh_scroll(0)
  if weapon_type[form.show_weapon_index] == "hslj" then
    form.btn_get_ytj.Visible = false
    form.lbl_get_ytj.Visible = false
    nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_GetNoOne)
  else
    form.btn_get_ytj.Visible = false
    form.lbl_get_ytj.Visible = false
  end
end
function refresh_origin_switch_control(form)
  local control_list = form.groupbox_origin:GetChildControlList()
  for i = 1, table.getn(control_list) do
    local control = control_list[i]
    control.Visible = false
  end
  if not nx_find_custom(form, "show_origin_index") then
    return
  end
  if table.getn(origin_type) == 0 then
    return
  end
  local str = origin_type[form.show_origin_index]
  if str == nil then
    return
  end
  local groupbox = form.groupbox_origin:Find("groupbox_" .. nx_string(str))
  if nx_is_valid(groupbox) then
    groupbox.Visible = true
    local rbtn_list = groupbox:GetChildControlList()
    for i = 1, table.getn(rbtn_list) do
      local control = rbtn_list[i]
      if nx_is_kind(control, "RadioButton") and control.Checked then
        if str == "wujue" then
          form.btn_get_origin.Visible = true
          form.btn_show_wudu_origin_help.Visible = false
          form.lbl_11.Visible = true
          on_rbtn_origin_wujue_checked_changed(control)
          form.btn_rank.Visible = false
          form.btn_tanti.Visible = false
        elseif str == "wudu" then
          form.btn_get_origin.Visible = false
          form.btn_show_wudu_origin_help.Visible = true
          form.lbl_11.Visible = false
          on_rbtn_origin_wudu_checked_changed(control)
          form.btn_rank.Visible = false
          form.btn_tanti.Visible = false
        elseif str == "ws" then
          form.btn_get_origin.Visible = false
          form.btn_show_wudu_origin_help.Visible = false
          form.lbl_11.Visible = false
          on_rbtn_origin_ws_checked_changed(control)
          form.btn_rank.Visible = true
          form.btn_tanti.Visible = true
        end
      end
    end
  end
  form.lbl_origin_1.BackImage = "gui\\language\\ChineseS\\yulan\\" .. str .. "_down.png"
  if form.show_origin_index + 1 > table.getn(origin_type) then
    form.btn_origin_right.Visible = false
  else
    local str_1 = origin_type[form.show_origin_index + 1]
    form.btn_origin_right.Visible = true
    form.btn_origin_right.NormalImage = "gui\\language\\ChineseS\\yulan\\" .. str_1 .. "_out.png"
    form.btn_origin_right.PushImage = "gui\\language\\ChineseS\\yulan\\" .. str_1 .. "_on.png"
  end
  if form.show_origin_index - 1 > 0 then
    local str_1 = origin_type[form.show_origin_index - 1]
    form.btn_origin_left.Visible = true
    form.btn_origin_left.NormalImage = "gui\\language\\ChineseS\\yulan\\" .. str_1 .. "_out.png"
    form.btn_origin_left.PushImage = "gui\\language\\ChineseS\\yulan\\" .. str_1 .. "_on.png"
  else
    form.btn_origin_left.Visible = false
  end
  local lbl_list = form.groupbox_origin_mark:GetChildControlList()
  for i = 1, table.getn(lbl_list) do
    local control = lbl_list[i]
    control.BackImage = "gui\\special\\yulan\\point_2.png"
  end
  local lbl_mark = form.groupbox_origin_mark:Find("lbl_origin_mark_" .. nx_string(form.show_origin_index))
  if nx_is_valid(lbl_mark) then
    lbl_mark.BackImage = "gui\\special\\yulan\\point_1.png"
  end
end
function open_weapon()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_weapon.Checked = true
end
function open_origin()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_origin.Checked = true
end
function show_origin()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_advanced_weapon_and_origin", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.rbtn_origin.Checked = true
end
function show_ytj()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_advanced_weapon_and_origin", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.rbtn_weapon.Checked = true
  if table.getn(weapon_type) == 0 then
    return
  end
  local is_find = false
  for i = 1, table.getn(weapon_type) do
    if weapon_type[i] == "hslj" then
      form.show_weapon_index = i
      is_find = true
    end
  end
  refresh_switch_control(form)
end
function show_wuxuege()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_advanced_weapon_and_origin", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.rbtn_wuxuege.Checked = true
end
function show_ws()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_advanced_weapon_and_origin", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.rbtn_origin.Checked = true
  if table.getn(origin_type) == 0 then
    return
  end
  local is_find = false
  for i = 1, table.getn(origin_type) do
    if origin_type[i] == "ws" then
      form.show_origin_index = i
      is_find = true
    end
  end
  refresh_origin_switch_control(form)
end
function on_btn_get_ytj_click(btn)
  nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_ReqToSwordPos)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function set_ytj_ower_info(...)
  if table.getn(arg) ~= 3 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not form.rbtn_weapon.Checked then
    return
  end
  if not nx_find_custom(form, "show_weapon_index") then
    return
  end
  if weapon_type[form.show_weapon_index] ~= "hslj" then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local name = client_player:QueryProp("Name")
  if nx_ws_equal(name, nx_widestr(arg[2])) then
    if nx_number(arg[3]) == 1 then
      form.btn_get_ytj.Visible = false
      form.lbl_get_ytj.Visible = false
    else
      form.btn_get_ytj.Visible = true
      form.lbl_get_ytj.Visible = true
    end
  else
    form.btn_get_ytj.Visible = false
    form.lbl_get_ytj.Visible = false
  end
  if gui.TextManager:IsIDName(nx_string(arg[2])) or nx_ws_equal(nx_widestr(arg[2]), nx_widestr("")) then
    set_weapon_owner_info(form, gui.TextManager:GetText("ui_vacancy"), false)
  else
    set_weapon_owner_info(form, nx_widestr(arg[2]), true)
  end
end
function on_server_star_show(...)
  if table.getn(arg) < 3 then
    return
  end
  local is_wudu = false
  local ini = nx_execute("util_functions", "get_ini", "ini\\advanced_weapon_and_origin.ini")
  if nx_is_valid(ini) then
    local wudu_sec_index = ini:FindSectionIndex("wudu")
    if wudu_sec_index < 0 then
      return
    end
    for i = 1, ini:GetSectionItemCount(wudu_sec_index) do
      local origin_id = ini:ReadString(wudu_sec_index, nx_string(i), "")
      if origin_wudu_rank_name[origin_id] == arg[3] then
        is_wudu = true
        break
      end
    end
  end
  if is_wudu then
    nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "set_origin_info", SHOW_WUDU, unpack(arg))
  else
    nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "set_origin_info", SHOW_WS, unpack(arg))
  end
end
function on_server_msg(...)
  if table.getn(arg) < 1 then
    return
  end
  if arg[1] == HuaShanSToC_ChooseTitle then
    local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_HUASHAN_SHOW_FORM, "noplayer", -1)
    if 0 < index then
      nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", index, 1)
    end
  elseif arg[1] == HuaShanSToC_AskGetSword then
    local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_HUASHAN_SHOW_FORM, "noplayer", -1)
    if 0 < index then
      nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", index, 2)
    end
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if arg[1] == HuaShanSToC_ReqBest5 then
    nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "set_origin_info", SHOW_WUJUE, unpack(arg))
  elseif arg[1] == HuaShanSToC_GetNoOne then
    nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "set_ytj_ower_info", unpack(arg))
  else
    return
  end
end
function on_btn_rotate_left_click(btn)
  btn.MouseDown = false
end
function on_btn_rotate_left_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_rotate_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) or not nx_is_valid(form.scenebox_origin_ower) then
      break
    end
    ui_RotateModel(form.scenebox_origin_ower, dist)
  end
end
function on_btn_rotate_right_click(btn)
  btn.MouseDown = false
end
function on_btn_rotate_right_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_rotate_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) or not nx_is_valid(form.scenebox_origin_ower) then
      break
    end
    ui_RotateModel(form.scenebox_origin_ower, dist)
  end
end
function on_btn_rank_click(btn)
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "open_form")
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", form, "rank_1_RevengeIntegral")
end
function on_btn_tanti_click(btn)
  nx_execute("form_stage_main\\form_general_info\\form_general_info_main", "open_form")
end
