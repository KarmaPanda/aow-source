require("util_gui")
require("util_functions")
require("role_composite")
require("custom_sender")
require("form_stage_main\\form_attribute_mall\\form_attribute_shop")
local FORM_NAME = "form_stage_main\\form_sworn\\form_sworn_info"
local face_list = {}
local sworn_location = {
  [1] = {
    [1] = {"18", "5"},
    [2] = {"1000", "1000"},
    [3] = {"1000", "1000"},
    [4] = {"1000", "1000"},
    [5] = {"1000", "1000"}
  },
  [2] = {
    [1] = {"18", "5"},
    [2] = {"-165", "5"},
    [3] = {"1000", "1000"},
    [4] = {"1000", "1000"},
    [5] = {"1000", "1000"}
  },
  [3] = {
    [1] = {"18", "5"},
    [2] = {"-150", "5"},
    [3] = {"200", "5"},
    [4] = {"1000", "1000"},
    [5] = {"1000", "1000"}
  },
  [4] = {
    [1] = {"18", "5"},
    [2] = {"-150", "5"},
    [3] = {"200", "5"},
    [4] = {"-480", "5"},
    [5] = {"1000", "1000"}
  },
  [5] = {
    [1] = {"-20", "5"},
    [2] = {"-180", "5"},
    [3] = {"130", "5"},
    [4] = {"-480", "5"},
    [5] = {"290", "5"}
  }
}
local scene_pic = {
  [1] = {
    [1] = {
      "gui\\special\\sworn\\sworn_1_1.png",
      "ui_xxx1"
    },
    [2] = {
      "gui\\special\\sworn\\sworn_1_2.png",
      "ui_xxx2"
    },
    [3] = {
      "gui\\special\\sworn\\sworn_1_3.png",
      "ui_xxx3"
    },
    [4] = {
      "gui\\special\\sworn\\sworn_1_4.png",
      "ui_xxx4"
    },
    [5] = {
      "gui\\special\\sworn\\sworn_1_5.png",
      "ui_xxx5"
    }
  },
  [2] = {
    [1] = {
      "gui\\special\\sworn\\sworn_2_1.png",
      "ui_xxx1"
    },
    [2] = {
      "gui\\special\\sworn\\sworn_2_2.png",
      "ui_xxx2"
    },
    [3] = {
      "gui\\special\\sworn\\sworn_2_3.png",
      "ui_xxx3"
    },
    [4] = {
      "gui\\special\\sworn\\sworn_2_4.png",
      "ui_xxx4"
    },
    [5] = {
      "gui\\special\\sworn\\sworn_2_5.png",
      "ui_xxx5"
    }
  }
}
local action_list = {
  "logoin_stand",
  "grd_0h_stand",
  "logoin_stand_2",
  "fwz_s060_stand",
  "logoin_stand"
}
function form_main_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  change_form_size()
  self.yiqi_value = 0
  self.sworn_count = 0
  self.sworn_info = ""
  self.sworn_title_image = ""
  self.cur_image = ""
  init_title_preview(self)
  nx_execute("custom_sender", "custom_sworn", 0)
  self.rbtn_1.Checked = true
  self.rbtn_normal.Checked = true
  self.pic_speed = self.groupbox_normal.Width / 10
  self.pic_state = 0
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("JinLanValue", "int", self, nx_current(), "on_jinlan_value_changed")
  end
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("JinLanValue", self)
  end
  nx_destroy(self)
