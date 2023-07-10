require("utils")
require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\static_data_type")
local FORM_LINGXIAO = "form_stage_main\\form_lingxiao\\form_lingxiao"
local FORM_ZHIZUNPAGE = "form_stage_main\\form_lingxiao\\form_linxiao_zhizun"
local LINGXIAO_XIANZHU = 1
local LINGXIAO_XUESHI = 2
local LINGXIAO_ZHANGLAO = 3
local LINGXIAO_CHENGZHONG = 4
local LINGXIAO_JOB1 = 1
local LINGXIAO_JOB2 = 2
local LINGXIAO_JOB3 = 3
local LINGXIAO_JOB4 = 4
local CMM_LINXIAOZHIZUN_REQREWARD = 0
local CMM_LINXIAOZHIZUN_REQROLEINFO = 1
local JOB_LINXIAO_ZHIZUN_XIANZHU = 11
local JOB_LINXIAO_ZHIZUN_SHUYING = 21
local JOB_LINXIAO_ZHIZUN_ANXIANG = 22
local JOB_LINXIAO_ZHIZUN_FENGHUO = 31
local JOB_LINXIAO_ZHIZUN_SHENLONG = 32
local JOB_LINXIAO_ZHIZUN_NANGE = 33
local JOB_LINXIAO_ZHIZUN_BEIWU = 34
local JOB_LINXIAO_ZHIZUN_CHENGZHONG = 41
local EM_BODY_WOMAN_JUV = 3
local EM_BODY_MAN_JUV = 4
function main_form_init(form)
  form.Fixed = true
  form.main_index = 1
  form.sub_index = 1
  form.actor2 = nil
  form.cur_sex = -1
  form.zhizun_11 = ""
  form.zhizun_21 = ""
  form.zhizun_22 = ""
  form.zhizun_31 = ""
  form.zhizun_32 = ""
  form.zhizun_33 = ""
  form.zhizun_34 = ""
end
function on_main_form_open(form)
  form.rbtn_xianzhu.Enabled = false
  form.rbtn_xianzhu.Checked = true
  form.rbtn_xianzhu.Enabled = true
  form.rbtn_first.Visible = false
  form.rbtn_second.Visible = false
  form.rbtn_third.Visible = false
  form.rbtn_four.Visible = false
  UpdateFormDesc(form, JOB_LINXIAO_ZHIZUN_XIANZHU)
  nx_execute("custom_sender", "custom_linxiao_zhizun", CMM_LINXIAOZHIZUN_REQROLEINFO)
  form.lbl_playername.Text = nx_widestr("")
  form.btn_reward.Visible = false
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_rbtn_main_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local main_index = rbtn.DataSource
    form.main_index = main_index
    if nx_int(main_index) == nx_int(LINGXIAO_XIANZHU) then
      form.rbtn_first.Visible = false
      form.rbtn_second.Visible = false
      form.rbtn_third.Visible = false
      form.rbtn_four.Visible = false
    elseif nx_int(main_index) == nx_int(LINGXIAO_XUESHI) then
      form.rbtn_first.Visible = true
      form.rbtn_second.Visible = true
      form.rbtn_third.Visible = false
      form.rbtn_four.Visible = false
      form.rbtn_first.Text = nx_widestr("@ui_lx_ch_1")
      form.rbtn_second.Text = nx_widestr("@ui_lx_ch_2")
    elseif nx_int(main_index) == nx_int(LINGXIAO_ZHANGLAO) then
      form.rbtn_first.Visible = true
      form.rbtn_second.Visible = true
      form.rbtn_third.Visible = true
      form.rbtn_four.Visible = true
      form.rbtn_first.Text = nx_widestr("@ui_lx_ch_3")
      form.rbtn_second.Text = nx_widestr("@ui_lx_ch_4")
      form.rbtn_third.Text = nx_widestr("@ui_lx_ch_5")
      form.rbtn_four.Text = nx_widestr("@ui_lx_ch_6")
    else
      form.rbtn_first.Visible = false
      form.rbtn_second.Visible = false
      form.rbtn_third.Visible = false
      form.rbtn_four.Visible = false
    end
    local type_id = nx_int(main_index) * 10 + 1
    if form.rbtn_first.Checked then
      UpdateFormDesc(form, type_id)
      UpdateFormModel(form, type_id)
    else
      form.rbtn_first.Checked = true
    end
    UpdatePlayerInfo(form, type_id)
  end
