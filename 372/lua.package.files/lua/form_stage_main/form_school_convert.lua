require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\itemtype_define")
require("share\\static_data_type")
require("share\\client_custom_define")
local ST_school_jianghu = 0
local ST_school_shaolin = 1
local ST_school_wudang = 2
local ST_school_emei = 3
local ST_school_junzitang = 4
local ST_school_jinyiwei = 5
local ST_school_jilegu = 6
local ST_school_gaibang = 7
local ST_school_tangmen = 8
local ST_force_yihua = 9
local ST_force_taohua = 10
local ST_force_xujia = 11
local ST_force_wanshou = 12
local ST_force_jinzhen = 13
local ST_force_wugen = 14
local ST_newschool_xuedao = 15
local ST_newschool_gumu = 16
local ST_newschool_changfeng = 17
local ST_newschool_nianluo = 18
local ST_Count = 19
local ArtPack = {
  ArtPack = "Cloth",
  HatArtPack = "Hat",
  PlantsArtPack = "Pants",
  ShoesArtPack = "Shoes"
}
local MODEL_TYPE_PLAYER = 1
local MODEL_TYPE_SCHOOL = 2
function show_school(school_id)
  local form = nx_value("form_stage_main\\form_school_convert")
  if not nx_is_valid(form) then
    util_auto_show_hide_form("form_stage_main\\form_school_convert")
    form = nx_value("form_stage_main\\form_school_convert")
  end
  if nx_is_valid(form) then
    select_school(form, school_id)
  end
end
function select_school(form, school_id)
  local form_logic = nx_value("form_school_convert")
  if not nx_is_valid(form_logic) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local index = form_logic:GetDestSchoolIndex(school_id)
  form.listbox_school.SelectIndex = index
end
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  local form_logic = nx_value("form_school_convert")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_school_convert")
  nx_set_value("form_school_convert", form_logic)
  self.actor_player = nx_null()
  self.actor_school = nx_null()
end
function main_form_open(self)
  local form_logic = nx_value("form_school_convert")
  form_logic:InitUI(self)
  nx_execute(nx_current(), "init_player_model", self)
  self.btn_type.Visible = false
  self.groupbox_type.Visible = false
  self.cbtn_equal.Visible = false
  self.btn_test.Visible = false
  self.btn_from.Visible = false
  self.btn_leave.Visible = false
  self.btn_last.Visible = false
  self.btn_mark.Visible = false
  self.groupbox_from.Visible = false
  self.groupbox_leave.Visible = false
  self.groupbox_last.Visible = false
  self.groupbox_mark.Visible = false
end
function main_form_close(self)
  local form_logic = nx_value("form_school_convert")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  nx_kill(nx_current(), "init_player_model", self)
  nx_kill(nx_current(), "init_school_model", self)
  nx_destroy(self)
end
function init_school_listbox(form)
  form.groupbox_school_list.Visible = false
  form.listbox_school:AddString(util_text("school_wulin"))
  form.listbox_school:AddString(util_text("school_shaolin"))
  form.listbox_school:AddString(util_text("school_wudang"))
  form.listbox_school:AddString(util_text("school_gaibang"))
  form.listbox_school:AddString(util_text("school_tangmen"))
  form.listbox_school:AddString(util_text("school_emei"))
  form.listbox_school:AddString(util_text("school_jinyiwei"))
  form.listbox_school:AddString(util_text("school_jilegu"))
  form.listbox_school:AddString(util_text("school_junzitang"))
  form.listbox_school:AddString(util_text("force_yihua"))
  form.listbox_school:AddString(util_text("force_taohua"))
  form.listbox_school:AddString(util_text("force_xujia"))
  form.listbox_school:AddString(util_text("force_wugen"))
  form.listbox_school:AddString(util_text("force_wanshou"))
  form.listbox_school:AddString(util_text("force_jinzhen"))
  form.listbox_school:AddString(util_text("newschool_gumu"))
  form.listbox_school:AddString(util_text("newschool_xuedao"))
  form.listbox_school:AddString(util_text("newschool_changfeng"))
  form.listbox_school:AddString(util_text("newschool_nianluo"))