end
function change_form_size()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.groupbox_rbtn_main.Top = form.Height - form.groupbox_rbtn_main.Height
  form.groupbox_rbtn_main.Width = form.Width
  form.groupbox_1.Width = form.Width
  form.groupbox_1.Height = form.Height - form.groupbox_rbtn_main.Height
  form.groupbox_self.Height = form.groupbox_1.Height
  form.groupbox_sworn_1.Height = form.groupbox_1.Height
  form.groupbox_sworn_2.Height = form.groupbox_1.Height
  form.groupbox_sworn_3.Height = form.groupbox_1.Height
  form.groupbox_sworn_4.Height = form.groupbox_1.Height
  form.groupbox_sworn_5.Height = form.groupbox_1.Height
  form.groupbox_2.Width = form.Width
  form.groupbox_2.Height = form.Height - form.groupbox_rbtn_main.Height
  form.groupbox_3.Width = form.Width
  form.groupbox_3.Height = form.Height - form.groupbox_rbtn_main.Height
  form.groupbox_4.Width = form.Width
  form.groupbox_4.Height = form.Height - form.groupbox_rbtn_main.Height
  form.groupbox_5.Width = form.Width
  form.groupbox_5.Height = form.Height - form.groupbox_rbtn_main.Height
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  close_form()
end
function on_rbtn_1_checked_changed(rbtn)
  if rbtn.Checked == true then
    local form = rbtn.ParentForm
    form.groupbox_1.Visible = true
    form.groupbox_2.Visible = false
    form.groupbox_3.Visible = false
    form.groupbox_4.Visible = false
    form.groupbox_5.Visible = false
  end
end
function on_rbtn_2_checked_changed(rbtn)
  if rbtn.Checked == true then
    local form = rbtn.ParentForm
    form.groupbox_1.Visible = false
    form.groupbox_2.Visible = true
    form.groupbox_3.Visible = false
    form.groupbox_4.Visible = false
    form.groupbox_5.Visible = false
  end
end
function on_rbtn_3_checked_changed(rbtn)
  if rbtn.Checked == true then
    local form = rbtn.ParentForm
    form.groupbox_1.Visible = false
    form.groupbox_2.Visible = false
    form.groupbox_3.Visible = true
    form.groupbox_4.Visible = false
    form.groupbox_5.Visible = false
  end
end
function on_rbtn_4_checked_changed(rbtn)
  if rbtn.Checked == true then
    local form = rbtn.ParentForm
    form.groupbox_1.Visible = false
    form.groupbox_2.Visible = false
    form.groupbox_3.Visible = false
    form.groupbox_4.Visible = true
    form.groupbox_5.Visible = false
  end
end
function on_rbtn_5_checked_changed(rbtn)
  if rbtn.Checked == true then
    local form = rbtn.ParentForm
    form.groupbox_1.Visible = false
    form.groupbox_2.Visible = false
    form.groupbox_3.Visible = false
    form.groupbox_4.Visible = false
    form.groupbox_5.Visible = true
  end
end
function on_rbtn_normal_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.groupbox_normal.Visible = true
    form.groupbox_luxury.Visible = false
    init_normal_pic(form)
  end
end
function on_rbtn_luxury_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.groupbox_normal.Visible = false
    form.groupbox_luxury.Visible = true
    init_luxury_pic(form)
  end
end
function on_btn_normal_left_click(btn)
  local form = btn.ParentForm
  if form.pic_state == 1 then
    return
  end
  local timer = nx_value(GAME_TIMER)
  local pic_count = table.getn(scene_pic[1])
  form.normal_pic_index = math.mod(form.normal_pic_index, pic_count) + 1
  form.lbl_normal_scene.Text = nx_widestr(util_text(scene_pic[1][form.normal_pic_index][2]))
  if form.pic_state == 2 then
    timer:UnRegister(nx_current(), "on_time_nornal_right", form)
    form.temp = form.normal_pic_main
    form.normal_pic_main = form.normal_pic_vice
    form.normal_pic_vice = form.temp
  else
    form.normal_pic_vice.BackImage = nx_string(scene_pic[1][form.normal_pic_index][1])
    form.normal_pic_vice.Left = form.groupbox_normal_pic.Width
  end
  timer:UnRegister(nx_current(), "on_time_nornal_left", form)
  timer:Register(100, -1, nx_current(), "on_time_nornal_left", form, -1, -1)
  form.pic_state = 1
