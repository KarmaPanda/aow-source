require("util_gui")
require("share\\view_define")
require("share\\logicstate_define")
require("define\\shortcut_key_define")
require("util_role_prop")
require("tips_data")
require("form_stage_main\\form_tvt\\define")
require("define\\gamehand_type")
local new_active_origin = {}
local new_complete_origin = 0
local FILE_FORM_MAIN_PLAYER_CFG = "ini\\ui\\newjh\\form_main_shortcut.ini"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local G_PAGE_COUNT = 20
local G_NG_GRID_COUNT = 25
local G_NG_PAGE_COUNT = 3
local G_NG_BEGININDEX = 300
local G_LIFE_BEGININDEX = 400
local view_num = 6
local job_already_learn = {}
local WUXUE_JINGMAI = 6
FORM_JOB_MAIN_NEW = "form_stage_main\\form_life\\form_job_main_new"
local left_right_func = {
  {
    open = "auto_show_hide_role_info",
    keyID = Key_Form_Role,
    image_on = "gui\\special\\btn_main\\btn_role_on.png",
    image_out = "gui\\special\\btn_main\\btn_role_out.png",
    image_down = "gui\\special\\btn_main\\btn_role_down.png"
  },
  {
    open = "auto_show_hide_bag",
    keyID = Key_Form_Bag,
    image_on = "gui\\special\\btn_main\\btn_bag_on.png",
    image_out = "gui\\special\\btn_main\\btn_bag_out.png",
    image_down = "gui\\special\\btn_main\\btn_bag_down.png"
  },
  {
    open = "on_btn_home_point_click",
    keyID = Key_Form_Home,
    image_on = "gui\\special\\btn_main\\btn_relive_on.png",
    image_out = "gui\\special\\btn_main\\btn_relive_out.png",
    image_down = "gui\\special\\btn_main\\btn_relive_down.png"
  },
  {
    open = "on_wuxue_form",
    keyID = Key_Form_WuXue,
    image_on = "gui\\special\\btn_main\\btn_wuxue_on.png",
    image_out = "gui\\special\\btn_main\\btn_wuxue_out.png",
    image_down = "gui\\special\\btn_main\\btn_wuxue_down.png"
  },
  {
    open = "on_open_task",
    keyID = Key_Form_Task,
    image_on = "gui\\special\\btn_main\\btn_task_on.png",
    image_out = "gui\\special\\btn_main\\btn_task_out.png",
    image_down = "gui\\special\\btn_main\\btn_task_down.png"
  },
  {
    open = "open_form_team",
    keyID = Key_Form_Team,
    image_on = "gui\\language\\ChineseS\\btn_main\\btn_team_on.png",
    image_out = "gui\\language\\ChineseS\\btn_main\\btn_team_out.png",
    image_down = "gui\\language\\ChineseS\\btn_main\\btn_team_down.png"
  }
}
local life_func = {
  {
    open = "auto_show_hide_role_info",
    keyID = Key_Form_Role,
    image_on = "gui\\special\\btn_main\\btn_role_on.png",
    image_out = "gui\\special\\btn_main\\btn_role_out.png",
    image_down = "gui\\special\\btn_main\\btn_role_down.png"
  },
  {
    open = "auto_show_hide_bag",
    keyID = Key_Form_Bag,
    image_on = "gui\\special\\btn_main\\btn_bag_on.png",
    image_out = "gui\\special\\btn_main\\btn_bag_out.png",
    image_down = "gui\\special\\btn_main\\btn_bag_down.png"
  },
  {
    open = "on_btn_home_point_click",
    keyID = Key_Form_Home,
    image_on = "gui\\special\\btn_main\\btn_relive_on.png",
    image_out = "gui\\special\\btn_main\\btn_relive_out.png",
    image_down = "gui\\special\\btn_main\\btn_relive_down.png"
  },
  {
    open = "form_stage_main\\form_life\\form_job_main_new",
    keyID = Key_Form_Life,
    image_on = "gui\\special\\btn_main\\btn_life_on.png",
    image_out = "gui\\special\\btn_main\\btn_life_out.png",
    image_down = "gui\\special\\btn_main\\btn_life_down.png"
  },
  {
    open = "on_open_task",
    keyID = Key_Form_Task,
    image_on = "gui\\special\\btn_main\\btn_task_on.png",
    image_out = "gui\\special\\btn_main\\btn_task_out.png",
    image_down = "gui\\special\\btn_main\\btn_task_down.png"
  },
  {
    open = "open_form_team",
    keyID = Key_Form_Team,
    image_on = "gui\\language\\ChineseS\\btn_main\\btn_team_on.png",
    image_out = "gui\\language\\ChineseS\\btn_main\\btn_team_out.png",
    image_down = "gui\\language\\ChineseS\\btn_main\\btn_team_down.png"
  }
}
local FORM_NAME = "form_stage_main\\form_main\\form_main_shortcut"
function main_form_init(self)
  self.Fixed = true
  self.bHaveReadOldCfg = false
  return 1
end
function get_server_page_lockstate()
  local main_shortcut_page = 0
  local main_shortcut_lockstate = false
  local shortcut_ng_page = 0
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    main_shortcut_page = util_get_property_key(game_config_info, "shortcut_page", 0)
    shortcut_ng_page = util_get_property_key(game_config_info, "shortcut_ng_page", 0)
    if 0 > nx_number(main_shortcut_page) or nx_number(main_shortcut_page) > 19 then
      main_shortcut_page = 0
    end
    if 0 > nx_number(shortcut_ng_page) or nx_number(shortcut_ng_page) > 2 then
      shortcut_ng_page = 0
    end
    main_shortcut_lockstate = nx_number(util_get_property_key(game_config_info, "shortcut_lockstate", 0)) == 0
  end
  return main_shortcut_page, main_shortcut_lockstate, shortcut_ng_page
end
function main_form_open(self)
  local main_shortcut_page, main_shortcut_lockstate, shortcut_ng_page = get_server_page_lockstate()
  local form = self
  self.no_need_motion_alpha = true
  form.ng_bind_str = get_svr_ng_bind()
  form.grid_shortcut_main.DragEnabled = true
  form.grid_shortcut_2.DragEnabled = true
  form.grid_shortcut_3.DragEnabled = true
  form.grid_shortcut_skill.DragEnabled = true
  form.grid_shortcut_ng.DragEnabled = true
  form.imagegrid_life.DragEnabled = true
  form.grid_shortcut_skill_1.DragEnabled = true
  form.grid_shortcut_skill_2.DragEnabled = true
  form.grid_shortcut_skill_3.DragEnabled = true
  if not self.bHaveReadOldCfg then
    form.old_lbl_skill_bg_img = self.lbl_skill_bg.BackImage
    form.old_juese_normal_bg_img = left_right_func[1].image_on
    form.old_juese_focus_bg_img = left_right_func[1].image_out
    form.old_juese_push_bg_img = left_right_func[1].image_down
    form.old_juese_disable_bg_img = self.btn_1.DisableImage
    form.old_jineng_normal_bg_img = left_right_func[4].image_on
    form.old_jineng_focus_bg_img = left_right_func[4].image_out
    form.old_jineng_push_bg_img = left_right_func[4].image_down
    form.old_jineng_disable_bg_img = self.btn_4.DisableImage
    form.old_grid_shortcut_main_bg_img = self.grid_shortcut_main.BackImage
    form.old_grid_shortcut_main_grid_bg_img = self.grid_shortcut_main.DrawGridBack
    form.old_grid_shortcut_2_bg_img = self.grid_shortcut_2.BackImage
    form.old_grid_shortcut_2_grid_bg_img = self.grid_shortcut_2.DrawGridBack
    form.old_grid_shortcut_skill_bg_img = self.grid_shortcut_skill.BackImage
    form.old_grid_shortcut_skill_grid_bg_img = self.grid_shortcut_skill.DrawGridBack
    form.old_grid_shortcut_ng_bg_img = self.grid_shortcut_ng.BackImage
    form.old_grid_shortcut_ng_grid_bg_img = self.grid_shortcut_ng.DrawGridBack
    form.old_grid_shortcut_skill_1_bg_img = self.grid_shortcut_skill_1.BackImage
    form.old_grid_shortcut_skill_1_grid_bg_img = self.grid_shortcut_skill_1.DrawGridBack
    form.old_grid_shortcut_skill_2_bg_img = self.grid_shortcut_skill_2.BackImage
    form.old_grid_shortcut_skill_2_grid_bg_img = self.grid_shortcut_skill_2.DrawGridBack
    form.old_grid_shortcut_skill_3_bg_img = self.grid_shortcut_skill_3.BackImage
    form.old_grid_shortcut_skill_3_grid_bg_img = self.grid_shortcut_skill_3.DrawGridBack
    form.old_grid_shortcut_3_bg_img = self.grid_shortcut_3.BackImage
    form.old_grid_shortcut_3_grid_bg_img = self.grid_shortcut_3.DrawGridBack
    form.old_btn_bind_1_normal_bg_img = self.btn_bind_1.NormalImage
    form.old_btn_bind_1_focus_bg_img = self.btn_bind_1.FocusImage
    form.old_btn_bind_1_checked_bg_img = self.btn_bind_1.CheckedImage
    form.old_btn_bind_2_normal_bg_img = self.btn_bind_2.NormalImage
    form.old_btn_bind_2_focus_bg_img = self.btn_bind_2.FocusImage
    form.old_btn_bind_2_checked_bg_img = self.btn_bind_2.CheckedImage
    form.old_btn_bind_3_normal_bg_img = self.btn_bind_3.NormalImage
    form.old_btn_bind_3_focus_bg_img = self.btn_bind_3.FocusImage
    form.old_btn_bind_3_checked_bg_img = self.btn_bind_3.CheckedImage
    form.old_btn_bind_4_normal_bg_img = self.btn_bind_4.NormalImage
    form.old_btn_bind_4_focus_bg_img = self.btn_bind_4.FocusImage
    form.old_btn_bind_4_checked_bg_img = self.btn_bind_4.CheckedImage
    form.old_btn_bind_5_normal_bg_img = self.btn_bind_5.NormalImage
    form.old_btn_bind_5_focus_bg_img = self.btn_bind_5.FocusImage
    form.old_btn_bind_5_checked_bg_img = self.btn_bind_5.CheckedImage
    form.old_btn_pre_normal_bg_img = self.btn_pre.NormalImage
    form.old_btn_pre_focus_bg_img = self.btn_pre.FocusImage
    form.old_btn_pre_push_bg_img = self.btn_pre.PushImage
    form.old_btn_next_normal_bg_img = self.btn_next.NormalImage
    form.old_btn_next_focus_bg_img = self.btn_next.FocusImage
    form.old_btn_next_push_bg_img = self.btn_next.PushImage
    form.old_btn_skill_show_normal_bg_img = self.btn_skill_show.NormalImage
    form.old_btn_skill_show_focus_bg_img = self.btn_skill_show.FocusImage
    form.old_btn_skill_show_push_bg_img = self.btn_skill_show.PushImage
    form.old_btn_fix_normal_bg_img = self.btn_fix.NormalImage
    form.old_btn_fix_focus_bg_img = self.btn_fix.FocusImage
    form.old_btn_fix_push_bg_img = self.btn_fix.PushImage
    form.old_lbl_page_bg_img = self.lbl_page.BackImage
    form.old_btn_unfix_normal_bg_img = self.btn_unfix.NormalImage
    form.old_btn_unfix_focus_bg_img = self.btn_unfix.FocusImage
    form.old_btn_unfix_push_bg_img = self.btn_unfix.PushImage
    form.old_btn_move_left_normal_bg_img = self.btn_move_left.NormalImage
    form.old_btn_move_left_focus_bg_img = self.btn_move_left.FocusImage
    form.old_btn_move_left_push_bg_img = self.btn_move_left.PushImage
    form.old_btn_move_left_disable_bg_img = self.btn_move_left.DisableImage
    form.old_btn_move_right_normal_bg_img = self.btn_move_right.NormalImage
    form.old_btn_move_right_focus_bg_img = self.btn_move_right.FocusImage
    form.old_btn_move_right_push_bg_img = self.btn_move_right.PushImage
    form.old_btn_move_right_disable_bg_img = self.btn_move_right.DisableImage
    form.old_lbl_zhenqi_value_bg_img = self.lbl_zhenqi_value.BackImage
    form.old_pbar_zhenqi_value_prog_bg_img = self.pbar_zhenqi_value.ProgressImage
    form.old_lbl_bar_back_bg_img = self.lbl_bar_back.BackImage
    form.old_pos_beijing_x = self.lbl_skill_bg.Left
    form.old_pos_beijing_y = self.lbl_skill_bg.Top
    form.old_pos_beijing_width = self.lbl_skill_bg.Width
    form.old_pos_beijing_height = self.lbl_skill_bg.Height
    form.old_pos_juese_x = self.btn_1.Left
    form.old_pos_juese_y = self.btn_1.Top
    form.old_pos_juese_width = self.btn_1.Width
    form.old_pos_juese_height = self.btn_1.Height
    form.old_pos_juese_shortcut_x = self.lbl_btn_1.Left
    form.old_pos_juese_shortcut_y = self.lbl_btn_1.Top
    form.old_pos_juese_shortcut_width = self.lbl_btn_1.Width
    form.old_pos_juese_shortcut_height = self.lbl_btn_1.Height
    form.old_pos_jineng_x = self.btn_4.Left
    form.old_pos_jineng_y = self.btn_4.Top
    form.old_pos_jineng_width = self.btn_4.Width
    form.old_pos_jineng_height = self.btn_4.Height
    form.old_pos_jineng_shortcut_x = self.lbl_btn_4.Left
    form.old_pos_jineng_shortcut_y = self.lbl_btn_4.Top
    form.old_pos_jineng_shortcut_width = self.lbl_btn_4.Width
    form.old_pos_jineng_shortcut_height = self.lbl_btn_4.Height
    form.old_pos_lbl_page_pos_x = self.lbl_page.Left
    form.old_pos_lbl_page_pos_y = self.lbl_page.Top
    form.old_pos_lbl_page_pos_width = self.lbl_page.Width
    form.old_pos_lbl_page_pos_height = self.lbl_page.Height
    form.old_pos_lbl_zhenqi_value_pos_x = self.lbl_zhenqi_value.Left
    form.old_pos_lbl_zhenqi_value_pos_y = self.lbl_zhenqi_value.Top
    form.old_pos_lbl_zhenqi_value_pos_width = self.lbl_zhenqi_value.Width
    form.old_pos_lbl_zhenqi_value_pos_height = self.lbl_zhenqi_value.Height
    form.old_pos_lbl_bar_back_pos_x = self.lbl_bar_back.Left
    form.old_pos_lbl_bar_back_pos_y = self.lbl_bar_back.Top
    form.old_pos_lbl_bar_back_pos_width = self.lbl_bar_back.Width
    form.old_pos_lbl_bar_back_pos_height = self.lbl_bar_back.Height
    form.old_pos_btn_jingmai_pos_x = self.btn_jingmai.Left
    form.old_pos_btn_jingmai_pos_y = self.btn_jingmai.Top
    form.old_pos_btn_jingmai_pos_width = self.btn_jingmai.Width
    form.old_pos_btn_jingmai_pos_height = self.btn_jingmai.Height
    form.old_pos_pbar_zhenqi_value_pos_x = self.pbar_zhenqi_value.Left
    form.old_pos_pbar_zhenqi_value_pos_y = self.pbar_zhenqi_value.Top
    form.old_pos_pbar_zhenqi_value_pos_width = self.pbar_zhenqi_value.Width
    form.old_pos_pbar_zhenqi_value_pos_height = self.pbar_zhenqi_value.Height
    self.bHaveReadOldCfg = true
  end
  local grid_shortcut_main = form.grid_shortcut_main
  local grid_count = grid_shortcut_main.RowNum * grid_shortcut_main.ClomnNum
  grid_shortcut_main.beginindex = 0
  grid_shortcut_main.endindex = grid_shortcut_main.beginindex + grid_count * G_PAGE_COUNT - 1
  grid_shortcut_main.page = nx_number(main_shortcut_page)
  local grid_count = form.grid_shortcut_2.RowNum * form.grid_shortcut_2.ClomnNum
  form.grid_shortcut_2.beginindex = form.grid_shortcut_main.endindex + 1
  form.grid_shortcut_2.endindex = form.grid_shortcut_2.beginindex + grid_count - 1
  form.grid_shortcut_2.page = 0
  local grid_count = form.grid_shortcut_skill.RowNum * form.grid_shortcut_skill.ClomnNum
  form.grid_shortcut_skill.beginindex = form.grid_shortcut_2.endindex + 1
  form.grid_shortcut_skill.endindex = form.grid_shortcut_skill.beginindex + grid_count - 1
  form.grid_shortcut_skill.page = 0
  form.grid_shortcut_skill.VisNum = grid_count
  local grid_count = form.grid_shortcut_skill_1.RowNum * form.grid_shortcut_skill_1.ClomnNum
  form.grid_shortcut_skill_1.beginindex = form.grid_shortcut_skill.endindex + 1
  form.grid_shortcut_skill_1.endindex = form.grid_shortcut_skill_1.beginindex + grid_count - 1
  form.grid_shortcut_skill_1.page = 0
  form.grid_shortcut_skill_1.VisNum = grid_count
  local grid_count = form.grid_shortcut_skill_2.RowNum * form.grid_shortcut_skill_2.ClomnNum
  form.grid_shortcut_skill_2.beginindex = form.grid_shortcut_skill_1.endindex + 1
  form.grid_shortcut_skill_2.endindex = form.grid_shortcut_skill_2.beginindex + grid_count - 1
  form.grid_shortcut_skill_2.page = 0
  form.grid_shortcut_skill_2.VisNum = grid_count
  local grid_count = form.grid_shortcut_skill_3.RowNum * form.grid_shortcut_skill_3.ClomnNum
  form.grid_shortcut_skill_3.beginindex = form.grid_shortcut_skill_2.endindex + 1
  form.grid_shortcut_skill_3.endindex = form.grid_shortcut_skill_3.beginindex + grid_count - 1
  form.grid_shortcut_skill_3.page = 0
  form.grid_shortcut_skill_3.VisNum = grid_count
  local grid_count = form.grid_shortcut_3.RowNum * form.grid_shortcut_3.ClomnNum
  form.grid_shortcut_3.beginindex = G_NG_BEGININDEX
  form.grid_shortcut_3.endindex = form.grid_shortcut_3.beginindex + grid_count * G_NG_PAGE_COUNT - 1
  form.grid_shortcut_3.page = nx_number(shortcut_ng_page)
  local grid_count = form.grid_shortcut_ng.RowNum * form.grid_shortcut_ng.ClomnNum
  form.grid_shortcut_ng.beginindex = form.grid_shortcut_3.endindex + 1
  form.grid_shortcut_ng.endindex = form.grid_shortcut_ng.beginindex + grid_count - 1
  form.grid_shortcut_ng.page = 0
  init_sub_ctrl(self)
  on_cbtn_ng_grid_extend_checked_changed(form.cbtn_ng_grid_show)
  update_page_index(form)
  if main_shortcut_lockstate then
    on_btn_unfix_click()
  else
    on_btn_fix_click()
  end
  refresh_shortcut_status()
  update_shortcut_key()
  init_left_right_six_btn()
  form.groupbox_shortcut.Visible = true
  form.groupbox_life.Visible = false
  init_life_module_by_learn()
  life_module_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", self, nx_current(), "update_newjh_main_shortcut_ui")
  end
  local GameShortcut = nx_value("GameShortcut")
  if nx_is_valid(GameShortcut) then
    GameShortcut:InitShortcutGrid()
    GameShortcut:InitDataBind()
  end
  init_bind_btn_data(self)
  change_form_size()
  local gui = nx_value("gui")
  local form_load = nx_value("form_common\\form_loading")
  if nx_is_valid(form_load) then
    gui.Desktop:ToBack(self)
  else
    gui.Desktop:ToFront(self)
  end
