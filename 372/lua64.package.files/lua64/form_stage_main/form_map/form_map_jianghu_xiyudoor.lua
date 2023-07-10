require("util_gui")
local FORM_PATH = "form_stage_main\\form_map\\form_map_jianghu_xiyudoor"
local LUA_PATH = "form_stage_main\\form_map\\form_map_jianghu_xiyudoor"
local ImagePath = "gui\\map\\area\\jianghu_interface\\"
local JHSCENE_INI_PATH = "ini\\jhscene_choose.ini"
local SERVER_SUB_CHOOSEFORM_OPEN = 4
local SERVER_SUB_CHOOSEFORM_SCENEINFO = 5
local SERVER_SUB_CHOOSEFORM_CLEAN_OK = 6
local CUSTOM_SUB_CHOOSEFORM_CHOOSE = 6
local CUSTOM_SUB_CHOOSEFORM_TRANSJH = 7
local CUSTOM_SUB_CHOOSEFORM_CLEAN_COOL = 8
local GROUPPOS_NULL = -1
local GROUPPOS_LEFT_UP = 0
local GROUPPOS_RIGHT_UP = 1
local GROUPPOS_LEFT_DOWN = 2
local GROUPPOS_RIGHT_DOWN = 3
function open_form(group_num, left_up_id, right_up_id, left_down_id, right_down_id, week_leave)
  if group_num == nil or left_up_id == nil or right_up_id == nil or left_down_id == nil or right_down_id == nil or week_leave == nil then
    return
  end
  local form = util_get_form(FORM_PATH, true)
  if not nx_is_valid(form) then
    return
  end
  init_form(form)
  form.left_up_scene = nx_string(left_up_id)
  form.right_up_scene = nx_string(right_up_id)
  form.left_down_scene = nx_string(left_down_id)
  form.right_down_scene = nx_string(right_down_id)
  form.group_num = nx_int(group_num)
  form.week_leave = nx_int(week_leave)
  update_form(form)
  form.choose_scene = GROUPPOS_LEFT_UP
  update_choose_form(form)
  form.Visible = true
  form:Show()
  nx_execute("util_gui", "ui_show_attached_form", form)
