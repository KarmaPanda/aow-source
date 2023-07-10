require("util_gui")
require("util_functions")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local FORM_WULIN_DAMIN = "form_stage_main\\form_battlefield_wulin\\form_wulin_team_damin"
local wudao_war_file = "share\\War\\WuDaoWar\\wudao_war.ini"
local wudao_tip_right_photo = "wudao_systeminfo_10105"
local wudao_tip_limite_not_right = "wudao_systeminfo_10106"
function open_wudao_team_damin_create_form(photo)
  if not is_in_wudao_prepare_scene() then
    return
  end
  local form_damin = nx_value(FORM_WULIN_DAMIN)
  if nx_is_valid(form_damin) and not form_damin.Visible then
    form_damin.Visible = true
  else
    util_show_form(FORM_WULIN_DAMIN, true)
  end
  local form = nx_value(FORM_WULIN_DAMIN)
  if nx_is_valid(form) then
    local grid = form.imagegrid_photo
    if nx_is_valid(grid) then
      local index = nx_int(photo) - 1
      on_imagegrid_photo_select_changed(grid, nx_int(index))
    end
  end
end
function main_form_init(self)
  self.Fixed = false
  self.team_photo = 0
  self.max_team_photo = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  init_team_photo_grid(self)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_imagegrid_photo_select_changed(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(index) < nx_int(0) or nx_int(index) > nx_int(form.max_team_photo - 1) then
    return
  end
  form.team_photo = index + 1
  local photo = self:GetItemImage(index)
  if nx_string(photo) == nx_string("") or photo == nil then
    return
  end
  form.imagegrid_1:AddItem(0, nx_string(photo), "", 1, -1)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.team_photo) <= nx_int(0) or nx_int(form.team_photo) > nx_int(form.max_team_photo) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_right_photo)
    return
  end
  local limite = nx_int(form.ipt_1.Text)
  if nx_int(limite) < nx_int(0) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_limite_not_right)
    return
  end
  custom_modify_team_info(nx_int(form.team_photo), limite)
  form:Close()
end
function custom_modify_team_info(image, limite)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_MODIFY_TEAM_INFO), nx_int(image), nx_int(limite))
end
function init_team_photo_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_photo
  if not nx_is_valid(grid) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", wudao_war_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("team_photo")
  if sec_count < 0 then
    return
  end
  local total_count = ini:GetSectionItemCount(sec_count)
  form.max_team_photo = total_count
  local remainder = math.fmod(total_count, 5)
  local row = 0
  if nx_int(remainder) == nx_int(0) then
    row = math.floor(total_count / 5)
  else
    row = math.floor(total_count / 5) + 1
  end
  grid:Clear()
  grid.RowNum = row
  grid.Height = grid.GridHeight * row + 10
  local visible_eara = nx_string(0) .. nx_string(",") .. nx_string(0) .. nx_string(",") .. nx_string(grid.Width) .. nx_string(",") .. nx_string(grid.Height)
  grid.ViewRect = visible_eara
  for i = 1, total_count do
    local photo = ini:ReadString(sec_count, nx_string(i), "")
    grid:AddItem(nx_int(i - 1), nx_string(photo), "", 1, -1)
  end
  form.groupscrollbox_1.IsEditMode = false
  form.groupscrollbox_1:ResetChildrenYPos()
end
function close_form()
  local form = nx_value(FORM_WULIN_DAMIN)
  if nx_is_valid(form) then
    form:Close()
  end
end