end
function on_btn_normal_right_click(btn)
  local form = btn.ParentForm
  if form.pic_state == 2 then
    return
  end
  local timer = nx_value(GAME_TIMER)
  local pic_count = table.getn(scene_pic[1])
  form.normal_pic_index = math.mod(form.normal_pic_index + pic_count - 2, pic_count) + 1
  form.lbl_normal_scene.Text = nx_widestr(util_text(scene_pic[1][form.normal_pic_index][2]))
  if form.pic_state == 1 then
    timer:UnRegister(nx_current(), "on_time_nornal_left", form)
    form.temp = form.normal_pic_main
    form.normal_pic_main = form.normal_pic_vice
    form.normal_pic_vice = form.temp
  else
    form.normal_pic_vice.BackImage = nx_string(scene_pic[1][form.normal_pic_index][1])
    form.normal_pic_vice.Left = 0 - form.groupbox_normal_pic.Width
  end
  timer:UnRegister(nx_current(), "on_time_nornal_right", form)
  timer:Register(100, -1, nx_current(), "on_time_nornal_right", form, -1, -1)
  form.pic_state = 2
end
function on_time_nornal_left(form, param1, param2)
  form.normal_pic_main.Left = form.normal_pic_main.Left - form.pic_speed
  form.normal_pic_vice.Left = form.normal_pic_vice.Left - form.pic_speed
  if form.normal_pic_main.Left + form.groupbox_normal_pic.Width <= 0 then
    form.temp = form.normal_pic_main
    form.normal_pic_main = form.normal_pic_vice
    form.normal_pic_vice = form.temp
    form.normal_pic_main.Left = 0
    form.pic_state = 0
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_time_nornal_left", form)
  end
end
function on_time_nornal_right(form, param1, param2)
  form.normal_pic_main.Left = form.normal_pic_main.Left + form.pic_speed
  form.normal_pic_vice.Left = form.normal_pic_vice.Left + form.pic_speed
  if form.normal_pic_main.Left >= form.groupbox_normal_pic.Width then
    form.temp = form.normal_pic_main
    form.normal_pic_main = form.normal_pic_vice
    form.normal_pic_vice = form.temp
    form.normal_pic_main.Left = 0
    form.pic_state = 0
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_time_nornal_right", form)
  end
end
function on_btn_luxury_left_click(btn)
  local form = btn.ParentForm
  if form.pic_state == 1 then
    return
  end
  local timer = nx_value(GAME_TIMER)
  local pic_count = table.getn(scene_pic[2])
  form.luxury_pic_index = math.mod(form.luxury_pic_index, pic_count) + 1
  form.lbl_luxury_scene.Text = nx_widestr(util_text(scene_pic[2][form.luxury_pic_index][2]))
  if form.pic_state == 2 then
    timer:UnRegister(nx_current(), "on_time_luxury_right", form)
  else
    form.luxury_pic_vice.BackImage = nx_string(scene_pic[2][form.luxury_pic_index][1])
    form.luxury_pic_vice.Left = form.groupbox_luxury_pic.Width
  end
  timer:UnRegister(nx_current(), "on_time_luxury_left", form)
  timer:Register(100, -1, nx_current(), "on_time_luxury_left", form, -1, -1)
  form.pic_state = 1
end
function on_btn_luxury_right_click(btn)
  local form = btn.ParentForm
  if form.pic_state == 2 then
    return
  end
  local timer = nx_value(GAME_TIMER)
  local pic_count = table.getn(scene_pic[2])
  form.luxury_pic_index = math.mod(form.luxury_pic_index + pic_count - 2, pic_count) + 1
  form.lbl_luxury_scene.Text = nx_widestr(util_text(scene_pic[2][form.luxury_pic_index][2]))
  if form.pic_state == 1 then
    timer:UnRegister(nx_current(), "on_time_luxury_left", form)
  else
    form.luxury_pic_vice.BackImage = nx_string(scene_pic[2][form.luxury_pic_index][1])
    form.luxury_pic_vice.Left = 0 - form.groupbox_luxury_pic.Width
  end
  timer:UnRegister(nx_current(), "on_time_luxury_right", form)
  timer:Register(100, -1, nx_current(), "on_time_luxury_right", form, -1, -1)
  form.pic_state = 2
end
function on_time_luxury_left(form, param1, param2)
  form.luxury_pic_main.Left = form.luxury_pic_main.Left - form.pic_speed
  form.luxury_pic_vice.Left = form.luxury_pic_vice.Left - form.pic_speed
  if form.luxury_pic_main.Left + form.groupbox_luxury_pic.Width <= 0 then
    form.temp = form.luxury_pic_main
    form.luxury_pic_main = form.luxury_pic_vice
    form.luxury_pic_vice = form.temp
    form.luxury_pic_main.Left = 0
    form.pic_state = 0
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_time_luxury_left", form)
  end
