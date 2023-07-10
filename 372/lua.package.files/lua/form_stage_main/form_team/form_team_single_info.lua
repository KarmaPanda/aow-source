require("util_functions")
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local DataList = util_split_wstring(nx_widestr(form.data_source), nx_widestr(","))
  if table.getn(DataList) == 4 then
    form.lbl_Name.Text = nx_widestr(DataList[1])
    form.lbl_Vol.BackImage = nx_string(DataList[2])
    form.lbl_Vcl.BackImage = nx_string(DataList[3])
    form.lbl_Zy.Text = nx_widestr(DataList[4])
  end
end
function on_main_form_close(form)
end
