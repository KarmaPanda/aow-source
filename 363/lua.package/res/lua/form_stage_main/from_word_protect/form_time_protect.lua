require("utils")
require("util_gui")
require("util_functions")
require("game_object")
local FORM_PROTECT_TIME = "form_stage_main\\from_word_protect\\form_time_protect"
local DEF_NORMAL_PROTECT_TIME = 0
local DEF_CLASH_PROTECT_TIME = 30
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  change_form_size()
  init_form(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local enable = form.cbtn_openfunc.Checked and 1 or 0
  local text = nx_string(form.ipt_normaltime.Text)
  if text == "" then
    text = "0"
  end
  local normal_time = nx_int(text)
  local text = nx_string(form.ipt_dinghaotime.Text)
  if text == "" then
    text = "0"
  end
  local clash_time = nx_int(text)
  nx_execute("custom_sender", "custom_set_word_protect_time", enable, normal_time, clash_time)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_normaldec_click(btn)
  local form = btn.ParentForm
  local text = nx_string(form.ipt_normaltime.Text)
  if text == "" then
    text = "0"
  end
  local normal_time = nx_int(text)
  normal_time = normal_time - 1
  if normal_time < 0 then
    normal_time = 0
  end
  form.ipt_normaltime.Text = nx_widestr(normal_time)
end
function on_btn_normalinc_click(btn)
  local form = btn.ParentForm
  local text = nx_string(form.ipt_normaltime.Text)
  if text == "" then
    text = "0"
  end
  local normal_time = nx_int(text)
  normal_time = normal_time + 1
  if 60 < normal_time then
    normal_time = 60
  end
  form.ipt_normaltime.Text = nx_widestr(normal_time)
end
function on_btn_dinghaodec_click(btn)
  local form = btn.ParentForm
  local text = nx_string(form.ipt_dinghaotime.Text)
  if text == "" then
    text = "0"
  end
  local clash_time = nx_int(text)
  clash_time = clash_time - 1
  if clash_time < 0 then
    clash_time = 0
  end
  form.ipt_dinghaotime.Text = nx_widestr(clash_time)
end
function on_btn_dinghaoinc_click(btn)
  local form = btn.ParentForm
  local text = nx_string(form.ipt_dinghaotime.Text)
  if text == "" then
    text = "0"
  end
  local clash_time = nx_int(text)
  clash_time = clash_time + 1
  if 60 < clash_time then
    clash_time = 60
  end
  form.ipt_dinghaotime.Text = nx_widestr(clash_time)
end
function on_cbtn_openfunc_click(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.btn_normaldec.Enabled = true
    form.btn_normalinc.Enabled = true
    form.ipt_normaltime.Enabled = true
    form.btn_dinghaodec.Enabled = true
    form.btn_dinghaoinc.Enabled = true
    form.ipt_dinghaotime.Enabled = true
  else
    form.btn_normaldec.Enabled = false
    form.btn_normalinc.Enabled = false
    form.ipt_normaltime.Enabled = false
    form.btn_dinghaodec.Enabled = false
    form.btn_dinghaoinc.Enabled = false
    form.ipt_dinghaotime.Enabled = false
  end
end
function on_ipt_changed(ipt)
  local text = nx_widestr(ipt.Text)
  local filters = {"-", "."}
  for i = 1, table.getn(filters) do
    local mytable = util_split_wstring(text, filters[i])
    text = nx_widestr("")
    for j = 1, table.getn(mytable) do
      text = text .. nx_widestr(mytable[j])
    end
  end
  local value = nx_number(text)
  if value < 0 then
    text = nx_widestr("0")
  elseif 60 < value then
    local content = nx_string(text)
    text = nx_widestr(string.sub(content, 1, string.len(content) - 1))
  end
  ipt.Text = nx_widestr(text)
  ipt.InputPos = nx_ws_length(ipt.Text)
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local is_open_protect = client_player:QueryProp("IsOpenTimeProtect")
  form.cbtn_openfunc.Checked = nx_int(is_open_protect) == nx_int(1)
  local normal_protect_time = nx_int(client_player:QueryProp("NormalProtectTime")) - 1
  if nx_int(normal_protect_time) < nx_int(0) then
    normal_protect_time = DEF_NORMAL_PROTECT_TIME
  end
  form.ipt_normaltime.Text = nx_widestr(normal_protect_time)
  local clash_protect_time = nx_int(client_player:QueryProp("ClashProtectTime")) - 1
  if nx_int(clash_protect_time) < nx_int(0) then
    clash_protect_time = DEF_CLASH_PROTECT_TIME
  end
  form.ipt_dinghaotime.Text = nx_widestr(clash_protect_time)
  form.btn_normaldec.Enabled = form.cbtn_openfunc.Checked
  form.btn_normalinc.Enabled = form.cbtn_openfunc.Checked
  form.ipt_normaltime.Enabled = form.cbtn_openfunc.Checked
  form.btn_dinghaodec.Enabled = form.cbtn_openfunc.Checked
  form.btn_dinghaoinc.Enabled = form.cbtn_openfunc.Checked
  form.ipt_dinghaotime.Enabled = form.cbtn_openfunc.Checked
end
function change_form_size()
  local form = nx_value(FORM_PROTECT_TIME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function show_form()
  util_show_form(FORM_PROTECT_TIME, true)
end