end
function on_time_luxury_right(form, param1, param2)
  form.luxury_pic_main.Left = form.luxury_pic_main.Left + form.pic_speed
  form.luxury_pic_vice.Left = form.luxury_pic_vice.Left + form.pic_speed
  if form.luxury_pic_main.Left >= form.groupbox_luxury_pic.Width then
    form.temp = form.luxury_pic_main
    form.luxury_pic_main = form.luxury_pic_vice
    form.luxury_pic_vice = form.temp
    form.luxury_pic_main.Left = 0
    form.pic_state = 0
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_time_luxury_right", form)
  end
end
function init_normal_pic(form)
  form.lbl_normal_pic_1.BackImage = nx_string(scene_pic[1][1][1])
  form.lbl_normal_scene.Text = nx_widestr(util_text(nx_string(scene_pic[1][1][2])))
  form.normal_pic_main = form.lbl_normal_pic_1
  form.normal_pic_vice = form.lbl_normal_pic_2
  form.normal_pic_index = nx_number(1)
  form.normal_pic_main.Left = 0
  form.normal_pic_main.Top = form.groupbox_normal.Top
  form.normal_pic_vice.Left = form.groupbox_normal.Width
  form.normal_pic_vice.Top = form.groupbox_normal.Top
end
function init_luxury_pic(form)
  form.lbl_luxury_pic_1.BackImage = nx_string(scene_pic[2][1][1])
  form.lbl_luxury_scene.Text = nx_widestr(util_text(nx_string(scene_pic[2][1][2])))
  form.luxury_pic_main = form.lbl_luxury_pic_1
  form.luxury_pic_vice = form.lbl_luxury_pic_2
  form.luxury_pic_index = nx_number(1)
  form.luxury_pic_main.Left = 0
  form.luxury_pic_main.Top = form.groupbox_luxury.Top
  form.luxury_pic_vice.Left = form.groupbox_luxury.Width
  form.luxury_pic_vice.Top = form.groupbox_luxury.Top
end
function update_sworn_info(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.has_sworn = arg[1]
  if nx_int(form.has_sworn) == nx_int(0) then
    form.groupbox_sworn_1_info.Visible = false
    form.groupbox_sworn_2_info.Visible = false
    form.groupbox_sworn_3_info.Visible = false
    form.groupbox_sworn_4_info.Visible = false
    form.groupbox_sworn_5_info.Visible = false
    update_other_info_black(form, form.scenebox_sworn_1, 2)
    update_other_info_black(form, form.scenebox_sworn_2, 3)
    update_other_info_black(form, form.scenebox_sworn_3, 4)
    update_other_info_black(form, form.scenebox_sworn_4, 5)
    update_other_info_black(form, form.scenebox_sworn_5, 6)
  elseif nx_int(form.has_sworn) == nx_int(1) then
    form.yiqi_value = nx_int(arg[3])
    form.lbl_jinlan_value.Text = nx_widestr(arg[2])
    form.lbl_yiqi_value.Text = nx_widestr(arg[3])
    form.lbl_36.Text = nx_widestr(util_format_string("ui_sworn037", nx_int(arg[4]), nx_int(arg[5])))
    form.lbl_38.Text = nx_widestr(util_format_string("ui_sworn038", nx_int(arg[6]), nx_int(arg[7])))
    if nx_int(arg[8]) > nx_int(0) then
      form.lbl_36.HintText = nx_widestr(util_format_string("ui_sworn_tips_jinlan_max", nx_int(arg[8])))
    end
    form.sworn_count = nx_int(arg[9])
    form.sworn_info = nx_widestr(arg[10])
    for i = 1, nx_number(form.sworn_count) do
      table.insert(face_list, nx_string(arg[10 + i]))
    end
    update_other_info(form)
  end
  update_self_info(form)
  update_location_sworn(form)
end
function update_self_info(form)
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
  local name = client_player:QueryProp("Name")
  local level_title = nx_string(client_player:QueryProp("LevelTitle"))
  local school = client_player:QueryProp("School")
  local force = client_player:QueryProp("Force")
  local newschool = client_player:QueryProp("NewSchool")
  form.lbl_self.Text = nx_widestr(name)
  form.lbl_self_info_1.Text = nx_widestr(util_text("desc_" .. level_title))
  if nx_string(newschool) ~= nx_string("") and nx_string(newschool) ~= nx_string("0") then
    form.lbl_self_info_2.Text = nx_widestr(util_text(newschool))
  elseif nx_string(force) ~= nx_string("") and nx_string(force) ~= nx_string("0") then
    form.lbl_self_info_2.Text = nx_widestr(util_text(force))
  elseif nx_string(school) ~= nx_string("") and nx_string(school) ~= nx_string("0") then
    form.lbl_self_info_2.Text = nx_widestr(util_text(school))
  else
    form.lbl_self_info_2.Text = nx_widestr(util_text("school_wulin"))
  end
  form.lbl_self_info_3.Text = nx_widestr(form.yiqi_value)
  local scenebox = form.scenebox_self
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if nx_find_custom(scenebox, "role_actor2") and nx_is_valid(scenebox.role_actor2) then
    local world = nx_value("world")
    world:Delete(scenebox.role_actor2)
  end
  if not nx_is_valid(scenebox.Scene) then
    util_addscene_to_scenebox(scenebox)
  end
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, scenebox.Scene)
  end
  local actor2 = create_scene_obj_composite(scenebox.Scene, client_player, false)
  if not nx_is_valid(actor2) then
    return
  end
  util_add_model_to_scenebox(scenebox, actor2)
  scenebox.role_actor2 = actor2
