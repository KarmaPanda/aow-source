require("util_gui")
require("custom_sender")
require("util_functions")
require("define\\object_type_define")
require("share\\view_define")
require("form_stage_main\\form_task\\task_define")
require("form_stage_main\\switch\\switch_define")
local TASK_INFO_NUM = 4
local ACCEPT_DARE_TASK = 0
local GET_TASK_PRIZE = 1
local GIVE_UP_TASK = 2
local BUY_DARE_PRIZE = 3
function on_main_form_init(self)
  self.Fixed = false
  self.TaskIDStr = ""
  self.TaskCount = 0
  self.TaskComplete = ""
  self.TaskPrize = ""
  self.PrizeSelect = ""
  self.ItemConfig = ""
  self.TotalCount = 0
  self.TaskID = 0
  self.MustDo = 0
  self.PageIndex = 0
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  if check_can_get_prize(form) then
    form.btn_get_prize.Enabled = true
  else
    form.btn_get_prize.Enabled = false
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("Task_Accepted", form, "form_stage_main\\form_task\\form_dare_school_task", "on_task_accepted_change")
  end
  show_form_info(form)
  return 1
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("Task_Accepted", form)
  end
  form.Visible = false
  nx_destroy(form)
end
function on_open_form(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_dare_school_task", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.TaskIDStr = nx_string(arg[1])
  form.TaskCount = nx_int(arg[2])
  form.TaskComplete = nx_string(arg[3])
  form.TaskPrize = nx_string(arg[4])
  form.ItemConfig = nx_string(arg[5])
  if form.Visible == true then
    show_form_info(form)
  end
  util_show_form("form_stage_main\\form_task\\form_dare_school_task", true)
end
function refresh_ok_btn(form, task_id)
  if not nx_is_valid(form) then
    return
  end
  if 1 == check_can_give_up(form.TaskID) then
    form.btn_give_up.Enabled = true
    form.lbl_selected.Visible = true
    form.btn_ok.Enabled = false
  else
    form.btn_give_up.Enabled = false
    form.lbl_selected.Visible = false
    form.btn_ok.Enabled = true
  end
end
function refresh_complete_task(task_complete)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_dare_school_task", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.TaskComplete = task_complete
  local complete_table = util_split_string(form.TaskComplete, "|")
  form.lbl_percent.Text = nx_widestr(util_text("ui_smtz_1")) .. nx_widestr(table.getn(complete_table)) .. nx_widestr("/") .. nx_widestr(form.TaskCount)
  if 0 == check_task_can_accept(form, form.TaskID) then
    form.btn_ok.Enabled = false
  else
    form.btn_ok.Enabled = true
  end
  if check_can_get_prize(form) then
    form.btn_get_prize.Enabled = true
  else
    form.btn_get_prize.Enabled = false
  end
end
function tool_item_removed()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_dare_school_task", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_give_up_dare_task(form)
  if not nx_is_valid(form) then
    return
  end
  if 1 == check_can_give_up(form.TaskID) then
    form.btn_give_up.Enabled = true
    form.lbl_selected.Visible = true
    form.btn_ok.Enabled = false
  else
    form.btn_give_up.Enabled = false
    form.lbl_selected.Visible = false
    form.btn_ok.Enabled = true
  end
end
function show_form_info(form)
  if not nx_is_valid(form) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local task_info_table = util_split_string(form.TaskIDStr, "|")
  local first_task_info = util_split_string(task_info_table[1], ",")
  if table.getn(first_task_info) ~= TASK_INFO_NUM then
    return
  end
  form.TaskID = nx_int(first_task_info[1])
  form.MustDo = nx_int(first_task_info[2])
  form.TotalCount = table.getn(task_info_table)
  form.lbl_must_do.Text = nx_widestr(form.MustDo)
  form.lbl_task_title.Text = nx_widestr(util_text(nx_string(first_task_info[3])))
  form.mltbox_task_describe.HtmlText = nx_widestr(util_text(nx_string(first_task_info[4])))
  if 0 == check_task_can_accept(form, form.TaskID) then
    form.btn_ok.Enabled = false
  else
    form.btn_ok.Enabled = true
  end
  if 1 == check_can_give_up(form.TaskID) then
    form.btn_give_up.Enabled = true
    form.lbl_selected.Visible = true
  else
    form.btn_give_up.Enabled = false
    form.lbl_selected.Visible = false
  end
  local complete_task = util_split_string(form.TaskComplete, "|")
  local complete_count = table.getn(complete_task)
  if complete_count >= form.TaskCount then
    form.btn_get_prize.Enabled = true
  else
    form.btn_get_prize.Enabled = false
  end
  form.lbl_percent.Text = nx_widestr(util_text("ui_smtz_1")) .. nx_widestr(complete_count) .. nx_widestr("/") .. nx_widestr(form.TaskCount)
  form.imagegrid_prize:Clear()
  local prize_info = taskmgr:GetDareSchoolPrizeInfo(nx_string(form.TaskPrize))
  local prize_table = util_split_string(prize_info, "|")
  if table.getn(prize_table) ~= 4 then
    return
  end
  for i, prize_id in pairs(prize_table) do
    local str_icon = nx_call("util_static_data", "item_query_ArtPack_by_id", prize_id, "Photo")
    form.imagegrid_prize:AddItem(i - 1, nx_string(str_icon), nx_widestr(prize_id), nx_int(1), nx_int(0))
  end
  form.PageIndex = 1
  form.PrizeSelect = ""
  form.lbl_page.Text = nx_widestr(nx_string(form.PageIndex) .. "/" .. nx_string(form.TotalCount))
  form.btn_front.Enabled = false
  form.btn_next.Enabled = true
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.PageIndex = form.PageIndex + 1
  local task_info_table = util_split_string(form.TaskIDStr, "|")
  local task_info = util_split_string(task_info_table[form.PageIndex], ",")
  if table.getn(task_info) ~= TASK_INFO_NUM then
    return
  end
  form.TaskID = nx_int(task_info[1])
  form.MustDo = nx_int(task_info[2])
  form.lbl_must_do.Text = nx_widestr(form.MustDo)
  form.lbl_task_title.Text = nx_widestr(util_text(nx_string(task_info[3])))
  form.mltbox_task_describe.HtmlText = nx_widestr(util_text(nx_string(task_info[4])))
  if 0 == check_task_can_accept(form, form.TaskID) then
    form.btn_ok.Enabled = false
  else
    form.btn_ok.Enabled = true
  end
  if form.PageIndex > table.getn(task_info_table) - 1 then
    btn.Enabled = false
  end
  form.btn_front.Enabled = true
  form.lbl_page.Text = nx_widestr(nx_string(form.PageIndex) .. "/" .. nx_string(form.TotalCount))
  if 1 == check_can_give_up(form.TaskID) then
    form.btn_give_up.Enabled = true
    form.lbl_selected.Visible = true
  else
    form.btn_give_up.Enabled = false
    form.lbl_selected.Visible = false
  end
end
function on_btn_front_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.PageIndex = form.PageIndex - 1
  local task_info_table = util_split_string(form.TaskIDStr, "|")
  local task_info = util_split_string(task_info_table[form.PageIndex], ",")
  if table.getn(task_info) ~= TASK_INFO_NUM then
    return
  end
  form.TaskID = nx_int(task_info[1])
  form.MustDo = nx_int(task_info[2])
  form.lbl_must_do.Text = nx_widestr(form.MustDo)
  form.lbl_task_title.Text = nx_widestr(util_text(nx_string(task_info[3])))
  form.mltbox_task_describe.HtmlText = nx_widestr(util_text(nx_string(task_info[4])))
  if 0 == check_task_can_accept(form, form.TaskID) then
    form.btn_ok.Enabled = false
  else
    form.btn_ok.Enabled = true
  end
  if form.PageIndex <= 1 then
    btn.Enabled = false
  end
  form.btn_next.Enabled = true
  form.lbl_page.Text = nx_widestr(nx_string(form.PageIndex) .. "/" .. nx_string(form.TotalCount))
  if 1 == check_can_give_up(form.TaskID) then
    form.btn_give_up.Enabled = true
    form.lbl_selected.Visible = true
  else
    form.btn_give_up.Enabled = false
    form.lbl_selected.Visible = false
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DARE_SCHOOL_TASK), nx_int(ACCEPT_DARE_TASK), nx_int(form.TaskID), nx_string(form.ItemConfig))
end
function on_btn_give_up_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DARE_SCHOOL_TASK), nx_int(GIVE_UP_TASK), nx_int(form.TaskID), nx_string(form.ItemConfig))
end
function on_btn_get_prize_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if form.PrizeSelect ~= "" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DARE_SCHOOL_TASK), nx_int(GET_TASK_PRIZE), form.PrizeSelect, nx_string(form.ItemConfig))
    form:Close()
  end