end
function init_form(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_sum.Text = gui.TextManager:GetFormatText("jhscene_grain_sum", nx_int(0))
  form.lbl_foe.Text = gui.TextManager:GetFormatText("jhscene_grain_foe", nx_int(0))
  form.lbl_count_down.Text = gui.TextManager:GetFormatText("jhscene_grain_countdown", nx_int(0), nx_int(0), nx_int(0))
  form.lbl_area.Text = nx_widestr("")
  form.lbl_find_time.Text = gui.TextManager:GetFormatText("jhscene_grain_select")
  form.lbl_area_map.BackImage = ""
  form.btn_left_top.NormalImage = ""
  form.btn_left_top.FocusImage = ""
  form.btn_left_top.PushImage = ""
  form.btn_left_top.TestTrans = true
  form.btn_right_top.NormalImage = ""
  form.btn_right_top.FocusImage = ""
  form.btn_right_top.PushImage = ""
  form.btn_right_top.TestTrans = true
  form.btn_left_down.NormalImage = ""
  form.btn_left_down.FocusImage = ""
  form.btn_left_down.PushImage = ""
  form.btn_left_down.TestTrans = true
  form.btn_right_down.NormalImage = ""
  form.btn_right_down.FocusImage = ""
  form.btn_right_down.PushImage = ""
  form.btn_right_down.TestTrans = true
  form.btn_move.HintText = nx_widestr("")
  form.choose_scene = GROUPPOS_NULL
  form.clean_cool_price = nx_int(0)
  form.cool_time_count = nx_int(0)
  form.clone_photo_num = nx_int(0)
  form.clone_photo_cur = nx_int(0)
end
function update_form(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local file_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\jhscene_choose.ini")
  if not nx_is_valid(file_ini) then
    return
  end
  form.lbl_residue.Text = gui.TextManager:GetFormatText("jhscene_canentry_count", nx_int(form.week_leave))
  local text_id = "jhscene_area_" .. nx_string(form.group_num)
  form.lbl_area.Text = gui.TextManager:GetFormatText(text_id)
  form.lbl_area_map.BackImage = ImagePath .. "jhscene_area_map_" .. nx_string(form.group_num) .. ".png"
  form.btn_move.Enabled = false
  form.btn_clear_time.Enabled = false
  form.btn_left.Visible = false
  form.btn_right.Visible = false
  if form.left_up_scene ~= nx_string("") and form.left_up_scene ~= nx_string("0") then
    form.btn_left_top.NormalImage = ImagePath .. "jhscene_normal_" .. form.left_up_scene .. ".png"
    form.btn_left_top.FocusImage = ImagePath .. "jhscene_focus_" .. form.left_up_scene .. ".png"
    form.btn_left_top.PushImage = ImagePath .. "jhscene_push_" .. form.left_up_scene .. ".png"
    text_id = "jhscene_scenename_tips_" .. form.left_up_scene
    form.btn_left_top.HintText = gui.TextManager:GetFormatText(text_id)
    local pos_left = 0
    local pos_top = 0
    local sect_config_index = file_ini:FindSectionIndex(nx_string(form.left_up_scene))
    if nx_int(sect_config_index) >= nx_int(0) then
      pos_left = nx_int(file_ini:ReadInteger(sect_config_index, "Left", 0))
      pos_top = nx_int(file_ini:ReadInteger(sect_config_index, "Top", 0))
    end
    form.btn_left_top.Left = pos_left
    form.btn_left_top.Top = pos_top
    form.btn_left_top.Visable = true
  else
    form.btn_left_top.Visable = false
  end
  if form.right_up_scene ~= nx_string("") and form.right_up_scene ~= nx_string("0") then
    form.btn_right_top.NormalImage = ImagePath .. "jhscene_normal_" .. form.right_up_scene .. ".png"
    form.btn_right_top.FocusImage = ImagePath .. "jhscene_focus_" .. form.right_up_scene .. ".png"
    form.btn_right_top.PushImage = ImagePath .. "jhscene_push_" .. form.right_up_scene .. ".png"
    text_id = "jhscene_scenename_tips_" .. form.right_up_scene
    form.btn_right_top.HintText = gui.TextManager:GetFormatText(text_id)
    local pos_left = 0
    local pos_top = 0
    local sect_config_index = file_ini:FindSectionIndex(nx_string(form.right_up_scene))
    if nx_int(sect_config_index) >= nx_int(0) then
      pos_left = nx_int(file_ini:ReadInteger(sect_config_index, "Left", 0))
      pos_top = nx_int(file_ini:ReadInteger(sect_config_index, "Top", 0))
    end
    form.btn_right_top.Left = pos_left
    form.btn_right_top.Top = pos_top
    form.btn_right_top.Visable = true
  else
    form.btn_right_top.Visable = false
  end
  if form.left_down_scene ~= nx_string("") and form.left_down_scene ~= nx_string("0") then
    form.btn_left_down.NormalImage = ImagePath .. "jhscene_normal_" .. form.left_down_scene .. ".png"
    form.btn_left_down.FocusImage = ImagePath .. "jhscene_focus_" .. form.left_down_scene .. ".png"
    form.btn_left_down.PushImage = ImagePath .. "jhscene_push_" .. form.left_down_scene .. ".png"
    text_id = "jhscene_scenename_tips_" .. form.left_down_scene
    form.btn_left_down.HintText = gui.TextManager:GetFormatText(text_id)
    local pos_left = 0
    local pos_top = 0
    local sect_config_index = file_ini:FindSectionIndex(nx_string(form.left_down_scene))
    if nx_int(sect_config_index) >= nx_int(0) then
      pos_left = nx_int(file_ini:ReadInteger(sect_config_index, "Left", 0))
      pos_top = nx_int(file_ini:ReadInteger(sect_config_index, "Top", 0))
    end
    form.btn_left_down.Left = pos_left
    form.btn_left_down.Top = pos_top
    form.btn_left_down.Visable = true
  else
    form.btn_left_down.Visable = false
  end
  if form.right_down_scene ~= nx_string("") and form.right_down_scene ~= nx_string("0") then
    form.btn_right_down.NormalImage = ImagePath .. "jhscene_normal_" .. form.right_down_scene .. ".png"
    form.btn_right_down.FocusImage = ImagePath .. "jhscene_focus_" .. form.right_down_scene .. ".png"
    form.btn_right_down.PushImage = ImagePath .. "jhscene_push_" .. form.right_down_scene .. ".png"
    text_id = "jhscene_scenename_tips_" .. form.right_down_scene
    form.btn_right_down.HintText = gui.TextManager:GetFormatText(text_id)
    local pos_left = 0
    local pos_top = 0
    local sect_config_index = file_ini:FindSectionIndex(nx_string(form.right_down_scene))
    if nx_int(sect_config_index) >= nx_int(0) then
      pos_left = nx_int(file_ini:ReadInteger(sect_config_index, "Left", 0))
      pos_top = nx_int(file_ini:ReadInteger(sect_config_index, "Top", 0))
    end
    form.btn_right_down.Left = pos_left
    form.btn_right_down.Top = pos_top
    form.btn_right_down.Visable = true
  else
    form.btn_right_down.Visable = false
  end
end
function update_choose_form(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  form.btn_left_top.NormalImage = ImagePath .. "jhscene_normal_" .. form.left_up_scene .. ".png"
  form.btn_right_top.NormalImage = ImagePath .. "jhscene_normal_" .. form.right_up_scene .. ".png"
  form.btn_left_down.NormalImage = ImagePath .. "jhscene_normal_" .. form.left_down_scene .. ".png"
  form.btn_right_down.NormalImage = ImagePath .. "jhscene_normal_" .. form.right_down_scene .. ".png"
  form.btn_move.Enabled = false
  form.btn_clear_time.Enabled = false
  if form.choose_scene ~= GROUPPOS_NULL then
    local choose_scene_name = ""
    if form.choose_scene == GROUPPOS_LEFT_UP then
      choose_scene_name = form.left_up_scene
      form.btn_left_top.NormalImage = ImagePath .. "jhscene_focus_" .. form.left_up_scene .. ".png"
    elseif form.choose_scene == GROUPPOS_RIGHT_UP then
      choose_scene_name = form.right_up_scene
      form.btn_right_top.NormalImage = ImagePath .. "jhscene_focus_" .. form.right_up_scene .. ".png"
    elseif form.choose_scene == GROUPPOS_LEFT_DOWN then
      choose_scene_name = form.left_down_scene
      form.btn_left_down.NormalImage = ImagePath .. "jhscene_focus_" .. form.left_down_scene .. ".png"
    elseif form.choose_scene == GROUPPOS_RIGHT_DOWN then
      choose_scene_name = form.right_down_scene
      form.btn_right_down.NormalImage = ImagePath .. "jhscene_focus_" .. form.right_down_scene .. ".png"
    else
      return
    end
    form.lbl_find_time.Text = gui.TextManager:GetFormatText("jhscene_grain_select")
    form.mltbox_1:Clear()
    for i = 1, 6 do
      local group_box = form.groupbox_caiji:Find("groupscrollbox_1")
      local item_icon = group_box:Find("caiji_icon_" .. nx_string(i))
      local item_name = group_box:Find("caiji_name_" .. nx_string(i))
      if nx_is_valid(item_icon) then
        item_icon.BackImage = ""
      end
      if nx_is_valid(item_name) then
        item_name.Text = nx_widestr("")
      end
    end
    for i = 1, 3 do
      local group_box = form:Find("groupbox_caiji")
      local item_icon = group_box:Find("lbl_monster_" .. nx_string(i))
      local item_name = group_box:Find("lbl_monster_name_" .. nx_string(i))
      if nx_is_valid(item_icon) then
        item_icon.BackImage = ""
      end
      if nx_is_valid(item_name) then
        item_name.Text = nx_widestr("")
      end
    end
    for i = 1, 8 do
      local group_box = form.groupbox_shili:Find("groupscrollbox_2")
      local item_icon = group_box:Find("shili_icon_" .. nx_string(i))
      local item_name = group_box:Find("lbl_shili_name_" .. nx_string(i))
      if nx_is_valid(item_icon) then
        item_icon.BackImage = ""
        item_icon.HintText = nx_widestr("")
      end
      if nx_is_valid(item_name) then
        item_name.Text = nx_widestr("")
      end
    end
    form.lbl_name.BackImage = ""
    form.lbl_name.HintText = nx_widestr("")
    local jhscene_ini = nx_execute("util_functions", "get_ini", JHSCENE_INI_PATH)
    if nx_is_valid(jhscene_ini) then
      local sect_index = jhscene_ini:FindSectionIndex(choose_scene_name)
      if nx_int(sect_index) >= nx_int(0) then
        local scene_name_id = jhscene_ini:ReadString(sect_index, "SceneName", "")
        form.lbl_find_time.Text = gui.TextManager:GetFormatText(scene_name_id)
        local scene_brief_id = jhscene_ini:ReadString(sect_index, "SceneBrief", "")
        form.mltbox_1:Clear()
        form.mltbox_1:AddHtmlText(gui.TextManager:GetFormatText(scene_brief_id), -1)
        local specialty_list = jhscene_ini:ReadString(sect_index, "SpecialtyList", "")
        local specialty_table = util_split_string(nx_string(specialty_list), ";")
        local specialty_num = table.getn(specialty_table)
        if nx_int(specialty_num) > nx_int(0) then
          for i = 1, specialty_num do
            local specialty_value = util_split_string(nx_string(specialty_table[i]), ",")
            local value_num = table.getn(specialty_value)
            if nx_int(value_num) >= nx_int(2) then
              local specialty_icon = specialty_value[1]
              local specialty_name = specialty_value[2]
              local group_box = form.groupbox_caiji:Find("groupscrollbox_1")
              local item_icon = group_box:Find("caiji_icon_" .. nx_string(i))
              local item_name = group_box:Find("caiji_name_" .. nx_string(i))
              if nx_is_valid(item_icon) and nx_is_valid(item_name) then
                item_icon.BackImage = ImagePath .. specialty_icon .. ".png"
                item_name.Text = gui.TextManager:GetFormatText(specialty_name)
              end
            end
          end
        end
        local boss_list = jhscene_ini:ReadString(sect_index, "BossList", "")
        local boss_table = util_split_string(nx_string(boss_list), ";")
        local boss_num = table.getn(boss_table)
        if nx_int(boss_num) > nx_int(0) then
          for i = 1, boss_num do
            local boss_value = util_split_string(nx_string(boss_table[i]), ",")
            local value_num = table.getn(boss_value)
            if nx_int(value_num) >= nx_int(2) then
              local boss_icon = boss_value[1]
              local boss_name = boss_value[2]
              local group_box = form:Find("groupbox_caiji")
              local item_icon = group_box:Find("lbl_monster_" .. nx_string(i))
              local item_name = group_box:Find("lbl_monster_name_" .. nx_string(i))
              if nx_is_valid(item_icon) and nx_is_valid(item_name) then
                item_icon.BackImage = ImagePath .. boss_icon .. ".png"
                item_name.Text = gui.TextManager:GetFormatText(boss_name)
              end
            end
          end
        end
        local force_list = jhscene_ini:ReadString(sect_index, "ForceList", "")
        local force_table = util_split_string(nx_string(force_list), ";")
        local force_num = table.getn(force_table)
        if nx_int(force_num) > nx_int(0) then
          for i = 1, force_num do
            local force_value = util_split_string(nx_string(force_table[i]), ",")
            local value_num = table.getn(force_value)
            if nx_int(value_num) >= nx_int(3) then
              local force_icon = force_value[1]
              local force_name = force_value[2]
              local force_tips = force_value[3]
              local group_box = form.groupbox_shili:Find("groupscrollbox_2")
              local item_icon = group_box:Find("shili_icon_" .. nx_string(i))
              local item_name = group_box:Find("lbl_shili_name_" .. nx_string(i))
              if nx_is_valid(item_icon) and nx_is_valid(item_name) then
                item_icon.BackImage = ImagePath .. force_icon .. ".png"
                item_icon.HintText = gui.TextManager:GetFormatText(force_tips)
                item_name.Text = gui.TextManager:GetFormatText(force_name)
              end
            end
          end
        end
        common_array:RemoveArray("ClonePhotoTable")
        common_array:RemoveArray("CloneTipsTable")
        local clone_list = jhscene_ini:ReadString(sect_index, "CloneList", "")
        local clone_table = util_split_string(nx_string(clone_list), ";")
        local clone_num = table.getn(clone_table)
        form.clone_photo_num = nx_int(clone_num)
        if nx_int(clone_num) > nx_int(0) then
          common_array:AddArray("ClonePhotoTable", form, 3600, false)
          common_array:AddArray("CloneTipsTable", form, 3600, false)
          for i = 1, clone_num do
            local clone_value = util_split_string(nx_string(clone_table[i]), ",")
            local value_num = table.getn(clone_value)
            if nx_int(value_num) >= nx_int(2) then
              common_array:AddChild("ClonePhotoTable", nx_string(i), clone_value[1])
              common_array:AddChild("CloneTipsTable", nx_string(i), clone_value[2])
            end
          end
          form.clone_photo_cur = nx_int(1)
        else
          form.clone_photo_num = nx_int(0)
          form.clone_photo_cur = nx_int(0)
        end
        update_clone_photo(form)
      end
    end
    nx_execute("custom_sender", "custom_send_scene_jhpk", nx_int(CUSTOM_SUB_CHOOSEFORM_CHOOSE), nx_int(form.choose_scene))
  end
end
function update_clone_photo(form)
  form.btn_left.Visible = false
  form.btn_right.Visible = false
  form.lbl_name.BackImage = ""
  form.lbl_name.HintText = nx_widestr("")
  if nx_int(form.clone_photo_num) <= nx_int(0) then
    return
  end
  if nx_int(form.clone_photo_cur) <= nx_int(0) or nx_int(form.clone_photo_cur) > nx_int(form.clone_photo_num) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.btn_left.Visible = true
  form.btn_right.Visible = true
  if nx_int(form.clone_photo_cur) == nx_int(1) then
    form.btn_left.Visible = false
  end
  if nx_int(form.clone_photo_cur) == nx_int(form.clone_photo_num) then
    form.btn_right.Visible = false
  end
  local photo_name = nx_string(common_array:FindChild("ClonePhotoTable", nx_string(form.clone_photo_cur)))
  local photo_tips_id = nx_string(common_array:FindChild("CloneTipsTable", nx_string(form.clone_photo_cur)))
  form.lbl_name.BackImage = ImagePath .. photo_name .. ".png"
  form.lbl_name.HintText = gui.TextManager:GetFormatText(photo_tips_id)
end
function update_scene_info(player_num, enemy_num, cool_time, clean_cool_price)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if player_num ~= nil then
    form.lbl_sum.Text = gui.TextManager:GetFormatText("jhscene_grain_sum", nx_int(player_num))
  end
  if enemy_num ~= nil then
    form.lbl_foe.Text = gui.TextManager:GetFormatText("jhscene_grain_foe", nx_int(enemy_num))
  end
  if cool_time ~= nil then
    form.cool_time_count = nx_int(cool_time)
    update_cool_time(form)
  end
  if clean_cool_price ~= nil then
    form.clean_cool_price = nx_int(clean_cool_price)
  end
end
function update_cool_time(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_number(form.cool_time_count) > 0 then
    local total_sec = form.cool_time_count
    local hour = nx_int(total_sec / 3600)
    total_sec = math.mod(total_sec, 3600)
    local minter = nx_int(total_sec / 60)
    local second = nx_int(math.mod(total_sec, 60))
    form.lbl_count_down.Text = gui.TextManager:GetFormatText("jhscene_grain_countdown", hour, minter, second)
    form.btn_move.Enabled = false
    form.btn_move.HintText = gui.TextManager:GetFormatText("scene_access_tips_1")
    form.btn_clear_time.Enabled = true
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_time_cool_count", form)
      timer:Register(1000, -1, nx_current(), "on_time_cool_count", form, -1, -1)
    end
  else
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_time_cool_count", form)
    end
    form.lbl_count_down.Text = gui.TextManager:GetFormatText("jhscene_grain_countdown", nx_int(0), nx_int(0), nx_int(0))
    if nx_int(form.week_leave) > nx_int(0) then
      form.btn_move.Enabled = true
      form.btn_move.HintText = nx_widestr("")
    else
      form.btn_move.Enabled = false
      form.btn_move.HintText = gui.TextManager:GetFormatText("scene_access_tips_1")
    end
    form.btn_clear_time.Enabled = false
  end
end
function on_time_cool_count(form)
  if not nx_is_valid(form) then
    return
  end
  form.cool_time_count = form.cool_time_count - 1
  if nx_number(form.cool_time_count) < 0 then
    form.cool_time_count = nx_int(0)
  end
  update_cool_time(form)
end
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.left_up_scene = nx_string("")
  form.right_up_scene = nx_string("")
  form.left_down_scene = nx_string("")
  form.right_down_scene = nx_string("")
  form.choose_scene = GROUPPOS_NULL
  form.clean_cool_price = nx_int(0)
  form.cool_time_count = nx_int(0)
  form.group_num = nx_int(0)
  form.week_leave = nx_int(0)
  form.clone_photo_num = nx_int(0)
  form.clone_photo_cur = nx_int(0)
end
function on_main_form_open(form)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_time_cool_count", form)
  end
  local common_array = nx_value("common_array")
  if nx_is_valid(common_array) then
    common_array:RemoveArray("ClonePhotoTable")
    common_array:RemoveArray("CloneTipsTable")
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_btn_move_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  if goods_grid:IsPlayerOldEquips() then
    nx_execute("form_stage_main\\form_home\\form_home_move", "open_form", form.choose_scene)
    form.Visible = false
    form:Close()
    return
  end
  if form.choose_scene ~= GROUPPOS_NULL then
    nx_execute("custom_sender", "custom_send_scene_jhpk", nx_int(CUSTOM_SUB_CHOOSEFORM_TRANSJH), nx_int(form.choose_scene), nx_int(1))
    form.Visible = false
    form:Close()
  end
end
function on_btn_clear_time_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if form.choose_scene ~= GROUPPOS_NULL then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local capital = client_player:QueryProp("CapitalType2")
    if nx_int(capital) < nx_int(form.clean_cool_price) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_money_2"), 2)
      end
      return
    end
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "jhscene_cleancool")
    if not nx_is_valid(dialog) then
      return
    end
    dialog:ShowModal()
    local text = gui.TextManager:GetFormatText("jhscene_confirm_clean_cool", nx_int(form.clean_cool_price))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    local res = nx_wait_event(100000000, dialog, "jhscene_cleancool_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_send_scene_jhpk", nx_int(CUSTOM_SUB_CHOOSEFORM_CLEAN_COOL), nx_int(form.choose_scene))
    end
  end
end
function on_btn_left_top_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.choose_scene = GROUPPOS_LEFT_UP
  update_choose_form(form)
end
function on_btn_right_top_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.choose_scene = GROUPPOS_RIGHT_UP
  update_choose_form(form)
end
function on_btn_left_down_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.choose_scene = GROUPPOS_LEFT_DOWN
  update_choose_form(form)
end
function on_btn_right_down_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.choose_scene = GROUPPOS_RIGHT_DOWN
  update_choose_form(form)
end
function on_btn_left_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.clone_photo_cur) > nx_int(1) then
    form.clone_photo_cur = form.clone_photo_cur - 1
    update_clone_photo(form)
  end
end
function on_btn_right_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.clone_photo_cur) < nx_int(form.clone_photo_num) and nx_int(form.clone_photo_cur) > nx_int(0) then
    form.clone_photo_cur = form.clone_photo_cur + 1
    update_clone_photo(form)
  end
end
function custom_message_callback(...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_msg = nx_number(arg[1])
  if sub_msg == SERVER_SUB_CHOOSEFORM_OPEN then
    if table.getn(arg) < 7 then
      return
    end
    open_form(arg[2], arg[3], arg[4], arg[5], arg[6], arg[7])
  elseif sub_msg == SERVER_SUB_CHOOSEFORM_SCENEINFO then
    if table.getn(arg) < 6 then
      return
    end
    local form = nx_value(FORM_PATH)
    if not nx_is_valid(form) then
      return
    end
    local choose_scene_name = ""
    if form.choose_scene == GROUPPOS_LEFT_UP then
      choose_scene_name = form.left_up_scene
    elseif form.choose_scene == GROUPPOS_RIGHT_UP then
      choose_scene_name = form.right_up_scene
    elseif form.choose_scene == GROUPPOS_LEFT_DOWN then
      choose_scene_name = form.left_down_scene
    elseif form.choose_scene == GROUPPOS_RIGHT_DOWN then
      choose_scene_name = form.right_down_scene
    end
    if choose_scene_name == nx_string(arg[2]) then
      update_scene_info(arg[3], arg[4], arg[5], arg[6])
    end
  elseif sub_msg == SERVER_SUB_CHOOSEFORM_CLEAN_OK then
    if table.getn(arg) < 2 then
      return
    end
    local form = nx_value(FORM_PATH)
    if not nx_is_valid(form) then
      return
    end
    local choose_scene_name = ""
    if form.choose_scene == GROUPPOS_LEFT_UP then
      choose_scene_name = form.left_up_scene
    elseif form.choose_scene == GROUPPOS_RIGHT_UP then
      choose_scene_name = form.right_up_scene
    elseif form.choose_scene == GROUPPOS_LEFT_DOWN then
      choose_scene_name = form.left_down_scene
    elseif form.choose_scene == GROUPPOS_RIGHT_DOWN then
      choose_scene_name = form.right_down_scene
    end
    if choose_scene_name == nx_string(arg[2]) then
      form.cool_time_count = nx_int(0)
      update_cool_time(form)
    end
  end
end
