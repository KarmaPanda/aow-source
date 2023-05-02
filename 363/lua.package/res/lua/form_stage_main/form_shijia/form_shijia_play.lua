require("util_functions")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
require("define\\sysinfo_define")
local FORM = "form_stage_main\\form_shijia\\form_shijia_play"
local shijia_leibie = {
  "shijia_dongfang",
  "shijia_nangong",
  "shijia_yanmen",
  "shijia_murong"
}
local shijia_trans = {
  "ui_shijia_ac_dongfang",
  "ui_shijia_ac_nangong",
  "ui_shijia_ac_yanmen",
  "ui_shijia_ac_murong",
  "ui_shijia_trans_OK"
}
local shijia_rank = {
  "rank_ff_activity_127",
  "rank_ff_activity_129",
  "rank_ff_activity_128",
  "rank_ff_activity_126"
}
local LEFT_TIMES = 0
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.select_rbtn = ""
  form.select_cbtn = ""
  local rbtn = form.rbtn_1
  if not nx_is_valid(rbtn) then
    return
  end
  local form_logic = nx_value("form_shijia_play")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_shijia_play")
  if nx_is_valid(form_logic) then
    nx_set_value("form_shijia_play", form_logic)
  end
  rbtn.Checked = true
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local form_logic = nx_value("form_shijia_play")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  nx_destroy(form)
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.select_rbtn = rbtn
  local form_logic = nx_value("form_shijia_play")
  if not nx_is_valid(form_logic) then
    return
  end
  local id = nx_int(rbtn.DataSource)
  if id >= nx_int(1) and id <= nx_int(4) then
    nx_execute("custom_sender", "custom_send_query_round_task", nx_int(5), nx_int(id))
  end
end
function on_btn_checked_changed(cbtn)
  if not cbtn.Checked then
    return
  end
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local groupbox = form.groupscrollbox_2
  if not nx_is_valid(groupbox) then
    return
  end
  local ctls = groupbox:GetChildControlList()
  for _, gbx in ipairs(ctls) do
    local cbtns = gbx:GetChildControlList()
    for _, btn in ipairs(cbtns) do
      if not nx_id_equal(btn, cbtn) then
        btn.Checked = false
      end
    end
  end
  local form_logic = nx_value("form_shijia_play")
  if not nx_is_valid(form_logic) then
    return
  end
  if not nx_find_custom(cbtn, "ID") then
    return
  end
  local id = nx_string(cbtn.ID)
  form.select_cbtn = id
  form_logic:UpdateSJDailyDesc(nx_string(id))
end
function on_imagegrid_1_mousein_grid(grid, index)
  local grid_id = grid.DataSource
  local form_logic = nx_value("form_shijia_play")
  if nx_is_valid(form_logic) then
    local form = grid.ParentForm
    if not nx_is_valid(form) then
      return
    end
    local x = grid.AbsLeft
    local y = grid.AbsTop
    local config_id = form_logic:GetPrize(nx_string(grid_id))
    if config_id ~= "" then
      nx_execute("tips_game", "show_tips_by_config", config_id, x, y, grid.ParentForm)
    end
  end
end
function on_imagegrid_1_mouseout_grid(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_trans_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local rbtn = form.select_rbtn
  if not nx_is_valid(rbtn) then
    return
  end
  local id = nx_int(rbtn.DataSource)
  if id < nx_int(1) or id > nx_int(4) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_int(LEFT_TIMES) <= nx_int(0) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19908"), 2)
    end
    form.btn_trans.Enabled = false
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    gui.TextManager:Format_SetIDName(nx_string("ui_shijia_trans_times"))
    gui.TextManager:Format_AddParam(nx_int(0))
    gui.TextManager:Format_AddParam(nx_int(0))
    form.btn_trans.HintText = gui.TextManager:Format_GetText()
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local goods_count = goods_grid:GetItemCount("backtown_lzy_sdsj_001")
  if nx_int(LEFT_TIMES) < nx_int(7) and goods_count <= 0 then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19918"), 2)
    end
    return
  end
  if nx_int(LEFT_TIMES) >= nx_int(7) or 1 <= goods_count then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    gui.TextManager:Format_SetIDName(shijia_trans[5])
    if nx_int(id) == nx_int(1) then
      gui.TextManager:Format_AddParam(shijia_trans[1])
    elseif nx_int(id) == nx_int(2) then
      gui.TextManager:Format_AddParam(shijia_trans[2])
    elseif nx_int(id) == nx_int(3) then
      gui.TextManager:Format_AddParam(shijia_trans[3])
    elseif nx_int(id) == nx_int(4) then
      gui.TextManager:Format_AddParam(shijia_trans[4])
    end
    local text = gui.TextManager:Format_GetText()
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "shijia_trans_sure")
    if not nx_is_valid(dialog) then
      return
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "shijia_trans_sure_confirm_return")
    if res ~= "ok" then
      return
    end
    nx_execute("custom_sender", "custom_shijia_trains", nx_int(0), nx_int(id))
  end