end
function on_btn_buy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local taskmanger = nx_value("TaskManager")
  if not nx_is_valid(taskmanger) then
    return
  end
  local mgr = nx_value("CapitalModule")
  if not nx_is_valid(mgr) then
    return
  end
  local money = taskmanger:GetShiMenMoney()
  gui.TextManager:Format_SetIDName("ui_buy_dare_prize")
  local switchmgr = nx_value("SwitchManager")
  if nx_is_valid(switchmgr) and switchmgr:CheckSwitchEnable(ST_FUNCTION_POINT_TO_BINDCARD) and mgr:CanDecCapital(4, nx_int64(money)) then
    gui.TextManager:Format_SetIDName("ui_cost_yinpiao")
  end
  gui.TextManager:Format_AddParam(nx_int(money))
  local text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DARE_SCHOOL_TASK), nx_int(BUY_DARE_PRIZE), nx_string(form.ItemConfig))
end
function on_imagegrid_prize_mousein_grid(grid, index)
  nx_execute("form_stage_main\\form_task\\form_task_main", "show_prize_tips", grid, index)
end
function on_imagegrid_prize_mouseout_grid()
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_prize_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local prize_id = grid:GetItemName(index)
  form.PrizeSelect = nx_string(prize_id)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_task_accepted_change(self, recordname, optype, row, clomn)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_dare_school_task", true, false)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("Task_Accepted") then
    return 0
  end
  if optype == "add" then
    local task_id = client_player:QueryRecord("Task_Accepted", row, accept_rec_id)
    refresh_ok_btn(form, task_id)
  end
  if optype == "del" or optype == "clear" then
    on_give_up_dare_task(form)
  end