end
function init_sub_ctrl(form)
  form.ani_jingmai.Visible = false
  form.btn_fix.Visible = true
  form.btn_unfix.Visible = false
  form.groupbox_bind.Visible = false
  load_shortcut_location()
  refresh_shortcut_vis_num(form)
end
function main_form_close(form)
  local is_help = nx_custom(form, "is_help")
  if is_help == nil or is_help == false then
    local GameShortcut = nx_value("GameShortcut")
    if nx_is_valid(GameShortcut) then
      GameShortcut:RemoveDataBind()
    end
    local asynor = nx_value("common_execute")
    if nx_is_valid(asynor) then
      asynor:RemoveExecute("refresh_shortcut_grid", form.grid_shortcut_main)
      asynor:RemoveExecute("refresh_shortcut_grid", form.grid_shortcut_2)
      asynor:RemoveExecute("refresh_shortcut_grid", form.grid_shortcut_skill)
      asynor:RemoveExecute("refresh_shortcut_grid", form.grid_shortcut_skill_1)
      asynor:RemoveExecute("refresh_shortcut_grid", form.grid_shortcut_skill_2)
      asynor:RemoveExecute("refresh_shortcut_grid", form.grid_shortcut_skill_3)
      asynor:RemoveExecute("refresh_shortcut_grid", form.grid_shortcut_ng)
    end
    nx_destroy(form)
  end
end
function on_main_form_shut(self)
  save_shortcut_location()
end
function reset_scene()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if nx_is_valid(form) then
    gui.shortcut_main_page = form.grid_shortcut_main.page
    gui.shortcut_fix = form.btn_fix.Visible
  end
  if nx_is_valid(form) then
    form:Close()
  end
  util_show_form("form_stage_main\\form_main\\form_main_shortcut", true)
  local form_trans = nx_value("form_stage_main\\form_main\\form_main_shortcut_trans")
  if nx_is_valid(form_trans) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_trans", "set_bottom_form_visible", false)
  end
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(form_main) then
    nx_execute("form_stage_main\\form_main\\form_main", "check_shortcut_ride", form_main)
    nx_execute("form_stage_main\\form_main\\form_main", "check_be_shortcut_ride", form_main)
  end
  nx_execute("form_stage_main\\form_main\\form_main", "check_sable_state")
end
function refresh_shortcut_status()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  local asynor = nx_value("common_execute")
  if nx_is_valid(form) and nx_is_valid(asynor) then
    asynor:AddExecute("refresh_shortcut_grid", form.grid_shortcut_main, 0.5)
    asynor:AddExecute("refresh_shortcut_grid", form.grid_shortcut_2, 0.5)
    asynor:AddExecute("refresh_shortcut_grid", form.grid_shortcut_skill, 0.5)
    asynor:AddExecute("refresh_shortcut_grid", form.grid_shortcut_skill_1, 0.5)
    asynor:AddExecute("refresh_shortcut_grid", form.grid_shortcut_skill_2, 0.5)
    asynor:AddExecute("refresh_shortcut_grid", form.grid_shortcut_skill_3, 0.5)
    asynor:AddExecute("refresh_shortcut_grid", form.grid_shortcut_ng, 0.5, "neigong")
  end
end
function change_form_size()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.Top = -form.Height
  local form_logic = nx_value("form_main_logic")
  if nx_is_valid(form_logic) then
    form_logic:ResetForm(nx_current())
  end
end
function on_shortcut_record_change(grid, recordname, optype, row, clomn)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(200, 1, nx_current(), "refresh_by_databind", grid, -1, -1)
    return
  end
end
function refresh_by_databind(grid)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_by_databind", grid)
  end
  local form = grid.ParentForm
  local game_shortcut = nx_value("GameShortcut")
  if not nx_is_valid(game_shortcut) then
    return
  end
  if is_skill_grid(grid) then
    game_shortcut:RefreshOneSkillGrid(grid)
  end
  if is_ng_grid(grid) then
    game_shortcut:RefreshNGShortcutGrid(grid)
    game_shortcut:UpdateNeiGongAni(grid)
    update_neigong_bind(grid)
  end
  if is_life_grid(grid) then
    game_shortcut:RefreshNGShortcutGrid(grid)
  end
  update_page_index(form)
end
function on_shortcutkey_prop_change()
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  shortcut_keys:InitShortcutKey()
  update_shortcut_key()
end
function on_view_operat_main_shortcut(grid, optype, view_ident, index, prop_name)
  local is_bag_tool = view_ident == VIEWPORT_TOOL or view_ident == VIEWPORT_EQUIP_TOOL or view_ident == VIEWPORT_MATERIAL_TOOL or view_ident == VIEWPORT_TASK_TOOL or view_ident == VIEWPORT_EQUIP
  if is_bag_tool then
    if nx_string(optype) == "updateitem" then
      return
    end
    if nx_string(prop_name) == "LeftTime" then
      return
    end
  end
  on_shortcut_record_change(grid)
end
function update_shortcut()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    return 0
  end
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_shortcut", form, -1, -1)
end
function on_update_shortcut(form)
  on_shortcut_record_change(form.grid_shortcut_main)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_shortcut", form)
end
function update_page_index(form)
  local page = form.grid_shortcut_main.page + 1
  local page_text = get_text("ui_mail_" .. page)
  form.lbl_page.Text = nx_widestr(page_text)
  form.btn_pre.Enabled = 1 < page
  form.btn_next.Enabled = page < G_PAGE_COUNT
  local page = form.grid_shortcut_3.page + 1
  form.btn_move_left.Enabled = 1 < page
  form.btn_move_right.Enabled = page < G_NG_PAGE_COUNT
end
function on_btn_pre_click(self)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_shortcut_main
  if 0 < grid.page then
    grid.page = grid.page - 1
    local game_config_info = nx_value("game_config_info")
    if nx_is_valid(game_config_info) then
      util_set_property_key(game_config_info, "shortcut_page", nx_int(grid.page))
    end
    local CustomizingManager = nx_value("customizing_manager")
    if nx_is_valid(CustomizingManager) then
      CustomizingManager:SaveConfigToServer()
    end
    on_shortcut_record_change(grid)
  end
end
function on_btn_next_click(self)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_shortcut_main
  if grid.page < G_PAGE_COUNT - 1 then
    grid.page = grid.page + 1
    local game_config_info = nx_value("game_config_info")
    if nx_is_valid(game_config_info) then
      util_set_property_key(game_config_info, "shortcut_page", nx_int(grid.page))
    end
    local CustomizingManager = nx_value("customizing_manager")
    if nx_is_valid(CustomizingManager) then
      CustomizingManager:SaveConfigToServer()
    end
    on_shortcut_record_change(grid)
  end
end
function on_btn_move_left_click(self)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_shortcut_3
  if 0 < grid.page then
    grid.page = grid.page - 1
    local game_config_info = nx_value("game_config_info")
    if nx_is_valid(game_config_info) then
      util_set_property_key(game_config_info, "shortcut_ng_page", nx_int(grid.page))
    end
    local CustomizingManager = nx_value("customizing_manager")
    if nx_is_valid(CustomizingManager) then
      CustomizingManager:SaveConfigToServer()
    end
    on_shortcut_record_change(grid)
  end
end
function on_btn_move_right_click(self)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_shortcut_3
  if grid.page < G_NG_PAGE_COUNT - 1 then
    grid.page = grid.page + 1
    local game_config_info = nx_value("game_config_info")
    if nx_is_valid(game_config_info) then
      util_set_property_key(game_config_info, "shortcut_ng_page", nx_int(grid.page))
    end
    local CustomizingManager = nx_value("customizing_manager")
    if nx_is_valid(CustomizingManager) then
      CustomizingManager:SaveConfigToServer()
    end
    on_shortcut_record_change(grid)
  end
end
function update_neigong_bind(grid)
  local game_shortcut = nx_value("GameShortcut")
  if nx_is_valid(game_shortcut) then
    game_shortcut:UpdateNeiGongBind(grid)
  end
  update_to_srv()
end
function on_use_shortcut_ng(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_hand = gui.GameHand
  if not is_ng_grid(grid) then
    return
  end
  local modify = 0
  if game_hand:IsEmpty() then
    if nx_id_equal(form.grid_shortcut_ng, grid) then
      modify = 5
    end
    local bind_lbl_name = "btn_bind_" .. index + 1 + modify
    if nx_find_custom(form, nx_string(bind_lbl_name)) then
      local bind_obj = nx_custom(form, nx_string(bind_lbl_name))
      local bind_index = nx_int(bind_obj.DataSource)
      if not grid:IsEmpty(index) then
        if not can_use_neigong_item(grid, index) then
          return
        end
        choose_main_shortcut_page(bind_index)
      end
    end
  end
end
function on_main_shortcut_lmouse_click(self, index)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if game_hand:IsEmpty() then
    if game_hand.IsDropped then
      game_hand.IsDropped = false
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
      return
    end
    local form = self.ParentForm
    if nx_id_equal(form.grid_shortcut_3, self) then
      local bind_lbl_name = "btn_bind_" .. index + 1
      if nx_find_custom(form, nx_string(bind_lbl_name)) then
        local bind_obj = nx_custom(form, nx_string(bind_lbl_name))
        local bind_index = nx_int(bind_obj.DataSource)
        if not self:IsEmpty(index) then
          if not can_use_neigong_item(self, index) then
            return
          end
          choose_main_shortcut_page(bind_index)
        end
      end
    end
    if nx_id_equal(form.grid_shortcut_ng, self) then
      local bind_lbl_name = "btn_bind_" .. index + 6
      if nx_find_custom(form, nx_string(bind_lbl_name)) then
        local bind_obj = nx_custom(form, nx_string(bind_lbl_name))
        local bind_index = nx_int(bind_obj.DataSource)
        if not self:IsEmpty(index) then
          if not can_use_neigong_item(self, index) then
            return
          end
          choose_main_shortcut_page(bind_index)
        end
      end
    end
    on_main_shortcut_useitem(self, index, true)
  else
    local grid_name = nx_string(self.Name)
    if grid_name == "grid_shortcut_2" then
      self.ParentForm.grid_shortcut_main:SetSelectItemIndex(nx_int(-1))
      self.ParentForm.grid_shortcut_3:SetSelectItemIndex(nx_int(-1))
    elseif grid_name == "grid_shortcut_main" then
      self.ParentForm.grid_shortcut_2:SetSelectItemIndex(nx_int(-1))
      self.ParentForm.grid_shortcut_3:SetSelectItemIndex(nx_int(-1))
    elseif grid_name == "grid_shortcut_3" then
      self.ParentForm.grid_shortcut_main:SetSelectItemIndex(nx_int(-1))
      self.ParentForm.grid_shortcut_2:SetSelectItemIndex(nx_int(-1))
    end
    if game_hand.IsDropped then
      game_hand.IsDropped = false
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
      return
    end
    nx_execute("shortcut_game", "on_shortcut_click", self, index)
    nx_execute("freshman_help", "select_item_callback", "")
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_main_shortcut_useitem(self, index, is_left)
  local AllowControl = nx_execute("form_stage_main\\form_main\\form_main_buff", "IsAllowControl")
  if not AllowControl then
    return
  end
  if is_left == nil then
    is_left = false
  end
  local game_shortcut = nx_value("GameShortcut")
  if nx_is_valid(game_shortcut) then
    game_shortcut:on_main_shortcut_useitem(self, index, is_left)
  end
end
function reset_ng_page()
  local form = util_get_form("form_stage_main\\form_main\\form_main_shortcut", false)
  if not nx_is_valid(form) then
    return
  end
  on_btn_move_left_click(form.btn_move_left)
  on_btn_move_left_click(form.btn_move_left)
end
function sel_ng_first()
  local form = util_get_form("form_stage_main\\form_main\\form_main_shortcut", false)
  if not nx_is_valid(form) then
    return
  end
  choose_main_shortcut_page(1)
  local game_shortcut = nx_value("GameShortcut")
  if nx_is_valid(game_shortcut) then
    game_shortcut:on_main_shortcut_useitem(form.grid_shortcut_3, nx_int(0), true)
  end
end
function use_grid_shortcut_item()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  if not nx_find_custom(form_main, "right_click_grid") then
    return
  end
  local grid = form_main.right_click_grid
  if not nx_is_valid(grid) then
    return
  end
  if not nx_find_custom(form_main, "right_click_index") then
    return
  end
  local index = form_main.right_click_index
  if nil == index then
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
  if client_player:FindProp("LogicState") then
    local offline_state = client_player:QueryProp("LogicState")
    if nx_int(offline_state) == nx_int(LS_OFFLINEJOB) then
      return
    end
  end
  local game_shortcut = nx_value("GameShortcut")
  if nx_is_valid(game_shortcut) then
    game_shortcut:on_shortcut_useitem(grid, index)
  end
end
function on_mousein_main_shortcut(self, index)
  nx_execute("shortcut_game", "show_shortcut_tips", self, index)
  local form = self.ParentForm
  if nx_id_equal(self, form.grid_shortcut_2) then
    local gui = nx_value("gui")
    local game_hand = gui.GameHand
    form.grid_shortcut_2.EmptyShowFade = not game_hand:IsEmpty()
    form.grid_shortcut_2.ShowEmpty = not game_hand:IsEmpty()
  end
end
function on_mouseout_main_shortcut(self, index)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_jingmai_click(self)
  if is_balance_war_scene() then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JINGMAI))
  if nx_is_valid(view) then
    local viewobj_list = view:GetViewObjList()
    local count = table.maxn(viewobj_list)
    if nx_int(count) > nx_int(0) then
      util_auto_show_hide_form("form_stage_main\\form_wuxue\\form_wuxue_jingmai_infomation")
    end
  end
