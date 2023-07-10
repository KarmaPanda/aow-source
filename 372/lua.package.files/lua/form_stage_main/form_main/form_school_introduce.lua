require("tips_data")
require("util_functions")
require("util_static_data")
require("share\\itemtype_define")
require("share\\static_data_type")
require("share\\client_custom_define")
local FINE_NEIGONG_INI = "share\\Skill\\NeiGong\\neigong.ini"
local FILE_SKILL_INI = "share\\Skill\\skill_new.ini"
local CLOTH_MAX = 4
local TAOLU_MAX = 5
local ArtPack = {
  ArtPack = "Cloth",
  HatArtPack = "Hat",
  PlantsArtPack = "Pants",
  ShoesArtPack = "Shoes"
}
local PROP_INFO = {
  Width = 250,
  Height = 20,
  Font = "font_text_chat",
  NormalColor = "255,204,204,204",
  FocusColor = "255,255,255,255",
  PushColor = "255,0,184,255",
  BackColor = "0,0,0,0",
  LineColor = "0,0,0,0"
}
local Cover_Img = {
  "gui\\language\\ChineseS\\schoolyulan\\mu.png",
  "gui\\language\\ChineseS\\schoolyulan\\tie.png",
  "gui\\language\\ChineseS\\schoolyulan\\yin.png",
  "gui\\language\\ChineseS\\schoolyulan\\jin.png"
}
local Back_Img = {
  school_shaolin = {
    image_on = "school_title_sl",
    image_out = "school_title_sl_out",
    image_down = "school_title_sl_down"
  },
  school_wudang = {
    image_on = "school_title_wd",
    image_out = "school_title_wd_out",
    image_down = "school_title_wd_down"
  },
  school_emei = {
    image_on = "school_title_em",
    image_out = "school_title_em_out",
    image_down = "school_title_em_down"
  },
  school_gaibang = {
    image_on = "school_title_gb",
    image_out = "school_title_gb_out",
    image_down = "school_title_gb_down"
  },
  school_junzitang = {
    image_on = "school_title_jzt",
    image_out = "school_title_jzt_out",
    image_down = "school_title_jzt_down"
  },
  school_tangmen = {
    image_on = "school_title_tm",
    image_out = "school_title_tm_out",
    image_down = "school_title_tm_down"
  },
  school_jinyiwei = {
    image_on = "school_title_jyw",
    image_out = "school_title_jyw_out",
    image_down = "school_title_jyw_down"
  },
  school_jilegu = {
    image_on = "school_title_jlg",
    image_out = "school_title_jlg_out",
    image_down = "school_title_jlg_down"
  },
  school_jianghu = {
    image_on = "school_title_wmp",
    image_out = "school_title_wmp_out",
    image_down = "school_title_wmp_down"
  },
  force_xujia = {
    image_on = "school_title_xjz",
    image_out = "school_title_xjz_out",
    image_down = "school_title_xjz_down"
  },
  force_jinzhen = {
    image_on = "school_title_jzsj",
    image_out = "school_title_jzsj_out",
    image_down = "school_title_jzsj_down"
  },
  force_wanshou = {
    image_on = "school_title_wssz",
    image_out = "school_title_wssz_out",
    image_down = "school_title_wssz_down"
  },
  force_wugen = {
    image_on = "school_title_wgm",
    image_out = "school_title_wgm_out",
    image_down = "school_title_wgm_down"
  },
  force_yihua = {
    image_on = "school_title_yhg",
    image_out = "school_title_yhg_out",
    image_down = "school_title_yhg_down"
  },
  force_taohua = {
    image_on = "school_title_thd",
    image_out = "school_title_thd_out",
    image_down = "school_title_thd_down"
  },
  newschool_gumu = {
    image_on = "school_title_gumu",
    image_out = "school_title_gumu_out",
    image_down = "school_title_gumu_down"
  },
  newschool_xuedao = {
    image_on = "school_title_xuedao",
    image_out = "school_title_xuedao_out",
    image_down = "school_title_xuedao_down"
  },
  newschool_changfeng = {
    image_on = "school_title_changfeng",
    image_out = "school_title_changfeng_out",
    image_down = "school_title_changfeng_down"
  },
  newschool_nianluo = {
    image_on = "school_title_nianluo",
    image_out = "school_title_nianluo_out",
    image_down = "school_title_nianluo_down"
  },
  newschool_shenshui = {
    image_on = "school_title_shenshui",
    image_out = "school_title_shenshui_out",
    image_down = "school_title_shenshui_down"
  },
  newschool_huashan = {
    image_on = "school_title_huashan",
    image_out = "school_title_huashan_out",
    image_down = "school_title_huashan_down"
  },
  newschool_wuxian = {
    image_on = "school_title_wuxian",
    image_out = "school_title_wuxian_out",
    image_down = "school_title_wuxian_down"
  },
  newschool_damo = {
    image_on = "school_title_damo",
    image_out = "school_title_damo_out",
    image_down = "school_title_damo_down"
  },
  school_mingjiao = {
    image_on = "school_title_mj",
    image_out = "school_title_mj_out",
    image_down = "school_title_mj_down"
  },
  newschool_shenji = {
    image_on = "school_title_sj",
    image_out = "school_title_sj_out",
    image_down = "school_title_sj_down"
  },
  school_tianshan = {
    image_on = "school_title_ts",
    image_out = "school_title_ts_out",
    image_down = "school_title_ts_down"
  },
  newschool_xingmiao = {
    image_on = "school_title_xm",
    image_out = "school_title_xm_out",
    image_down = "school_title_xm_down"
  }
}
function set_node_prop(node)
  if not nx_is_valid(node) then
    return
  end
  for key, value in pairs(PROP_INFO) do
    nx_set_property(node, nx_string(key), value)
  end