end
function init_convert_step(form)
  form.groupbox_step_1.Expand = false
  form.groupbox_step_1.BtnTitle = form.btn_title_step_1
  form.groupbox_step_1.MltboxDesc = form.mltbox_desc_step_1
  form.groupbox_step_1.BtnDone = form.btn_done_step_1
  form.groupbox_step_1.BtnAccept = form.btn_accept_step_1
  form.groupbox_step_2.Expand = false
  form.groupbox_step_2.BtnTitle = form.btn_title_step_2
  form.groupbox_step_2.MltboxDesc = form.mltbox_desc_step_2
  form.groupbox_step_2.BtnDone = form.btn_done_step_2
  form.groupbox_step_2.BtnAccept = form.btn_accept_step_2
  form.groupbox_step_3.Expand = false
  form.groupbox_step_3.BtnTitle = form.btn_title_step_3
  form.groupbox_step_3.MltboxDesc = form.mltbox_desc_step_3
  form.groupbox_step_3.BtnDone = form.btn_done_step_3
  form.groupbox_step_3.BtnAccept = form.btn_accept_step_3
  form.groupbox_step_4.Expand = false
  form.groupbox_step_4.BtnTitle = form.btn_title_step_4
  form.groupbox_step_4.MltboxDesc = form.mltbox_desc_step_4
  form.groupbox_step_4.BtnDone = form.btn_done_step_4
  form.groupbox_step_4.BtnAccept = form.btn_accept_step_4
  update_groupscrollbox_step(form)
end
function update_groupscrollbox_step(form)
  local height = 0
  if not form.groupbox_step_1.Expand then
    form.groupbox_step_1.MltboxDesc.Visible = false
    form.groupbox_step_1.BtnDone.Visible = false
    form.groupbox_step_1.BtnAccept.Visible = false
    form.groupbox_step_1.Height = 60
  else
    form.groupbox_step_1.MltboxDesc.Visible = true
    form.groupbox_step_1.BtnDone.Visible = true
    form.groupbox_step_1.BtnAccept.Visible = true
    form.groupbox_step_1.Height = 223
  end
  height = height + form.groupbox_step_1.Height
  if not form.groupbox_step_2.Expand then
    form.groupbox_step_2.MltboxDesc.Visible = false
    form.groupbox_step_2.BtnDone.Visible = false
    form.groupbox_step_2.BtnAccept.Visible = false
    form.groupbox_step_2.Height = 60
  else
    form.groupbox_step_2.MltboxDesc.Visible = true
    form.groupbox_step_2.BtnDone.Visible = true
    form.groupbox_step_2.BtnAccept.Visible = true
    form.groupbox_step_2.Height = 223
  end
  height = height + form.groupbox_step_2.Height
  if not form.groupbox_step_3.Expand then
    form.groupbox_step_3.MltboxDesc.Visible = false
    form.groupbox_step_3.BtnDone.Visible = false
    form.groupbox_step_3.BtnAccept.Visible = false
    form.groupbox_step_3.Height = 60
  else
    form.groupbox_step_3.MltboxDesc.Visible = true
    form.groupbox_step_3.BtnDone.Visible = true
    form.groupbox_step_3.BtnAccept.Visible = true
    form.groupbox_step_3.Height = 223
  end
  height = height + form.groupbox_step_3.Height
  if not form.groupbox_step_4.Expand then
    form.groupbox_step_4.MltboxDesc.Visible = false
    form.groupbox_step_4.BtnDone.Visible = false
    form.groupbox_step_4.BtnAccept.Visible = false
    form.groupbox_step_4.Height = 60
  else
    form.groupbox_step_4.MltboxDesc.Visible = true
    form.groupbox_step_4.BtnDone.Visible = true
    form.groupbox_step_4.BtnAccept.Visible = true
    form.groupbox_step_4.Height = 223
  end
  height = height + form.groupbox_step_4.Height
  form.groupscrollbox_step.Height = height
  form.groupscrollbox_step.IsEditMode = false
  form.groupscrollbox_step:ResetChildrenYPos()
end
function on_btn_step_click(self)
  local form = self.ParentForm
  local groupbox_list = {
    form.groupbox_step_1,
    form.groupbox_step_2,
    form.groupbox_step_3,
    form.groupbox_step_4
  }
  local groupbox = self.Parent
  local flag = groupbox.Expand
  form.groupbox_step_1.Expand = false
  form.groupbox_step_2.Expand = false
  form.groupbox_step_3.Expand = false
  form.groupbox_step_4.Expand = false
  groupbox.Expand = not flag
  local form_logic = nx_value("form_school_convert")
  if nx_is_valid(form_logic) then
    form_logic:UpdateConvertStepGroupBox(form)
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function init_player_model(form)
  local scene_box = form.scenebox_player
  init_actor2_model(form, scene_box, MODEL_TYPE_PLAYER, true)
end
function init_school_model(form)
  local scene_box = form.scenebox_school
  init_actor2_model(form, scene_box, MODEL_TYPE_SCHOOL, false)