end
function on_btn_refresh_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_shijia_trains", nx_int(1), nx_int(0))
  local shijia_btn = form.select_rbtn
  if not nx_is_valid(shijia_btn) then
    return
  end
  local id = nx_int(shijia_btn.DataSource)
  if id >= nx_int(1) and id <= nx_int(4) then
    nx_execute("custom_sender", "custom_send_query_round_task", nx_int(5), nx_int(id))
  end
  btn.Enabled = false
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "form_refresh", form)
    timer:Register(5000, 1, nx_current(), "form_refresh", form, -1, -1)
  end
end
function form_refresh(form)
  if not nx_is_valid(form) then
    return
  end
  form.btn_refresh.Enabled = true
end
function on_btn_rank_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local rbtn = form.select_rbtn
  if not nx_is_valid(rbtn) then
    return
  end
  local shijia_type = nx_int(rbtn.DataSource)
  if shijia_type < nx_int(1) or shijia_type > nx_int(4) then
    return
  end
  local rank_name = ""
  if nx_int(shijia_type) == nx_int(1) then
    rank_name = shijia_rank[1]
  elseif nx_int(shijia_type) == nx_int(2) then
    rank_name = shijia_rank[2]
  elseif nx_int(shijia_type) == nx_int(3) then
    rank_name = shijia_rank[3]
  elseif nx_int(shijia_type) == nx_int(4) then
    rank_name = shijia_rank[4]
  end
  local form_rank_path = "form_stage_main\\form_rank\\form_rank_main"
  local form_rank = nx_value(form_rank_path)
  if not nx_is_valid(form_rank) then
    form_rank = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_rank\\form_rank_main", true, false)
  end
  if not nx_is_valid(form_rank) then
    return
  end
  form_rank:Show()
  form_rank.Visible = true
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", form_rank, rank_name)
end
function on_server_msg(times)
  local form = util_get_form(FORM, false)
  if not nx_is_valid(form) then
    return
  end
  LEFT_TIMES = nx_int(times)
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return
  end
  local open = SwitchManager:CheckSwitchEnable(ST_FUNCTION_SHIJIA_TRANS)
  if open and nx_int(LEFT_TIMES) > nx_int(0) then
    form.btn_trans.Enabled = true
  else
    form.btn_trans.Enabled = false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName(nx_string("ui_shijia_trans_times"))
  if nx_int(LEFT_TIMES) > nx_int(6) then
    local left_free = LEFT_TIMES - 6
    gui.TextManager:Format_AddParam(nx_int(left_free))
  else
    gui.TextManager:Format_AddParam(nx_int(0))
  end
  gui.TextManager:Format_AddParam(nx_int(LEFT_TIMES))
  form.btn_trans.HintText = gui.TextManager:Format_GetText()
end
function open_form(strId)
  local count = table.getn(shijia_leibie)
  local Id = 0
  for i = 1, count do
    if nx_string(strId) == nx_string(shijia_leibie[i]) then
      Id = nx_int(i)
      break
    end
  end
  if nx_int(Id) == nx_int(0) then
    return
  end
  local form = util_get_form(FORM, true)
  if not nx_is_valid(form) then
    return
  end
  local rbtn = ""
  if nx_int(Id) == nx_int(1) then
    rbtn = form.rbtn_1
  elseif nx_int(Id) == nx_int(2) then
    rbtn = form.rbtn_2
  elseif nx_int(Id) == nx_int(3) then
    rbtn = form.rbtn_3
  elseif nx_int(Id) == nx_int(4) then
    rbtn = form.rbtn_4
  end
  if nx_is_valid(rbtn) then
    rbtn.Checked = true
  end
end
function open_play_form(...)
  local form = util_get_form(FORM, true)
  if not nx_is_valid(form) then
    return
  end
  local shijia_type = nx_int(arg[2])
  local arraylist = ""
  local count = table.getn(arg)
  for i = 3, count do
    arraylist = arraylist .. nx_string(arg[i])
    if i ~= count then
      arraylist = arraylist .. ";"
    end
  end
  local form_logic = nx_value("form_shijia_play")
  if nx_is_valid(form_logic) then
    form_logic:InitSJDailyUI(nx_int(shijia_type), nx_string(arraylist))
  end
end
