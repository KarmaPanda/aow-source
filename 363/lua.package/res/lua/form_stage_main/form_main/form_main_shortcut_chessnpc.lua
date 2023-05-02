require("util_static_data")
require("share\\client_custom_define")
local g_npc
function main_form_init(self)
  self.Fixed = true
  self.no_need_motion_alpha = true
  return 1
end
function on_main_form_open(self)
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = false
  change_form_size()
  refresh_form(self)
  local hp_ratio = nx_number(self.imagegrid_1.client_machine_obj:QueryProp("HPRatio"))
  local need_cd = nx_number(self.imagegrid_1.client_machine_obj:QueryProp("NeedCD"))
  on_hp_change(hp_ratio)
  on_need_cd_change(need_cd)
end
function on_main_form_close(self)
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = true
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function on_need_cd_change(prop_value)
  local self = nx_value(nx_current())
  if not nx_is_valid(self) or self.Visible == false then
    return
  end
  local gui = nx_value("gui")
  gui.CoolManager:StartACool(nx_int(978881), nx_int(prop_value) * 1000, nx_int(-1), 0)
end
function on_hp_change(prop_value)
  local self = nx_value(nx_current())
  if not nx_is_valid(self) or self.Visible == false then
    return
  end
  self.pbar_hp.Maximum = 100
  self.pbar_hp.Value = nx_number(prop_value)
end
function show_form(npc)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_shortcut_chessnpc", true)
  form.npc = npc
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_main_shortcut_chessnpc", true)
end
function hide_form()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_chessnpc")
  if nx_is_valid(form) then
    form:Close()
  end
end
function refresh_form(form)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local gui = nx_value("gui")
  local client_ident = game_visual:QueryRoleClientIdent(form.npc)
  local client_machine_obj = game_client:GetSceneObj(nx_string(client_ident))
  local visual_machine_obj = form.npc
  local grid = form.imagegrid_1
  grid.client_machine_obj = 0
  grid.CloseIndex = 0
  grid.client_machine_obj = client_machine_obj
  if not client_machine_obj:FindRecord("chess_skill_rec") then
    return
  end
  local row_count = client_machine_obj:GetRecordRows("chess_skill_rec")
  if row_count <= 0 then
    return
  end
  local index = 0
  local chess_npc_manager = nx_value("ChessNpcManager")
  for i = 0, row_count - 1 do
    local skill_id = client_machine_obj:QueryRecord("chess_skill_rec", i, 0)
    local photo = chess_npc_manager:GetChessSkillPhto(skill_id)
    local name = gui.TextManager:GetText(skill_id)
    grid:AddItem(nx_int(index), photo, name, nx_int(0), i)
    grid:SetCoolType(nx_int(index), nx_int(978881))
    if canuse == 0 then
      grid:ChangeItemImageToBW(nx_int(index), true)
    end
    index = index + 1
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_chessnpc")
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "npc") then
    return
  end
  if not nx_is_valid(form.npc) then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local gui = nx_value("gui")
  local client_ident = game_visual:QueryRoleClientIdent(form.npc)
  local client_machine_obj = game_client:GetSceneObj(nx_string(client_ident))
  local row_count = client_machine_obj:GetRecordRows("chess_skill_rec")
  if row_count < 4 then
    row_count = 4
  end
  form.imagegrid_1.ClomnNum = row_count
  form.Width = 342 + (row_count - 4) * 56
  form.lbl_2.Width = 290 + (row_count - 4) * 56
  form.imagegrid_1.Width = 237 + (row_count - 4) * 58
  form.imagegrid_1.ViewRect = "5,5," .. nx_string(240 + (row_count - 4) * 60) .. ",58"
  form.Left = gui.Width / 2 - form.Width / 2
  form.Top = shortcut_grid.groupbox_shortcut_1.AbsTop - form.Height + 86
end
function on_rightclick_grid(self, index)
  if not nx_find_custom(self, "client_machine_obj") then
    return
  end
  local client_machine_obj = self.client_machine_obj
  local row_count = client_machine_obj:GetRecordRows("chess_skill_rec")
  if row_count <= 0 then
    return
  end
  local chess_npc_manager = nx_value("ChessNpcManager")
  local skill_index = index
  local skill_id = client_machine_obj:QueryRecord("chess_skill_rec", index, 0)
  local skill_type = chess_npc_manager:GetChessSkillType(skill_id)
  local chess_npc_manager = nx_value("ChessNpcManager")
  if nx_is_valid(chess_npc_manager) and not (0 < nx_number(client_machine_obj:QueryProp("NeedCD"))) then
    chess_npc_manager:OnClientOperate(skill_type, skill_index)
  end
end
function on_mousein_grid(grid, index)
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local gui = nx_value("gui")
  local client_machine_obj = grid.client_machine_obj
  local row_count = client_machine_obj:GetRecordRows("chess_skill_rec")
  if row_count <= 0 then
    return
  end
  local skill_id = client_machine_obj:QueryRecord("chess_skill_rec", index, 0)
  local tip_text = gui.TextManager:GetText(nx_string("desc_") .. nx_string(skill_id))
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.ConfigID = skill_id
    item.ItemType = 1015
    local tips_manager = nx_value("tips_manager")
    if nx_is_valid(tips_manager) then
      tips_manager.InShortcut = true
    end
    nx_execute("tips_game", "show_goods_tip", item, x, y, 32, 32, grid.ParentForm)
  end
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
local WAIT_TIME = 30
function start_chinese_chess_game(server_time)
  local timer = nx_value("timer_game")
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  role.servertime = server_time
  role.curUpdateCount = 0
  timer:UnRegister(nx_current(), "on_update_start_time", role)
  timer:Register(1000, WAIT_TIME, nx_current(), "on_update_start_time", role, -1, -1)
end
function on_update_start_time(role)
  local gui = nx_value("gui")
  local start_x = gui.Width / 2
  local start_z = gui.Height / 2
  local overtime = WAIT_TIME - role.curUpdateCount
  local SpriteManager = nx_value("SpriteManager")
  SpriteManager:ShowBallFormScreenPos("timer", nx_string(overtime), start_x, start_z, "")
  role.curUpdateCount = role.curUpdateCount + 1
  if nx_int(role.curUpdateCount) == nx_int(WAIT_TIME) then
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "on_update_start_time", role)
    role.servertime = nil
    role.curUpdateCount = nil
  end
end
