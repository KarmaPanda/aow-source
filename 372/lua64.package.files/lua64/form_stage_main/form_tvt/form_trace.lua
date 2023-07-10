require("util_gui")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
local g_form_name = "form_stage_main\\form_tvt\\form_trace"
local g_max_arrows = 15
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  local group = form.groupbox_arrow
  form.center_x = nx_float(group.Width / 2)
  form.center_y = nx_float(group.Height / 2)
  form.radius = nx_float(group.Width / 2) - 20
  form.arrow_width = nx_float(18)
  form.arrow_height = nx_float(19)
  local gui = nx_value("gui")
  local items = form.groupbox_arrow:GetChildControlList()
  for i, item in pairs(items) do
    item.Visible = false
  end
  local count = g_max_arrows - table.getn(items)
  if 0 < count then
    for i = 1, count do
      local lbl = gui:Create("Label")
      if nx_is_valid(lbl) then
        lbl.Width = form.arrow_width
        lbl.Height = form.arrow_height
        lbl.Rotate = true
        lbl.ClickEvent = true
        lbl.Transparent = false
        lbl.Visible = false
        nx_bind_script(lbl, nx_current())
        nx_callback(lbl, "on_get_capture", "on_show_npc_tips")
        nx_callback(lbl, "on_lost_capture", "on_hide_npc_tips")
        form.groupbox_arrow:Add(lbl)
        form.groupbox_arrow:ToFront(lbl)
      end
    end
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function on_show_npc_tips(lbl)
  local form = lbl.ParentForm
  local x, z = lbl.target_x, lbl.target_z
  local str = util_format_string("{@0:npc}({@1:x},{@2:z})", lbl.target_npc, x, z)
  nx_execute("tips_game", "show_text_tip", str, lbl.AbsLeft, lbl.AbsTop, 0, form)
end
function on_hide_npc_tips(lbl)
  nx_execute("tips_game", "hide_tip")
end