end
function on_rbtn_sub_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local sub_index = rbtn.DataSource
    local main_index = form.main_index
    form.sub_index = sub_index
    local type_id = nx_int(main_index) * 10 + nx_int(sub_index)
    UpdateFormDesc(form, type_id)
    UpdateFormModel(form, type_id)
    UpdatePlayerInfo(form, type_id)
  end
end
function on_btn_left_click(btn)
  btn.MouseDown = false
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    local model = form.actor2
    if nx_is_valid(model) then
      local angle_x = model.AngleX
      local angle_y = model.AngleY
      local angle_z = model.AngleZ
      angle_y = angle_y + dist
      model:SetAngle(angle_x, angle_y, angle_z)
    end
  end
end
function on_btn_right_click(btn)
  btn.MouseDown = false
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    local model = form.actor2
    if nx_is_valid(model) then
      local angle_x = model.AngleX
      local angle_y = model.AngleY
      local angle_z = model.AngleZ
      angle_y = angle_y + dist
      model:SetAngle(angle_x, angle_y, angle_z)
    end
  end
end
function on_btn_reward_click(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  local client_palyer = game_client:GetPlayer()
  if not nx_is_valid(client_palyer) then
    return
  end
  local type_id = nx_int(form.main_index) * 10 + nx_int(form.sub_index)
  if nx_int(type_id) == nx_int(JOB_LINXIAO_ZHIZUN_CHENGZHONG) then
    return
  end
  local prop_name = "zhizun_" .. nx_string(type_id)
  if not nx_find_custom(form, prop_name) then
    return
  end
  local role = parse_role_info(nx_custom(form, prop_name))
  if nx_int(role.isnpc) == nx_int(1) or nx_int(role.receive) == nx_int(1) then
    return
  end
  if nx_string(role.name) == "" then
    return
  end
  local self_name = client_palyer:QueryProp("Name")
  if not nx_ws_equal(nx_widestr(self_name), nx_widestr(role.name)) then
    return
  end
  nx_execute("custom_sender", "custom_linxiao_zhizun", CMM_LINXIAOZHIZUN_REQREWARD, type_id)
end
function on_server_msg(sub_msg, ...)
  local SMM_LINXIAOZHIZUN_ROLEINFO = 0
  local form = nx_value(FORM_ZHIZUNPAGE)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(sub_msg) == nx_int(SMM_LINXIAOZHIZUN_ROLEINFO) then
    local prop_table = {
      "zhizun_11",
      "zhizun_21",
      "zhizun_22",
      "zhizun_31",
      "zhizun_32",
      "zhizun_33",
      "zhizun_34"
    }
    for i = 1, table.getn(prop_table) do
      nx_set_custom(form, prop_table[i], "")
    end
    local datastr = nx_string(arg[1])
    if nx_string(datastr) ~= "" then
      local usr_table = util_split_wstring(arg[1], nx_widestr(";"))
      local count = table.getn(prop_table)
      if count > table.getn(usr_table) then
        count = table.getn(usr_table)
      end
      for i = 1, count do
        local role = parse_role_info(usr_table[i])
        local prop = "zhizun_" .. nx_string(role.job)
        nx_set_custom(form, prop, usr_table[i])
      end
    end
    UpdateFormModel(form, JOB_LINXIAO_ZHIZUN_XIANZHU)
    UpdatePlayerInfo(form, JOB_LINXIAO_ZHIZUN_XIANZHU)
  end
end
function UpdateFormModel(form, type_id)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(type_id) == nx_int(JOB_LINXIAO_ZHIZUN_CHENGZHONG) then
    create_role_model(form, 0, 0, type_id)
  else
    local prop_name = "zhizun_" .. nx_string(type_id)
    if nx_find_custom(form, prop_name) then
      local data = nx_string(nx_custom(form, prop_name))
      if data ~= "" then
        local role = parse_role_info(nx_custom(form, prop_name))
        if role.uid == "" or nx_int(role.isnpc) == nx_int(1) then
          create_role_model(form, 0, 1, type_id, true)
        else
          create_role_model(form, role.sex, 1, type_id)
        end
      else
        create_role_model(form, 0, 1, type_id, true)
      end
    else
      clear_role_model(form)
    end
  end
end
function UpdatePlayerInfo(form, type_id)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_palyer = game_client:GetPlayer()
  if not nx_is_valid(client_palyer) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  form.lbl_playername.Text = nx_widestr("")
  form.btn_reward.Visible = false
  if nx_int(type_id) ~= nx_int(JOB_LINXIAO_ZHIZUN_CHENGZHONG) then
    local prop_name = "zhizun_" .. nx_string(type_id)
    if nx_find_custom(form, prop_name) then
      local data = nx_string(nx_custom(form, prop_name))
      if data ~= "" then
        local role = parse_role_info(nx_custom(form, prop_name))
        if nx_int(role.isnpc) == nx_int(1) then
          local name = nx_string(role.name)
          name = string.gsub(name, "%(npc%)", "")
          form.lbl_playername.Text = gui.TextManager:GetFormatText(name)
        else
          form.lbl_playername.Text = nx_widestr(role.name)
          local self_name = client_palyer:QueryProp("Name")
          if nx_ws_equal(nx_widestr(role.name), nx_widestr(self_name)) then
            form.btn_reward.Visible = true
          end
        end
      end
    end
  end
end
function UpdateFormDesc(form, type_id)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local text1, text2, text3, text4, text5, text6 = get_config_desc(type_id)
  form.mltbox_1.HtmlText = nx_widestr("")
  form.mltbox_2.HtmlText = nx_widestr("")
  form.mltbox_3.HtmlText = nx_widestr("")
  form.mltbox_4.HtmlText = nx_widestr("")
  form.mltbox_5.HtmlText = nx_widestr("")
  form.mltbox_6.HtmlText = nx_widestr("")
  if nx_string(text1) ~= "" then
    form.mltbox_1.HtmlText = gui.TextManager:GetFormatText(nx_string(text1))
  end
  if nx_string(text2) ~= "" then
    form.mltbox_2.HtmlText = gui.TextManager:GetFormatText(nx_string(text2))
  end
  if nx_string(text3) ~= "" then
    form.mltbox_3.HtmlText = gui.TextManager:GetFormatText(nx_string(text3))
  end
  if nx_string(text4) ~= "" then
    form.mltbox_4.HtmlText = gui.TextManager:GetFormatText(nx_string(text4))
  end
  if nx_string(text5) ~= "" then
    form.mltbox_5.HtmlText = gui.TextManager:GetFormatText(nx_string(text5))
  end
  if nx_string(text6) ~= "" then
    form.mltbox_6.HtmlText = gui.TextManager:GetFormatText(nx_string(text6))
  end
end
function parse_role_info(str)
  if nx_string(str) == "" then
    return {}
  end
  local role = {}
  local data_table = util_split_wstring(str, nx_widestr(","))
  role.name = nx_widestr(data_table[1])
  role.uid = nx_string(data_table[2])
  role.job = nx_int(data_table[3])
  role.sex = nx_int(data_table[4])
  role.isnpc = nx_int(data_table[5])
  role.receive = nx_int(data_table[6])
  role.show_type = nx_int(data_table[7])
  role.body_type = nx_int(data_table[8])
  role.body_face = nx_int(data_table[9])
  role.face = nx_string(data_table[10])
  role.hat = nx_string(data_table[11])
  role.cloth = nx_string(data_table[12])
  role.pants = nx_string(data_table[13])
  role.shoes = nx_string(data_table[14])
  return role
end
function get_config_desc(main_type)
  local ini = nx_execute("util_functions", "get_ini", "ini\\lingxiao\\OriginShow.ini")
  if not nx_is_valid(ini) then
    return "", "", "", "", "", ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(main_type))
  if sec_index < 0 then
    return "", "", "", "", "", ""
  end
  local text1 = nx_string(ini:ReadString(sec_index, "Text1", ""))
  local text2 = nx_string(ini:ReadString(sec_index, "Text2", ""))
  local text3 = nx_string(ini:ReadString(sec_index, "Text3", ""))
  local text4 = nx_string(ini:ReadString(sec_index, "Text4", ""))
  local text5 = nx_string(ini:ReadString(sec_index, "Text5", ""))
  local text6 = nx_string(ini:ReadString(sec_index, "Text6", ""))
  return text1, text2, text3, text4, text5, text6
