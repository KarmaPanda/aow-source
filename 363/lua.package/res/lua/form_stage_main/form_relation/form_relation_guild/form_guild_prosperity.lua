require("custom_sender")
require("util_gui")
require("form_stage_main\\form_agree_war\\form_agree_war_main")
local FORM_NAME = "form_stage_main\\form_relation\\form_relation_guild\\form_guild_prosperity"
local CLIENT_CUSTOMMSG_GUILD = 1014
local SUB_CUSTOMMSG_REQUEST_PROSPERITY_INFO = 113
function open_form()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local form = util_auto_show_hide_form(nx_current())
  if nx_is_valid(form) and form.Visible then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_PROSPERITY_INFO))
  end
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
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
function on_recv_prosperity(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  if size < 7 then
    return
  end
  local guild_level = nx_int(arg[1])
  local evaluation = nx_int(arg[2])
  local base_max = nx_int(arg[3])
  local plus = nx_int(arg[4])
  local next_evaluation = nx_int(arg[5])
  local next_plus = nx_int(arg[6])
  local prosperity = nx_string(arg[7])
  form.lbl_evaluation.BackImage = "gui\\guild\\formback\\level_" .. nx_string(evaluation) .. ".png"
  form.lbl_total_max.Text = nx_widestr(base_max + plus)
  form.lbl_base_max.Text = nx_widestr(base_max)
  form.lbl_plus.Text = nx_widestr(plus)
  form.lbl_level.Text = nx_widestr(guild_level)
  form.lbl_evaluation_1.Text = nx_widestr(util_text("ui_prosperity_evaluation_" .. nx_string(evaluation)))
  form.lbl_next_evaluation.Text = nx_widestr(util_text("ui_prosperity_evaluation_" .. nx_string(next_evaluation)))
  form.lbl_next_plus.Text = nx_widestr(next_plus)
  local table_prosperity = util_split_string(prosperity, ",")
  local count = table.getn(table_prosperity)
  if count <= 0 or (count - 1) % 3 ~= 0 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupscrollbox_event.IsEditMode = true
  form.groupscrollbox_event:DeleteAll()
  local prosperity_event_count = 0
  for i = 1, count - 1, 3 do
    local event_id = table_prosperity[i]
    local count = table_prosperity[i + 1]
    local total_count = table_prosperity[i + 2]
    local groupbox_one = create_ctrl("GroupBox", "groupbox_event_" .. nx_string(event_id), form.groupbox_event, form.groupscrollbox_event)
    if nx_is_valid(groupbox_one) then
      local lbl_21 = create_ctrl("Label", "lbl_21_" .. nx_string(event_id), form.lbl_21, groupbox_one)
      if not nx_is_valid(lbl_21) then
        return
      end
      local lbl_event_name = create_ctrl("Label", "lbl_event_name_" .. nx_string(event_id), form.lbl_event_name, groupbox_one)
      if not nx_is_valid(lbl_event_name) then
        return
      end
      local lbl_event_count = create_ctrl("Label", "lbl_event_count_" .. nx_string(event_id), form.lbl_event_count, groupbox_one)
      if not nx_is_valid(lbl_event_count) then
        return
      end
      lbl_event_name.Text = gui.TextManager:GetFormatText("ui_prosperity_event_name_" .. nx_string(event_id), nx_int(total_count))
      lbl_event_count.Text = nx_widestr(nx_string(count) .. "/" .. nx_string(total_count))
      if nx_number(count) >= nx_number(total_count) then
        prosperity_event_count = prosperity_event_count + 1
      end
    end
  end
  form.groupscrollbox_event.IsEditMode = false
  form.groupscrollbox_event:ResetChildrenYPos()
  form.lbl_prosperity.Text = nx_widestr(nx_string(prosperity_event_count) .. "/" .. nx_string((count - 1) / 3))
end
