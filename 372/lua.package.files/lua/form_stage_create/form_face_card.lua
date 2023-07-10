require("utils")
local push_down_image = "gui\\special\\tvt\\bg_kuang.png"
local normal_image = "gui\\common\\form_back\\bj_kuang.png"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  return 1
end
function main_form_open(self)
  return 1
end
function on_btn_del_click(btn)
  local gui = nx_value("gui")
  local res = show_confirm(nx_widestr(gui.TextManager:GetText("ui_face_del_confirm")))
  if "cancel" == res then
    return
  end
  local card = btn.Parent
  local form = card.Parent.Parent
  local full_name = form.path .. card.file_name
  os.remove(full_name)
  nx_execute("form_stage_create\\form_face_share", "update_cards_show", form)
end
function on_btn_select_click(btn)
  local card = btn.Parent
  local form = card.Parent.Parent
  if nx_is_valid(form:Find("ipt_filename")) then
    form.ipt_filename.Text = nx_widestr(card.show_name)
  end
  form.select_file = card.file_name
  local group_box = card.Parent
  local card_list = group_box:GetChildControlList()
  for i = 1, #card_list do
    if card_list[i].lbl_bg.BackImage == push_down_image then
      card_list[i].lbl_bg.BackImage = normal_image
    end
  end
  card.lbl_bg.BackImage = push_down_image
end