end
function get_config_equip(main_type)
  local ini = nx_execute("util_functions", "get_ini", "ini\\lingxiao\\OriginShow.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(main_type))
  if sec_index < 0 then
    return ""
  end
  local equip_boy = nx_string(ini:ReadString(sec_index, "BoyEquipID", ""))
  local equip_gril = nx_string(ini:ReadString(sec_index, "GrilEquipID", ""))
  return equip_boy, equip_gril
end
function get_item_info(configid, prop)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
function clear_role_model(form)
  if not nx_find_custom(form, "actor2") then
    return
  end
  if nx_is_valid(form.actor2) then
    local world = nx_value("world")
    world:Delete(form.actor2)
    nx_execute("util_gui", "ui_ClearModel", form.role_box)
    form.actor2 = nil
  end
end
function create_role_model(form, sex, body, main_type, blackhole)
  if not nx_find_custom(form, "actor2") then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local actor2 = form.actor2
  local bNeedReCreate = false
  if nx_int(form.cur_sex) ~= nx_int(sex) or nx_int(form.cur_body) ~= nx_int(body) then
    bNeedReCreate = true
  end
  if bNeedReCreate and nx_is_valid(form.actor2) then
    local world = nx_value("world")
    world:Delete(form.actor2)
    nx_execute("util_gui", "ui_ClearModel", form.role_box)
    actor2 = nil
    form.actor2 = nil
  end
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
  end
  if bNeedReCreate then
    if nx_int(body) ~= nx_int(0) then
      local body_type = EM_BODY_MAN_JUV
      if nx_int(sex) == nx_int(1) then
        body_type = EM_BODY_WOMAN_JUV
      end
      actor2 = nx_execute("role_composite", "create_role_composite", form.role_box.Scene, true, sex, "stand", body_type)
    else
      actor2 = nx_execute("role_composite", "create_role_composite", form.role_box.Scene, true, sex)
    end
    if not nx_is_valid(actor2) then
      return
    end
    while nx_call("role_composite", "is_loading", 2, actor2) do
      nx_pause(0)
    end
    nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
    form.actor2 = actor2
  end
  if not nx_is_valid(actor2) then
    return
  end
  actor2.sex = sex
  form.cur_sex = sex
  form.cur_body = body
  local actor_role = actor2:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
  end
  nx_execute("role_composite", "unlink_skin", actor2, "hat")
  nx_execute("role_composite", "unlink_skin", actor2, "shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "pants")
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  local equip_boy, equip_gril = get_config_equip(main_type)
  local equip_id = equip_boy
  if nx_int(sex) == nx_int(1) then
    equip_id = equip_gril
  end
  if nx_string(equip_id) ~= "" then
    local cloth = item_query_ArtPack_by_id_Ex(equip_id, sex)
    if nx_string(cloth) ~= "" then
      nx_execute("role_composite", "link_skin", actor2, "cloth", nx_string(cloth) .. ".xmod")
      nx_execute("role_composite", "link_skin", actor2, "cloth_h", nx_string(cloth) .. "_h.xmod")
    end
    local model_table = {
      "HatArtPack",
      "PlantsArtPack",
      "ShoesArtPack"
    }
    local model_name = {
      "hat",
      "pants",
      "shoes"
    }
    local size = table.getn(model_table)
    for i = 1, size do
      local pack_no = get_item_info(equip_id, model_table[i])
      if nx_int(pack_no) > nx_int(0) then
        local model_path = item_static_query(nx_int(pack_no), sex, STATIC_DATA_ITEM_ART)
        if model_path ~= "" then
          nx_execute("role_composite", "link_skin", actor2, model_name[i], nx_string(model_path) .. ".xmod")
        end
      end
    end
  end
  if blackhole then
    nx_function("ext_set_model_single_color", actor2, "0.05,0.05,0.05")
    nx_function("ext_set_model_around_color", actor2, "0.69,0.825,0.996", "0.02")
  else
    nx_function("ext_set_model_single_color", actor2, "1,1,1")
    nx_function("ext_set_model_around_color", actor2, "1,1,1", "0")
  end
end