end
function on_btn_jingmai_get_capture(self)
  if is_balance_war_scene() then
    self.HintText = nx_widestr("")
    return
  end
  self.HintText = nx_widestr(util_text("tips_jingmai_info"))
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JINGMAI))
  if nx_is_valid(view) then
    local viewobj_list = view:GetViewObjList()
    local count = table.maxn(viewobj_list)
    if nx_int(count) > nx_int(0) then
      set_jingmaiinfo_tips(self)
    else
      self.HintText = nx_widestr("")
    end
  end
end
function play_zhenqi_aination()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    return
  end
  form.ani_jingmai.Visible = true
  form.ani_jingmai:Stop()
  form.ani_jingmai:Play()
  return
end
function on_ani_jingmai_animation_end(animation)
  animation.Visible = false
end
function set_net_quality(percent)
end
function update_shortcut_key()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    return
  end
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  form.lbl_1.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index1))
  form.lbl_2.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index2))
  form.lbl_3.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index3))
  form.lbl_4.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index4))
  form.lbl_5.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index5))
  form.lbl_6.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index6))
  form.lbl_7.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index7))
  form.lbl_8.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index8))
  form.lbl_9.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index9))
  form.lbl_10.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index10))
  form.lbl_11.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubShortcutGrid_Index1))
  form.lbl_12.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubShortcutGrid_Index2))
  form.lbl_13.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubShortcutGrid_Index3))
  form.lbl_14.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubShortcutGrid_Index4))
  form.lbl_15.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubShortcutGrid_Index5))
  form.lbl_16.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubShortcutGrid_Index6))
  form.lbl_17.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubShortcutGrid_Index7))
  form.lbl_18.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubShortcutGrid_Index8))
  form.lbl_19.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubShortcutGrid_Index9))
  form.lbl_20.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubShortcutGrid_Index10))
  form.lbl_21.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut1_index1))
  form.lbl_22.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut1_index2))
  form.lbl_23.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut1_index3))
  form.lbl_24.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut1_index4))
  form.lbl_25.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut1_index5))
  form.lbl_26.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut1_index6))
  form.lbl_27.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut1_index7))
  form.lbl_28.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut1_index8))
  form.lbl_29.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut1_index9))
  form.lbl_30.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut1_index10))
  form.lbl_31.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut2_index1))
  form.lbl_32.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut2_index2))
  form.lbl_33.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut2_index3))
  form.lbl_34.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut2_index4))
  form.lbl_35.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut2_index5))
  form.lbl_36.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut2_index6))
  form.lbl_37.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut2_index7))
  form.lbl_38.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut2_index8))
  form.lbl_39.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut2_index9))
  form.lbl_40.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut2_index10))
  form.lbl_41.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut3_index1))
  form.lbl_42.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut3_index2))
  form.lbl_43.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut3_index3))
  form.lbl_44.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut3_index4))
  form.lbl_45.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut3_index5))
  form.lbl_46.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut3_index6))
  form.lbl_47.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut3_index7))
  form.lbl_48.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut3_index8))
  form.lbl_49.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut3_index9))
  form.lbl_50.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut3_index10))
  form.lbl_51.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut4_index1))
  form.lbl_52.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut4_index2))
  form.lbl_53.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut4_index3))
  form.lbl_54.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut4_index4))
  form.lbl_55.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut4_index5))
  form.lbl_56.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut4_index6))
  form.lbl_57.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut4_index7))
  form.lbl_58.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut4_index8))
  form.lbl_59.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut4_index9))
  form.lbl_60.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubSkillShortcut4_index10))
  form.lbl_kuaijie_1.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_NGShortcutGrid_Index1))
  form.lbl_kuaijie_2.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_NGShortcutGrid_Index2))
  form.lbl_kuaijie_3.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_NGShortcutGrid_Index3))
  form.lbl_kuaijie_4.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_NGShortcutGrid_Index4))
  form.lbl_kuaijie_5.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_NGShortcutGrid_Index5))
  form.lbl_kuaijie_6.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubNGShortcutGrid_index1))
  form.lbl_kuaijie_7.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubNGShortcutGrid_index2))
  form.lbl_kuaijie_8.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubNGShortcutGrid_index3))
  form.lbl_kuaijie_9.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubNGShortcutGrid_index4))
  form.lbl_kuaijie_10.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubNGShortcutGrid_index5))
  form.lbl_kuaijie_11.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubNGShortcutGrid_index6))
  form.lbl_kuaijie_12.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubNGShortcutGrid_index7))
  form.lbl_kuaijie_13.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubNGShortcutGrid_index8))
  form.lbl_kuaijie_14.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubNGShortcutGrid_index9))
  form.lbl_kuaijie_15.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_SubNGShortcutGrid_index10))
  for i = 1, 6 do
    local lbl_btn = "lbl_btn_" .. i
    lbl = nx_custom(form, lbl_btn)
    if not nx_is_valid(lbl) then
      return
    end
    if left_right_func[i] then
      lbl.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(left_right_func[i].keyID))
    end
  end
  for i = 1, 6 do
    local lbl_btn = "lbl_life_0" .. i
    lbl = nx_custom(form, lbl_btn)
    if not nx_is_valid(lbl) then
      return
    end
    if life_func[i] then
      lbl.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(life_func[i].keyID))
    end
  end
  nx_execute("form_stage_main\\form_main\\form_main_func_btns", "update_btns_shortcut_key")
end
function skill_flash(pos, flag)
end
function get_neigong_obj(configid)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_NEIGONG))
  if not nx_is_valid(view) then
    return
  end
  local view_lst = view:GetViewObjList()
  for j = 1, table.getn(view_lst) do
    local viewid = view_lst[j]:QueryProp("ConfigID")
    if configid == viewid then
      return view_lst[j]
    end
  end
  return nil
end
function on_btn_unfix_click(btn)
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    util_set_property_key(game_config_info, "shortcut_lockstate", 0)
  end
  local CustomizingManager = nx_value("customizing_manager")
  if nx_is_valid(CustomizingManager) then
    CustomizingManager:SaveConfigToServer()
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_shortcut_main
  grid.DragEnabled = true
  local grid = form.grid_shortcut_2
  grid.DragEnabled = true
  local grid = form.grid_shortcut_skill
  grid.DragEnabled = true
  local grid = form.grid_shortcut_skill_1
  grid.DragEnabled = true
  local grid = form.grid_shortcut_skill_2
  grid.DragEnabled = true
  local grid = form.grid_shortcut_skill_3
  grid.DragEnabled = true
  form.btn_unfix.Visible = false
  form.btn_fix.Visible = true
  close_fix_tips()
end
function on_btn_fix_click(btn)
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    util_set_property_key(game_config_info, "shortcut_lockstate", 1)
  end
  local CustomizingManager = nx_value("customizing_manager")
  if nx_is_valid(CustomizingManager) then
    CustomizingManager:SaveConfigToServer()
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_shortcut_main
  grid.DragEnabled = false
  local grid = form.grid_shortcut_2
  grid.DragEnabled = false
  local grid = form.grid_shortcut_skill
  grid.DragEnabled = false
  local grid = form.grid_shortcut_skill_1
  grid.DragEnabled = false
  local grid = form.grid_shortcut_skill_2
  grid.DragEnabled = false
  local grid = form.grid_shortcut_skill_3
  grid.DragEnabled = false
  form.btn_fix.Visible = false
  form.btn_unfix.Visible = true
end
function on_cbtn_skill_lock_checked_changed(cbtn)
  local groupbox = cbtn.ParentForm.groupbox_skill
  groupbox.Fixed = cbtn.Checked
  cbtn.ParentForm.cbtn_lock_skill.Visible = not cbtn.Checked
end
function on_cbtn_skill1_lock_checked_changed(cbtn)
  local groupbox = cbtn.ParentForm.groupbox_skill_1
  groupbox.Fixed = cbtn.Checked
  cbtn.ParentForm.cbtn_lock_skill1.Visible = not cbtn.Checked
end
function on_cbtn_skill2_lock_checked_changed(cbtn)
  local groupbox = cbtn.ParentForm.groupbox_skill_2
  groupbox.Fixed = cbtn.Checked
  cbtn.ParentForm.cbtn_lock_skill2.Visible = not cbtn.Checked
end
function on_cbtn_skill3_lock_checked_changed(cbtn)
  local groupbox = cbtn.ParentForm.groupbox_skill_3
  groupbox.Fixed = cbtn.Checked
  cbtn.ParentForm.cbtn_lock_skill3.Visible = not cbtn.Checked
end
function on_cbtn_ng_lock_checked_changed(cbtn)
  local groupbox = cbtn.ParentForm.groupbox_ng
  groupbox.Fixed = cbtn.Checked
  cbtn.ParentForm.cbtn_lock_ng.Visible = not cbtn.Checked
end
function on_cbtn_lock_skill_checked_changed(cbtn)
  cbtn.ParentForm.cbtn_skill_lock.Checked = cbtn.Checked
end
function on_cbtn_lock_ng_checked_changed(cbtn)
  cbtn.ParentForm.cbtn_ng_lock.Checked = cbtn.Checked
end
function on_cbtn_lock_skill1_checked_changed(cbtn)
  cbtn.ParentForm.cbtn_skill1_lock.Checked = cbtn.Checked
end
function on_cbtn_lock_skill2_checked_changed(cbtn)
  cbtn.ParentForm.cbtn_skill2_lock.Checked = cbtn.Checked
end
function on_cbtn_lock_skill3_checked_changed(cbtn)
  cbtn.ParentForm.cbtn_skill3_lock.Checked = cbtn.Checked
end
function on_btn_defult_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local absleft = form.grid_shortcut_2.AbsLeft - 22
  local abstop = form.grid_shortcut_2.AbsTop - form.groupbox_shortcut_2.Height - 20
  local gui = nx_value("gui")
  form.groupbox_skill.AbsLeft = absleft
  form.groupbox_skill.AbsTop = abstop
  form.groupbox_skill_1.AbsLeft = absleft
  form.groupbox_skill_1.AbsTop = abstop - form.groupbox_skill_1.Height
  form.groupbox_skill_2.AbsLeft = gui.Desktop.Width - form.groupbox_skill_2.Width - form.groupbox_skill_3.Width
  form.groupbox_skill_2.AbsTop = abstop - form.groupbox_skill_2.Height + 10
  form.groupbox_skill_3.AbsLeft = gui.Desktop.Width - form.groupbox_skill_3.Width
  form.groupbox_skill_3.AbsTop = abstop - form.groupbox_skill_3.Height + 10
  form.groupbox_ng.AbsLeft = form.lbl_page.AbsLeft + 18
  form.groupbox_ng.AbsTop = form.lbl_page.AbsTop - form.groupbox_ng.Height / 4 + 4
end
function on_grid_shortcut_main_drag_enter(self, index)
  if not nx_find_custom(self, "DragEnabled") or not self.DragEnabled then
    return
  end
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  game_hand.IsDragged = false
  game_hand.IsDropped = false
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form.drag_move_x = 0
    form.drag_move_y = 0
  end
end
function on_grid_shortcut_main_drag_move(self, index, x, y)
  if not nx_find_custom(self, "DragEnabled") or not self.DragEnabled then
    open_fix_tips(true)
    return
  end
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if limit_drag(x, y, game_hand) then
    return
  end
  if not game_hand.IsDragged then
    game_hand.IsDragged = true
    nx_execute("shortcut_game", "on_shortcut_click", self, index)
  end
end
function on_grid_shortcut_main_drag_leave(self, index)
end
function on_grid_shortcut_main_drop_in(self, index)
  if not nx_find_custom(self, "DragEnabled") or not self.DragEnabled then
    return
  end
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if game_hand.Para3 == "shortcut_right" then
    game_hand:ClearHand()
    return
  end
  if game_hand.IsDragged and not game_hand.IsDropped then
    nx_execute("shortcut_game", "on_shortcut_click", self, index)
    game_hand.IsDropped = true
  end
end
function on_grid_shortcut_2_drag_enter(self, index)
  on_grid_shortcut_main_drag_enter(self, index)
end
function on_grid_shortcut_2_drag_move(self, index, x, y)
  on_grid_shortcut_main_drag_move(self, index, x, y)
end
function on_grid_shortcut_2_drag_leave(self, index)
  on_grid_shortcut_main_drag_leave(self, index)
end
function on_grid_shortcut_2_drop_in(self, index)
  on_grid_shortcut_main_drop_in(self, index)
end
function on_grid_shortcut_3_drag_enter(self, index)
  on_grid_shortcut_main_drag_enter(self, index)
end
function on_grid_shortcut_3_drag_move(self, index, x, y)
  on_grid_shortcut_main_drag_move(self, index, x, y)
end
function on_grid_shortcut_3_drag_leave(self, index)
  on_grid_shortcut_main_drag_leave(self, index)
end
function on_grid_shortcut_3_drop_in(self, index)
  on_grid_shortcut_main_drop_in(self, index)
end
function on_grid_shortcut_ng_drag_enter(self, index)
  on_grid_shortcut_main_drag_enter(self, index)
end
function on_grid_shortcut_ng_drag_move(self, index, x, y)
  on_grid_shortcut_main_drag_move(self, index, x, y)
end
function on_grid_shortcut_ng_drop_in(self, index)
  on_grid_shortcut_main_drop_in(self, index)
end
function on_groupbox_skill_get_capture(groupbox)
  local cbtn = groupbox.ParentForm.cbtn_skill_lock
  if cbtn.Checked then
    return
  end
  groupbox.BackImage = "gui\\mainform\\bg_shortcut.png"
end
function on_groupbox_skill_1_get_capture(groupbox)
  local cbtn = groupbox.ParentForm.cbtn_skill1_lock
  if cbtn.Checked then
    return
  end
  groupbox.BackImage = "gui\\mainform\\bg_shortcut.png"
end
function on_groupbox_skill_2_get_capture(groupbox)
  local cbtn = groupbox.ParentForm.cbtn_skill2_lock
  if cbtn.Checked then
    return
  end
  groupbox.BackImage = "gui\\mainform\\bg_shortcut.png"
end
function on_groupbox_skill_3_get_capture(groupbox)
  local cbtn = groupbox.ParentForm.cbtn_skill3_lock
  if cbtn.Checked then
    return
  end
  groupbox.BackImage = "gui\\mainform\\bg_shortcut.png"
end
function on_groupbox_skill_lost_capture(groupbox)
  groupbox.BackImage = ""
end
function on_groupbox_ng_get_capture(groupbox)
  local cbtn = groupbox.ParentForm.cbtn_ng_lock
  if cbtn.Checked then
    return
  end
  groupbox.BackImage = "gui\\mainform\\bg_shortcut.png"
end
function on_groupbox_ng_lost_capture(groupbox)
  groupbox.BackImage = ""
