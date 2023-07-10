require("form_stage_main\\form_marry\\form_marry_util")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  form.grid_flow:SetColAlign(0, "center")
  set_form_pos(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_colse_click(self)
  local form = self.ParentForm
  form:Close()
end
function show_data(rite)
  local form = util_get_form(FORM_MARRY_DETAILS, true)
  if not nx_is_valid(form) then
    return 0
  end
  local marry_rite_ini = nx_execute("util_functions", "get_ini", INI_FILE_MARRY_RITE)
  if not nx_is_valid(marry_rite_ini) then
    return 0
  end
  local index = marry_rite_ini:FindSectionIndex(nx_string(rite))
  if 0 > nx_number(index) then
    return 0
  end
  local fuli_desc = marry_rite_ini:ReadString(index, "RiteFuliDesc", "")
  local flow_name = marry_rite_ini:ReadString(index, "RiteFlowNamePrefix", "")
  local flow = marry_rite_ini:ReadString(index, "RiteFlow", "")
  form.grid_flow:ClearRow()
  local flow_tab = util_split_string(nx_string(flow), ",")
  for i = 1, table.getn(flow_tab) do
    if nx_number(flow_tab[i]) == 1 then
      local row = form.grid_flow:InsertRow(-1)
      form.grid_flow:SetGridText(row, 0, util_text(flow_name .. nx_string(i)))
    end
  end
  form.mltbox_info.HtmlText = util_text(fuli_desc)
  util_show_form(FORM_MARRY_DETAILS, true)
end
