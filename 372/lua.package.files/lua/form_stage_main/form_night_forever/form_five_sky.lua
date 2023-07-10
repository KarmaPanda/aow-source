require("util_static_data")
require("util_functions")
require("util_gui")
local FORM_PATH = "form_stage_main\\form_night_forever\\form_five_sky"
local CLIENT_SUB_FIVE_SKY_REQUEST_DATA = 1
local SERVER_SUB_FIVE_SKY_SEND_DATA = 1
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_five_sky_form(form)
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "request_data", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function init_five_sky_form(form)
  form.index = 0
  form.total_max_value = 0
  form.total_cur_value = 0
  form.max_value = 0
  form.cur_value = 0
  form.total_step = 0
  form.str_step_value = ""
  form.week_max_value = 0
  form.week_cur_value = 0
  form.rbtn_seek.Checked = true
  form.rbtn_map_1.Checked = true
  refresh_seek_box(form)
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("FiveSkyJin", "int", form, FORM_PATH, "on_FiveSkyJin_changed")
  databinder:AddRolePropertyBind("FiveSkyMu", "int", form, FORM_PATH, "on_FiveSkyMu_changed")
  databinder:AddRolePropertyBind("FiveSkyShui", "int", form, FORM_PATH, "on_FiveSkyShui_changed")
  databinder:AddRolePropertyBind("FiveSkyHuo", "int", form, FORM_PATH, "on_FiveSkyHuo_changed")
  databinder:AddRolePropertyBind("FiveSkyTu", "int", form, FORM_PATH, "on_FiveSkyTu_changed")
  databinder:AddRolePropertyBind("FiveSkyTotal_1", "int", form, FORM_PATH, "on_FiveSkyTotal_1_changed")
  databinder:AddRolePropertyBind("FiveSkyTotal", "int", form, FORM_PATH, "on_FiveSkyTotal_changed")
  local timer = nx_value("timer_game")
  timer:Register(30000, -1, nx_current(), "request_data", form, -1, -1)
end
function request_data(form)
  nx_execute("custom_sender", "custom_five_sky", CLIENT_SUB_FIVE_SKY_REQUEST_DATA, nx_int(form.index))
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.rbtn_seek.Checked == true then
    form.box_seek.Visible = true
    form.box_prize.Visible = false
    refresh_seek_box(form)
  elseif form.rbtn_prize.Checked == true then
    form.box_seek.Visible = false
    form.box_prize.Visible = true
    refresh_prize_box(form)
  end
end
function on_rbtn_map_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked == true then
    form.index = nx_int(rbtn.DataSource)
    nx_execute("custom_sender", "custom_five_sky", CLIENT_SUB_FIVE_SKY_REQUEST_DATA, nx_int(rbtn.DataSource))
  end