end
function on_grid_shortcut_skill_drag_enter(self, index)
  on_grid_shortcut_main_drag_enter(self, index)
end
function on_grid_shortcut_skill_drag_move(self, index, x, y)
  on_grid_shortcut_main_drag_move(self, index, x, y)
end
function on_grid_shortcut_skill_drop_in(self, index)
  on_grid_shortcut_main_drop_in(self, index)
end
function on_btn_ctrl_close_click(btn)
  local groupbox = btn.Parent
  groupbox.Visible = false
end
function on_btn_skill_show_click(btn)
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local first_time = true
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\shortcut.ini"
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return
    end
    first_time = 1 ~= ini:ReadInteger("btn_skill_show", "check", 0)
  end
  if first_time then
    on_btn_defult_click()
    ini:WriteInteger("btn_skill_show", "check", nx_int(1))
    ini:SaveToFile()
  end
  nx_destroy(ini)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form.groupbox_ctrl.Visible = not form.groupbox_ctrl.Visible
  end
end
function on_cbtn_skill_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local grid = form.grid_shortcut_skill
  local groupbox = grid.Parent
  groupbox.Visible = cbtn.Checked
  local GameShortcut = nx_value("GameShortcut")
  if not nx_is_valid(GameShortcut) then
    return
  end
  GameShortcut:SetGridVisible(grid, cbtn.Checked)
  if cbtn.Checked then
    GameShortcut:RefreshOneSkillGrid(grid)
  end
end
function on_cbtn_skill1_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local grid = form.grid_shortcut_skill_1
  local groupbox = grid.Parent
  groupbox.Visible = cbtn.Checked
  local GameShortcut = nx_value("GameShortcut")
  if not nx_is_valid(GameShortcut) then
    return
  end
  GameShortcut:SetGridVisible(grid, cbtn.Checked)
  if cbtn.Checked then
    GameShortcut:RefreshOneSkillGrid(grid)
  end
end
function on_cbtn_skill2_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local grid = form.grid_shortcut_skill_2
  local groupbox = grid.Parent
  groupbox.Visible = cbtn.Checked
  local GameShortcut = nx_value("GameShortcut")
  if not nx_is_valid(GameShortcut) then
    return
  end
  GameShortcut:SetGridVisible(grid, cbtn.Checked)
  if cbtn.Checked then
    GameShortcut:RefreshOneSkillGrid(grid)
  end
end
function on_cbtn_skill3_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local grid = form.grid_shortcut_skill_3
  local groupbox = grid.Parent
  groupbox.Visible = cbtn.Checked
  local GameShortcut = nx_value("GameShortcut")
  if not nx_is_valid(GameShortcut) then
    return
  end
  GameShortcut:SetGridVisible(grid, cbtn.Checked)
  if cbtn.Checked then
    GameShortcut:RefreshOneSkillGrid(grid)
  end
end
function on_cbtn_ng_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.groupbox_ng.Visible = cbtn.Checked
end
function on_cbtn_ng_grid_extend_checked_changed(btn)
  local grid = btn.ParentForm.grid_shortcut_ng
  if not nx_is_valid(grid) then
    return
  end
  local isShow = btn.Checked
  local gb = grid.Parent
  if not nx_is_valid(gb) then
    return
  end
  if isShow then
    gb.Height = 110
  else
    gb.Height = 54
  end
end
function open_bind_groupbox(index)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if index < 1 or 10 < index then
    return
  end
  local bind_lbl_name = "btn_bind_" .. index
  local btn = nx_custom(form, bind_lbl_name)
  if not nx_is_valid(btn) then
    return
  end
  btn.Checked = not btn.Checked
end
function on_btn_bind_checked_changed(self)
  local form = self.ParentForm
  form.groupbox_bind.Visible = not form.groupbox_bind.Visible
  if form.groupbox_bind.Visible then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui.Desktop:ToFront(form)
    end
  end
  if self.Checked then
    if nx_int(self.data) <= nx_int(5) then
      form.groupbox_bind.AbsLeft = self.AbsLeft - form.groupbox_bind.Width / 2
      form.groupbox_bind.AbsTop = self.AbsTop - form.groupbox_bind.Height
    else
      form.groupbox_bind.AbsLeft = self.AbsLeft - form.groupbox_bind.Width / 2
      form.groupbox_bind.AbsTop = form.grid_shortcut_ng.AbsTop - form.groupbox_bind.Height
    end
    clear_other_bind(self)
  end
end
function clear_other_bind(self)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_shortcut_3
  local num = grid.RowNum * grid.ClomnNum
  grid = form.grid_shortcut_ng
  num = num + grid.RowNum * grid.ClomnNum
  for i = 1, num do
    local bind_lbl_name = "btn_bind_" .. i
    if nx_find_custom(form, bind_lbl_name) then
      local bind_obj = nx_custom(form, bind_lbl_name)
      if not nx_id_equal(self, bind_obj) then
        bind_obj.Checked = false
      end
    end
  end
end
function on_btn_bind_click(self)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_shortcut_3
  local num = grid.RowNum * grid.ClomnNum
  local cur_begin = grid.page * grid.ClomnNum
  for i = 1, num do
    local bind_lbl_name = "btn_bind_" .. i
    if nx_find_custom(form, bind_lbl_name) then
      local bind_obj = nx_custom(form, bind_lbl_name)
      if bind_obj.Checked then
        bind_obj.DataSource = self.DataSource
        set_bind_by_index(cur_begin + i, bind_obj.DataSource)
        if 0 == nx_number(self.DataSource) then
          bind_obj.Text = nx_widestr("")
        else
          bind_obj.Text = get_text("ui_mail_" .. self.DataSource)
        end
        bind_obj.Checked = false
      end
    end
  end
  cur_begin = grid.ClomnNum * G_NG_PAGE_COUNT
  grid = form.grid_shortcut_ng
  num = grid.RowNum * grid.ClomnNum
  for i = 1, num do
    local bind_lbl_name = "btn_bind_" .. i + form.grid_shortcut_3.ClomnNum
    if nx_find_custom(form, bind_lbl_name) then
      local bind_obj = nx_custom(form, bind_lbl_name)
      if bind_obj.Checked then
        bind_obj.DataSource = self.DataSource
        set_bind_by_index(cur_begin + i, bind_obj.DataSource)
        if 0 == nx_number(self.DataSource) then
          bind_obj.Text = nx_widestr("")
        else
          bind_obj.Text = get_text("ui_mail_" .. self.DataSource)
        end
        bind_obj.Checked = false
      end
    end
  end
  update_to_srv()
  form.groupbox_bind.Visible = false
end
function get_text(id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  return nx_widestr(gui.TextManager:GetText(id))
end
function on_ani_end(ani)
  ani.Visible = false
end
function find_grid_item(config_id, image_grid)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) or not nx_is_valid(image_grid) then
    return -1
  end
  local rows = image_grid.RowNum
  local cols = image_grid.ClomnNum
  local size = rows * cols - 1
  for i = 0, size do
    local item_data = goods_grid:GetItemData(image_grid, i)
    local config = nx_execute("tips_data", "get_prop_in_item", item_data, "ConfigID")
    if nx_string(config) == nx_string(config_id) then
      return i
    end
  end
  return -1
end
function limit_drag(move_x, move_y, gamehand)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) or not gamehand:IsEmpty() then
    return false
  end
  if not nx_find_custom(form, "drag_move_x") or not nx_find_custom(form, "drag_move_y") then
    form.drag_move_x = 0
    form.drag_move_y = 0
  end
  form.drag_move_x = form.drag_move_x + move_x
  form.drag_move_y = form.drag_move_y + move_y
  if math.abs(form.drag_move_x) < 4 and math.abs(form.drag_move_y) < 4 then
    return true
  end
  return false
end
function choose_main_shortcut_page(index)
  local index = nx_number(index)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if index <= 0 or index > G_PAGE_COUNT then
    return
  end
  form.grid_shortcut_main.page = nx_int(index - 1)
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    util_set_property_key(game_config_info, "shortcut_page", nx_int(form.grid_shortcut_main.page))
  end
  local CustomizingManager = nx_value("customizing_manager")
  if nx_is_valid(CustomizingManager) then
    CustomizingManager:SaveConfigToServer()
  end
  on_shortcut_record_change(form.grid_shortcut_main)
end
function on_btn_1_click(self)
  if left_right_func[1] then
    local form = left_right_func[1].open
    if not is_special(1) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_2_click(self)
  if left_right_func[2] then
    local form = left_right_func[2].open
    if not is_special(2) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
  end
end
function on_btn_3_click(self)
  if left_right_func[3] then
    local form = left_right_func[3].open
    if not is_special(3) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
  end
end
function on_btn_4_click(self)
  if left_right_func[4] then
    local form = left_right_func[4].open
    if not is_special(4) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
  end
end
function on_btn_5_click(self)
  if left_right_func[5] then
    local form = left_right_func[5].open
    if not is_special(5) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
  end
end
function on_btn_6_click(self)
  if left_right_func[6] then
    local form = left_right_func[6].open
    if not is_special(6) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
  end
end
function init_left_right_six_btn()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 6 do
    local btn_name = "btn_" .. i
    local btn = nx_custom(form, btn_name)
    if nx_is_valid(btn) and left_right_func[i] then
      btn.NormalImage = left_right_func[i].image_out
      btn.FocusImage = left_right_func[i].image_on
      btn.PushImage = left_right_func[i].image_down
    end
  end
end
function is_special(index)
  if left_right_func[index] then
    local key = left_right_func[index].keyID
    if Key_Form_Origin == key or Key_Form_WuXue == key or Key_Form_Task == key or Key_Form_Team == key or Key_Form_Bag == key or Key_Form_Role == key or Key_Form_Home == key then
      return true
    else
      return false
    end
  end
  return false
end
function on_wuxue_form()
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "auto_show_hide_wuxue")
end
function on_open_origin()
  local origin_id = nx_execute("form_stage_main\\form_main\\form_main_shortcut", "get_new_origin_id")
  if nx_int(origin_id) > nx_int(0) then
    nx_execute("form_stage_main\\form_origin\\form_origin", "open_origin_form_by_id", nx_int(origin_id))
  else
    nx_execute("form_stage_main\\form_origin\\form_origin", "auto_show_hide_origin")
  end
end
function on_open_task()
  nx_execute("form_stage_main\\form_task\\form_task_main", "auto_show_hide_task_form")
end
function open_form_team()
  nx_execute("form_stage_main\\form_team\\form_team_recruit", "auto_show_hide_team")
end
function on_btn_home_point_click()
  nx_execute("form_stage_main\\form_homepoint\\form_home_point", "auto_show_hide_point_form")
end
function auto_show_hide_role_info()
  nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
end
function auto_show_hide_bag()
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag")
end
function get_svr_ng_bind()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local ng_bind_info = client_player:QueryProp("NeiGongBind")
  local ng_bind_table = util_split_string(ng_bind_info, ";")
  if table.getn(ng_bind_table) ~= G_NG_GRID_COUNT + 1 then
    ng_bind_info = string.rep("0;", G_NG_GRID_COUNT)
  end
  return ng_bind_info
end
function set_bind_by_index(index, value)
  if index <= 0 or index > G_NG_GRID_COUNT then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "ng_bind_str") then
    return
  end
  local t = util_split_string(form.ng_bind_str, ";")
  t[index] = value or 0
  local rst = table_to_string(t, ";")
  form.ng_bind_str = rst
end
function update_to_srv()
  local info = ""
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    info = form.ng_bind_str
  end
  if info ~= get_svr_ng_bind() then
    nx_execute("custom_sender", "custom_update_ng_bind", info)
  end
end
local life_table = {
  {
    desc = "sh_cf",
    NormalImage = "gui\\special\\life_btn\\btn_cf_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_cf_on.png",
    PushImage = "gui\\special\\life_btn\\btn_cf_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_cf_disable.png"
  },
  {
    desc = "sh_cs",
    NormalImage = "gui\\special\\life_btn\\btn_cs_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_cs_on.png",
    PushImage = "gui\\special\\life_btn\\btn_cs_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_cs_disable.png"
  },
  {
    desc = "sh_ds",
    NormalImage = "gui\\special\\life_btn\\btn_ds_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_ds_on.png",
    PushImage = "gui\\special\\life_btn\\btn_ds_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_ds_disable.png"
  },
  {
    desc = "sh_gs",
    NormalImage = "gui\\special\\life_btn\\btn_gs_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_gs_on.png",
    PushImage = "gui\\special\\life_btn\\btn_gs_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_gs_disable.png"
  },
  {
    desc = "sh_hs",
    NormalImage = "gui\\special\\life_btn\\btn_hs_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_hs_on.png",
    PushImage = "gui\\special\\life_btn\\btn_hs_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_hs_disable.png"
  },
  {
    desc = "sh_kg",
    NormalImage = "gui\\special\\life_btn\\btn_kg_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_kg_on.png",
    PushImage = "gui\\special\\life_btn\\btn_kg_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_kg_disable.png"
  },
  {
    desc = "sh_lh",
    NormalImage = "gui\\special\\life_btn\\btn_lh_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_lh_on.png",
    PushImage = "gui\\special\\life_btn\\btn_lh_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_lh_disable.png"
  },
  {
    desc = "sh_nf",
    NormalImage = "gui\\special\\life_btn\\btn_nf_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_nf_on.png",
    PushImage = "gui\\special\\life_btn\\btn_nf_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_nf_disable.png"
  },
  {
    desc = "sh_qf",
    NormalImage = "gui\\special\\life_btn\\btn_qf_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_qf_on.png",
    PushImage = "gui\\special\\life_btn\\btn_qf_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_qf_disable.png"
  },
  {
    desc = "sh_qg",
    NormalImage = "gui\\special\\life_btn\\btn_qg_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_qg_on.png",
    PushImage = "gui\\special\\life_btn\\btn_qg_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_qg_disable.png"
  },
  {
    desc = "sh_qis",
    NormalImage = "gui\\special\\life_btn\\btn_qis_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_qis_on.png",
    PushImage = "gui\\special\\life_btn\\btn_qis_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_qis_disable.png"
  },
  {
    desc = "sh_jq",
    NormalImage = "gui\\special\\life_btn\\btn_qj_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_qj_on.png",
    PushImage = "gui\\special\\life_btn\\btn_qj_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_qj_disable.png"
  },
  {
    desc = "sh_qs",
    NormalImage = "gui\\special\\life_btn\\btn_qs_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_qs_on.png",
    PushImage = "gui\\special\\life_btn\\btn_qs_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_qs_disable.png"
  },
  {
    desc = "sh_ss",
    NormalImage = "gui\\special\\life_btn\\btn_ss_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_ss_on.png",
    PushImage = "gui\\special\\life_btn\\btn_ss_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_ss_disable.png"
  },
  {
    desc = "sh_tj",
    NormalImage = "gui\\special\\life_btn\\btn_tj_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_tj_on.png",
    PushImage = "gui\\special\\life_btn\\btn_tj_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_tj_disable.png"
  },
  {
    desc = "sh_yf",
    NormalImage = "gui\\special\\life_btn\\btn_yf_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_yf_on.png",
    PushImage = "gui\\special\\life_btn\\btn_yf_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_yf_disable.png"
  },
  {
    desc = "sh_ys",
    NormalImage = "gui\\special\\life_btn\\btn_ys_out.png",
    FocusImage = "gui\\special\\life_btn\\btn_ys_on.png",
    PushImage = "gui\\special\\life_btn\\btn_ys_down.png",
    DisableImage = "gui\\special\\life_btn\\btn_ys_disable.png"
  }
}
function life_module_open(self)
  local grid_shortcut_life = self.imagegrid_life
  grid_shortcut_life.beginindex = G_LIFE_BEGININDEX
  local grid_count = grid_shortcut_life.RowNum * grid_shortcut_life.ClomnNum
  grid_shortcut_life.endindex = grid_shortcut_life.beginindex + grid_count - 1
  grid_shortcut_life.page = 0
  self.life_page = 1
  refresh_SK_display(self)
  init_life_left_right_six_btn()
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddTableBind("job_rec", self.groupbox_life, nx_current(), "on_life_rec_refresh")
  databinder:AddRolePropertyBind("OpenLifeJob", "string", self, nx_current(), "on_update_open_life_flag")
  refresh_life_module(1)
