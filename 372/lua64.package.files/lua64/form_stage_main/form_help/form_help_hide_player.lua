require("util_gui")
local CLIENT_CUSTOMMSG_COMPLETE_FRESHMAN_HELP_STEP = 950
local FRESHMAN_TYPE_HIDE_PLAYER = 301
function open_form()
  util_auto_show_hide_form(nx_current())
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.no_tip = false
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  if form.no_tip then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_COMPLETE_FRESHMAN_HELP_STEP), nx_int(1), nx_int(FRESHMAN_TYPE_HIDE_PLAYER))
    end
  end
  form.Visible = false
  form:Close()
end
function on_btn_no_tip_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.no_tip = not form.no_tip
  if form.no_tip then
    btn.NormalImage = "gui\\common\\checkbutton\\cbtn_5_down.png"
    btn.FocusImage = "gui\\common\\checkbutton\\cbtn_5_down.png"
    btn.PushImage = "gui\\common\\checkbutton\\cbtn_5_down.png"
  else
    btn.NormalImage = "gui\\common\\checkbutton\\cbtn_5_out.png"
    btn.FocusImage = "gui\\common\\checkbutton\\cbtn_5_on.png"
    btn.PushImage = "gui\\common\\checkbutton\\cbtn_5_down.png"
  end
end