end
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function show_school(school_name)
  local form = nx_value("form_stage_main\\form_main\\form_school_introduce")
  if not nx_is_valid(form) then
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_main\\form_school_introduce")
    form = nx_value("form_stage_main\\form_main\\form_school_introduce")
  end
  local groupbox = nx_null()
  local rbtn_type = nx_null()
  local rbtn_school = nx_null()
  if string.find(school_name, "school_") == 1 then
    groupbox = form.groupbox_list
    rbtn_type = form.rbtn_old
  elseif string.find(school_name, "force_") == 1 then
    groupbox = form.groupbox_news
    rbtn_type = form.rbtn_new
  elseif string.find(school_name, "newschool_") == 1 then
    groupbox = form.groupbox_news
    rbtn_type = form.rbtn_new
  end
  if not nx_is_valid(groupbox) then
    return
  end
  local ctrl_list = groupbox:GetChildControlList()
  for _, child in ipairs(ctrl_list) do
    if nx_name(child) == "RadioButton" and child.DataSource == school_name then
      rbtn_school = child
      break
    end
  end
  if not nx_is_valid(rbtn_school) then
    return
  end
  rbtn_type.Checked = true
  rbtn_school.Checked = true
end
function main_form_init(self)
end
function on_main_form_open(self)
  on_size_change()
  self.rbtn_old.Checked = true
  self.lbl_back.Visible = false
  self.lbl_ng.Visible = false
  self.cur_select_school = "school_wudang"
  self.lbl_tips_fs.Visible = 0 == load_form_ini("fs")
  self.lbl_tips_mp.Visible = 0 == load_form_ini("mp")
  self.lbl_tips_ng.Visible = 0 == load_form_ini("ng")
  self.lbl_tips_zs.Visible = 0 == load_form_ini("zs")
  local form_school_introduce = nx_value("form_school_introduce")
  if nx_is_valid(form_school_introduce) then
    nx_destroy(form_school_introduce)
  end
  form_school_introduce = nx_create("form_school_introduce")
  if nx_is_valid(form_school_introduce) then
    nx_set_value("form_school_introduce", form_school_introduce)
  end
  show(self)
end
function on_main_form_close(self)
  nx_execute("util_gui", "ui_ClearModel", self.scenebox)
  local form_school_introduce = nx_value("form_school_introduce")
  if nx_is_valid(form_school_introduce) then
    nx_destroy(form_school_introduce)
  end
  nx_destroy(self)
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  form.lbl_tips_mp.Visible = false
  save_to_ini("mp", 1)
  local lbl = get_lbl(rbtn)
  if not nx_is_valid(lbl) then
    return
  end
  if rbtn.Checked then
    form.cur_select_school = rbtn.DataSource
  end
  if not rbtn.Checked then
    lbl.BackImage = Back_Img[rbtn.DataSource].image_out
    return
  end
  lbl.BackImage = Back_Img[rbtn.DataSource].image_down
  if nx_is_valid(rbtn) then
    show(rbtn.ParentForm)
  end
end
function on_rbtn_get_capture(rbtn)
  if rbtn.Checked or not rbtn.Enabled then
    return
  end
  local lbl = get_lbl(rbtn)
  if not nx_is_valid(lbl) then
    return
  end
  lbl.BackImage = Back_Img[rbtn.DataSource].image_on
