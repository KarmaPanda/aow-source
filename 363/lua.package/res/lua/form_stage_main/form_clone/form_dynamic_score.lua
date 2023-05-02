require("share\\server_custom_define")
require("share\\client_custom_define")
require("const_define")
require("util_gui")
require("control_set")
local FORM_MAIN_PATH = "form_stage_main\\form_clone\\form_dynamic_score"
local FORM_MAIN_LUA_PATH = "form_stage_main\\form_clone\\form_dynamic_score"
local IMAGE_PATH_BOSS_NULL = "gui\\common\\button\\btn_taolu2_down.png"
local IMAGE_PATH_BOSS_LIVE = "gui\\common\\button\\btn_taolu2_on.png"
local IMAGE_PATH_BOSS_DEAD = "gui\\common\\button\\btn_taolu2_out.png"
local ScoreForm_Update = 0
function close_form()
  local form = nx_value(FORM_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function custom_handle(head_msg, ...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_msg = nx_number(arg[1])
  if nx_number(ScoreForm_Update) == sub_msg then
    if table.getn(arg) < 10 then
      return
    end
    local score_total = nx_int(arg[2])
    local score_num = nx_int(arg[3])
    local point_num = nx_int(arg[4])
    local boss_dead_num = nx_int(arg[5])
    local boss_create_num = nx_int(arg[6])
    local cur_boss_id = nx_string(arg[7])
    local boss_pos_x = nx_int(arg[8])
    local boss_pos_z = nx_int(arg[9])
    local taolu_limit_id = nx_int(arg[10])
    local form = util_get_form(FORM_MAIN_PATH, true, false)
    if not nx_is_valid(form) then
      return
    end
    form:Show()
    form.taolu_id = taolu_limit_id
    form.boss_id = cur_boss_id
    form.boss_pos_x = boss_pos_x
    form.boss_pos_z = boss_pos_z
    update(form, score_total, score_num, point_num, boss_dead_num, boss_create_num)
  end
end
function on_main_form_init(form)
  form.Fixed = false
  form.flag_num = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_point.Visible = false
  local level = 1
  local game_client = nx_value("game_client")
  local scene = game_client:GetScene()
  if nx_is_valid(scene) and scene:FindProp("Level") then
    level = scene:QueryProp("Level")
  end
  if nx_number(level) ~= 2 then
    form.btn_taolu.Enabled = false
  else
    form.btn_taolu.Enabled = true
  end
  form.lbl_hint1.Visible = false
  form.lbl_hint2.Visible = false
  form.lbl_hint3.Visible = false
  if nx_number(level) == 1 then
    local is_hint = GetIniInfo("dynamic_clone_hint_normal")
    if is_hint == 0 then
      form.lbl_hint1.Visible = true
    end
  elseif nx_number(level) == 2 then
    local is_hint = GetIniInfo("dynamic_clone_hint_hard")
    if is_hint == 0 then
      form.lbl_hint1.Visible = true
      form.lbl_hint2.Visible = true
    end
  end
  form.Left = gui.Width - form.Width - 240
  form.Top = 120
  form.is_show_end = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_taolu_click(btn, mouseID)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "taolu_id") then
    return
  end
  local taolu_form = nx_value("form_stage_main\\form_clone\\form_taolu_select")
  if nx_is_valid(taolu_form) then
    return
  end
  nx_execute("form_stage_main\\form_clone\\form_taolu_select", "open_form", form.taolu_id)
end
function on_lbl_back_get_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local level = 1
  local game_client = nx_value("game_client")
  local scene = game_client:GetScene()
  if nx_is_valid(scene) and scene:FindProp("Level") then
    level = scene:QueryProp("Level")
  end
  if nx_number(level) == 1 then
    if form.lbl_hint1.Visible then
      SetIniInfo("dynamic_clone_hint_normal", 1)
      form.lbl_hint1.Visible = false
    end
  elseif form.lbl_hint1.Visible or form.lbl_hint2.Visible then
    SetIniInfo("dynamic_clone_hint_hard", 1)
    form.lbl_hint1.Visible = false
    form.lbl_hint2.Visible = false
  end
end
function on_btn_taolu_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local level = 1
  local game_client = nx_value("game_client")
  local scene = game_client:GetScene()
  if nx_is_valid(scene) and scene:FindProp("Level") then
    level = scene:QueryProp("Level")
  end
  if nx_number(level) == 1 then
    if form.lbl_hint1.Visible then
      SetIniInfo("dynamic_clone_hint_normal", 1)
      form.lbl_hint1.Visible = false
    end
  elseif form.lbl_hint1.Visible or form.lbl_hint2.Visible then
    SetIniInfo("dynamic_clone_hint_hard", 1)
    form.lbl_hint1.Visible = false
    form.lbl_hint2.Visible = false
  end
end
function on_lbl_icon_get_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local level = 1
  local game_client = nx_value("game_client")
  local scene = game_client:GetScene()
  if nx_is_valid(scene) and scene:FindProp("Level") then
    level = scene:QueryProp("Level")
  end
  if nx_number(level) == 1 then
    if form.lbl_hint1.Visible then
      SetIniInfo("dynamic_clone_hint_normal", 1)
      form.lbl_hint1.Visible = false
    end
  elseif form.lbl_hint1.Visible or form.lbl_hint2.Visible then
    SetIniInfo("dynamic_clone_hint_hard", 1)
    form.lbl_hint1.Visible = false
    form.lbl_hint2.Visible = false
  end
  form.lbl_hint3.Visible = false
end
function update(form, score_total, score_num, point_num, boss_dead_num, boss_create_num)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local cur_width = nx_float(score_num) / score_total * 177
  if 177 < nx_number(cur_width) then
    cur_width = 177
  end
  if nx_number(cur_width) <= 0 then
    form.lbl_score.Visible = false
  else
    form.lbl_score.Visible = true
    form.lbl_score.Width = nx_int(cur_width)
  end
  if nx_number(form.flag_num) > nx_number(point_num) then
    local start_index = point_num + 1
    for i = nx_number(start_index), nx_number(form.flag_num) do
      local ctrl_name = string.format("lbl_point%d", nx_number(i))
      local ctrl_obj = nx_object(form:Find(ctrl_name))
      if nx_is_valid(ctrl_obj) then
        form:Remove(ctrl_obj)
        gui:Delete(ctrl_obj)
      end
    end
  elseif nx_number(form.flag_num) < nx_number(point_num) then
    local start_index = form.flag_num + 1
    for i = nx_number(start_index), nx_number(point_num) do
      local new_ctrl = gui.Designer:Clone(form.lbl_point)
      if nx_is_valid(new_ctrl) then
        new_ctrl.Visible = true
        nx_bind_script(new_ctrl, nx_current())
        new_ctrl.DesignMode = false
        new_ctrl.Name = string.format("lbl_point%d", nx_number(i))
        form:Add(new_ctrl)
      end
    end
  end
  form.flag_num = point_num
  for i = 1, nx_number(form.flag_num) do
    local ctrl_name = string.format("lbl_point%d", nx_number(i))
    local ctrl_obj = nx_object(form:Find(ctrl_name))
    if nx_is_valid(ctrl_obj) then
      ctrl_obj.Left = form.lbl_point.Left + (i - 1) * form.lbl_point.Width
      ctrl_obj.Top = form.lbl_point.Top
      if i < nx_number(boss_create_num) then
        ctrl_obj.BackImage = nx_string(IMAGE_PATH_BOSS_DEAD)
        ctrl_obj.HintText = nx_widestr(gui.TextManager:GetFormatText("sys_clonezone_009"))
      elseif i == nx_number(boss_create_num) then
        if nx_number(boss_dead_num) == nx_number(boss_create_num) then
          ctrl_obj.BackImage = nx_string(IMAGE_PATH_BOSS_DEAD)
          ctrl_obj.HintText = nx_widestr(gui.TextManager:GetFormatText("sys_clonezone_009"))
        else
          ctrl_obj.BackImage = nx_string(IMAGE_PATH_BOSS_LIVE)
          ctrl_obj.HintText = nx_widestr(gui.TextManager:GetFormatText("sys_clonezone_008", nx_string(form.boss_id), nx_int(form.boss_pos_x), nx_int(form.boss_pos_z)))
        end
      else
        ctrl_obj.BackImage = nx_string(IMAGE_PATH_BOSS_NULL)
        ctrl_obj.HintText = nx_widestr(gui.TextManager:GetFormatText("sys_clonezone_007"))
      end
    end
  end
  if nx_number(point_num) == nx_number(boss_dead_num) then
    if form.is_show_end then
      form.is_show_end = false
      form.lbl_hint3.Visible = true
      form.lbl_icon.BackImage = nx_string("gui\\common\\form_back\\clone_shuangjian2.png")
      local tips_id = "ui_clone_tlxz_18"
      local game_client = nx_value("game_client")
      local scene = game_client:GetScene()
      if nx_is_valid(scene) and scene:FindProp("SourceID") then
        tips_id = nx_string("ui_clone_tlxz_18") .. "_" .. nx_string(scene:QueryProp("SourceID"))
      end
      form.lbl_icon.HintText = nx_widestr(gui.TextManager:GetFormatText(nx_string(tips_id)))
    end
  else
    form.lbl_icon.BackImage = nx_string("gui\\common\\form_back\\clone_shuangjian1.png")
    form.lbl_icon.HintText = nx_widestr("")
  end
end
