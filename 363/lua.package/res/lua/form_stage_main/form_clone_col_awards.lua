require("share\\view_define")
require("util_gui")
require("game_object")
require("util_static_data")
require("define\\tip_define")
require("share\\client_custom_define")
require("share\\capital_define")
local COL_LEVEL_ANI = {
  ["1"] = "tg_score_level_2",
  ["2"] = "tg_score_level_3",
  ["3"] = "tg_score_level_4"
}
BOXAWARD_TYPE_TONG = 0
BOXAWARD_TYPE_YIN = 1
BOXAWARD_TYPE_JIN = 2
MOUSE_ON = 0
MOUSE_OUT = 1
MOUSE_CLICK = 2
box_image_tab = {
  [BOXAWARD_TYPE_TONG] = {
    [MOUSE_ON] = "gui\\animations\\tiguan\\box_tie_on.png",
    [MOUSE_OUT] = "gui\\animations\\tiguan\\box_tie_out.png",
    [MOUSE_CLICK] = "gui\\animations\\tiguan\\box_tie_click.png"
  },
  [BOXAWARD_TYPE_YIN] = {
    [MOUSE_ON] = "gui\\animations\\tiguan\\box_yin_on.png",
    [MOUSE_OUT] = "gui\\animations\\tiguan\\box_yin_out.png",
    [MOUSE_CLICK] = "gui\\animations\\tiguan\\box_yin_click.png"
  },
  [BOXAWARD_TYPE_JIN] = {
    [MOUSE_ON] = "gui\\animations\\tiguan\\box_jin_on.png",
    [MOUSE_OUT] = "gui\\animations\\tiguan\\box_jin_out.png",
    [MOUSE_CLICK] = "gui\\animations\\tiguan\\box_jin_click.png"
  }
}
function main_form_init(self)
  self.Fixed = true
  self.isOpen = false
  self.isView = false
  return 1
end
function on_main_form_open(self)
  local b_relationship = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_relationship")
  if b_relationship then
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_relationship")
  end
  change_form_size(self)
  self.Fixed = false
end
function change_form_size(self)
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  nx_destroy(self)
  local form = nx_value("form_stage_main\\form_itembind\\form_itembind_pickup")
  if nx_is_valid(form) then
    form:Close()
  end
  local form1 = nx_value("form_stage_main\\form_team\\form_team_assign")
  if nx_is_valid(form1) then
    form1:Close()
  end
end
function on_btn_close_click(self)
  local Parent_form = self.Parent
  if nx_is_valid(Parent_form) then
    Parent_form:Close()
  end
  local form_rank = nx_value("form_stage_main\\form_damage_statistics_rank")
  if nx_is_valid(form_rank) then
    form_rank:Close()
  end
  local award_form = nx_value("form_stage_main\\form_clone_awards")
  if nx_is_valid(award_form) then
    award_form.Visible = true
  end
end
function on_lbl_open_click(lbl)
  local form = lbl.Parent
  local boss_id = ""
  nx_execute("custom_sender", "custom_clone_request_open_col_award")
  lbl.Visible = false
end
function refresh_col_award_form(form, score_level, ntotal_score, col_use_time, col_try_count)
  if not nx_is_valid(form) then
    return
  end
  local col_lv = nx_int(score_level)
  if nx_int(col_lv) < nx_int(1) then
    col_lv = 1
  end
  if nx_int(col_lv) > nx_int(3) then
    col_lv = 3
  end
  form.box_type = col_lv - 1
  local use_time_minute = col_use_time / 60
  local use_time_hour = use_time_minute / 60
  use_time_minute = use_time_minute % 60
  form.lbl_score.Text = nx_widestr(nx_string(ntotal_score))
  form.lbl_time_hour.Text = nx_widestr(nx_string(nx_int(use_time_hour)))
  form.lbl_time_minute.Text = nx_widestr(nx_string(use_time_minute))
  form.lbl_try_count.Text = nx_widestr(nx_string(col_try_count))
  form.ani_lv.AnimationImage = nx_string(COL_LEVEL_ANI[nx_string(col_lv)])
  form.ani_lv.Loop = false
  form.ani_lv.PlayMode = 0
  form.ani_lv:PlayPauseAt(0)
  if form.box_type == BOXAWARD_TYPE_JIN then
    form.cbtn_box.NormalImage = box_image_tab[BOXAWARD_TYPE_JIN][MOUSE_ON]
    form.cbtn_box.FocusImage = box_image_tab[BOXAWARD_TYPE_JIN][MOUSE_OUT]
    form.cbtn_box.CheckedImage = box_image_tab[BOXAWARD_TYPE_JIN][MOUSE_CLICK]
  elseif form.box_type == BOXAWARD_TYPE_YIN then
    form.cbtn_box.NormalImage = box_image_tab[BOXAWARD_TYPE_YIN][MOUSE_ON]
    form.cbtn_box.FocusImage = box_image_tab[BOXAWARD_TYPE_YIN][MOUSE_OUT]
    form.cbtn_box.CheckedImage = box_image_tab[BOXAWARD_TYPE_YIN][MOUSE_CLICK]
  elseif form.box_type == BOXAWARD_TYPE_TONG then
    form.cbtn_box.NormalImage = box_image_tab[BOXAWARD_TYPE_TONG][MOUSE_ON]
    form.cbtn_box.FocusImage = box_image_tab[BOXAWARD_TYPE_TONG][MOUSE_OUT]
    form.cbtn_box.CheckedImage = box_image_tab[BOXAWARD_TYPE_TONG][MOUSE_CLICK]
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddViewBind(VIEWPORT_DROP_BOX, form, nx_current(), "on_view_operat")
end
function on_btn_ShowDamageRank_click(self)
  local form_rank = nx_value("form_stage_main\\form_damage_statistics_rank")
  if not nx_is_valid(form_rank) then
    form_rank = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_damage_statistics_rank", true, false)
    nx_set_value("form_damage_statistics_rank", form_button)
  end
  form_rank:Show()
  self.ParentForm.Visible = false
end
function on_cbtn_box_click(cbtn)
  local form = cbtn.Parent
  if form.isOpen == true then
    return
  end
  cbtn.BackImage = box_image_tab[form.box_type][MOUSE_CLICK]
  form.isOpen = true
  nx_execute("custom_sender", "custom_clone_request_open_col_award")
end
function on_view_operat(form, optype, view_ident, index)
  if not nx_is_valid(form) then
    return
  end
  if optype == "deleteview" then
    if form.isView == true then
      form.isOpen = false
      form.isView = false
    end
  elseif optype == "createview" and form.isOpen == true then
    form.isView = true
  end
end