end
function init_actor2_model(form, scene_box, model_type, is_player)
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
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  nx_execute("util_gui", "ui_ClearModel", scene_box)
  nx_execute("util_gui", "util_addscene_to_scenebox", scene_box)
  local actor2 = nx_null()
  if is_player then
    actor2 = nx_execute("role_composite", "create_scene_obj_composite", scene_box.Scene, client_player, false)
  else
    local sex = client_player:QueryProp("Sex")
    actor2 = nx_execute("role_composite", "create_role_composite", scene_box.Scene, false, sex, "stand")
  end
  while nx_is_valid(form) and nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) then
    return
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", scene_box, actor2)
  local action = nx_value("action_module")
  if nx_is_valid(action) then
    action:BlendAction(actor2, "stand", false, true)
  end
  actor2:SetAngle(actor2.AngleX, actor2.AngleY, actor2.AngleZ)
  scene_box.Scene.camera.Fov = 0.08333333333333333 * math.pi * 2
  if model_type == MODEL_TYPE_PLAYER then
    form.actor_player = actor2
  elseif model_type == MODEL_TYPE_SCHOOL then
    form.actor_school = actor2
  end
end
function on_btn_school_click(self)
  local form = self.ParentForm
  local groupbox = form.groupbox_school_list
  groupbox.Visible = not groupbox.Visible
end
function on_listbox_school_select_changed(self)
  local form_logic = nx_value("form_school_convert")
  if not nx_is_valid(form_logic) then
    return
  end
  local form = self.ParentForm
  form.groupbox_school_list.Visible = false
  local index = self.SelectIndex
  local sel_school = form_logic:GetDestSchoolID(index)
  local cur_school = form_logic:GetCurrentSchool()
  form.lbl_cur_school.Text = util_text(cur_school)
  form.lbl_dest_school.Text = util_text(sel_school)
  show_school_cloth(form, sel_school)
  form_logic:ConvertTo(form, cur_school, sel_school)
end
function on_listbox_type_select_changed(self)
end
function on_listbox_from_select_changed(self)
  local form_logic = nx_value("form_school_convert")
  if not nx_is_valid(form_logic) then
    return
  end
  local form = self.ParentForm
  form.groupbox_school_list.Visible = false
  local index_from = self.SelectIndex
  local school_from = form_logic:GetSchoolID(index_from)
  local index_dest = form.listbox_school.SelectIndex
  local school_dest = form_logic:GetSchoolID(index_dest)
  form.lbl_cur_school.Text = util_text(school_from)
  form.lbl_dest_school.Text = util_text(school_dest)
  form_logic:ConvertTo(form, school_from, school_dest)
end
function on_listbox_leave_select_changed(self)
end
function on_listbox_last_select_changed(self)
end
function on_listbox_mark_select_changed(self)
end
function show_school_cloth(form, school)
  if not nx_is_valid(form.actor_school) then
    init_school_model(form)
  end
  local form_logic = nx_value("form_school_convert")
  if not nx_is_valid(form_logic) then
    return
  end
  local index = form_logic:GetSchoolIndex(school)
  local cloth = form_logic:GetSchoolCloth(index)
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
  if not nx_find_custom(form, "actor_school") then
    return
  end
  local actor2 = form.actor_school
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
  local sex = client_player:QueryProp("Sex")
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
function on_btn_path_checked_changed(self)
  local form = self.ParentForm
  local form_logic = nx_value("form_school_convert")
  if not nx_is_valid(form_logic) then
    return
  end
  if not nx_find_custom(self, "path_id") then
    return
  end
  if self.Checked then
    local path_id = self.path_id
    form_logic:ShowPath(form, path_id)
  end
end
function init_ui(form)
  init_listbox_test(from)
  init_school_listbox(form)
  init_convert_step_groupbox(form)