end
function update_location_sworn(form)
  local sworn_count = 0
  if form.sworn_count == nil or form.sworn_count == 0 then
    sworn_count = 5
  else
    sworn_count = nx_number(form.sworn_count)
  end
  for i = 1, sworn_count do
    local groupbox = form.groupbox_1:Find("groupbox_sworn_" .. nx_string(i))
    if nx_is_valid(groupbox) then
      groupbox.Visible = true
    end
  end
  form.groupbox_sworn_1.Left = nx_number(sworn_location[sworn_count][1][1])
  form.groupbox_sworn_1.Top = nx_number(sworn_location[sworn_count][1][2])
  form.groupbox_sworn_2.Left = nx_number(sworn_location[sworn_count][2][1])
  form.groupbox_sworn_2.Top = nx_number(sworn_location[sworn_count][2][2])
  form.groupbox_sworn_3.Left = nx_number(sworn_location[sworn_count][3][1])
  form.groupbox_sworn_3.Top = nx_number(sworn_location[sworn_count][3][2])
  form.groupbox_sworn_4.Left = nx_number(sworn_location[sworn_count][4][1])
  form.groupbox_sworn_4.Top = nx_number(sworn_location[sworn_count][4][2])
  form.groupbox_sworn_5.Left = nx_number(sworn_location[sworn_count][5][1])
  form.groupbox_sworn_5.Top = nx_number(sworn_location[sworn_count][5][2])