end
function refresh_SK_display(form)
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  for i = 1, 6 do
    local lbl_btn = "lbl_life_0" .. i
    lbl = nx_custom(form, lbl_btn)
    if not nx_is_valid(lbl) then
      return
    end
    if life_func[i] then
      lbl.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(life_func[i].keyID))
    end
  end
end
function on_life_rec_refresh()
  local form = nx_value(FORM_NAME)
  local index = form.life_page
  init_life_module_by_learn()
  refresh_life_module(index)
  local size = table.maxn(life_table) - view_num + 1
  form.btn_life_right.Enabled = form.life_page ~= size
  form.btn_life_left.Enabled = form.life_page ~= 1
end
function refresh_life_module(index)
  if nx_running(nx_current(), "exe_refresh_life_module") then
    nx_kill(nx_current(), "exe_refresh_life_module")
  end
  nx_execute(nx_current(), "exe_refresh_life_module", index)
end
function exe_refresh_life_module(index)
  init_life_module_by_learn()
  local job_already_learn_size = table.maxn(job_already_learn)
  if job_already_learn_size ~= table.maxn(life_table) then
    return
  end
  local form = nx_value(FORM_NAME)
  if index < 1 or index > table.maxn(life_table) then
    return
  end
  local begin_index = index
  local end_index = math.min(table.maxn(life_table), index + view_num)
  local time_count = 0
  while nx_is_valid(form) and not form.LoadFinish do
    time_count = time_count + nx_pause(0)
    if 5 < time_count then
      return
    end
  end
  if not nx_is_valid(form) then
    nx_log("not nx_is_valid(form)")
    return
  end
  for i = 1, view_num do
    local btn = nx_custom(form, "btn_life_" .. i)
    local table_index = i + begin_index - 1
    if end_index >= table_index then
      btn.NormalImage = job_already_learn[table_index].NormalImage
      btn.FocusImage = job_already_learn[table_index].FocusImage
      btn.PushImage = job_already_learn[table_index].PushImage
      btn.DisableImage = job_already_learn[table_index].DisableImage
      btn.Enabled = is_learn_life_job(job_already_learn[table_index].desc)
    else
      btn.NormalImage = nil
      btn.FocusImage = nil
      btn.PushImage = nil
      btn.DisableImage = nil
    end
    fresh_job_flag(form, job_already_learn[table_index].desc, i)
  end
end
function fresh_job_flag(form, jobid, viewid)
  local lbl_flag = nx_custom(form, "lbl_flag_" .. viewid)
  if not nx_is_valid(lbl_flag) then
    return
  end
  lbl_flag.BackImage = ""
  local flag = nx_execute(FORM_JOB_MAIN_NEW, "check_flag_valid", jobid)
  if not flag then
    return
  end
  lbl_flag.BackImage = "gui\\mainform\\smallgame\\mylife\\gantan.png"
end
function init_life_module_by_learn()
  local size = table.maxn(life_table)
  local begin = 1
  local t_end = size
  for i = 1, size do
    if is_learn_life_job(life_table[i].desc) then
      job_already_learn[begin] = life_table[i]
      begin = begin + 1
    else
      job_already_learn[t_end] = life_table[i]
      t_end = t_end - 1
    end
  end
end
function on_btn_life_left_click(self)
  local form = self.ParentForm
  local page = form.life_page
  if 1 < page then
    form.life_page = form.life_page - 1
  end
  self.Enabled = form.life_page ~= 1
  local size = table.maxn(life_table) - view_num + 1
  form.btn_life_right.Enabled = form.life_page ~= size
  refresh_life_module(form.life_page)
end
function on_btn_life_right_click(self)
  local form = self.ParentForm
  local page = form.life_page
  local size = table.maxn(life_table) - view_num + 1
  if page < size then
    form.life_page = form.life_page + 1
  end
  self.Enabled = form.life_page ~= size
  form.btn_life_left.Enabled = form.life_page ~= 1
  refresh_life_module(form.life_page)
end
function init_life_left_right_six_btn()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 6 do
    local btn_name = "btn_life_0" .. i
    local btn = nx_custom(form, btn_name)
    if nx_is_valid(btn) and life_func[i] then
      btn.NormalImage = life_func[i].image_out
      btn.FocusImage = life_func[i].image_on
      btn.PushImage = life_func[i].image_down
    end
  end
end
function on_btn_life_01_click(self)
  if life_func[1] then
    local form = life_func[1].open
    if not is_special_life(1) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
  end
end
function on_btn_life_02_click(self)
  if life_func[2] then
    local form = life_func[2].open
    if not is_special_life(2) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
  end
end
function on_btn_life_03_click(self)
  if life_func[3] then
    local form = life_func[3].open
    if not is_special_life(3) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
  end
end
function on_btn_life_04_click(self)
  if life_func[4] then
    local form = life_func[4].open
    if not is_special_life(4) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
  end
end
function on_btn_life_05_click(self)
  if life_func[5] then
    local form = life_func[5].open
    if not is_special_life(5) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
  end
end
function on_btn_life_06_click(self)
  if life_func[6] then
    local form = life_func[6].open
    if not is_special_life(6) then
      util_auto_show_hide_form(form)
    else
      nx_execute(nx_current(), form)
    end
  end
end
function is_special_life(index)
  if life_func[index] then
    local key = life_func[index].keyID
    if Key_Form_Task == key or Key_Form_Team == key or Key_Form_Bag == key or Key_Form_Role == key or Key_Form_Home == key then
      return true
    else
      return false
    end
  end
  return false
end
function on_btn_life_1_click(self)
  local index_in_life_table = get_life_skill_by_index(1)
  if nil == index_in_life_table then
    return
  end
  local open_form = life_table[index_in_life_table].open
  local desc = life_table[index_in_life_table].desc
  local func_name = "life_skill_form_" .. desc
  nx_execute("form_stage_main\\form_life\\form_job_main_new", func_name)
end
function on_btn_life_2_click(self)
  local index_in_life_table = get_life_skill_by_index(2)
  if nil == index_in_life_table then
    return
  end
  local open_form = life_table[index_in_life_table].open
  local desc = life_table[index_in_life_table].desc
  local func_name = "life_skill_form_" .. desc
  nx_execute("form_stage_main\\form_life\\form_job_main_new", func_name)
end
function on_btn_life_3_click(self)
  local index_in_life_table = get_life_skill_by_index(3)
  if nil == index_in_life_table then
    return
  end
  local open_form = life_table[index_in_life_table].open
  local desc = life_table[index_in_life_table].desc
  local func_name = "life_skill_form_" .. desc
  nx_execute("form_stage_main\\form_life\\form_job_main_new", func_name)
end
function on_btn_life_4_click(self)
  local index_in_life_table = get_life_skill_by_index(4)
  if nil == index_in_life_table then
    return
  end
  local open_form = life_table[index_in_life_table].open
  local desc = life_table[index_in_life_table].desc
  local func_name = "life_skill_form_" .. desc
  nx_execute("form_stage_main\\form_life\\form_job_main_new", func_name)
end
function on_btn_life_5_click(self)
  local index_in_life_table = get_life_skill_by_index(5)
  if nil == index_in_life_table then
    return
  end
  local open_form = life_table[index_in_life_table].open
  local desc = life_table[index_in_life_table].desc
  local func_name = "life_skill_form_" .. desc
  nx_execute("form_stage_main\\form_life\\form_job_main_new", func_name)
end
function on_btn_life_6_click(self)
  local index_in_life_table = get_life_skill_by_index(6)
  if nil == index_in_life_table then
    return
  end
  local open_form = life_table[index_in_life_table].open
  local desc = life_table[index_in_life_table].desc
  local func_name = "life_skill_form_" .. desc
  nx_execute("form_stage_main\\form_life\\form_job_main_new", func_name)
end
function on_imagegrid_life_drag_enter(self, index)
  if not nx_find_custom(self, "DragEnabled") or not self.DragEnabled then
    return
  end
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  game_hand.IsDragged = false
  game_hand.IsDropped = false
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form.life_move_x = 0
    form.life_move_y = 0
  end
end
function on_imagegrid_life_drag_move(self, index, x, y)
  if not nx_find_custom(self, "DragEnabled") or not self.DragEnabled then
    open_fix_tips(true)
    return
  end
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if not game_hand.IsDragged then
    game_hand.IsDragged = true
    nx_execute("shortcut_game", "on_shortcut_click", self, index)
  end
end
function on_imagegrid_life_drag_leave()
end
function on_imagegrid_life_drag_in(self, index)
  if not nx_find_custom(self, "DragEnabled") or not self.DragEnabled then
    return
  end
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if game_hand.Para3 == "shortcut_right" then
    game_hand:ClearHand()
    return
  end
  if game_hand.IsDragged and not game_hand.IsDropped then
    nx_execute("shortcut_game", "on_shortcut_click", self, index)
    game_hand.IsDropped = true
  end
end
function on_imagegrid_life_rightclick_grid(self, index, is_left)
  if is_left == nil then
    is_left = false
  end
  local game_shortcut = nx_value("GameShortcut")
  if nx_is_valid(game_shortcut) then
    game_shortcut:on_main_shortcut_useitem(self, index, is_left)
  end
end
function on_imagegrid_life_select_changed(self, index)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if game_hand:IsEmpty() then
    on_main_shortcut_useitem(self, index, true)
  else
    nx_execute("shortcut_game", "on_shortcut_click", self, index)
  end