end
function init_listbox_test(form)
  local listbox = form.listbox_test
  local SCHOOL_DATA_LIST = {
    {
      ST_school_jianghu,
      "school_jianghu",
      "school_jianghu",
      "wumenpai04"
    },
    {
      ST_school_shaolin,
      "school_shaolin",
      "school_shaolin",
      "shaolin10"
    },
    {
      ST_school_wudang,
      "school_wudang",
      "school_wudang",
      "wudang10"
    },
    {
      ST_school_emei,
      "school_emei",
      "school_emei",
      "emei10"
    },
    {
      ST_school_junzitang,
      "school_junzitang",
      "school_junzitang",
      "junzi10"
    },
    {
      ST_school_jinyiwei,
      "school_jinyiwei",
      "school_jinyiwei",
      "jinyi10"
    },
    {
      ST_school_jilegu,
      "school_jilegu",
      "school_jilegu",
      "jile10"
    },
    {
      ST_school_gaibang,
      "school_gaibang",
      "school_gaibang",
      "gaibang10"
    },
    {
      ST_school_tangmen,
      "school_tangmen",
      "school_tangmen",
      "tangmen10"
    },
    {
      ST_force_yihua,
      "force_yihua",
      "force_yihua",
      "yihuagong08"
    },
    {
      ST_force_taohua,
      "force_taohua",
      "force_taohua",
      "taohua06"
    },
    {
      ST_force_xujia,
      "force_xujia",
      "force_xujia",
      "xujiazhuang02"
    },
    {
      ST_force_wanshou,
      "force_wanshou",
      "force_wanshou",
      "wssz02"
    },
    {
      ST_force_jinzhen,
      "force_jinzhen",
      "force_jinzhen",
      "jzsj02"
    },
    {
      ST_force_wugen,
      "force_wugen",
      "force_wugen",
      "wugenmen02"
    },
    {
      ST_newschool_xuedao,
      "newschool_xuedao",
      "newschool_xuedao",
      "xuedao06"
    },
    {
      ST_newschool_gumu,
      "newschool_gumu",
      "newschool_gumu",
      "gumu06"
    },
    {
      ST_newschool_changfeng,
      "newschool_changfeng",
      "newschool_changfeng",
      "changfeng06"
    },
    {
      ST_newschool_nianluo,
      "newschool_nianluo",
      "newschool_nianluo",
      "nianluoba06"
    }
  }
  for _, data in ipairs(SCHOOL_DATA_LIST) do
    local text = util_text(data[4])
    listbox:AddString(text)
  end
end
function init_shcool_listbox(form)
  local listbox = form.listbox_school
  local SCHOOL_DATA_LIST = {
    {
      ST_school_jianghu,
      "school_jianghu",
      "school_jianghu",
      "wumenpai04"
    },
    {
      ST_school_shaolin,
      "school_shaolin",
      "school_shaolin",
      "shaolin10"
    },
    {
      ST_school_wudang,
      "school_wudang",
      "school_wudang",
      "wudang10"
    },
    {
      ST_school_emei,
      "school_emei",
      "school_emei",
      "emei10"
    },
    {
      ST_school_junzitang,
      "school_junzitang",
      "school_junzitang",
      "junzi10"
    },
    {
      ST_school_jinyiwei,
      "school_jinyiwei",
      "school_jinyiwei",
      "jinyi10"
    },
    {
      ST_school_jilegu,
      "school_jilegu",
      "school_jilegu",
      "jile10"
    },
    {
      ST_school_gaibang,
      "school_gaibang",
      "school_gaibang",
      "gaibang10"
    },
    {
      ST_school_tangmen,
      "school_tangmen",
      "school_tangmen",
      "tangmen10"
    },
    {
      ST_force_yihua,
      "force_yihua",
      "force_yihua",
      "yihuagong08"
    },
    {
      ST_force_taohua,
      "force_taohua",
      "force_taohua",
      "taohua06"
    },
    {
      ST_force_xujia,
      "force_xujia",
      "force_xujia",
      "xujiazhuang02"
    },
    {
      ST_force_wanshou,
      "force_wanshou",
      "force_wanshou",
      "wssz02"
    },
    {
      ST_force_jinzhen,
      "force_jinzhen",
      "force_jinzhen",
      "jzsj02"
    },
    {
      ST_force_wugen,
      "force_wugen",
      "force_wugen",
      "wugenmen02"
    },
    {
      ST_newschool_xuedao,
      "newschool_xuedao",
      "newschool_xuedao",
      "xuedao06"
    },
    {
      ST_newschool_gumu,
      "newschool_gumu",
      "newschool_gumu",
      "gumu06"
    },
    {
      ST_newschool_changfeng,
      "newschool_changfeng",
      "newschool_changfeng",
      "changfeng06"
    },
    {
      ST_newschool_nianluo,
      "newschool_nianluo",
      "newschool_nianluo",
      "nianluoba06"
    }
  }
  for _, data in ipairs(SCHOOL_DATA_LIST) do
    local text = util_text(data[4])
    listbox:AddString(text)
  end