end
function on_rbtn_lost_capture(rbtn)
  if rbtn.Checked or not rbtn.Enabled then
    return
  end
  local lbl = get_lbl(rbtn)
  if not nx_is_valid(lbl) then
    return
  end
  lbl.BackImage = Back_Img[rbtn.DataSource].image_out
end
function get_lbl(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  local form = rbtn.ParentForm
  local rbtn_name = rbtn.Name
  local i, j = string.find(rbtn_name, "rbtn")
  local lbl_name = "lbl" .. string.sub(rbtn_name, j + 1)
  local lbl = nx_custom(form, lbl_name)
  return lbl
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_imagegrid_ng_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form_school_introduce = nx_value("form_school_introduce")
  if not nx_is_valid(form_school_introduce) then
    return
  end
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return
  end
  local school_id = get_cur_school_id()
  if "" == school_id then
    return
  end
  local ng_list = form_school_introduce:GetNeiGong(school_id)
  local size = table.getn(ng_list)
  if index > table.getn(ng_list) then
    return
  end
  local name = ng_list[index + 1]
  local staticdata = get_ini_prop(FINE_NEIGONG_INI, name, "StaticData", "")
  local min_varpropno = neigong_static_query(staticdata, "MinVarPropNo")
  local bufferlevel = get_ini_prop("share\\Skill\\NeiGong\\neigong_varprop.ini", nx_string(min_varpropno + 35), "BufferLevel")
  local level = 36
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(name)
  item.ItemType = ITEMTYPE_NEIGONG
  item.StaticData = nx_number(staticdata)
  item.Level = level
  item.BufferLevel = bufferlevel
  item.is_static = true
  item.WuXing = faculty_query:GetWuXing(nx_string(name))
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager.InShortcut = true
  end
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_ng_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_skill_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local name = get_skill_id(index)
  if not name then
    return
  end
  local staticdata = get_ini_prop(FILE_SKILL_INI, name, "StaticData", "")
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(name)
  item.ItemType = ITEMTYPE_ZHAOSHI
  item.StaticData = nx_number(staticdata)
  item.Level = 1
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_skill_select_changed(grid, index)
  local form = grid.ParentForm
  local name = get_skill_id(index)
  if not name then
    return
  end
  form.lbl_tips_zs.Visible = false
  save_to_ini("zs", 1)
  show_skill_action(name, form.scenebox, form.actor2)
end
function on_ImageControlGrid_cloth_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form_school_introduce = nx_value("form_school_introduce")
  if not nx_is_valid(form_school_introduce) then
    return
  end
  local cur_school = get_cur_school_id()
  local cloth_list = form_school_introduce:GetCloth(cur_school)
  if index >= table.getn(cloth_list) / 2 then
    return
  end
  local cloth = cloth_list[2 * (index + 1)]
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(cloth)
  item.ItemType = ITEMTYPE_ORIGIN_SUIT
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_ImageControlGrid_cloth_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_ImageControlGrid_cloth_select_changed(grid, index, flag)
  if grid:IsEmpty(index) then
    return
  end
  local form = grid.ParentForm
  if not flag then
    form.lbl_tips_fs.Visible = false
    save_to_ini("fs", 1)
  end
  local form_school_introduce = nx_value("form_school_introduce")
  if not nx_is_valid(form_school_introduce) then
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
  local sex = client_player:QueryProp("Sex")
  local cur_school = get_cur_school_id()
  local cloth_list = form_school_introduce:GetCloth(cur_school)
  if index >= table.getn(cloth_list) / 2 then
    return
  end
  local cloth = cloth_list[2 * (index + 1)]
  local cloth_ani = form_school_introduce:GetClothAni(cloth)
  form.ani.AnimationImage = cloth_ani
  form.ani.Loop = false
  form.ani:Play()
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if not nx_find_custom(form, "actor2") then
    return
  end
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  local nArtPack = item_query_ArtPack_by_id(cloth, "ArtPack", sex)
  local model_name = "MaleModel"
  if 0 ~= sex then
    model_name = "FemaleModel"
  end
  local model = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(nArtPack), model_name)
  local part = {
    "headdress",
    "mask",
    "scarf",
    "shoulders",
    "pendant1",
    "pendant2",
    "cloth",
    "shoes",
    "pants",
    "hat",
    "cloth_h"
  }
  for _, v in pairs(part) do
    role_composite:UnLinkSkin(actor2, v)
  end
  role_composite:LinkSkin(actor2, "Hat", " ", false)
  for id, prop in pairs(ArtPack) do
    local art_id = nx_number(item_query:GetItemPropByConfigID(cloth, id))
    if art_id < 0 then
      nx_execute("role_composite", "unlink_skin", actor2, prop)
      nx_execute("role_composite", "unlink_skin", actor2, string.lower(prop))
    elseif 0 < art_id then
      local model = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(art_id), model_name)
      if "Cloth" == prop or "cloth" == prop then
        role_composite:LinkClothSkin(actor2, model)
        role_composite:LinkSkin(actor2, "cloth_h", model .. "_h.xmod", false)
      else
        role_composite:LinkSkin(actor2, prop, model .. ".xmod", false)
      end
    end
  end