end
function is_learn_life_job(job_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if 0 <= client_player:FindRecordRow("job_rec", 0, job_id, 0) then
    return true
  end
  return false
end
function get_life_skill_by_index(index)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if index < 1 or index > view_num then
    return
  end
  local btn = nx_custom(form, "btn_life_" .. index)
  if not nx_is_valid(btn) then
    return
  end
  for i = 1, table.maxn(life_table) do
    if life_table[i].NormalImage == btn.NormalImage then
      return i
    end
  end
end
function on_btn_life_1_get_capture(self)
  local index_in_life_table = get_life_skill_by_index(1)
  if nil == index_in_life_table then
    return
  end
  local desc = life_table[index_in_life_table].desc
  text = get_text("tips_" .. desc)
  nx_execute("tips_game", "show_text_tip", text, self.AbsLeft, self.AbsTop)
end
function on_btn_life_2_get_capture(self)
  local index_in_life_table = get_life_skill_by_index(2)
  if nil == index_in_life_table then
    return
  end
  local desc = life_table[index_in_life_table].desc
  text = get_text("tips_" .. desc)
  nx_execute("tips_game", "show_text_tip", text, self.AbsLeft, self.AbsTop)
end
function on_btn_life_3_get_capture(self)
  local index_in_life_table = get_life_skill_by_index(3)
  if nil == index_in_life_table then
    return
  end
  local desc = life_table[index_in_life_table].desc
  text = get_text("tips_" .. desc)
  nx_execute("tips_game", "show_text_tip", text, self.AbsLeft, self.AbsTop)
end
function on_btn_life_4_get_capture(self)
  local index_in_life_table = get_life_skill_by_index(4)
  if nil == index_in_life_table then
    return
  end
  local desc = life_table[index_in_life_table].desc
  text = get_text("tips_" .. desc)
  nx_execute("tips_game", "show_text_tip", text, self.AbsLeft, self.AbsTop)
end
function on_btn_life_5_get_capture(self)
  local index_in_life_table = get_life_skill_by_index(5)
  if nil == index_in_life_table then
    return
  end
  local desc = life_table[index_in_life_table].desc
  text = get_text("tips_" .. desc)
  nx_execute("tips_game", "show_text_tip", text, self.AbsLeft, self.AbsTop)
end
function on_btn_life_6_get_capture(self)
  local index_in_life_table = get_life_skill_by_index(6)
  if nil == index_in_life_table then
    return
  end
  local desc = life_table[index_in_life_table].desc
  text = get_text("tips_" .. desc)
  nx_execute("tips_game", "show_text_tip", text, self.AbsLeft, self.AbsTop)
end
function on_btn_life_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_pbar_zhenqi_value_get_capture(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local jingmai_name = nx_string(client_player:QueryProp("CurJingMai"))
  if jingmai_name == "0" or jingmai_name == "" or jingmai_name == nil then
    local text = util_text("tips_curjingmai_null")
    nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop)
  else
    local wuxue_query = nx_value("WuXueQuery")
    if not nx_is_valid(wuxue_query) then
      return
    end
    local jingmai = wuxue_query:GetLearnID_JingMai(nx_string(jingmai_name))
    if not nx_is_valid(jingmai) then
      return
    end
    nx_execute("tips_game", "show_goods_tip", jingmai, self.AbsLeft, self.AbsTop, 32, 32, self.ParentForm)
  end
end
function on_pbar_zhenqi_value_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function set_new_active_origin(origin_id)
  if origin_id <= 0 then
    new_active_origin = {}
  else
    table.insert(new_active_origin, origin_id)
  end
end
function del_new_active_origin(origin_id)
  if origin_id <= 0 then
    new_active_origin = {}
  else
    for i = 1, table.getn(new_active_origin) do
      if new_active_origin[i] == origin_id then
        table.remove(new_active_origin, i)
      end
    end
  end
end
function is_new_active_origin(origin_id)
  for i = 1, table.getn(new_active_origin) do
    if origin_id == new_active_origin[i] then
      return true
    end
  end
  return false
end
function get_new_origin_id()
  return new_complete_origin
end
function set_new_origin_id(origin_id)
  new_complete_origin = origin_id
end
function on_update_open_life_flag(form)
  refresh_life_module(1)
end
function homepoint_guide_flag(show)
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    return
  end
  if show then
    form.btn_3.NormalImage = "homepoint_mark"
    form.btn_3.FocusImage = "homepoint_mark"
    form.homepointguide = true
    util_auto_show_hide_form("form_stage_main\\form_help\\form_luojiaodian")
  else
    form.homepointguide = false
    form.btn_3.NormalImage = left_right_func[3].image_out
    form.btn_3.FocusImage = left_right_func[3].image_on
  end
end
function open_fix_tips(visible)
  visible = visible or false
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local tips = form.groupbox_1
  form.groupbox_1.Visible = visible
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(FORM_NAME, "close_fix_tips", form.groupbox_1)
  timer:Register(10000, 1, FORM_NAME, "close_fix_tips", form.groupbox_1, -1, -1)
end
function close_fix_tips()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local tips = form.groupbox_1
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  form.groupbox_1.Visible = false
  timer:UnRegister(FORM_NAME, "close_fix_tips", form.groupbox_1)
end
function table_to_string(t, split)
  local rst = ""
  for i = 1, table.getn(t) - 1 do
    rst = rst .. nx_string(t[i]) .. nx_string(split)
  end
  return rst
end
function save_shortcut_location()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    return false
  end
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  local groupbox_ng = form.groupbox_ng
  local groupbox_skill = form.groupbox_skill
  local groupbox_skill_1 = form.groupbox_skill_1
  local groupbox_skill_2 = form.groupbox_skill_2
  local groupbox_skill_3 = form.groupbox_skill_3
  local cbtn_ng = form.cbtn_ng
  local cbtn_ng_grid_show = form.cbtn_ng_grid_show
  local cbtn_skill = form.cbtn_skill
  local cbtn_skill1 = form.cbtn_skill1
  local cbtn_skill2 = form.cbtn_skill2
  local cbtn_skill3 = form.cbtn_skill3
  local cbtn_ng_lock = form.cbtn_ng_lock
  local cbtn_skill_lock = form.cbtn_skill_lock
  local cbtn_skill1_lock = form.cbtn_skill1_lock
  local cbtn_skill2_lock = form.cbtn_skill2_lock
  local cbtn_skill3_lock = form.cbtn_skill3_lock
  ini.FileName = account .. "\\shortcut.ini"
  ini:LoadFromFile()
  ini:WriteInteger("groupbox_ng", "cbtn_ng", nx_int(cbtn_ng.Checked))
  ini:WriteInteger("groupbox_ng", "cbtn_ng_grid_show", nx_int(cbtn_ng_grid_show.Checked))
  ini:WriteInteger("groupbox_ng", "cbtn_ng_lock", nx_int(cbtn_ng_lock.Checked))
  ini:WriteInteger("groupbox_ng", "Left", nx_int(groupbox_ng.Left))
  ini:WriteInteger("groupbox_ng", "Top", nx_int(groupbox_ng.Top))
  ini:WriteString("groupbox_ng", "HAnchor", nx_string(groupbox_ng.HAnchor))
  ini:WriteString("groupbox_ng", "VAnchor", nx_string(groupbox_ng.VAnchor))
  ini:WriteInteger("groupbox_skill", "cbtn_skill", nx_int(cbtn_skill.Checked))
  ini:WriteInteger("groupbox_skill", "cbtn_skill_lock", nx_int(cbtn_skill_lock.Checked))
  ini:WriteInteger("groupbox_skill", "Left", nx_int(groupbox_skill.Left))
  ini:WriteInteger("groupbox_skill", "Top", nx_int(groupbox_skill.Top))
  ini:WriteInteger("groupbox_skill", "VisNum", nx_int(form.grid_shortcut_skill.VisNum))
  ini:WriteString("groupbox_skill", "HAnchor", nx_string(groupbox_skill.HAnchor))
  ini:WriteString("groupbox_skill", "VAnchor", nx_string(groupbox_skill.VAnchor))
  ini:WriteInteger("groupbox_skill_1", "cbtn_skill1", nx_int(cbtn_skill1.Checked))
  ini:WriteInteger("groupbox_skill_1", "cbtn_skill1_lock", nx_int(cbtn_skill1_lock.Checked))
  ini:WriteInteger("groupbox_skill_1", "Left", nx_int(groupbox_skill_1.Left))
  ini:WriteInteger("groupbox_skill_1", "Top", nx_int(groupbox_skill_1.Top))
  ini:WriteInteger("groupbox_skill_1", "VisNum", nx_int(form.grid_shortcut_skill_1.VisNum))
  ini:WriteString("groupbox_skill_1", "HAnchor", nx_string(groupbox_skill_1.HAnchor))
  ini:WriteString("groupbox_skill_1", "VAnchor", nx_string(groupbox_skill_1.VAnchor))
  ini:WriteInteger("groupbox_skill_2", "cbtn_skill2", nx_int(cbtn_skill2.Checked))
  ini:WriteInteger("groupbox_skill_2", "cbtn_skill2_lock", nx_int(cbtn_skill2_lock.Checked))
  ini:WriteInteger("groupbox_skill_2", "Left", nx_int(groupbox_skill_2.Left))
  ini:WriteInteger("groupbox_skill_2", "Top", nx_int(groupbox_skill_2.Top))
  ini:WriteInteger("groupbox_skill_2", "VisNum", nx_int(form.grid_shortcut_skill_2.VisNum))
  ini:WriteString("groupbox_skill_2", "HAnchor", nx_string(groupbox_skill_2.HAnchor))
  ini:WriteString("groupbox_skill_2", "VAnchor", nx_string(groupbox_skill_2.VAnchor))
  ini:WriteInteger("groupbox_skill_3", "cbtn_skill3", nx_int(cbtn_skill3.Checked))
  ini:WriteInteger("groupbox_skill_3", "cbtn_skill3_lock", nx_int(cbtn_skill3_lock.Checked))
  ini:WriteInteger("groupbox_skill_3", "Left", nx_int(groupbox_skill_3.Left))
  ini:WriteInteger("groupbox_skill_3", "Top", nx_int(groupbox_skill_3.Top))
  ini:WriteInteger("groupbox_skill_3", "VisNum", nx_int(form.grid_shortcut_skill_3.VisNum))
  ini:WriteString("groupbox_skill_3", "HAnchor", nx_string(groupbox_skill_3.HAnchor))
  ini:WriteString("groupbox_skill_3", "VAnchor", nx_string(groupbox_skill_3.VAnchor))
  ini:SaveToFile()
  nx_destroy(ini)
end
function load_shortcut_location()
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    nx_destroy(ini)
    return
  end
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\shortcut.ini"
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return
    end
    form.cbtn_ng.Checked = 1 == ini:ReadInteger("groupbox_ng", "cbtn_ng", 0)
    form.cbtn_ng_grid_show.Checked = 1 == ini:ReadInteger("groupbox_ng", "cbtn_ng_grid_show", 0)
    form.cbtn_ng_lock.Checked = 1 == ini:ReadInteger("groupbox_ng", "cbtn_ng_lock", 1)
    form.groupbox_ng.HAnchor = ini:ReadString("groupbox_ng", "HAnchor", "Center")
    form.groupbox_ng.VAnchor = ini:ReadString("groupbox_ng", "VAnchor", "Center")
    form.groupbox_ng.Left = ini:ReadInteger("groupbox_ng", "Left", 0)
    form.groupbox_ng.Top = ini:ReadInteger("groupbox_ng", "Top", 0)
    form.cbtn_skill.Checked = 1 == ini:ReadInteger("groupbox_skill", "cbtn_skill", 0)
    form.cbtn_skill_lock.Checked = 1 == ini:ReadInteger("groupbox_skill", "cbtn_skill_lock", 1)
    form.groupbox_skill.HAnchor = ini:ReadString("groupbox_skill", "HAnchor", "Center")
    form.groupbox_skill.VAnchor = ini:ReadString("groupbox_skill", "VAnchor", "Center")
    form.groupbox_skill.Left = ini:ReadInteger("groupbox_skill", "Left", 0)
    form.groupbox_skill.Top = ini:ReadInteger("groupbox_skill", "Top", 0)
    form.grid_shortcut_skill.VisNum = ini:ReadInteger("groupbox_skill", "VisNum", 0)
    form.cbtn_skill1.Checked = 1 == ini:ReadInteger("groupbox_skill_1", "cbtn_skill1", 0)
    form.cbtn_skill1_lock.Checked = 1 == ini:ReadInteger("groupbox_skill_1", "cbtn_skill1_lock", 1)
    form.groupbox_skill_1.HAnchor = ini:ReadString("groupbox_skill_1", "HAnchor", "Center")
    form.groupbox_skill_1.VAnchor = ini:ReadString("groupbox_skill_1", "VAnchor", "Center")
    form.groupbox_skill_1.Left = ini:ReadInteger("groupbox_skill_1", "Left", 0)
    form.groupbox_skill_1.Top = ini:ReadInteger("groupbox_skill_1", "Top", 0)
    form.grid_shortcut_skill_1.VisNum = ini:ReadInteger("groupbox_skill_1", "VisNum", 0)
    form.cbtn_skill2.Checked = 1 == ini:ReadInteger("groupbox_skill_2", "cbtn_skill2", 0)
    form.cbtn_skill2_lock.Checked = 1 == ini:ReadInteger("groupbox_skill_2", "cbtn_skill2_lock", 1)
    form.groupbox_skill_2.HAnchor = ini:ReadString("groupbox_skill_2", "HAnchor", "Center")
    form.groupbox_skill_2.VAnchor = ini:ReadString("groupbox_skill_2", "VAnchor", "Center")
    form.groupbox_skill_2.Left = ini:ReadInteger("groupbox_skill_2", "Left", 0)
    form.groupbox_skill_2.Top = ini:ReadInteger("groupbox_skill_2", "Top", 0)
    form.grid_shortcut_skill_2.VisNum = ini:ReadInteger("groupbox_skill_2", "VisNum", 0)
    form.cbtn_skill3.Checked = 1 == ini:ReadInteger("groupbox_skill_3", "cbtn_skill3", 0)
    form.cbtn_skill3_lock.Checked = 1 == ini:ReadInteger("groupbox_skill_3", "cbtn_skill3_lock", 1)
    form.groupbox_skill_3.HAnchor = ini:ReadString("groupbox_skill_3", "HAnchor", "Center")
    form.groupbox_skill_3.VAnchor = ini:ReadString("groupbox_skill_3", "VAnchor", "Center")
    form.groupbox_skill_3.Left = ini:ReadInteger("groupbox_skill_3", "Left", 0)
    form.groupbox_skill_3.Top = ini:ReadInteger("groupbox_skill_3", "Top", 0)
    form.grid_shortcut_skill_3.VisNum = ini:ReadInteger("groupbox_skill_3", "VisNum", 0)
  end
  nx_destroy(ini)
end
function is_skill_grid(grid)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(grid) then
    return false
  end
  if nx_id_equal(grid, form.grid_shortcut_main) or nx_id_equal(grid, form.grid_shortcut_2) or nx_id_equal(grid, form.grid_shortcut_skill) or nx_id_equal(grid, form.grid_shortcut_skill_1) or nx_id_equal(grid, form.grid_shortcut_skill_2) or nx_id_equal(grid, form.grid_shortcut_skill_3) then
    return true
  end
  return false
end
function is_ng_grid(grid)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(grid) then
    return false
  end
  if nx_id_equal(grid, form.grid_shortcut_3) or nx_id_equal(grid, form.grid_shortcut_ng) then
    return true
  end
  return false
end
function is_life_grid(grid)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(grid) then
    return false
  end
  if nx_id_equal(grid, form.imagegrid_life) then
    return true
  end
  return false
end
function on_btn_skill_num_minus_click(btn)
  local grid = btn.ParentForm.grid_shortcut_skill
  local cur_num = grid.VisNum
  chang_grid_visible_num(grid, cur_num - 1)
end
function on_btn_skill_num_plus_click(btn)
  local grid = btn.ParentForm.grid_shortcut_skill
  local cur_num = grid.VisNum
  chang_grid_visible_num(grid, cur_num + 1)
end
function on_btn_skill1_num_minus_click(btn)
  local grid = btn.ParentForm.grid_shortcut_skill_1
  local cur_num = grid.VisNum
  chang_grid_visible_num(grid, cur_num - 1)
end
function on_btn_skill1_num_plus_click(btn)
  local grid = btn.ParentForm.grid_shortcut_skill_1
  local cur_num = grid.VisNum
  chang_grid_visible_num(grid, cur_num + 1)
end
function on_btn_skill2_num_minus_click(btn)
  local grid = btn.ParentForm.grid_shortcut_skill_2
  local cur_num = grid.VisNum
  chang_grid_visible_num(grid, cur_num - 1)
end
function on_btn_skill2_num_plus_click(btn)
  local grid = btn.ParentForm.grid_shortcut_skill_2
  local cur_num = grid.VisNum
  chang_grid_visible_num(grid, cur_num + 1)
end
function on_btn_skill3_num_minus_click(btn)
  local grid = btn.ParentForm.grid_shortcut_skill_3
  local cur_num = grid.VisNum
  chang_grid_visible_num(grid, cur_num - 1)
end
function on_btn_skill3_num_plus_click(btn)
  local grid = btn.ParentForm.grid_shortcut_skill_3
  local cur_num = grid.VisNum
  chang_grid_visible_num(grid, cur_num + 1)
end
function chang_grid_visible_num(grid, num)
  if not nx_is_valid(grid) then
    return
  end
  local grid_count = grid.RowNum * grid.ClomnNum
  if num <= 0 or num > grid_count then
    return
  end
  if not nx_find_custom(grid, "VisNum") then
    return
  end
  local groupbox = grid.Parent
  if 1 == grid.RowNum then
    local H_WIDTH = 467
    groupbox.Width = H_WIDTH - (grid_count - num) * 44
    local pos = ""
    local top = 6
    for i = 1, num do
      local left = 10 + 44 * (i - 1)
      pos = pos .. nx_string(left) .. "," .. nx_string(top) .. ";"
    end
    for i = num + 1, grid_count do
      pos = pos .. nx_string(888) .. "," .. nx_string(top) .. ";"
    end
    grid.GridsPos = pos
  elseif 1 == grid.ClomnNum then
    local V_HEIGHT = 484
    groupbox.Height = V_HEIGHT - (grid_count - num) * 46
    local pos = ""
    local left = 8
    for i = 1, num do
      local top = 10 + 46 * (i - 1)
      pos = pos .. nx_string(left) .. "," .. nx_string(top) .. ";"
    end
    for i = num + 1, grid_count do
      pos = pos .. nx_string(888) .. "," .. nx_string(top) .. ";"
    end
    grid.GridsPos = pos
  end
  grid.VisNum = num
  local begin_index = grid.beginindex + grid.page * grid.ClomnNum
  for index = num, grid_count - 1 do
    if not grid:IsEmpty(index) then
      nx_execute("custom_sender", "custom_remove_shortcut", begin_index + index)
    end
  end
  refresh_shortcut_vis_num_lable(grid.ParentForm)
end
function refresh_shortcut_vis_num(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_shortcut_skill
  local grid_count = grid.RowNum * grid.ClomnNum
  if grid.VisNum <= 0 or grid_count < grid.VisNum then
    grid.VisNum = grid_count
  end
  chang_grid_visible_num(grid, grid.VisNum)
  grid = form.grid_shortcut_skill_1
  grid_count = grid.RowNum * grid.ClomnNum
  if grid.VisNum <= 0 or grid_count < grid.VisNum then
    grid.VisNum = grid_count
  end
  chang_grid_visible_num(grid, grid.VisNum)
  grid = form.grid_shortcut_skill_2
  grid_count = grid.RowNum * grid.ClomnNum
  if grid.VisNum <= 0 or grid_count < grid.VisNum then
    grid.VisNum = grid_count
  end
  chang_grid_visible_num(grid, grid.VisNum)
  grid = form.grid_shortcut_skill_3
  grid_count = grid.RowNum * grid.ClomnNum
  if grid.VisNum <= 0 or grid_count < grid.VisNum then
    grid.VisNum = grid_count
  end
  chang_grid_visible_num(grid, grid.VisNum)
end
function refresh_shortcut_vis_num_lable(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_skill_num.Text = nx_widestr(form.grid_shortcut_skill.VisNum)
  form.lbl_skill1_num.Text = nx_widestr(form.grid_shortcut_skill_1.VisNum)
  form.lbl_skill2_num.Text = nx_widestr(form.grid_shortcut_skill_2.VisNum)
  form.lbl_skill3_num.Text = nx_widestr(form.grid_shortcut_skill_3.VisNum)
end
function set_jingmaiinfo_tips(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return ""
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local curjingmai_name = nx_string(client_player:QueryProp("CurJingMai"))
  if curjingmai_name == nil or curjingmai_name == "0" or curjingmai_name == "" then
    btn.HintText = nx_widestr(util_text("tips_jingmai_info_1"))
  else
    local gui = nx_value("gui")
    local item = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_jingmai_infomation", "get_jingmai_item")
    if not nx_is_valid(item) then
      return
    end
    local level_faculty = item:QueryProp("TotalFillValue")
    local cur_fillvalue = item:QueryProp("CurFillValue")
    local Level = item:QueryProp("Level")
    local jingmai_name = nx_string(client_player:QueryProp("CurJingMai"))
    local MaxLevel = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "get_maxlevel_by_conditions", item)
    local jingmai_var = client_player:QueryProp("JingMaiTotalLevel")
    btn.HintText = nx_widestr(gui.TextManager:GetFormatText("tips_jingmai_info", nx_widestr(cur_fillvalue), nx_widestr(level_faculty), nx_widestr(Level), nx_widestr(MaxLevel), nx_widestr(util_text(jingmai_name)), nx_widestr(jingmai_var)))
  end
end
function update_newjh_main_shortcut_ui(form)
  if not nx_is_valid(form) then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form.btn_2.Visible = false
    form.btn_3.Visible = false
    form.btn_5.Visible = false
    form.btn_6.Visible = false
    form.lbl_btn_2.Visible = false
    form.lbl_btn_3.Visible = false
    form.lbl_btn_5.Visible = false
    form.lbl_btn_6.Visible = false
    local btn_1_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_1", "NormalImage", "")
    local btn_1_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_1", "FocusImage", "")
    local btn_1_push_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_1", "PushImage", "")
    local btn_1_disable_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_1", "DisableImage", "")
    form.btn_1.NormalImage = nx_string(btn_1_normal_img)
    form.btn_1.FocusImage = nx_string(btn_1_focus_img)
    form.btn_1.PushImage = nx_string(btn_1_push_img)
    form.btn_1.DisableImage = nx_string(btn_1_disable_img)
    local btn_4_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_4", "NormalImage", "")
    local btn_4_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_4", "FocusImage", "")
    local btn_4_push_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_4", "PushImage", "")
    local btn_4_disable_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_4", "DisableImage", "")
    form.btn_4.NormalImage = nx_string(btn_4_normal_img)
    form.btn_4.FocusImage = nx_string(btn_4_focus_img)
    form.btn_4.PushImage = nx_string(btn_4_push_img)
    form.btn_4.DisableImage = nx_string(btn_4_disable_img)
    local lbl_skill_bg_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_skill_bg", "BackImage", "")
    local lbl_skill_bg_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_skill_bg", "Left", "")
    local lbl_skill_bg_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_skill_bg", "Top", "")
    local lbl_skill_bg_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_skill_bg", "Width", "")
    local lbl_skill_bg_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_skill_bg", "Height", "")
    form.lbl_skill_bg.BackImage = nx_string(lbl_skill_bg_bg)
    form.lbl_skill_bg.Left = nx_int(lbl_skill_bg_left)
    form.lbl_skill_bg.Top = nx_int(lbl_skill_bg_top)
    form.lbl_skill_bg.Width = nx_int(lbl_skill_bg_width)
    form.lbl_skill_bg.Height = nx_int(lbl_skill_bg_height)
    local btn_1_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_1", "Left", "")
    local btn_1_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_1", "Top", "")
    local btn_1_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_1", "Width", "")
    local btn_1_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_1", "Height", "")
    form.btn_1.Left = nx_int(btn_1_left)
    form.btn_1.Top = nx_int(btn_1_top)
    form.btn_1.Width = nx_int(btn_1_width)
    form.btn_1.Height = nx_int(btn_1_height)
    local lbl_btn_1_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_btn_1", "Left", "")
    local lbl_btn_1_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_btn_1", "Top", "")
    form.lbl_btn_1.Left = nx_int(lbl_btn_1_left)
    form.lbl_btn_1.Top = nx_int(lbl_btn_1_top)
    local btn_4_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_4", "Left", "")
    local btn_4_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_4", "Top", "")
    local btn_4_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_4", "Width", "")
    local btn_4_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_4", "Height", "")
    form.btn_4.Left = nx_int(btn_4_left)
    form.btn_4.Top = nx_int(btn_4_top)
    form.btn_4.Width = nx_int(btn_4_width)
    form.btn_4.Height = nx_int(btn_4_height)
    local lbl_btn_4_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_btn_4", "Left", "")
    local lbl_btn_4_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_btn_4", "Top", "")
    form.lbl_btn_4.Left = nx_int(lbl_btn_4_left)
    form.lbl_btn_4.Top = nx_int(lbl_btn_4_top)
    local grid_shortcut_main_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_main", "BackImage", "")
    local grid_shortcut_main_drawback = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_main", "DrawGridBack", "")
    form.grid_shortcut_main.BackImage = nx_string(grid_shortcut_main_bg)
    form.grid_shortcut_main.DrawGridBack = nx_string(grid_shortcut_main_drawback)
    local grid_shortcut_2_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_2", "BackImage", "")
    local grid_shortcut_2_drawback = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_2", "DrawGridBack", "")
    form.grid_shortcut_2.BackImage = nx_string(grid_shortcut_2_bg)
    form.grid_shortcut_2.DrawGridBack = nx_string(grid_shortcut_2_drawback)
    local grid_shortcut_skill_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_skill", "BackImage", "")
    local grid_shortcut_skill_drawback = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_skill", "DrawGridBack", "")
    form.grid_shortcut_skill.BackImage = nx_string(grid_shortcut_skill_bg)
    form.grid_shortcut_skill.DrawGridBack = nx_string(grid_shortcut_skill_drawback)
    local grid_shortcut_ng_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_ng", "BackImage", "")
    local grid_shortcut_ng_drawback = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_ng", "DrawGridBack", "")
    form.grid_shortcut_ng.BackImage = nx_string(grid_shortcut_ng_bg)
    form.grid_shortcut_ng.DrawGridBack = nx_string(grid_shortcut_ng_drawback)
    local grid_shortcut_skill_1_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_skill_1", "BackImage", "")
    local grid_shortcut_skill_1_drawback = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_skill_1", "DrawGridBack", "")
    form.grid_shortcut_skill_1.BackImage = nx_string(grid_shortcut_skill_1_bg)
    form.grid_shortcut_skill_1.DrawGridBack = nx_string(grid_shortcut_skill_1_drawback)
    local grid_shortcut_skill_2_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_skill_2", "BackImage", "")
    local grid_shortcut_skill_2_drawback = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_skill_2", "DrawGridBack", "")
    form.grid_shortcut_skill_2.BackImage = nx_string(grid_shortcut_skill_2_bg)
    form.grid_shortcut_skill_2.DrawGridBack = nx_string(grid_shortcut_skill_2_drawback)
    local grid_shortcut_skill_3_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_skill_3", "BackImage", "")
    local grid_shortcut_skill_3_drawback = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_skill_3", "DrawGridBack", "")
    form.grid_shortcut_skill_3.BackImage = nx_string(grid_shortcut_skill_3_bg)
    form.grid_shortcut_skill_3.DrawGridBack = nx_string(grid_shortcut_skill_3_drawback)
    local grid_shortcut_3_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_3", "BackImage", "")
    local grid_shortcut_3_drawback = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "grid_shortcut_3", "DrawGridBack", "")
    form.grid_shortcut_3.BackImage = nx_string(grid_shortcut_3_bg)
    form.grid_shortcut_3.DrawGridBack = nx_string(grid_shortcut_3_drawback)
    local btn_bind_1_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_1", "NormalImage", "")
    local btn_bind_1_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_1", "FocusImage", "")
    local btn_bind_1_checked_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_1", "CheckedImage", "")
    form.btn_bind_1.NormalImage = nx_string(btn_bind_1_normal_img)
    form.btn_bind_1.FocusImage = nx_string(btn_bind_1_focus_img)
    form.btn_bind_1.CheckedImage = nx_string(btn_bind_1_checked_img)
    local btn_bind_2_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_2", "NormalImage", "")
    local btn_bind_2_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_2", "FocusImage", "")
    local btn_bind_2_checked_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_2", "CheckedImage", "")
    form.btn_bind_2.NormalImage = nx_string(btn_bind_2_normal_img)
    form.btn_bind_2.FocusImage = nx_string(btn_bind_2_focus_img)
    form.btn_bind_2.CheckedImage = nx_string(btn_bind_2_checked_img)
    local btn_bind_3_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_3", "NormalImage", "")
    local btn_bind_3_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_3", "FocusImage", "")
    local btn_bind_3_checked_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_3", "CheckedImage", "")
    form.btn_bind_3.NormalImage = nx_string(btn_bind_3_normal_img)
    form.btn_bind_3.FocusImage = nx_string(btn_bind_3_focus_img)
    form.btn_bind_3.CheckedImage = nx_string(btn_bind_3_checked_img)
    local btn_bind_4_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_4", "NormalImage", "")
    local btn_bind_4_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_4", "FocusImage", "")
    local btn_bind_4_checked_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_4", "CheckedImage", "")
    form.btn_bind_4.NormalImage = nx_string(btn_bind_4_normal_img)
    form.btn_bind_4.FocusImage = nx_string(btn_bind_4_focus_img)
    form.btn_bind_4.CheckedImage = nx_string(btn_bind_4_checked_img)
    local btn_bind_5_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_5", "NormalImage", "")
    local btn_bind_5_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_5", "FocusImage", "")
    local btn_bind_5_checked_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_bind_5", "CheckedImage", "")
    form.btn_bind_5.NormalImage = nx_string(btn_bind_5_normal_img)
    form.btn_bind_5.FocusImage = nx_string(btn_bind_5_focus_img)
    form.btn_bind_5.CheckedImage = nx_string(btn_bind_5_checked_img)
    local btn_pre_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_pre", "NormalImage", "")
    local btn_pre_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_pre", "FocusImage", "")
    local btn_pre_push_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_pre", "PushImage", "")
    form.btn_pre.NormalImage = nx_string(btn_pre_normal_img)
    form.btn_pre.FocusImage = nx_string(btn_pre_focus_img)
    form.btn_pre.PushImage = nx_string(btn_pre_push_img)
    local btn_next_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_next", "NormalImage", "")
    local btn_next_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_next", "FocusImage", "")
    local btn_next_push_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_next", "PushImage", "")
    form.btn_next.NormalImage = nx_string(btn_next_normal_img)
    form.btn_next.FocusImage = nx_string(btn_next_focus_img)
    form.btn_next.PushImage = nx_string(btn_next_push_img)
    local btn_skill_show_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_skill_show", "NormalImage", "")
    local btn_skill_show_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_skill_show", "FocusImage", "")
    local btn_skill_show_push_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_skill_show", "PushImage", "")
    form.btn_skill_show.NormalImage = nx_string(btn_skill_show_normal_img)
    form.btn_skill_show.FocusImage = nx_string(btn_skill_show_focus_img)
    form.btn_skill_show.PushImage = nx_string(btn_skill_show_push_img)
    local btn_fix_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_fix", "NormalImage", "")
    local btn_fix_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_fix", "FocusImage", "")
    local btn_fix_push_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_fix", "PushImage", "")
    form.btn_fix.NormalImage = nx_string(btn_fix_normal_img)
    form.btn_fix.FocusImage = nx_string(btn_fix_focus_img)
    form.btn_fix.PushImage = nx_string(btn_fix_push_img)
    local lbl_page_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_page", "BackImage", "")
    form.lbl_page.BackImage = nx_string(lbl_page_bg)
    local btn_unfix_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_unfix", "NormalImage", "")
    local btn_unfix_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_unfix", "FocusImage", "")
    local btn_unfix_push_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_unfix", "PushImage", "")
    form.btn_unfix.NormalImage = nx_string(btn_unfix_normal_img)
    form.btn_unfix.FocusImage = nx_string(btn_unfix_focus_img)
    form.btn_unfix.PushImage = nx_string(btn_unfix_push_img)
    local btn_move_left_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_move_left", "NormalImage", "")
    local btn_move_left_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_move_left", "FocusImage", "")
    local btn_move_left_push_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_move_left", "PushImage", "")
    local btn_move_left_disable_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_move_left", "DisableImage", "")
    form.btn_move_left.NormalImage = nx_string(btn_move_left_normal_img)
    form.btn_move_left.FocusImage = nx_string(btn_move_left_focus_img)
    form.btn_move_left.PushImage = nx_string(btn_move_left_push_img)
    form.btn_move_left.DisableImage = nx_string(btn_move_left_disable_img)
    local btn_move_right_normal_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_move_right", "NormalImage", "")
    local btn_move_right_focus_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_move_right", "FocusImage", "")
    local btn_move_right_push_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_move_right", "PushImage", "")
    local btn_move_right_disable_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_move_right", "DisableImage", "")
    form.btn_move_right.NormalImage = nx_string(btn_move_right_normal_img)
    form.btn_move_right.FocusImage = nx_string(btn_move_right_focus_img)
    form.btn_move_right.PushImage = nx_string(btn_move_right_push_img)
    form.btn_move_right.DisableImage = nx_string(btn_move_right_disable_img)
    local lbl_zhenqi_value_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_zhenqi_value", "BackImage", "")
    form.lbl_zhenqi_value.BackImage = nx_string(lbl_zhenqi_value_bg)
    local pbar_zhenqi_value_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_zhenqi_value", "ProgressImage", "")
    form.pbar_zhenqi_value.ProgressImage = nx_string(pbar_zhenqi_value_bg)
    local lbl_bar_back_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_bar_back", "BackImage", "")
    form.lbl_bar_back.BackImage = nx_string(lbl_bar_back_bg)
    local groupbox_shortcut_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "groupbox_shortcut", "Top", "")
    form.groupbox_shortcut.Top = nx_int(groupbox_shortcut_top)
    local lbl_page_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_page", "Left", "")
    local lbl_page_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_page", "Top", "")
    local lbl_page_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_page", "Width", "")
    local lbl_page_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_page", "Height", "")
    form.lbl_page.Left = nx_int(lbl_page_left)
    form.lbl_page.Top = nx_int(lbl_page_top)
    form.lbl_page.Width = nx_int(lbl_page_width)
    form.lbl_page.Height = nx_int(lbl_page_height)
    local lbl_zhenqi_value_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_zhenqi_value", "Left", "")
    local lbl_zhenqi_value_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_zhenqi_value", "Top", "")
    local lbl_zhenqi_value_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_zhenqi_value", "Width", "")
    local lbl_zhenqi_value_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_zhenqi_value", "Height", "")
    form.lbl_zhenqi_value.Left = nx_int(lbl_zhenqi_value_left)
    form.lbl_zhenqi_value.Top = nx_int(lbl_zhenqi_value_top)
    form.lbl_zhenqi_value.Width = nx_int(lbl_zhenqi_value_width)
    form.lbl_zhenqi_value.Height = nx_int(lbl_zhenqi_value_height)
    local lbl_bar_back_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_bar_back", "Left", "")
    local lbl_bar_back_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_bar_back", "Top", "")
    local lbl_bar_back_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_bar_back", "Width", "")
    local lbl_bar_back_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_bar_back", "Height", "")
    form.lbl_bar_back.Left = nx_int(lbl_bar_back_left)
    form.lbl_bar_back.Top = nx_int(lbl_bar_back_top)
    form.lbl_bar_back.Width = nx_int(lbl_bar_back_width)
    form.lbl_bar_back.Height = nx_int(lbl_bar_back_height)
    local btn_jingmai_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_jingmai", "Left", "")
    local btn_jingmai_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_jingmai", "Top", "")
    local btn_jingmai_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_jingmai", "Width", "")
    local btn_jingmai_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_jingmai", "Height", "")
    form.btn_jingmai.Left = nx_int(btn_jingmai_left)
    form.btn_jingmai.Top = nx_int(btn_jingmai_top)
    form.btn_jingmai.Width = nx_int(btn_jingmai_width)
    form.btn_jingmai.Height = nx_int(btn_jingmai_height)
    local pbar_zhenqi_value_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_zhenqi_value", "Left", "")
    local pbar_zhenqi_value_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_zhenqi_value", "Top", "")
    local pbar_zhenqi_value_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_zhenqi_value", "Width", "")
    local pbar_zhenqi_value_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_zhenqi_value", "Height", "")
    form.pbar_zhenqi_value.Left = nx_int(pbar_zhenqi_value_left)
    form.pbar_zhenqi_value.Top = nx_int(pbar_zhenqi_value_top)
    form.pbar_zhenqi_value.Width = nx_int(pbar_zhenqi_value_width)
    form.pbar_zhenqi_value.Height = nx_int(pbar_zhenqi_value_height)
  else
    form.btn_2.Visible = true
    form.btn_3.Visible = true
    form.btn_5.Visible = true
    form.btn_6.Visible = true
    form.lbl_btn_2.Visible = true
    form.lbl_btn_3.Visible = true
    form.lbl_btn_5.Visible = true
    form.lbl_btn_6.Visible = true
    form.btn_1.NormalImage = form.old_juese_normal_bg_img
    form.btn_1.FocusImage = form.old_juese_focus_bg_img
    form.btn_1.PushImage = form.old_juese_push_bg_img
    form.btn_1.DisableImage = form.old_juese_disable_bg_img
    form.btn_4.NormalImage = form.old_jineng_normal_bg_img
    form.btn_4.FocusImage = form.old_jineng_focus_bg_img
    form.btn_4.PushImage = form.old_jineng_push_bg_img
    form.btn_4.DisableImage = form.old_jineng_disable_bg_img
    form.lbl_skill_bg.BackImage = form.old_lbl_skill_bg_img
    form.lbl_skill_bg.Left = form.old_pos_beijing_x
    form.lbl_skill_bg.Top = form.old_pos_beijing_y
    form.lbl_skill_bg.Width = form.old_pos_beijing_width
    form.lbl_skill_bg.Height = form.old_pos_beijing_height
    form.btn_1.Left = form.old_pos_juese_x
    form.btn_1.Top = form.old_pos_juese_y
    form.btn_1.Width = form.old_pos_juese_width
    form.btn_1.Height = form.old_pos_juese_height
    form.lbl_btn_1.Left = form.old_pos_juese_shortcut_x
    form.lbl_btn_1.Top = form.old_pos_juese_shortcut_y
    form.btn_4.Left = form.old_pos_jineng_x
    form.btn_4.Top = form.old_pos_jineng_y
    form.btn_4.Width = form.old_pos_jineng_width
    form.btn_4.Height = form.old_pos_jineng_height
    form.lbl_btn_4.Left = form.old_pos_jineng_shortcut_x
    form.lbl_btn_4.Top = form.old_pos_jineng_shortcut_y
    form.grid_shortcut_main.BackImage = form.old_grid_shortcut_main_bg_img
    form.grid_shortcut_main.DrawGridBack = form.old_grid_shortcut_main_grid_bg_img
    form.grid_shortcut_2.BackImage = form.old_grid_shortcut_2_bg_img
    form.grid_shortcut_2.DrawGridBack = form.old_grid_shortcut_2_grid_bg_img
    form.grid_shortcut_skill.BackImage = form.old_grid_shortcut_skill_bg_img
    form.grid_shortcut_skill.DrawGridBack = form.old_grid_shortcut_skill_grid_bg_img
    form.grid_shortcut_ng.BackImage = form.old_grid_shortcut_ng_bg_img
    form.grid_shortcut_ng.DrawGridBack = form.old_grid_shortcut_ng_grid_bg_img
    form.grid_shortcut_skill_1.BackImage = form.old_grid_shortcut_skill_1_bg_img
    form.grid_shortcut_skill_1.DrawGridBack = form.old_grid_shortcut_skill_1_grid_bg_img
    form.grid_shortcut_skill_2.BackImage = form.old_grid_shortcut_skill_2_bg_img
    form.grid_shortcut_skill_2.DrawGridBack = form.old_grid_shortcut_skill_2_grid_bg_img
    form.grid_shortcut_skill_3.BackImage = form.old_grid_shortcut_skill_3_bg_img
    form.grid_shortcut_skill_3.DrawGridBack = form.old_grid_shortcut_skill_3_grid_bg_img
    form.grid_shortcut_3.BackImage = form.old_grid_shortcut_3_bg_img
    form.grid_shortcut_3.DrawGridBack = form.old_grid_shortcut_3_grid_bg_img
    form.btn_bind_1.NormalImage = form.old_btn_bind_1_normal_bg_img
    form.btn_bind_1.FocusImage = form.old_btn_bind_1_focus_bg_img
    form.btn_bind_1.CheckedImage = form.old_btn_bind_1_checked_bg_img
    form.btn_bind_2.NormalImage = form.old_btn_bind_2_normal_bg_img
    form.btn_bind_2.FocusImage = form.old_btn_bind_2_focus_bg_img
    form.btn_bind_2.CheckedImage = form.old_btn_bind_2_checked_bg_img
    form.btn_bind_3.NormalImage = form.old_btn_bind_3_normal_bg_img
    form.btn_bind_3.FocusImage = form.old_btn_bind_3_focus_bg_img
    form.btn_bind_3.CheckedImage = form.old_btn_bind_3_checked_bg_img
    form.btn_bind_4.NormalImage = form.old_btn_bind_4_normal_bg_img
    form.btn_bind_4.FocusImage = form.old_btn_bind_4_focus_bg_img
    form.btn_bind_4.CheckedImage = form.old_btn_bind_4_checked_bg_img
    form.btn_bind_5.NormalImage = form.old_btn_bind_5_normal_bg_img
    form.btn_bind_5.FocusImage = form.old_btn_bind_5_focus_bg_img
    form.btn_bind_5.CheckedImage = form.old_btn_bind_5_checked_bg_img
    form.btn_pre.NormalImage = form.old_btn_pre_normal_bg_img
    form.btn_pre.FocusImage = form.old_btn_pre_focus_bg_img
    form.btn_pre.PushImage = form.old_btn_pre_push_bg_img
    form.btn_next.NormalImage = form.old_btn_next_normal_bg_img
    form.btn_next.FocusImage = form.old_btn_next_focus_bg_img
    form.btn_next.PushImage = form.old_btn_next_push_bg_img
    form.btn_skill_show.NormalImage = form.old_btn_skill_show_normal_bg_img
    form.btn_skill_show.FocusImage = form.old_btn_skill_show_focus_bg_img
    form.btn_skill_show.PushImage = form.old_btn_skill_show_push_bg_img
    form.btn_fix.NormalImage = form.old_btn_fix_normal_bg_img
    form.btn_fix.FocusImage = form.old_btn_fix_focus_bg_img
    form.btn_fix.PushImage = form.old_btn_fix_push_bg_img
    form.lbl_page.BackImage = form.old_lbl_page_bg_img
    form.btn_unfix.NormalImage = form.old_btn_unfix_normal_bg_img
    form.btn_unfix.FocusImage = form.old_btn_unfix_focus_bg_img
    form.btn_unfix.PushImage = form.old_btn_unfix_push_bg_img
    form.btn_move_left.NormalImage = form.old_btn_move_left_normal_bg_img
    form.btn_move_left.FocusImage = form.old_btn_move_left_focus_bg_img
    form.btn_move_left.PushImage = form.old_btn_move_left_push_bg_img
    form.btn_move_left.DisableImage = form.old_btn_move_left_disable_bg_img
    form.btn_move_right.NormalImage = form.old_btn_move_right_normal_bg_img
    form.btn_move_right.FocusImage = form.old_btn_move_right_focus_bg_img
    form.btn_move_right.PushImage = form.old_btn_move_right_push_bg_img
    form.btn_move_right.DisableImage = form.old_btn_move_right_disable_bg_img
    form.lbl_zhenqi_value.BackImage = form.old_lbl_zhenqi_value_bg_img
    form.pbar_zhenqi_value.ProgressImage = form.old_pbar_zhenqi_value_prog_bg_img
    form.lbl_bar_back.BackImage = form.old_lbl_bar_back_bg_img
    form.groupbox_shortcut.Top = -162
    form.lbl_page.Left = form.old_pos_lbl_page_pos_x
    form.lbl_page.Top = form.old_pos_lbl_page_pos_y
    form.lbl_page.Width = form.old_pos_lbl_page_pos_width
    form.lbl_page.Height = form.old_pos_lbl_page_pos_height
    form.lbl_zhenqi_value.Left = form.old_pos_lbl_zhenqi_value_pos_x
    form.lbl_zhenqi_value.Top = form.old_pos_lbl_zhenqi_value_pos_y
    form.lbl_zhenqi_value.Width = form.old_pos_lbl_zhenqi_value_pos_width
    form.lbl_zhenqi_value.Height = form.old_pos_lbl_zhenqi_value_pos_height
    form.lbl_bar_back.Left = form.old_pos_lbl_bar_back_pos_x
    form.lbl_bar_back.Top = form.old_pos_lbl_bar_back_pos_y
    form.lbl_bar_back.Width = form.old_pos_lbl_bar_back_pos_width
    form.lbl_bar_back.Height = form.old_pos_lbl_bar_back_pos_height
    form.btn_jingmai.Left = form.old_pos_btn_jingmai_pos_x
    form.btn_jingmai.Top = form.old_pos_btn_jingmai_pos_y
    form.btn_jingmai.Width = form.old_pos_btn_jingmai_pos_width
    form.btn_jingmai.Height = form.old_pos_btn_jingmai_pos_height
    form.pbar_zhenqi_value.Left = form.old_pos_pbar_zhenqi_value_pos_x
    form.pbar_zhenqi_value.Top = form.old_pos_pbar_zhenqi_value_pos_y
    form.pbar_zhenqi_value.Width = form.old_pos_pbar_zhenqi_value_pos_width
    form.pbar_zhenqi_value.Height = form.old_pos_pbar_zhenqi_value_pos_height
  end
  return
end
function can_use_neigong_item(grid, index)
  local game_shortcut = nx_value("GameShortcut")
  if not nx_is_valid(game_shortcut) then
    return false
  end
  local veiw_id = game_shortcut:GetShortcutItemViewId(grid, index)
  if veiw_id == "" then
    return false
  elseif veiw_id == "neigong" then
    return true
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    if veiw_id == "121" then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("shortcut_new_jianghu_2"), 2)
      end
      return false
    end
  elseif veiw_id == "176" then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("shortcut_new_jianghu_1"), 2)
    end
    return false
  end
  return true
