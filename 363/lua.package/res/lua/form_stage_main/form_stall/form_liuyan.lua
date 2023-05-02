require("share\\view_define")
require("util_gui")
require("util_functions")
require("define\\object_type_define")
require("game_object")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  gui.Focused = self.ipt_liuyan
  self.ipt_liuyan.ReturnFontFormat = false
  move_position(self)
  return 1
end
function on_main_form_close(self)
  self.Visible = false
  nx_destroy(self)
  return 1
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form.Visible = false
  nx_destroy(form)
  return 1
end
function form_error(form, text)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
  local info = gui.TextManager:GetFormatText(text)
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog.Left = form.Left + (form.Width - dialog.Width) / 2
  dialog.Top = form.Top + (form.Height - dialog.Height) / 2
  dialog:ShowModal()
  nx_wait_event(100000000, dialog, "error_return")
end
function on_confirm_btn_click(self)
  local form = self.Parent
  local liuyan = form.ipt_liuyan.Text
  if liuyan == "" then
    form_error(form, "")
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local CheckWords = nx_value("CheckWords")
  local filter_liuyan = CheckWords:CleanWords(nx_widestr(liuyan))
  game_visual:CustomSend(nx_int(671), filter_liuyan)
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function on_liuyan_ok()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_liuyan", false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function move_position(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_ipt_liuyan_changed(ipt_liuyan)
end
function IsPlayerObj(obj)
  if not nx_is_valid(obj) then
    return false
  end
  local type = obj:QueryProp("Type")
  if TYPE_PLAYER == tonumber(type) then
    return true
  end
  return false
end
function GetPlayerByStallNpc(stallNpc)
  if not nx_is_valid(stallNpc) then
    return nil
  end
  local game_client = nx_value("game_client")
  local player = stallNpc:QueryProp("Player")
  local playerObj = game_client:GetSceneObj(nx_string(player))
  if IsPlayerObj(playerObj) then
    return playerObj
  end
  return nil
end
function GetPlayer()
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return nil
  end
  local playerObj
  if IsPlayerObj(target) then
    playerObj = target
  else
    local obj = GetPlayerByStallNpc(target)
    if obj == nil then
      return nil
    end
    playerObj = obj
  end
  return playerObj
end