end
function show_limit_info(school_id, bexpand)
  local form_school_introduce = nx_value("form_school_introduce")
  if not nx_is_valid(form_school_introduce) then
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local info_t = form_school_introduce:GetConditonInfo(school_id)
  local size = table.getn(info_t)
  if size == 0 then
    return
  end
  if bexpand and size < 2 then
    return
  end
  local info = info_t[1]
  if bexpand then
    info = info_t[2]
  end
  form.mltbox_limitinfo:Clear()
  form.mltbox_limitinfo:AddHtmlText(nx_widestr(util_text(info)), -1)
  local height = form.mltbox_limitinfo:GetContentHeight() + 6
  form.mltbox_limitinfo.Height = math.max(height, 60)
  form.mltbox_limitinfo.ViewRect = "6,6," .. nx_string(form.mltbox_limitinfo.Width) .. "," .. nx_string(height)
  local xxx = form.groupbox_limit.Top + form.groupbox_limit.Height
  local space = 0
  form.groupbox_limit.Height = form.mltbox_intro.Height + form.mltbox_limitinfo.Height + form.lbl_23.Height + space
  form.groupbox_limit.Top = xxx - form.groupbox_limit.Height
  if bexpand then
    form.cbtn_expand.Top = form.cbtn_expand.Height - form.groupbox_limit.Height - 20
  else
    form.cbtn_expand.Top = -35 - form.cbtn_expand.Height
  end
  form.cbtn_expand.Checked = bexpand
  form.cbtn_expand.Visible = 1 < size
  local info_yd = form_school_introduce:GetConditioninfo_yd(school_id)
  form.mltbox_intro:Clear()
  form.mltbox_intro:AddHtmlText(util_text(info_yd), -1)
end
function on_cbtn_expand_checked_changed(cbtn)
  local form_school_introduce = nx_value("form_school_introduce")
  if not nx_is_valid(form_school_introduce) then
    return
  end
  local school_id = get_cur_school_id()
  local info_t = form_school_introduce:GetConditonInfo(school_id)
  if 0 == table.getn(info_t) then
    return
  end
  local info = info_t[1]
  if cbtn.Checked then
    info = info_t[2]
  end
  local form = cbtn.ParentForm
  form.mltbox_limitinfo:Clear()
  form.mltbox_limitinfo:AddHtmlText(nx_widestr(util_text(info)), -1)
  local height = form.mltbox_limitinfo:GetContentHeight() + 6
  form.mltbox_limitinfo.Height = math.max(height, 60)
  form.mltbox_limitinfo.ViewRect = "6,6," .. nx_string(form.mltbox_limitinfo.Width) .. "," .. nx_string(height)
  local xxx = form.groupbox_limit.Top + form.groupbox_limit.Height
  local space = 0
  form.groupbox_limit.Height = form.mltbox_intro.Height + form.mltbox_limitinfo.Height + form.lbl_23.Height + space
  form.groupbox_limit.Top = xxx - form.groupbox_limit.Height
  if cbtn.Checked then
    form.cbtn_expand.Top = form.cbtn_expand.Height - form.groupbox_limit.Height + 10
  else
    form.cbtn_expand.Top = -35 - form.cbtn_expand.Height
  end
end
function on_btn_movie_click(btn)
  local form_school_introduce = nx_value("form_school_introduce")
  if not nx_is_valid(form_school_introduce) then
    return
  end
  local video_path = form_school_introduce:GetVideoPath(get_cur_school_id())
  nx_execute("form_stage_main\\form_main\\form_school_introduce_video", "show_school_video", video_path)
  local form = btn.ParentForm
  form.lbl_back.Visible = true
end
function on_btn_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.scenebox, dist)
    end
  end
end
function on_btn_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.scenebox, dist)
    end
  end