end
function refresh_seek_box(form)
  local gui = nx_value("gui")
  local FiveSkyQuery = nx_value("FiveSkyQuery")
  if not nx_is_valid(FiveSkyQuery) then
    return
  end
  form.mltbox_intro:Clear()
  local intro_title = nx_widestr(gui.TextManager:GetText("ui_fivesky_intro")) .. nx_widestr("<br>")
  form.mltbox_intro:AddHtmlText(intro_title, -1)
  local str_title = FiveSkyQuery:GetFiveSkyTitle(form.index)
  form.lbl_subtitle.Text = nx_widestr(gui.TextManager:GetText(str_title))
  local str_intro = FiveSkyQuery:GetFiveSkyIntro(form.index)
  local str_intro_lst = util_split_string(str_intro, ";")
  for i = 1, table.getn(str_intro_lst) do
    local jihuo = ""
    if get_step_stage(form, i) == true then
      jihuo = nx_widestr(gui.TextManager:GetText("ui_fivesky_yjh"))
      local str_temp = "ui_fivesky_cw" .. nx_string(i)
      local str_cw = nx_widestr(gui.TextManager:GetText(str_temp)) .. jihuo .. nx_widestr("<br>")
      form.mltbox_intro:AddHtmlText(str_cw, -1)
      form.mltbox_intro:AddHtmlText(gui.TextManager:GetText(str_intro_lst[i]), -1)
    else
      jihuo = nx_widestr(gui.TextManager:GetText("ui_fivesky_wjh"))
      local str_temp = "ui_fivesky_cw" .. nx_string(i)
      local str_cw = nx_widestr(gui.TextManager:GetText(str_temp)) .. jihuo .. nx_widestr("<br>")
      form.mltbox_intro:AddHtmlText(str_cw, -1)
      form.mltbox_intro:AddHtmlText(nx_widestr("???"), -1)
    end
  end
  form.mltbox_taskinfo:Clear()
  local task_title = nx_widestr(gui.TextManager:GetText("ui_fivesky_taskinfo")) .. nx_widestr("<br>")
  form.mltbox_taskinfo:AddHtmlText(task_title, -1)
  local str_taskinfo = FiveSkyQuery:GetFiveSkyTaskInfo(form.index)
  local str_taskinfo_lst = util_split_string(str_taskinfo, ";")
  local index = 1
  for i = 1, table.getn(str_taskinfo_lst) do
    local str_subtask_lst = util_split_string(str_taskinfo_lst[i], ",")
    for j = 1, table.getn(str_subtask_lst) do
      local jihuo = ""
      if nx_number(i) > nx_number(1) then
        if get_step_stage(form, i - 1) == true then
          jihuo = nx_widestr(gui.TextManager:GetText("ui_fivesky_yjh"))
        else
          jihuo = nx_widestr(gui.TextManager:GetText("ui_fivesky_wjh"))
        end
      else
        jihuo = nx_widestr(gui.TextManager:GetText("ui_fivesky_yjh"))
      end
      local str_subtask = nx_widestr(index) .. nx_widestr(".") .. gui.TextManager:GetText(str_subtask_lst[j]) .. jihuo .. nx_widestr("<br>")
      form.mltbox_taskinfo:AddHtmlText(str_subtask, -1)
      index = index + 1
    end
  end
  form.mltbox_taskinfo:AddHtmlText(gui.TextManager:GetText(FiveSkyQuery:GetFiveSkyTaskExInfo(form.index)), -1)
  form.pbar_mini.Maximum = nx_int(form.max_value)
  form.pbar_mini.Value = nx_int(form.cur_value)
  form.lbl_barvalue_mini.Text = nx_widestr(form.cur_value) .. nx_widestr("/") .. nx_widestr(form.max_value)
  form.pbar_main.Maximum = nx_int(form.total_max_value)
  form.pbar_main.Value = nx_int(form.total_cur_value)
  form.lbl_barvalue_main.Text = nx_widestr(form.total_cur_value) .. nx_widestr("/") .. nx_widestr(form.total_max_value)
  if get_step_stage(form, 3) == true then
    form.lbl_tips_3.Text = nx_widestr(gui.TextManager:GetText("ui_fivesky_lbl_yjh"))
    form.lbl_tips_3.ForeColor = "255,0,255,0"
  else
    form.lbl_tips_3.Text = nx_widestr(gui.TextManager:GetText("ui_fivesky_lbl_wjh"))
    form.lbl_tips_3.ForeColor = "255,255,0,0"
  end
  if get_step_stage(form, 2) == true then
    form.lbl_tips_2.Text = nx_widestr(gui.TextManager:GetText("ui_fivesky_lbl_yjh"))
    form.lbl_tips_2.ForeColor = "255,0,255,0"
  else
    form.lbl_tips_2.Text = nx_widestr(gui.TextManager:GetText("ui_fivesky_lbl_wjh"))
    form.lbl_tips_2.ForeColor = "255,255,0,0"
  end
  if get_step_stage(form, 1) == true then
    form.lbl_tips_1.Text = nx_widestr(gui.TextManager:GetText("ui_fivesky_lbl_yjh"))
    form.lbl_tips_1.ForeColor = "255,0,255,0"
  else
    form.lbl_tips_1.Text = nx_widestr(gui.TextManager:GetText("ui_fivesky_lbl_wjh"))
    form.lbl_tips_1.ForeColor = "255,255,0,0"
  end
end
function on_server_msg(sub_msg, ...)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(sub_msg) == nx_int(SERVER_SUB_FIVE_SKY_SEND_DATA) then
    form.total_max_value = nx_int(arg[1])
    form.total_cur_value = nx_int(arg[2])
    form.max_value = nx_int(arg[3])
    form.cur_value = nx_int(arg[4])
    form.total_step = nx_int(arg[5])
    form.week_max_value = nx_int(arg[6])
    form.week_cur_value = nx_int(arg[7])
    form.str_step_value = nx_string(arg[8])
    refresh_seek_box(form)
  end
