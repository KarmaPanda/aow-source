require("util_gui")
require("util_functions")
require("custom_handler")
require("custom_sender")
local FORM_QX_NAME = "form_stage_main\\form_guild_war\\form_guild_war_escort"
local DOMAIN_INI_FILE = "share\\war\\GuildDomainExtraInfo.ini"
local LEVEL_INI_FILE = "share\\InterActive\\Arsonist\\newguildstrike.ini"
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.current_domain_id = -1
  form.first_domain_id = ""
  change_form_size(form)
  clear_ui_info(form)
  show_domain_info(form)
end
function change_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_refresh_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  clear_ui_info()
  custom_request_fire_newstrike_info()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_domain_info(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local domain_ini = nx_execute("util_functions", "get_ini", DOMAIN_INI_FILE)
  if not nx_is_valid(domain_ini) then
    return
  end
  local level_ini = nx_execute("util_functions", "get_ini", LEVEL_INI_FILE)
  if not nx_is_valid(level_ini) then
    return
  end
  local domain_count = domain_ini:GetSectionCount()
  form.first_domain_id = nx_string(domain_ini:GetSectionByIndex(0))
  form.groupscrollbox_domain:DeleteAll()
  local index = 0
  for i = 1, domain_count do
    local btn = gui:Create("Button")
    if not nx_is_valid(btn) then
      return
    end
    local domain_id = nx_string(domain_ini:GetSectionByIndex(i - 1))
    local domain_level = domain_ini:ReadInteger(i - 1, "DomainLevel", 1)
    btn.level = domain_level
    local max_count = level_ini:ReadInteger(domain_level, "MaxCount", 1)
    btn.max_count = max_count
    btn.domain_id = domain_id
    btn.Name = nx_string(domain_id)
    btn.captain = nx_widestr("")
    btn.pro_val = ""
    btn.strike_count = 0
    btn.player_count = ""
    btn.Text = util_text("ui_dipan_" .. nx_string(btn.domain_id))
    btn.NormalImage = "gui\\common\\button\\btn_normal1_out.png"
    btn.FocusImage = "gui\\common\\button\\btn_normal1_on.png"
    btn.PushImage = "gui\\common\\button\\btn_normal1_down.png"
    btn.DrawMode = "Expand"
    btn.ForeColor = "255,255,255,255"
    btn.Height = 30
    btn.Width = 85
    btn.Left = 17
    btn.Top = 40 * (i - 1)
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_select_click")
    form.groupscrollbox_domain:Add(btn)
  end
end
function on_btn_select_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  update_selected_domain_info(form, btn.domain_id)
  form.current_domain_id = btn.domain_id
end
function rec_fire_newstrike_info(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_QX_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  local size = table.getn(arg) - 1
  if size <= 0 or size % 4 ~= 0 then
    return
  end
  local player_count = nx_int(arg[1])
  form.lbl_playercount.Text = nx_widestr(nx_string(player_count) .. "/100")
  clear_ui_info(form)
  local rows = size / 4
  for i = 1, rows do
    local idx_base = 2 + (i - 1) * 4
    local btn = form.groupscrollbox_domain:Find(nx_string(arg[idx_base]))
    if nx_is_valid(btn) then
      btn.captain = arg[idx_base + 1]
      btn.pro_val = arg[idx_base + 2]
      btn.strike_count = arg[idx_base + 3]
    end
  end
  if form.current_domain_id ~= -1 then
    update_selected_domain_info(form, form.current_domain_id)
  else
    update_selected_domain_info(form, form.first_domain_id)
  end
end
function update_selected_domain_info(form, domain_id)
  if not nx_is_valid(form) then
    return
  end
  local btn = form.groupscrollbox_domain:Find(nx_string(domain_id))
  if not nx_is_valid(btn) then
    return
  end
  form.lbl_19.Text = nx_widestr(btn.captain)
  form.lbl_18.Text = nx_widestr(btn.pro_val)
  form.lbl_num.Text = nx_widestr(nx_string(btn.strike_count) .. "/" .. nx_string(btn.max_count))
  form.lbl_20.Text = nx_widestr(nx_string(btn.level))
  form.lbl_12.Text = util_text("ui_dipanweizhi_" .. nx_string(btn.domain_id))
end
function clear_ui_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_12.Text = nx_widestr("")
  form.lbl_19.Text = nx_widestr("")
  form.lbl_num.Text = nx_widestr("")
  form.lbl_18.Text = nx_widestr("")
  form.lbl_20.Text = nx_widestr("")
end
