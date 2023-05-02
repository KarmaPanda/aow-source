require("custom_sender")
require("share\\view_define")
require("share\\itemtype_define")
require("define\\gamehand_type")
require("form_stage_main\\form_tvt\\define")
require("util_gui")
SanHill_ClientMsg_Join = 1
SanHill_ClientMsg_Leave = 2
SanHill_ClientMsg_Reset = 3
SanHill_ClientMsg_OpenUI = 4
SanHill_ClientMsg_Quit = 5
SanHill_ClientMsg_Unlock = 6
SanHill_ClientMsg_Invite = 9
SanHill_ClientMsg_AccpetInvite = 10
SanHill_ClientMsg_BeginFight = 11
SanHill_ClientMsg_Dolive = 12
SanHill_ServerMsg_OpenForm = 1
SanHill_ServerMsg_OpenReadyUI = 2
SanHill_ServerMsg_OpenInviteUI = 3
SanHill_ServerMsg_SuccessUI = 4
SanHill_ServerMsg_FailUI = 5
SanHill_ServerMsg_Dolive = 6
SanHill_ServerMsg_OpenFightUI = 7
SanHill_ServerMsg_Unlock = 8
SanHill_ServerMsg_LeaveScene = 9
SanHill_ServerMsg_RankInfo = 10
SanHill_ServerMsg_GetFightTimes = 11
boss_icon_col = 1
star_num_col = 2
is_pass_col = 3
max_surcount_col = 4
week_is_pass_col = 5
col_count = 5
local FORM = "form_stage_main\\form_skyhill\\form_sanhill"
local star_image = "gui\\special\\03skyhill\\wancheng.png"
local finish_image = "gui\\special\\03skyhill\\gou.png"
local lock_image = "gui\\special\\03skyhill\\kuang_daisuo.png"
local back_image1 = "gui\\special\\03skyhill\\01.png"
local back_image2 = "gui\\special\\03skyhill\\02.png"
local back_image3 = "gui\\special\\03skyhill\\03.png"
local max_progress = 10
local title_text_table = {
  [1] = "ui_fyy_clone1",
  [2] = "ui_fyy_clone2",
  [3] = "ui_fyy_clone3",
  [4] = "ui_fyy_clone4",
  [5] = "ui_fyy_clone5",
  [6] = "ui_fyy_clone6"
}
local open_condition_text_table = {
  [1] = "ui_fyy_clone1_condition",
  [2] = "ui_fyy_clone2_condition",
  [3] = "ui_fyy_clone3_condition",
  [4] = "ui_fyy_clone4_condition",
  [5] = "ui_fyy_clone5_condition",
  [6] = "ui_fyy_clone6_condition"
}
local next_explain_1 = "ui_fyy_clone1_text"
local next_explain_2 = "ui_fyy_clone3_text"
local next_explain_3 = "ui_fyy_clone5_text"
function main_form_init(form)
  form.cur_lay_flag = 0
  form.reset_num_flag = 0
  form.tips_num_flag = 0
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  form.select_index = 0
  form.select_boss_icon = ""
  form.open_ceng = 0
  form.open_boss = 0
  form.unlock = 0
  form.sur_count = 0
  form.max_surcount = 0
  form.week_challenge_count = 0
  form.is_timer = 0
  nx_execute("custom_sender", "custom_sanhill_msg", SanHill_ClientMsg_OpenUI)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "sanhill_btn_unlock", form)
    nx_destroy(form)
  end