end
function create_model()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local actor2 = nx_custom(form, "actor2")
  if nx_is_valid(actor2) then
    return
  end
  local form_school_introduce = nx_value("form_school_introduce")
  if not nx_is_valid(form_school_introduce) then
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
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  nx_execute("util_gui", "ui_ClearModel", form.scenebox)
  nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox)
  local game_effect = nx_create("GameEffect")
  if nx_is_valid(game_effect) then
    nx_bind_script(game_effect, "game_effect", "game_effect_init", form.scenebox.Scene)
    form.scenebox.Scene.game_effect = game_effect
  end
  local terrain = form.scenebox.Scene:Create("Terrain")
  form.scenebox.Scene.terrain = terrain
  local actor2
  local sex = client_player:QueryProp("Sex")
  if sex == 0 then
    actor2 = nx_execute("role_composite", "create_role_composite", form.scenebox.Scene, true, 0, "logoin_stand_2")
  else
    actor2 = nx_execute("role_composite", "create_role_composite", form.scenebox.Scene, true, 1, "logoin_stand_2")
  end
  while nx_is_valid(form) and nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) then
    return
  end
  actor2.modify_face = client_player:QueryProp("ModifyFace")
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox, actor2)
  local action = nx_value("action_module")
  if nx_is_valid(action) then
    action:BlendAction(actor2, "stand", false, true)
  end
  actor2:SetAngle(actor2.AngleX, actor2.AngleY, actor2.AngleZ)
  form.scenebox.Scene.camera.Fov = 0.1388888888888889 * math.pi * 2
  form.actor2 = actor2
end
function on_size_change()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Width = gui.Desktop.Width
    form.Height = gui.Desktop.Height
    form.lbl_back.Width = gui.Desktop.Width
    form.lbl_back.Height = gui.Desktop.Height
    form.groupbox_player.Height = gui.Desktop.Height
    form.lbl_10.Width = gui.Desktop.Width
    form.lbl_11.Width = gui.Desktop.Width
    form.groupbox_player.Width = gui.Desktop.Width
    form.AbsLeft = 0
    form.AbsTop = 0
    form.groupbox_player.Left = -gui.Desktop.Width / 2
    form.groupbox_player.Top = -gui.Desktop.Height / 2
    form.scenebox.Height = gui.Desktop.Height
    form.scenebox.Width = gui.Desktop.Width
  end
  nx_execute("form_stage_main\\form_main\\form_school_introduce_video", "on_size_change")
end
function on_btn_school_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUIDE_ADD_SCHOOL), 1, nx_string(get_cur_school_id()))
end
function on_cbtn_detial_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.lbl_tips_ng.Visible = false
  form.lbl_tips_zs.Visible = false
  save_to_ini("zs", 1)
  save_to_ini("ng", 1)
  if cbtn.Checked then
    form.groupbox_ng_pic.Visible = true
    form.groupbox_ng.Visible = true
    form.lbl_ng.Visible = true
    form.lbl_wx.Visible = false
    form.groupscrollbox_wuxue.Visible = false
    form.groupbox_detial.Visible = false
  else
    form.groupbox_ng_pic.Visible = false
    form.groupbox_ng.Visible = false
    form.lbl_ng.Visible = false
    form.lbl_wx.Visible = true
    form.groupscrollbox_wuxue.Visible = true
    form.groupbox_detial.Visible = true
  end
end
function get_cur_school_id()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return "school_wudang"
  end
  return form.cur_select_school
end
function get_skill_id(skill_grid_index)
  local form_school_introduce = nx_value("form_school_introduce")
  if not nx_is_valid(form_school_introduce) then
    return
  end
  local school_id = get_cur_school_id()
  if "" == school_id then
    return
  end
  local taolu_id = get_cur_taolu_id()
  if "" == taolu_id then
    return
  end
  local skill_list = form_school_introduce:GetTaoLuSkill(school_id, taolu_id)
  if skill_grid_index >= table.getn(skill_list) then
    return
  end
  local name = skill_list[skill_grid_index + 1]
  return name
end
function get_cur_taolu_id()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return ""
  end
  local groupscrollbox_wuxue = form.groupscrollbox_wuxue
  local ctrl_list = groupscrollbox_wuxue:GetChildControlList()
  for _, ctrl in pairs(ctrl_list) do
    if nx_name(ctrl) == "RadioButton" and ctrl.Checked then
      return ctrl.DataSource
    end
  end
  return ""
end
function show_pic(school_id, form)
  local form_school_introduce = nx_value("form_school_introduce")
  form.lbl_pic.BackImage = form_school_introduce:GetPic(school_id)
end
function show_desc(school_id, form)
  local form_school_introduce = nx_value("form_school_introduce")
  local info = form_school_introduce:GetDescID(school_id)
  form.mltbox_desc:Clear()
  form.mltbox_desc:AddHtmlText(util_text(info), -1)