end
function get_step_stage(form, step)
  local step_value_lst = util_split_string(form.str_step_value, ",")
  if nx_int(step) > nx_int(table.getn(step_value_lst)) then
    return false
  end
  if nx_int(form.cur_value) >= nx_int(step_value_lst[step]) then
    return true
  end
  return false
end
function on_lbl_step_get_capture(lbl)
  local gui = nx_value("gui")
  local FiveSkyQuery = nx_value("FiveSkyQuery")
  if not nx_is_valid(FiveSkyQuery) then
    return
  end
  local form = lbl.ParentForm
  local str_tips = FiveSkyQuery:GetFiveSkyTips(nx_int(form.index))
  local str_tips_lst = util_split_string(str_tips, ";")
  local index = nx_number(lbl.DataSource)
  if nx_number(index) > nx_number(table.getn(str_tips_lst)) then
    return
  end
  local tips = gui.TextManager:GetText(str_tips_lst[index])
  local gui = nx_value("gui")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips), mouse_x, mouse_z)
end
function on_lbl_step_lost_capture(lbl)
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
function refresh_prize_box(form)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local FiveSkyQuery = nx_value("FiveSkyQuery")
  if not nx_is_valid(FiveSkyQuery) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  form.lbl_prop_jin.Text = nx_widestr(client_player:QueryProp("FiveSkyJin"))
  form.lbl_prop_mu.Text = nx_widestr(client_player:QueryProp("FiveSkyMu"))
  form.lbl_prop_shui.Text = nx_widestr(client_player:QueryProp("FiveSkyShui"))
  form.lbl_prop_huo.Text = nx_widestr(client_player:QueryProp("FiveSkyHuo"))
  form.lbl_prop_tu.Text = nx_widestr(client_player:QueryProp("FiveSkyTu"))
  form.lbl_prop_total.Text = nx_widestr(client_player:QueryProp("FiveSkyTotal_1"))
  form.lbl_prop_total_2.Text = nx_widestr(client_player:QueryProp("FiveSkyTotal"))
  form.lbl_prop_week.Text = nx_widestr(form.week_cur_value) .. nx_widestr("/") .. nx_widestr(form.week_max_value)
  local str_join_prize = FiveSkyQuery:GetJoinPrize()
  local str_join_lst = util_split_string(str_join_prize, ";")
  for i = 1, table.getn(str_join_lst) do
    local photo = ItemQuery:GetItemPropByConfigID(str_join_lst[i], "Photo")
    form.imagegrid_join:AddItem(i - 1, photo, nx_widestr(str_join_lst[i]), 1, 0)
  end
  local str_rank_prize = FiveSkyQuery:GetRankPrize()
  local str_rank_lst = util_split_string(str_rank_prize, ";")
  for i = 1, table.getn(str_rank_lst) do
    local photo = ItemQuery:GetItemPropByConfigID(str_rank_lst[i], "Photo")
    form.imagegrid_rank:AddItem(i - 1, photo, nx_widestr(str_rank_lst[i]), 1, 0)
  end
end
function on_imagegrid_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_FiveSkyJin_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = client_player:QueryProp("FiveSkyJin")
  if nx_number(value) < 0 then
    value = 0
  end
  form.lbl_prop_jin.Text = nx_widestr(value)
end
function on_FiveSkyMu_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = client_player:QueryProp("FiveSkyMu")
  if nx_number(value) < 0 then
    value = 0
  end
  form.lbl_prop_mu.Text = nx_widestr(value)
end
function on_FiveSkyShui_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = client_player:QueryProp("FiveSkyShui")
  if nx_number(value) < 0 then
    value = 0
  end
  form.lbl_prop_shui.Text = nx_widestr(value)
end
function on_FiveSkyHuo_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = client_player:QueryProp("FiveSkyHuo")
  if nx_number(value) < 0 then
    value = 0
  end
  form.lbl_prop_huo.Text = nx_widestr(value)
end
function on_FiveSkyTu_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = client_player:QueryProp("FiveSkyTu")
  if nx_number(value) < 0 then
    value = 0
  end
  form.lbl_prop_tu.Text = nx_widestr(value)
end
function on_FiveSkyTotal_1_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = client_player:QueryProp("FiveSkyTotal_1")
  if nx_number(value) < 0 then
    value = 0
  end
  form.lbl_prop_total.Text = nx_widestr(value)
end
function on_FiveSkyTotal_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = client_player:QueryProp("FiveSkyTotal")
  if nx_number(value) < 0 then
    value = 0
  end
  form.lbl_prop_total_2.Text = nx_widestr(value)
end