end
function change_shortcut_form_main_page(...)
  local form_cut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form_cut) then
    return
  end
  form_cut.grid_shortcut_main.page = nx_int(0)
  on_shortcut_record_change(form_cut.grid_shortcut_main)
end
function neigong_bing_weapon(...)
  local form_shortcut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form_shortcut) then
    return
  end
  local bind_index = nx_int(arg[1])
  if nx_int(bind_index) < nx_int(1) or nx_int(bind_index) > nx_int(3) then
    return
  end
  local btn_root_name = "btn_bind_" .. nx_string(bind_index)
  local btn_root = form_shortcut.groupbox_shortcut_3:Find(nx_string(btn_root_name))
  if not nx_is_valid(btn_root) then
    return
  end
  btn_root.Checked = true
  local bind_btn_name = "btn_bind_0" .. nx_string(bind_index)
  local bind_btn = form_shortcut.groupbox_bind:Find(nx_string(bind_btn_name))
  if not nx_is_valid(bind_btn) then
    return
  end
  on_btn_bind_click(bind_btn)
end
function is_balance_war_scene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("InteractStatus") then
    return false
  end
  local interact_status = player:QueryProp("InteractStatus")
  return nx_int(interact_status) == nx_int(ITT_BALANCE_WAR)
end
local FILE_SKILL_INI = "share\\Skill\\skill_new.ini"
function on_imagegrid_1_mousein_grid(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  if grid:IsEmpty(index) then
    return
  end
  local strSkill = grid:GetItemName(index)
  local staticdata = nx_execute("tips_data", "get_ini_prop", FILE_SKILL_INI, nx_string(strSkill), "StaticData", "")
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(strSkill)
  item.ItemType = ITEMTYPE_ZHAOSHI
  item.StaticData = nx_number(staticdata)
  item.Level = 1
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_1_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_1_drag_enter(self, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_hand = gui.GameHand
  game_hand.IsDragged = false
  game_hand.IsDropped = false
end
function on_imagegrid_1_drag_move(self, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_hand = gui.GameHand
  if not game_hand.IsDragged then
    game_hand.IsDragged = true
    on_imagegrid_1_click(self, index)
  end
end
function on_imagegrid_1_select_changed(self, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_hand = gui.GameHand
  if game_hand:IsEmpty() then
    if game_hand.IsDropped then
      game_hand.IsDropped = false
    end
  else
    if game_hand.IsDropped then
      game_hand.IsDropped = false
    end
    on_imagegrid_1_click(self, index)
  end
end
function on_imagegrid_1_click(grid, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_hand = gui.GameHand
  if grid:IsEmpty(index) and game_hand:IsEmpty() then
    return
  end
  if game_hand:IsEmpty() then
    local photo = grid:GetItemImage(index)
    local strSkill = grid:GetItemName(index)
    game_hand:SetHand(GHT_SHORTCUT, photo, photo, nx_string(strSkill), nx_string(index), "imagegrid_1")
    return
  end
  local gamehand_type = game_hand.Type
  if gamehand_type == GHT_SHORTCUT then
    if game_hand.Para4 ~= "imagegrid_1" then
      game_hand:ClearHand()
      return
    end
    if not grid:IsEmpty(index) then
      if nx_int(index) ~= nx_int(game_hand.Para3) then
        local image = grid:GetItemImage(index)
        local strSkillNow = grid:GetItemName(index)
        grid:AddItem(nx_int(game_hand.Para3), image, nx_widestr(""), nx_int(0), nx_int(0))
        grid:SetItemName(nx_int(game_hand.Para3), strSkillNow)
        grid:SetItemCoverImage(nx_int(game_hand.Para3), "")
        grid:CoverItem(nx_int(game_hand.Para3), false)
        nx_execute("form_stage_main\\form_wuxue\\form_wuxue_skill", "set_cover_image", grid, strSkillNow, nx_int(game_hand.Para3))
      end
    else
      grid:DelItem(nx_int(game_hand.Para3))
      grid:SetItemCoverImage(nx_int(game_hand.Para3), "")
      grid:CoverItem(nx_int(game_hand.Para3), false)
    end
    grid:AddItem(index, game_hand.Para1, nx_widestr(""), nx_int(0), nx_int(0))
    grid:SetItemName(index, nx_widestr(game_hand.Para2))
    grid:SetItemCoverImage(index, "")
    grid:CoverItem(index, false)
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_skill", "set_cover_image", grid, game_hand.Para2, index)
    game_hand:ClearHand()
  else
    game_hand:ClearHand()
  end
end
function synchro_shortcut_index()
  local form_main_shortcut = nx_value(FORM_NAME)
  if not nx_is_valid(form_main_shortcut) then
    return
  end
  local new_gbox = form_main_shortcut.groupbox_skill_4
  if not nx_is_valid(new_gbox) then
    return
  end
  local old_gbox = form_main_shortcut.groupbox_shortcut_1
  if not nx_is_valid(old_gbox) then
    return
  end
  for i = 1, 10 do
    local new_lbl_name = "lbl_new_" .. nx_string(i)
    local old_lbl_name = "lbl_" .. nx_string(i)
    local new_lbl = new_gbox:Find(new_lbl_name)
    local old_lbl = old_gbox:Find(old_lbl_name)
    if nx_is_valid(new_lbl) and nx_is_valid(old_lbl) then
      new_lbl.Text = old_lbl.Text
    end
  end
end
function hide_skill_yu_xaun_gbox()
  local form_main_shortcut = nx_value(FORM_NAME)
  if not nx_is_valid(form_main_shortcut) then
    return
  end
  local gbox = form_main_shortcut.groupbox_skill_4
  if nx_is_valid(gbox) then
    gbox.Visible = false
  end
end
function show_skill_yu_xaun_gbox()
  local form_main_shortcut = nx_value(FORM_NAME)
  if not nx_is_valid(form_main_shortcut) then
    return
  end
  local gui = nx_value("gui")
  local gbox = form_main_shortcut.groupbox_skill_4
  if nx_is_valid(gbox) and not gbox.Visible then
    gbox.Visible = true
    gbox.AbsTop = gui.Height / 4 * 3
  end
end
function on_btn_reset_click(btn)
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "yu_she_skill")
  if not nx_is_valid(dialog) then
    return
  end
  local text = util_text("ui_yu_she_reset")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "yu_she_skill_confirm_return")
  if res ~= "ok" then
    return
  end
  local form_main_shortcut = nx_value(FORM_NAME)
  if not nx_is_valid(form_main_shortcut) then
    return
  end
  local grid = form_main_shortcut.imagegrid_1
  if not nx_is_valid(grid) then
    return
  end
  if not nx_find_custom(grid, "SelectTaoLu") then
    return
  end
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_skill", "rec_taolu_info", nx_string(grid.SelectTaoLu), nx_int(1))
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(util_text("yuxuan_systeminfo_10006"), 2)
  end
end
function on_btn_ok_click(btn)
  local form_main_shortcut = nx_value(FORM_NAME)
  if not nx_is_valid(form_main_shortcut) then
    return
  end
  local grid = form_main_shortcut.imagegrid_1
  if not nx_is_valid(grid) then
    return
  end
  if not nx_find_custom(grid, "SelectTaoLu") then
    return
  end
  local strTotal = grid.SelectTaoLu .. ","
  for i = 0, 9 do
    local strSkill = nx_string(grid:GetItemName(i))
    if i ~= 9 then
      strTotal = strTotal .. strSkill .. ","
    else
      strTotal = strTotal .. strSkill
    end
  end
  nx_execute("custom_sender", "custom_taosha", nx_int(12), strTotal)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_skill_4.Visible = false
end
function init_bind_btn_data(form)
  for i = 1, 15 do
    local bind_lbl_name = "btn_bind_" .. i
    if nx_find_custom(form, bind_lbl_name) then
      local bind_obj = nx_custom(form, bind_lbl_name)
      bind_obj.data = nx_int(i)
    end
  end
end
