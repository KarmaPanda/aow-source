require("util_functions")
require("util_gui")
local FORM_PATH = "form_stage_main\\form_world_auction\\form_boss_auction_drop"
function open_form(...)
  local form = util_show_form(FORM_PATH, true)
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 3 then
    return
  end
  form.npc_id = arg[1]
  form.captain_name = arg[2]
  form.item_info = arg[3]
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  change_form_size(true)
  self.lbl_light.Visible = true
  self.groupbox_comment.Visible = false
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:AddExecute("HighLight", self, nx_float(0.01), self.lbl_light, self.groupbox_comment, nx_float(0.5), nx_float(1.5), nx_current(), nx_string("execute_end"))
  end
end
function on_main_form_close(self)
  nx_destroy(self)
  nx_execute("form_stage_main\\form_main\\form_main", "hide_boss_drop_info")
end
function execute_end()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "item_info") then
    return
  end
  nx_execute("form_stage_main\\form_main\\form_main", "show_boss_drop_info", form.item_info, form.lbl_1.AbsTop + form.lbl_1.Height + 10, form.lbl_1.AbsLeft)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function change_form_size(isfrist)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local self = nx_value(nx_current())
  if not nx_is_valid(self) then
    return
  end
  self.Left = 0
  self.Top = 0
  self.Width = gui.Width
  self.Height = gui.Height
  self.groupbox_back.Left = 0
  self.groupbox_back.Top = 0
  self.groupbox_back.Width = gui.Width
  self.groupbox_back.Height = gui.Height
  self.groupbox_comment.Left = (self.Width - self.groupbox_comment.Width) / 2
  self.groupbox_comment.Top = (self.Height - self.groupbox_comment.Height) / 2
  self.lbl_light.Left = (self.Width - self.lbl_light.Width) / 2
  self.lbl_light.Top = (self.Height - self.lbl_light.Height) / 2
  self.btn_close.Top = self.groupbox_comment.Top
  self.btn_close.Left = self.groupbox_comment.Left + self.groupbox_comment.Width - 20
  if isfrist ~= true then
    nx_execute("form_stage_main\\form_main\\form_main", "move_boss_drop_grid", self.lbl_1.AbsTop + self.lbl_1.Height + 10, self.lbl_1.AbsLeft)
  end
end