end
function show_neigong(school_id, form)
  local form_school_introduce = nx_value("form_school_introduce")
  local grid = form.imagegrid_ng
  local ng_list = form_school_introduce:GetNeiGong(school_id)
  grid:Clear()
  local grid_index = 0
  for i, id in ipairs(ng_list) do
    local staticdata = get_ini_prop(FINE_NEIGONG_INI, id, "StaticData", "")
    local photo = neigong_static_query(staticdata, "Photo")
    grid:AddItem(grid_index, photo, util_text(id), 1, -1)
    grid:SetItemCoverImage(grid_index, nx_string(Cover_Img[grid_index + 1]))
    grid:CoverItem(grid_index, true)
    grid_index = grid_index + 1
  end
  form.lbl_ng_pic.BackImage = form_school_introduce:GetNeiGongPic(school_id)
end
function show_cloth(school_id, form)
  local form_school_introduce = nx_value("form_school_introduce")
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local grid = form.ImageControlGrid_cloth
  grid:Clear()
  local cloth_list = form_school_introduce:GetCloth(school_id)
  local size = math.min(table.getn(cloth_list) / 2, CLOTH_MAX)
  local grid_index = 0
  for i = 1, size do
    local pose_id = cloth_list[2 * i - 1]
    local cloth_id = cloth_list[2 * i]
    local photo = item_query_ArtPack_by_id(cloth_id, "Photo")
    grid:AddItem(grid_index, photo, util_text(cloth_id), 1, -1)
    grid:SetItemCoverImage(grid_index, nx_string(Cover_Img[grid_index + 1]))
    grid:CoverItem(grid_index, true)
    grid_index = grid_index + 1
  end
end
function show_taolu(school_id, form)
  local form_school_introduce = nx_value("form_school_introduce")
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local groupscrollbox_wuxue = form.groupscrollbox_wuxue
  groupscrollbox_wuxue:DeleteAll()
  local taolu_list = form_school_introduce:GetTaoLu(school_id)
  local size = math.min(table.getn(taolu_list), TAOLU_MAX)
  for i = 1, size do
    local wuxue = taolu_list[i]
    local rbtn = gui:Create("RadioButton")
    groupscrollbox_wuxue:Add(rbtn)
    set_node_prop(rbtn)
    rbtn.Text = util_text(wuxue)
    rbtn.DataSource = wuxue
    nx_bind_script(rbtn, nx_current())
    nx_callback(rbtn, "on_checked_changed", "on_taolu_changed")
    if 1 == i then
      rbtn.Checked = true
    end
  end
  groupscrollbox_wuxue:ResetChildrenYPos()
end
function on_taolu_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    local school_id = get_cur_school_id()
    local taolu_id = rbtn.DataSource
    show_skill(school_id, taolu_id, form)
  end
end
function show_taolu_info(school_id, taolu_id, form)
  local form_school_introduce = nx_value("form_school_introduce")
  local taolu_info = form_school_introduce:GetTaoLuInfo(school_id, taolu_id)
  if table.getn(taolu_info) ~= 5 then
    return
  end
  set_star(form.groupbox_attack, taolu_info[1])
  set_star(form.groupbox_defend, taolu_info[2])
  set_star(form.groupbox_recover, taolu_info[3])
  set_star(form.groupbox_operate, taolu_info[4])
  form.mltbox_site:Clear()
  form.mltbox_site:AddHtmlText(util_text(taolu_info[5]), -1)
end
function show_skill(school_id, taolu_id, form)
  local form_school_introduce = nx_value("form_school_introduce")
  if not nx_is_valid(form_school_introduce) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_skill
  local skill_list = form_school_introduce:GetTaoLuSkill(school_id, taolu_id)
  grid:Clear()
  local grid_index = 0
  for _, id in ipairs(skill_list) do
    local photo = skill_static_query_by_id(id, "Photo")
    grid:AddItem(grid_index, photo, util_text(id), 1, -1)
    grid_index = grid_index + 1
  end
  show_taolu_info(school_id, taolu_id, form)
end
function link_weapon(actor2)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "actor2") then
    return
  end
  if not nx_id_equal(form.actor2, actor2) then
    return
  end
  local form_school_introduce = nx_value("form_school_introduce")
  if not nx_is_valid(form_school_introduce) then
    return
  end
  local school_id = get_cur_school_id()
  local weapon_id = form_school_introduce:GetDefaultWeapon(school_id)
  if "" == nx_string(weapon_id) then
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
  local sex = client_player:QueryProp("Sex")
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  local nArtPack = item_query_ArtPack_by_id(weapon_id, "ArtPack", sex)
  local model_name = "MaleModel"
  if 0 ~= sex then
    model_name = "FemaleModel"
  end
  local weapon = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(nArtPack), model_name)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(weapon_id), nx_string("ItemType"))
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:SetRoleWeaponName(actor2, nx_string(weapon))
  role_composite:UseWeapon(actor2, game_visual:QueryRoleWeaponName(actor2), 2, nx_int(item_type))