end
function on_btn_state_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_sanhill_msg", SanHill_ClientMsg_Join, form.select_index)
end
function on_server_msg(sub_msg, ...)
  if nx_int(sub_msg) == nx_int(SanHill_ServerMsg_OpenForm) then
    local form = nx_value(FORM)
    if not nx_is_valid(form) then
      return
    end
    refresh_form(form, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(SanHill_ServerMsg_OpenReadyUI) then
    local form_ready = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_skyhill\\form_sanhill_ready", true, false)
    if not nx_is_valid(form_ready) then
      return
    end
    form_ready:Show()
    local form_box = nx_value("form_stage_main\\form_main\\form_main_box")
    if nx_is_valid(form_box) then
      form_box:Close()
    end
    local form_clone = nx_value("form_stage_main\\form_clone\\form_clone_main")
    if nx_is_valid(form_clone) then
      form_clone:Close()
    end
    nx_execute("form_stage_main\\form_skyhill\\form_sanhill_ready", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(SanHill_ServerMsg_OpenInviteUI) then
    local form_invite = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_skyhill\\form_sanhill_invite", true, false)
    if not nx_is_valid(form_invite) then
      return
    end
    form_invite:Show()
    nx_execute("form_stage_main\\form_skyhill\\form_sanhill_invite", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(SanHill_ServerMsg_SuccessUI) then
    local form_success = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_skyhill\\form_sanhill_success", true, false)
    if not nx_is_valid(form_success) then
      return
    end
    form_success:Show()
    nx_execute("form_stage_main\\form_skyhill\\form_sanhill_success", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(SanHill_ServerMsg_FailUI) then
    local form_fail = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_skyhill\\form_sanhill_fail", true, false)
    if not nx_is_valid(form_fail) then
      return
    end
    form_fail:Show()
    nx_execute("form_stage_main\\form_skyhill\\form_sanhill_fail", "open_form")
  elseif nx_int(sub_msg) == nx_int(SanHill_ServerMsg_Dolive) then
    is_dolive()
  elseif nx_int(sub_msg) == nx_int(SanHill_ServerMsg_OpenFightUI) then
    show_fight_ui(unpack(arg))
  elseif nx_int(sub_msg) == nx_int(SanHill_ServerMsg_Unlock) then
    unlock_ceng(arg[1])
  elseif nx_int(sub_msg) == nx_int(SanHill_ServerMsg_LeaveScene) then
    local form_ready = nx_value("form_stage_main\\form_skyhill\\form_sanhill_ready")
    if nx_is_valid(form_ready) then
      form_ready:Close()
    end
    local form_success = nx_value("form_stage_main\\form_skyhill\\form_sanhill_success")
    if nx_is_valid(form_success) then
      form_success:Close()
    end
    local form_fail = nx_value("form_stage_main\\form_skyhill\\form_sanhill_fail")
    if nx_is_valid(form_fail) then
      form_fail:Close()
    end
    local form_invite = nx_value("form_stage_main\\form_skyhill\\form_sanhill_invite")
    if nx_is_valid(form_invite) then
      form_invite:Close()
    end
    local form_fight = nx_value("form_stage_main\\form_skyhill\\form_sanhill_fight")
    if nx_is_valid(form_fight) then
      form_fight:Close()
    end
  elseif nx_int(sub_msg) == nx_int(SanHill_ServerMsg_RankInfo) then
    local form_rank = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_skyhill\\form_sanhill_rank", true, false)
    if not nx_is_valid(form_rank) then
      return
    end
    local form_clone_main = nx_value("form_stage_main\\form_clone\\form_clone_main")
    if not nx_is_valid(form_clone_main) then
      return
    end
    nx_execute("form_stage_main\\form_skyhill\\form_sanhill_rank", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(SanHill_ServerMsg_GetFightTimes) then
    local form_rank = nx_value("form_stage_main\\form_skyhill\\form_sanhill_fight")
    if not nx_is_valid(form_rank) then
      return
    end
    nx_execute("form_stage_main\\form_skyhill\\form_sanhill_fight", "set_fighttimes", unpack(arg))
  end
end
function clone_control(form, control_name, aid)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local control = nx_custom(form, nx_string(control_name))
  local new_control = gui.Designer:Clone(control)
  if not nx_is_valid(new_control) then
    return nx_null()
  end
  nx_bind_script(new_control, nx_current())
  new_control.DesignMode = false
  new_control.Name = string.format("%s_%s", nx_string(control_name), nx_string(aid))
  new_control.Visible = true
  new_control.aid = aid
  local child_list = control:GetChildControlList()
  for _, child_control in pairs(child_list) do
    if nx_is_valid(child_control) then
      local new_child = gui.Designer:Clone(child_control)
      new_child.fatherctl = new_control
      new_child.DesignMode = false
      new_child.Name = string.format("%s_%s", nx_string(child_control.Name), nx_string(aid))
      new_child.aid = aid
      new_control:Add(new_child)
    end
  end
  return new_control
end
function refresh_form(form, ...)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local framebox = form.framebox
  local ceng_box = form.ceng_box
  local temp_table = arg
  local now_ceng = temp_table[1]
  form.week_challenge_count = temp_table[2]
  local last_lvl = temp_table[3]
  local reward1 = temp_table[4]
  local reward2 = temp_table[5]
  local reward3 = temp_table[6]
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  local count = table.getn(temp_table) / (5 * col_count)
  if nx_int(count) <= nx_int(0) then
    return
  end
  local gui = nx_value("gui")
  framebox.IsEditMode = true
  local index = 1
  for i = 1, count do
    local item_box = clone_control(form, "ceng_box", nx_string(i))
    framebox:Add(item_box)
    item_box.Left = 5
    for j = 1, 5 do
      local sub_index = (i - 1) * 5 + j
      local boss_icon_index = (i - 1) * (5 * col_count) + (j - 1) * col_count + boss_icon_col
      local boss_icon = temp_table[boss_icon_index]
      local star_num_index = (i - 1) * (5 * col_count) + (j - 1) * col_count + star_num_col
      local star_num = temp_table[star_num_index]
      local is_pass_index = (i - 1) * (5 * col_count) + (j - 1) * col_count + is_pass_col
      local is_pass = temp_table[is_pass_index]
      local max_surcount_index = (i - 1) * (5 * col_count) + (j - 1) * col_count + max_surcount_col
      local max_surcount = temp_table[max_surcount_index]
      local week_is_pass_index = (i - 1) * (5 * col_count) + (j - 1) * col_count + week_is_pass_col
      local week_is_pass = temp_table[week_is_pass_index]
      local child_name = string.format("%s_%s", nx_string("boss_icon") .. nx_string(j), nx_string(i))
      local boss_icon_control = item_box:Find(child_name)
      boss_icon_control.BackImage = nx_string(boss_icon)
      child_name = string.format("%s_%s", nx_string("star") .. nx_string(j), nx_string(i))
      local star_control = item_box:Find(child_name)
      if nx_int(star_num) <= nx_int(0) then
        star_control.Text = nx_widestr("")
        star_control.BackImage = star_image
        boss_icon_control.BlendColor = "250,255,255,255"
      else
        star_control.BackImage = ""
        boss_icon_control.BlendColor = "255,255,255,255"
      end
      child_name = string.format("%s_%s", nx_string("lbl_flag") .. nx_string(j), nx_string(i))
      local lbl_flag_control = item_box:Find(child_name)
      lbl_flag_control.Visible = true
      child_name = string.format("%s_%s", nx_string("rbtn_select") .. nx_string(j), nx_string(i))
      local select_control = item_box:Find(child_name)
      select_control.index = index
      select_control.select_boss_icon = boss_icon
      select_control.sur_count = star_num
      select_control.max_surcount = max_surcount
      if nx_int(last_lvl) == nx_int(sub_index) then
        select_control.Checked = true
        form.select_index = select_control.index
        form.select_boss_icon = select_control.select_boss_icon
        form.sur_count = select_control.sur_count
        form.max_surcount = select_control.max_surcount
      end
      nx_bind_script(select_control, nx_current())
      nx_callback(select_control, "on_click", "on_rbtn_select_click")
      index = index + 1
      if nx_int(is_pass) > nx_int(0) then
        form.open_ceng = i
        form.open_boss = sub_index
      end
      if nx_int(form.open_boss + 1) < nx_int(sub_index) or nx_int(star_num) <= nx_int(0) then
        select_control.Enabled = false
      else
        select_control.Enabled = true
        lbl_flag_control.BackImage = ""
      end
      if nx_int(form.open_boss + 1) < nx_int(sub_index) then
        lbl_flag_control.BackImage = nx_string(lock_image)
      end
      if nx_int(week_is_pass) > nx_int(0) then
        lbl_flag_control.BackImage = nx_string(finish_image)
      end
    end
    local child_name = string.format("%s_%s", nx_string("btn_lock"), nx_string(i))
    local btn_lock_control = item_box:Find(child_name)
    nx_bind_script(btn_lock_control, nx_current())
    nx_callback(btn_lock_control, "on_click", "on_btn_lock_click")
    child_name = string.format("%s_%s", nx_string("back_image"), nx_string(i))
    local back_image_control = item_box:Find(child_name)
    child_name = string.format("%s_%s", nx_string("mltbox_open_condition"), nx_string(i))
    local mltbox_open_condition_control = item_box:Find(child_name)
    mltbox_open_condition_control.HtmlText = nx_widestr(gui.TextManager:GetText(open_condition_text_table[i]))
    if nx_int(i) <= nx_int(now_ceng) then
      back_image_control.Visible = false
      btn_lock_control.Visible = false
      mltbox_open_condition_control.Visible = false
    end
    child_name = string.format("%s_%s", nx_string("lbl_title"), nx_string(i))
    local lbl_title_control = item_box:Find(child_name)
    lbl_title_control.Text = nx_widestr(gui.TextManager:GetText(title_text_table[i]))
    child_name = string.format("%s_%s", nx_string("lbl_reward"), nx_string(i))
    local lbl_reward_control = item_box:Find(child_name)
    nx_bind_script(lbl_reward_control, nx_current())
    nx_callback(lbl_reward_control, "on_mousein_grid", "on_mousein_lbl_reward_grid")
    nx_callback(lbl_reward_control, "on_mouseout_grid", "on_mouseout_lbl_reward_grid")
    if nx_int(i) == nx_int(2) then
      local photo = ItemQuery:GetItemPropByConfigID(reward1, "Photo")
      lbl_reward_control:AddItem(0, photo, nx_widestr(reward1), 1, 0)
    elseif nx_int(i) == nx_int(4) then
      local photo = ItemQuery:GetItemPropByConfigID(reward2, "Photo")
      lbl_reward_control:AddItem(0, photo, nx_widestr(reward2), 1, 0)
    elseif nx_int(i) == nx_int(6) then
      local photo = ItemQuery:GetItemPropByConfigID(reward3, "Photo")
      lbl_reward_control:AddItem(0, photo, nx_widestr(reward3), 1, 0)
    end
    lbl_reward_control.Visible = true
    child_name = string.format("%s_%s", nx_string("mltbox"), nx_string(i))
    local mltbox_control = item_box:Find(child_name)
    mltbox_control.HtmlText = nx_widestr("")
    mltbox_control.Visible = false
    if nx_int(i) == nx_int(1) then
      lbl_reward_control.Visible = false
      mltbox_control.Visible = true
      mltbox_control.HtmlText = nx_widestr(gui.TextManager:GetText(next_explain_1))
    elseif nx_int(i) == nx_int(3) then
      lbl_reward_control.Visible = false
      mltbox_control.Visible = true
      mltbox_control.HtmlText = nx_widestr(gui.TextManager:GetText(next_explain_2))
    elseif nx_int(i) == nx_int(5) then
      lbl_reward_control.Visible = false
      mltbox_control.Visible = true
      mltbox_control.HtmlText = nx_widestr(gui.TextManager:GetText(next_explain_3))
    end
    if nx_int(i) == nx_int(1) or nx_int(i) == nx_int(2) then
      item_box.BackImage = nx_string(back_image1)
    elseif nx_int(i) == nx_int(3) or nx_int(i) == nx_int(4) then
      item_box.BackImage = nx_string(back_image2)
    elseif nx_int(i) == nx_int(5) or nx_int(i) == nx_int(6) then
      item_box.BackImage = nx_string(back_image3)
    end
  end
  if nx_int(now_ceng) == nx_int(0) then
    form.groupscrollbox_2.Visible = false
    form.btn_state.Visible = false
  else
    form.groupscrollbox_2.Visible = true
    form.btn_state.Visible = true
  end
  if nx_int(form.select_index) == nx_int(0) then
    local ceng_name = string.format("%s_%s", nx_string("ceng_box"), nx_string(1))
    local item_box = framebox:Find(ceng_name)
    local child_name = string.format("%s_%s", nx_string("rbtn_select") .. nx_string(1), nx_string(1))
    local select_control = item_box:Find(child_name)
    select_control.Checked = true
    form.select_index = select_control.index
    form.select_boss_icon = select_control.select_boss_icon
    form.sur_count = select_control.sur_count
    form.max_surcount = select_control.max_surcount
  end
  refresh_right_info(form)
  unlock_logic(form)
  framebox.IsEditMode = false
  framebox:ResetChildrenYPos()
end
function unlock_logic(form)
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local framebox = form.framebox
  for i = 1, 6 do
    local ceng_name = string.format("%s_%s", nx_string("ceng_box"), nx_string(i))
    local item_box = framebox:Find(ceng_name)
    local child_name = string.format("%s_%s", nx_string("btn_lock"), nx_string(i))
    local btn_lock_control = item_box:Find(child_name)
    local ceng = nx_int(nx_int(form.open_boss) / nx_int(5)) + 1
    if nx_int(ceng) >= nx_int(i) and btn_lock_control.Visible == true then
      local conditionid = 0
      if nx_int(i) == nx_int(1) or nx_int(i) == nx_int(2) then
        conditionid = 117241
      elseif nx_int(i) == nx_int(3) or nx_int(i) == nx_int(4) then
        conditionid = 117242
      elseif nx_int(i) == nx_int(5) or nx_int(i) == nx_int(6) then
        conditionid = 117264
      end
      local b_ok = condition_manager:CanSatisfyCondition(player, player, conditionid)
      if b_ok then
        btn_lock_control.Enabled = true
      else
        btn_lock_control.Enabled = false
      end
    else
      btn_lock_control.Enabled = false
    end
  end
end
function reset_last_select_boss(form, index)
  local framebox = form.framebox
  if nx_int(form.select_index) == nx_int(0) then
    return
  end
  local row = nx_int(form.select_index / 5)
  local col = nx_int(form.select_index % 5)
  if nx_int(col) == nx_int(0) then
    col = 5
  else
    row = row + 1
  end
  local ceng_name = string.format("%s_%s", nx_string("ceng_box"), nx_string(row))
  local item_box = framebox:Find(ceng_name)
  local child_name = string.format("%s_%s", nx_string("rbtn_select") .. nx_string(col), nx_string(row))
  local select_control = item_box:Find(child_name)
  if nx_int(index) == nx_int(form.select_index) then
    select_control.Checked = true
  else
    select_control.Checked = false
  end
end
function refresh_right_info(form)
  local gui = nx_value("gui")
  local SanHillManager = nx_value("SanHillManager")
  if not nx_is_valid(SanHillManager) then
    return
  end
  local index = form.select_index
  if nx_int(index) <= nx_int(0) then
    return
  end
  form.lbl_select_boss.BackImage = nx_string(SanHillManager:GetBossIcon(index))
  form.lbl_select_boss_name.Text = nx_widestr(gui.TextManager:GetText(SanHillManager:GetBossName(index)))
  form.lbl_select_boss_power.Text = nx_widestr(gui.TextManager:GetText(SanHillManager:GetBossPower(index)))
  form.mltbox_boss_info.HtmlText = nx_widestr(gui.TextManager:GetText(SanHillManager:GetBossInfo(index)))
  form.mltbox_pass_info.HtmlText = nx_widestr(gui.TextManager:GetText(SanHillManager:GetPassInfo(index)))
  form.mltbox_pass_strategy.HtmlText = nx_widestr(gui.TextManager:GetText(SanHillManager:GetPassStrategy(index)))
  form.lbl_cur_pass.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sanhill_level_info", nx_int(form.select_index)))
  form.lbl_last_chall_num.Text = nx_widestr(nx_string(form.sur_count))
  form.lbl_chall_max_num.Text = nx_widestr(form.week_challenge_count)
end
function on_btn_lock_click(btn)
  local form = btn.ParentForm
  if nx_int(form.is_timer) > nx_int(0) then
    return
  end
  local aid = btn.aid
  nx_execute("custom_sender", "custom_sanhill_msg", SanHill_ClientMsg_Unlock, nx_int(aid))
end
function unlock_ceng(ceng)
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local framebox = form.framebox
  form.unlock = ceng
  local ceng_name = string.format("%s_%s", nx_string("ceng_box"), nx_string(ceng))
  local item_box = framebox:Find(ceng_name)
  local child_name = string.format("%s_%s", nx_string("back_image"), nx_string(ceng))
  local back_image_control = item_box:Find(child_name)
  child_name = string.format("%s_%s", nx_string("btn_lock"), nx_string(ceng))
  local btn_lock_control = item_box:Find(child_name)
  child_name = string.format("%s_%s", nx_string("mltbox_open_condition"), nx_string(ceng))
  local mltbox_open_condition_control = item_box:Find(child_name)
  local timer = nx_value("timer_game")
  timer:UnRegister(form, "sanhill_btn_unlock", form)
  timer:Register(100, -1, nx_current(), "sanhill_btn_unlock", form, -1, -1)
  btn_lock_control.Visible = false
  mltbox_open_condition_control.Visible = false
  if nx_int(form.unlock) == nx_int(0) then
    form.groupscrollbox_2.Visible = false
    form.btn_state.Visible = false
  else
    form.groupscrollbox_2.Visible = true
    form.btn_state.Visible = true
  end
  refresh_right_info(form)
end
function sanhill_btn_unlock(form)
  local timer = nx_value("timer_game")
  local framebox = form.framebox
  local aid = form.unlock
  form.is_timer = 1
  local ceng_name = string.format("%s_%s", nx_string("ceng_box"), nx_string(aid))
  local item_box = framebox:Find(ceng_name)
  local child_name = string.format("%s_%s", nx_string("back_image"), nx_string(aid))
  local back_image_control = item_box:Find(child_name)
  local str = util_split_string(nx_string(back_image_control.BlendColor), ",")
  local alpha = nx_int(str[1])
  alpha = alpha - 10
  back_image_control.BlendColor = nx_string(nx_string(alpha) .. "," .. nx_string(str[2]) .. "," .. nx_string(str[3]) .. "," .. nx_string(str[4]))
  if nx_int(alpha) <= nx_int(0) then
    form.is_timer = 0
    back_image_control.Visible = false
    timer:UnRegister(nx_current(), "sanhill_btn_unlock", form)
  end
end
function on_rbtn_select_click(rbtn)
  local form = rbtn.ParentForm
  reset_last_select_boss(form, rbtn.index)
  form.select_index = rbtn.index
  form.select_boss_icon = rbtn.select_boss_icon
  form.sur_count = rbtn.sur_count
  form.max_surcount = rbtn.max_surcount
  refresh_right_info(form)
end
function is_dolive()
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_sanhill_is_dolive")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_sanhill_msg", SanHill_ClientMsg_Dolive)
  end
end
function show_fight_ui(...)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  local form_fight = nx_value("form_stage_main\\form_skyhill\\form_sanhill_fight")
  if nx_is_valid(form_fight) then
    return
  end
  local level = arg[1]
  local limit_time = arg[2]
  local dead_count = arg[3]
  local titile = arg[4]
  local content1 = arg[5]
  local content2 = arg[6]
  if form.ani_sanhill_title_open.Visible == true or form.ani_sanhill_title_close.Visible == true or form.ani_sanhill_content.Visible == true or form.sanhill_groupbox.Visible == true then
    return
  end
  form.ani_sanhill_content.level = level
  form.ani_sanhill_content.limit_time = limit_time
  form.ani_sanhill_content.dead_count = dead_count
  form.ani_sanhill_content.content1 = content1
  form.ani_sanhill_content.content2 = content2
  local gui = nx_value("gui")
  form.ani_sanhill_title_open.Left = (gui.Width - form.ani_sanhill_title_open.Width) / 2
  form.ani_sanhill_title_open.Loop = false
  form.ani_sanhill_title_open.PlayMode = 2
  form.ani_sanhill_title_open.Visible = true
  form.ani_sanhill_title_open:Play()
  form.mltbox_sanhill_title.HtmlText = nx_widestr(gui.TextManager:GetText(nx_string(titile)))
end
function show_passlevel_info(level, limit_time, dead_count, content1, content2)
  local temp_table = {}
  table.insert(temp_table, level)
  table.insert(temp_table, limit_time)
  table.insert(temp_table, dead_count)
  table.insert(temp_table, content1)
  table.insert(temp_table, content2)
  local form_fight = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_skyhill\\form_sanhill_fight", true, false)
  if not nx_is_valid(form_fight) then
    return
  end
  form_fight:Show()
  nx_execute("form_stage_main\\form_skyhill\\form_sanhill_fight", "open_form", unpack(temp_table))
end
function is_in_sanhill()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nx_int(0)
  end
  if not client_player:FindProp("InteractStatus") then
    return nx_int(0)
  end
  local state = nx_int(client_player:QueryProp("InteractStatus"))
  if state == nx_int(ITT_SAN_HILL) then
    return nx_int(1)
  else
    return nx_int(0)
  end
end
function on_mousein_lbl_reward_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_mouseout_lbl_reward_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
  if 0 >= table.getn(table_prop_name) then
    return
  end
  table_prop_value.ConfigID = nx_string(prize_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", "task_grid_data")
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_set_custom(grid.Data, "is_static", true)
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
  grid.Data:ClearChild()
end