end
function init_convert_step_groupbox(form)
  local groupbox = form.groupbox_step_1
  local btn_title = form.btn_title_step_1
  local mltbox = form.mltbox_desc_step_1
  local btn_done = form.btn_done_step_1
  local btn_accept = form.btn_accept_step_1
  groupbox.Expand = false
  groupbox.step_id = 0
  groupbox.BtnTitle = btn_title
  groupbox.MltboxDesc = mltbox
  groupbox.BtnDone = btn_done
  groupbox.BtnAccept = btn_accept
  local groupbox = form.groupbox_step_2
  local btn_title = form.btn_title_step_2
  local mltbox = form.mltbox_desc_step_2
  local btn_done = form.btn_done_step_2
  local btn_accept = form.btn_accept_step_2
  groupbox.Expand = false
  groupbox.step_id = 1
  groupbox.BtnTitle = btn_title
  groupbox.MltboxDesc = mltbox
  groupbox.BtnDone = btn_done
  groupbox.BtnAccept = btn_accept
  local groupbox = form.groupbox_step_3
  local btn_title = form.btn_title_step_3
  local mltbox = form.mltbox_desc_step_3
  local btn_done = form.btn_done_step_3
  local btn_accept = form.btn_accept_step_3
  groupbox.Expand = false
  groupbox.step_id = 2
  groupbox.BtnTitle = btn_title
  groupbox.MltboxDesc = mltbox
  groupbox.BtnDone = btn_done
  groupbox.BtnAccept = btn_accept
  local groupbox = form.groupbox_step_4
  local btn_title = form.btn_title_step_4
  local mltbox = form.mltbox_desc_step_4
  local btn_done = form.btn_done_step_4
  local btn_accept = form.btn_accept_step_4
  groupbox.Expand = false
  groupbox.step_id = 3
  groupbox.BtnTitle = btn_title
  groupbox.MltboxDesc = mltbox
  groupbox.BtnDone = btn_done
  groupbox.BtnAccept = btn_accept
  update_groupscrollbox_step(form)
end
function on_btn_accept_step_click(self)
  local form_logic = nx_value("form_school_convert")
  if not nx_is_valid(form_logic) then
    return
  end
  local groupbox = self.Parent
  if not nx_find_custom(groupbox, "step_id") then
    return
  end
  local step_id = groupbox.step_id
  local path_id = form_logic:GetCurPath()
  local str_path = form_logic:GetPathID(path_id)
  if task_id ~= "" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUIDE_ADD_SCHOOL), 5, nx_string(str_path), nx_int(step_id))
  end
end
function on_btn_type_click(self)
  local form = self.ParentForm
  local groupbox = form.groupbox_type
  groupbox.Visible = not groupbox.Visible
end
function on_btn_from_click(self)
  local form = self.ParentForm
  local groupbox = form.groupbox_from
  groupbox.Visible = not groupbox.Visible
end
function on_btn_leave_click(self)
  local form = self.ParentForm
  local groupbox = form.groupbox_leave
  groupbox.Visible = not groupbox.Visible
end
function on_btn_last_click(self)
  local form = self.ParentForm
  local groupbox = form.groupbox_last
  groupbox.Visible = not groupbox.Visible
end
function on_btn_mark_click(self)
  local form = self.ParentForm
  local groupbox = form.groupbox_mark
  groupbox.Visible = not groupbox.Visible
end
function on_btn_test_click(self)
  local form = self.ParentForm
  local form_logic = nx_value("form_school_convert")
  if not nx_is_valid(form_logic) then
    return
  end
  local from_id = form.listbox_from.SelectIndex
  local leave_id = form.listbox_leave.SelectIndex
  local last_id = form.listbox_last.SelectIndex
  local mark_id = form.listbox_mark.SelectIndex
  local dest_id = form.listbox_school.SelectIndex
  local from = form_logic:GetFrom(from_id)
  local leave = form_logic:GetLeave(leave_id)
  local last = form_logic:GetLast(last_id)
  local mark = form_logic:GetMark(mark_id)
  local dest = form_logic:GetDest(dest_id)
  local ps_type = form_logic:GetPlayerSchoolType(from, leave, nx_string(last), mark)
  if ps_type == "" then
    nx_msgbox("\195\187\211\208\198\165\197\228\181\196\195\197\197\201\192\224\208\205\211\235\214\174\182\212\211\166")
    form.listbox_type.SelectIndex = -1
    return
  end
  local type_desc = form_logic:GetTypeDesc(ps_type)
  local type_id = form.listbox_type:FindString(type_desc)
  form.listbox_type.SelectIndex = type_id
  local last = ""
  if form.cbtn_equal.Checked then
    last = dest
  else
    last = ""
  end
  form_logic:ConvertEx(form, from, dest, ps_type, last, form.cbtn_equal.Checked)
end