end
function add_weapon(actor2, skill_name)
  if skill_name == nil then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  if not nx_is_valid(actor2) then
    return false
  end
  role_composite:UnLinkWeapon(actor2)
  if nx_find_custom(actor2, "wuxue_book_set") then
    actor2.wuxue_book_set = nil
  else
    nx_set_custom(actor2, "wuxue_book_set", "")
  end
  local LimitIndex = nx_execute("tips_data", "get_ini_prop", FILE_SKILL_INI, skill_name, "UseLimit", "")
  if LimitIndex == nil or nx_int(LimitIndex) == nx_int(0) then
    return false
  end
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return false
  end
  local ItemType = skill_query:GetSkillWeaponType(nx_int(LimitIndex))
  if ItemType == nil or nx_int(ItemType) == nx_int(0) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local taolu = nx_execute("util_static_data", "skill_static_query_by_id", skill_name, "TaoLu")
  local weapon_name = get_weapon_name(taolu)
  if weapon_name == "" then
    return true
  end
  local weapon_list = util_split_string(weapon_name, ",")
  local count = table.getn(weapon_list)
  local bow, arrow_case = "", ""
  if count == 2 then
    bow = nx_string(weapon_list[1])
    arrow_case = nx_string(weapon_list[2])
    if bow ~= "" and arrow_case ~= "" and bow ~= nil and arrow_case ~= nil and nx_int(ItemType) == nx_int(127) then
      show_bow_n_arrow(true, actor2, bow, arrow_case)
    end
  elseif count == 1 then
    game_visual:SetRoleWeaponName(actor2, nx_string(weapon_name))
  end
  local set_index = nx_int(ItemType) - 100
  if nx_int(set_index) >= nx_int(1) or nx_int(set_index) <= nx_int(8) then
    local action_set = nx_string(set_index) .. "h"
    nx_set_custom(actor2, "wuxue_book_set", action_set)
  end
  role_composite:UseWeapon(actor2, game_visual:QueryRoleWeaponName(actor2), 2, nx_int(ItemType))
  if nx_int(ItemType) == nx_int(116) then
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::H_weaponR_01", "ini\\npc\\hw_fz001")
    local actor_role = game_visual:QueryActRole(actor2)
    local shot_weapon = actor_role:GetLinkObject("ShotWeapon")
    shot_weapon.Visible = false
  end
  game_visual:SetRoleLogicState(actor2, 1)
  return true
end
function show(form)
  local form_school_introduce = nx_value("form_school_introduce")
  if not nx_is_valid(form_school_introduce) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  check_sex()
  local school_id = get_cur_school_id()
  if "" == school_id then
    return
  end
  local text_id = form_school_introduce:GetJoinText(school_id)
  if "" ~= text_id then
    form.btn_school.Visible = true
    form.btn_school.Text = nx_widestr(util_text(text_id))
  else
    form.btn_school.Visible = false
  end
  show_desc(school_id, form)
  local actor2 = nx_custom(form, "actor2")
  if nx_is_valid(actor2) then
    show_bow_n_arrow(false, actor2)
  end
  create_model()
  if not nx_is_valid(form) then
    return
  end
  show_neigong(school_id, form)
  show_cloth(school_id, form)
  local index = 0
  for i = CLOTH_MAX - 1, 0, -1 do
    if not form.ImageControlGrid_cloth:IsEmpty(i) then
      index = i
      break
    end
  end
  form.ImageControlGrid_cloth:SetSelectItemIndex(index)
  on_ImageControlGrid_cloth_select_changed(form.ImageControlGrid_cloth, index, true)
  show_taolu(school_id, form)
  local taolu_id = get_cur_taolu_id()
  if "" == taolu_id then
    return
  end
  show_skill(school_id, taolu_id, form)
  show_pic(school_id, form)
  local skill_id = form_school_introduce:GetDefaultSkill(school_id)
  show_skill_action(skill_id, form.scenebox, form.actor2)
  show_limit_info(school_id, false)
  form.groupbox_desc.BlendAlpha = 100
  form.groupbox_limit.BlendAlpha = 100
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(100, 20, nx_current(), "refresh_alpha", form, -1, -1)
  end