end
function update_other_info(form)
  if form.sworn_info == nil or form.sworn_info == "" then
    return
  end
  local sworn_list = util_split_wstring(nx_widestr(form.sworn_info), ";")
  for i = 1, table.getn(sworn_list) do
    local sworn_info_list = util_split_wstring(sworn_list[i], ",")
    if table.getn(sworn_info_list) >= 10 then
      local name = nx_widestr(sworn_info_list[1])
      local sex = nx_int(sworn_info_list[2])
      local school = nx_string(sworn_info_list[3])
      local force = nx_string(sworn_info_list[4])
      local newschool = nx_string(sworn_info_list[5])
      local level_title = nx_string(sworn_info_list[6])
      local show_type = nx_int(sworn_info_list[7])
      local hat = nx_string(sworn_info_list[8])
      local cloth = nx_string(sworn_info_list[9])
      local pants = nx_string(sworn_info_list[10])
      local shoes = nx_string(sworn_info_list[11])
      local body_type = nx_string(sworn_info_list[12])
      local body_face = nx_string(sworn_info_list[13])
      local face = face_list[i]
      local groupbox = form.groupbox_1:Find("groupbox_sworn_" .. nx_string(i))
      local lbl_name = groupbox:Find("lbl_sworn_" .. nx_string(i))
      local scenebox = groupbox:Find("scenebox_sworn_" .. nx_string(i))
      local groupbox_info = groupbox:Find("groupbox_sworn_" .. nx_string(i) .. "_info")
      local lbl_info_1 = groupbox_info:Find("lbl_sworn_" .. nx_string(i) .. "_info_1")
      local lbl_info_2 = groupbox_info:Find("lbl_sworn_" .. nx_string(i) .. "_info_2")
      local lbl_info_3 = groupbox_info:Find("lbl_sworn_" .. nx_string(i) .. "_info_3")
      lbl_name.Text = nx_widestr(name)
      lbl_info_1.Text = nx_widestr(util_text("desc_" .. level_title))
      if newschool ~= nx_string("") and newschool ~= nx_string("0") then
        lbl_info_2.Text = nx_widestr(util_text(newschool))
      elseif force ~= nx_string("") and force ~= nx_string("0") then
        lbl_info_2.Text = nx_widestr(util_text(force))
      elseif school ~= nx_string("") and school ~= nx_string("0") then
        lbl_info_2.Text = nx_widestr(util_text(school))
      else
        lbl_info_2.Text = nx_widestr(util_text("school_wulin"))
      end
      lbl_info_3.Text = nx_widestr(form.yiqi_value)
      groupbox.Visible = true
      if nx_find_custom(scenebox, "role_actor2") and nx_is_valid(scenebox.role_actor2) then
        local world = nx_value("world")
        world:Delete(scenebox.role_actor2)
      end
      if not nx_is_valid(scenebox.Scene) then
        util_addscene_to_scenebox(scenebox)
      end
      local world = nx_value("world")
      if nx_is_valid(world) then
        nx_call("scene", "support_physics", world, scenebox.Scene)
      end
      local actor2 = create_role_composite(scenebox.Scene, false, nx_number(sex), action_list[nx_number(i)], nx_number(body_type))
      nx_execute("role_composite", "unlink_skin", actor2, "Hat")
      link_skin(actor2, "hat", hat .. ".xmod", false)
      link_skin(actor2, "cloth", cloth .. ".xmod", false)
      link_skin(actor2, "pants", pants .. ".xmod", false)
      link_skin(actor2, "shoes", shoes .. ".xmod", false)
      local role_composite = nx_value("role_composite")
      if nx_is_valid(role_composite) then
        if nx_number(body_face) > nx_number(0) then
          role_composite:LinkFaceSkin(actor2, nx_int(sex), nx_number(body_face), false)
        elseif 0 < string.len(face) then
          role_composite:SetPlayerFaceDetial(get_role_face(actor2), nx_string(face), nx_int(sex), nx_null())
        end
      end
      if nx_int(show_type) == nx_int(1) then
        link_skin(actor2, "cloth_h", cloth .. "_h.xmod", false)
      end
      util_add_model_to_scenebox(scenebox, actor2)
      scenebox.role_actor2 = actor2
    end
  end