end
function check_task_can_accept(form, task_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local task_accept_count = 0
  local task_complete_count = 0
  local task_info_table = util_split_string(form.TaskIDStr, "|")
  local task_complete = util_split_string(form.TaskComplete, "|")
  task_complete_count = table.getn(task_complete)
  for i, taskIDTemp in pairs(task_complete) do
    if nx_int(task_id) == nx_int(taskIDTemp) then
      return 0
    end
  end
  local row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id), 0)
  if 0 <= row then
    return 0
  end
  for i, taskInfo in pairs(task_info_table) do
    local task_info = util_split_string(taskInfo, ",")
    if table.getn(task_info) ~= TASK_INFO_NUM then
      return 0
    end
    local task_info_id = task_info[1]
    local row_task = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_info_id), 0)
    if 0 <= row_task then
      task_accept_count = task_accept_count + 1
    end
  end
  if task_complete_count + task_accept_count >= form.TaskCount then
    return 0
  end
  return 1
end
function check_can_get_prize(form)
  if not nx_is_valid(form) then
    return false
  end
  local completed = util_split_string(form.TaskComplete, "|")
  if table.getn(completed) >= form.TaskCount then
    return true
  end
  return false
end
function check_can_give_up(task_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id), 0)
  if 0 <= row then
    return 1
  end
  return 0
end