end
function refresh_alpha(form)
  if not nx_is_valid(form) then
    return
  end
  local groupbox_desc = form.groupbox_desc
  local groupbox_limit = form.groupbox_limit
  groupbox_desc.BlendAlpha = groupbox_desc.BlendAlpha + 7.75
  groupbox_limit.BlendAlpha = groupbox_limit.BlendAlpha + 7.75
end
function set_star(groupbox, num)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(groupbox) then
    return
  end
  groupbox:DeleteAll()
  local quotientr = num / 2
  for i = 1, quotientr do
    local lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = (i - 1) * 20
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_2.png"
    lbl_star.AutoSize = true
  end
  local remainder = num % 2
  if remainder == 1 then
    local lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = quotientr * 20 - 10
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_1.png"
    lbl_star.AutoSize = true
  end
end
function show_skill_action(skill_id, scenebox, actor2)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if not nx_is_valid(scenebox) then
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  skill_effect:EndShowZhaoshi(actor2, "")
  action:ActionInit(actor2)
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "stand", true, true)
  skill_effect:BeginShowZhaoshi(actor2, skill_id)
  add_weapon(actor2, skill_id)
end
function check_sex()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
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
  local sex = client_player:QueryProp("Sex")
  local groupbox_list = form.groupbox_list
  local ctrl_list = groupbox_list:GetChildControlList()
  for _, child in ipairs(ctrl_list) do
    if nx_name(child) == "RadioButton" then
      if sex == 0 then
        if child.DataSource == "school_emei" or child.DataSource == "force_yihua" or child.DataSource == "newschool_shenshui" then
          child.Enabled = false
        end
      elseif child.DataSource == "school_shaolin" or child.DataSource == "force_wugen" or child.DataSource == "newschool_damo" then
        child.Enabled = false
      end
    end
  end
  groupbox_list = form.groupbox_news
  ctrl_list = groupbox_list:GetChildControlList()
  for _, child in ipairs(ctrl_list) do
    if nx_name(child) == "RadioButton" then
      if sex == 0 then
        if child.DataSource == "school_emei" or child.DataSource == "force_yihua" or child.DataSource == "newschool_shenshui" then
          child.Enabled = false
        end
      elseif child.DataSource == "school_shaolin" or child.DataSource == "force_wugen" or child.DataSource == "newschool_damo" then
        child.Enabled = false
      end
    end
  end
end
function get_weapon_name(skill_id)
  local ini = get_ini("ini\\ui\\wuxue\\skill_weapon.ini", true)
  if not nx_is_valid(ini) then
    return ""
  end
  local weapon_name = ini:ReadString("weapon_name", skill_id, "")
  return weapon_name
end
function clear()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
end
function save_to_ini(key, value)
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    nx_destroy(ini)
    return
  end
  ini.FileName = account .. "\\fsi.ini"
  ini:LoadFromFile()
  ini:WriteInteger("r", nx_string(key), nx_int(value))
  ini:SaveToFile()
  nx_destroy(ini)
end
function load_form_ini(key)
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\fsi.ini"
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return 0
    end
    return ini:ReadInteger("r", nx_string(key), 0)
  end
  nx_destroy(ini)
  return 0
end
function on_rbtn_1_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.groupbox_list.Visible = rbtn.Checked
    form.groupbox_news.Visible = not rbtn.Checked
    if form.rbtn_wd.Checked then
      form.cur_select_school = "school_wudang"
      show(form)
    else
      form.rbtn_wd.Checked = true
    end
  end
end
function on_rbtn_2_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.groupbox_list.Visible = not rbtn.Checked
    form.groupbox_news.Visible = rbtn.Checked
    if form.rbtn_xjz.Checked then
      form.cur_select_school = "force_xujia"
      show(form)
    else
      form.rbtn_xjz.Checked = true
    end
  end
end
function show_bow_n_arrow(b_link, actor2, bow, arrow_case)
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local actor_role = game_visual:QueryActRole(actor2)
  if not nx_is_valid(actor_role) then
    return
  end
  if nx_boolean(b_link) then
    nx_set_custom(actor2, "wuxue_book_set", "0h")
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::B_weaponR_01", bow)
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::B_weaponR_01", arrow_case)
    local shot_weapon = actor_role:GetLinkObject("ShotWeapon")
    if nx_is_valid(shot_weapon) then
      shot_weapon.Visible = true
    end
    game_visual:SetRoleWeaponName(actor2, bow)
  else
    if nx_find_custom(actor2, "wuxue_book_set") then
      actor2.wuxue_book_set = nil
    else
      nx_set_custom(actor2, "wuxue_book_set", "")
    end
    role_composite:UnLinkWeapon(actor2)
    actor_role:UnLink("ShotWeapon", false)
  end
end