end
function update_other_info_black(form, scenebox, index)
  hat_model = {
    [0] = "obj\\char\\b_hair\\b_hair1",
    [1] = "obj\\char\\g_hair\\g_hair1"
  }
  cloth_model = {
    [0] = "obj\\char\\b_jianghu001\\b_cloth001",
    [1] = "obj\\char\\g_jianghu001\\g_cloth001"
  }
  pants_model = {
    [0] = "obj\\char\\b_jianghu001\\b_pants001",
    [1] = "obj\\char\\g_jianghu001\\g_pants001"
  }
  shoes_model = {
    [0] = "obj\\char\\b_jianghu001\\b_shoes001",
    [1] = "obj\\char\\g_jianghu001\\g_shoes001"
  }
  if not nx_is_valid(scenebox) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sworn_sex = 1
  local sex = client_player:QueryProp("Sex")
  sworn_sex = sex
  if nx_find_custom(scenebox, "role_actor2") and nx_is_valid(scenebox.role_actor2) then
    local world = nx_value("world")
    world:Delete(scenebox.role_actor2)
  end
  if not nx_is_valid(scenebox.Scene) then
    util_addscene_to_scenebox(scenebox)
  end
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, scenebox.Scene)
  end
  local actor2 = create_role_composite(scenebox.Scene, false, sworn_sex, action_list[index])
  local skin_info = {
    [1] = {
      link_name = "hat",
      model_name = hat_model[sworn_sex]
    },
    [2] = {
      link_name = "cloth",
      model_name = cloth_model[sworn_sex]
    },
    [3] = {
      link_name = "pants",
      model_name = pants_model[sworn_sex]
    },
    [4] = {
      link_name = "shoes",
      model_name = shoes_model[sworn_sex]
    }
  }
  for i, info in pairs(skin_info) do
    if info.model_name ~= nil then
      link_skin(actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
  util_add_model_to_scenebox(scenebox, actor2)
  scenebox.role_actor2 = actor2
  nx_function("ext_set_model_single_color", actor2, "0.05,0.05,0.05")
  nx_function("ext_set_model_around_color", actor2, "0.69,0.825,0.996", "0.005")
end
function get_role_face(actor2)
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor_role_face = actor_role:GetLinkObject("actor_role_face")
  if not nx_is_valid(actor_role_face) then
    return nil
  end
  return actor_role_face
end
function init_title_preview(form)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  form.groupbox_preview.Visible = true
  local groupbox = form:Find("groupbox_1")
  if not nx_is_valid(groupbox) then
    return
  end
  local groupbox_preview = groupbox:Find("groupbox_preview")
  if not nx_is_valid(groupbox_preview) then
    return
  end
  form.sworn_0.Enabled = false
  form.sworn_1.Enabled = false
  form.sworn_2.Enabled = false
  form.sworn_3.Enabled = false
  form.sworn_4.Enabled = false
  form.sworn_5.Enabled = false
  form.sworn_6.Enabled = false
  form.sworn_7.Enabled = false
  form.sworn_8.Enabled = false
  form.sworn_9.Enabled = false
  form.sworn_10.Enabled = false
  nx_execute("custom_sender", "custom_sworn", nx_int(7))
end
function on_title_checked_changed(btn)
  if btn.Checked == true then
    local form = btn.ParentForm
    form.sworn_title_image = nx_string(btn.Name)
  end
end
function on_btn_use_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if nx_string(form.sworn_title_image) == nx_string("") then
    return
  end
  nx_execute("custom_sender", "custom_sworn", nx_int(6), nx_string(form.sworn_title_image))
end
function on_btn_preview_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_preview.Visible then
    form.groupbox_preview.Visible = false
  else
    form.groupbox_preview.Visible = true
  end
end
function get_title_info(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local arg_count = table.getn(arg)
  if arg_count < 1 then
    return
  end
  local groupbox = form:Find("groupbox_1")
  if not nx_is_valid(groupbox) then
    return
  end
  local groupbox_preview = groupbox:Find("groupbox_preview")
  if not nx_is_valid(groupbox_preview) then
    return
  end
  form.cur_image = arg[1]
  if 1 < arg_count then
    for i = 2, arg_count do
      local image_name = arg[i]
      local control = groupbox_preview:Find(nx_string(image_name))
      if nx_is_valid(control) then
        control.Enabled = true
        if nx_string(image_name) == nx_string(form.cur_image) then
          control.Checked = true
        end
      end
    end
  end
end
function on_btn_mall_click(btn)
  open_mall(FORM_NAME, nx_int(1))
end
function on_jinlan_value_changed(form)
  if not nx_is_valid(form) then
    return
  end
  local jinlan_value = get_jinlan_value()
  form.lbl_jinlan_value.Text = nx_widestr(jinlan_value)
end
function get_jinlan_value()
  local player = get_player()
  if not nx_is_valid(player) then
    return 0
  end
  local jinlan_value = 0
  if player:FindProp("JinLanValue") then
    jinlan_value = player:QueryProp("JinLanValue")
  end
  return jinlan_value
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil
  end
  local client_player = game_client:GetPlayer()
  return client_player
end
