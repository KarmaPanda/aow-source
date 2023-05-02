require("form_stage_main\\form_origin\\form_origin_define")
function main_form_init(form)
  form.Fixed = true
  form.Top = 0
  form.Left = 0
end
function on_main_form_open(form)
  form.Top = 0
  form.Left = 0
  form.rbtn_chengshi.link_groupbox = form.groupbox_chengshi
  form.rbtn_cunzheng.link_groupbox = form.groupbox_cunzheng
  form.rbtn_menpai.link_groupbox = form.groupbox_menpai
  form.rbtn_chengshi.line = 1
  form.rbtn_cunzheng.line = 2
  form.rbtn_menpai.line = 3
  form.rbtn_chengshi.Checked = true
  on_rbtn_changed(form.rbtn_chengshi)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local isGuildLeader = nx_int(player:QueryProp("IsGuildCaptain"))
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_click(btn)
  nx_execute(FORM_ORIGIN_LINE, "on_btn_click", btn)
end
function on_rbtn_changed(rbtn)
  local form = rbtn.ParentForm
  local originForm = nx_value(FORM_ORIGIN)
  if not nx_is_valid(form) or not nx_is_valid(originForm) then
    return
  end
  if rbtn.Checked == false then
    return
  end
  local i, j = string.find(rbtn.Name, "rbtn_")
  form.select_key_name = string.sub(rbtn.Name, j + 1)
  form.select_line = rbtn.line
  hide_all_grpbox_except(form, rbtn.link_groupbox)
  nx_execute(FORM_ORIGIN, "refresh_type_origin", originForm, originForm.main_type, originForm.sub_type)
  form.lbl_3.AbsLeft = rbtn.AbsLeft + 30
end
function on_select_line(line)
  local form = nx_value(FORM_ORIGIN_GUILD)
  if 1000 < line then
    line = line - 1000
  end
  local destBtn
  if line == form.rbtn_chengshi.line then
    destBtn = form.rbtn_chengshi
  elseif line == form.rbtn_cunzheng.line then
    destBtn = form.rbtn_cunzheng
  elseif line == form.rbtn_menpai.line then
    destBtn = form.rbtn_menpai
  end
  if nx_is_valid(destBtn) then
    destBtn.Checked = true
    on_rbtn_changed(destBtn)
  end
end
function hide_all_grpbox_except(form, grpbox)
  form.groupbox_chengshi.Visible = false
  form.groupbox_cunzheng.Visible = false
  form.groupbox_menpai.Visible = false
  grpbox.Visible = true
end
