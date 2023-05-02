require("util_functions")
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local DataList = util_split_wstring(nx_widestr(form.data_source), nx_widestr(","))
  form.lbl_2.Text = nx_widestr("@ui_zudui003") .. nx_widestr(form.eid)
  if table.getn(DataList) == 24 then
    form.lbl_Name11.Text = nx_widestr(DataList[1])
    form.lbl_Vo11.BackImage = nx_string(DataList[2])
    form.lbl_Zy11.Text = nx_widestr(DataList[4])
    form.lbl_Name12.Text = nx_widestr(DataList[5])
    form.lbl_Vo12.BackImage = nx_string(DataList[6])
    form.lbl_Zy12.Text = nx_widestr(DataList[8])
    form.lbl_Name13.Text = nx_widestr(DataList[9])
    form.lbl_Vo13.BackImage = nx_string(DataList[10])
    form.lbl_Zy13.Text = nx_widestr(DataList[12])
    form.lbl_Name14.Text = nx_widestr(DataList[13])
    form.lbl_Vo14.BackImage = nx_string(DataList[14])
    form.lbl_Zy14.Text = nx_widestr(DataList[16])
    form.lbl_Name15.Text = nx_widestr(DataList[17])
    form.lbl_Vo15.BackImage = nx_string(DataList[18])
    form.lbl_Zy15.Text = nx_widestr(DataList[20])
    form.lbl_Name16.Text = nx_widestr(DataList[21])
    form.lbl_Vo16.BackImage = nx_string(DataList[22])
    form.lbl_Zy16.Text = nx_widestr(DataList[24])
  end
end
function on_main_form_close(form)
end
