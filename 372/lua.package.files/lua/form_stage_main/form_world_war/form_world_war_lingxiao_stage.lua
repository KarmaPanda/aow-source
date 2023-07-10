require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
local FORM_NAME = "form_stage_main\\form_world_war\\form_world_war_lingxiao_stage"
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function update_general_info(...)
  local arg_count = table.getn(arg)
  if arg_count < 20 or math.mod(arg_count, 5) ~= 0 then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, math.floor(arg_count / 5) do
    local base_index = (i - 1) * 5
    local gb = form:Find("groupbox_" .. nx_string(i))
    if nx_is_valid(gb) then
      local lbl_num = gb:Find("lbl_num_" .. nx_string(i))
      if nx_is_valid(lbl_num) then
        lbl_num.Text = nx_widestr(arg[base_index + 1])
      end
      local lbl_trea = gb:Find("lbl_trea_" .. nx_string(i))
      if nx_is_valid(lbl_trea) then
        lbl_trea.Text = nx_widestr(arg[base_index + 2])
      end
      local lbl_host = gb:Find("lbl_host_" .. nx_string(i))
      if nx_is_valid(lbl_host) then
        lbl_host.Text = nx_widestr(arg[base_index + 3])
      end
      local lbl_master = gb:Find("lbl_master_" .. nx_string(i))
      if nx_is_valid(lbl_master) then
        lbl_master.Text = nx_widestr(arg[base_index + 4])
      end
      local lbl_score = gb:Find("lbl_score_" .. nx_string(i))
      if nx_is_valid(lbl_score) then
        lbl_score.Text = nx_widestr(arg[base_index + 5])
      end
    end
  end
end
