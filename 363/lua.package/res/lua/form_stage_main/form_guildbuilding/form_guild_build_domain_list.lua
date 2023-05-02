local CUSTOMMSG_OPER_GUILD_DOMAIN_BUY = 0
local CUSTOMMSG_OPER_GUILD_DOMAIN_INFO = 1
local CUSTOMMSG_GET_GUILD_DOMAIN_INFO = 2
local get_part_domain_info = 0
local get_all_domain_info = 1
function form_init(form)
end
function on_main_form_open(form)
  form.pic_1.flag = 0
  form.pic_2.flag = 0
  form.pic_3.flag = 0
  form.pic_4.flag = 0
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form.Visible = false
  end
end
function on_lbl_get_capture(self)
  self.ForeColor = "255,255,255,0"
  local index = nx_number(string.sub(self.Name, -1, -1))
  local pic_obj = self.Parent:Find("pic_" .. nx_string(index))
  if nx_is_valid(pic_obj) and pic_obj.flag ~= 1 then
    pic_obj.Image = "gui\\guild\\guildbuy\\sj_1.png"
  else
    pic_obj.Image = "gui\\special\\task\\icon-mengpai.png"
  end
end
function on_lbl_lost_capture(self)
  self.ForeColor = "255,255,255,255"
  local index = nx_number(string.sub(self.Name, -1, -1))
  local pic_obj = self.Parent:Find("pic_" .. nx_string(index))
  if nx_is_valid(pic_obj) and pic_obj.flag ~= 1 then
    pic_obj.Image = "gui\\guild\\guildbuy\\sj_2.png"
  else
    pic_obj.Image = "gui\\special\\task\\icon-mengpai.png"
  end
end
function on_pic_get_capture(self)
  if self.flag ~= 1 then
    self.Image = "gui\\guild\\guildbuy\\sj_1.png"
  else
    self.Image = "gui\\special\\task\\icon-mengpai.png"
  end
  local index = nx_number(string.sub(self.Name, -1, -1))
  local lbl_obj = self.Parent:Find("lbl_" .. nx_string(index))
  if nx_is_valid(lbl_obj) then
    lbl_obj.ForeColor = "255,255,255,0"
  end
end
function on_pic_lost_capture(self)
  if self.flag ~= 1 then
    self.Image = "gui\\guild\\guildbuy\\sj_2.png"
  else
    self.Image = "gui\\special\\task\\icon-mengpai.png"
  end
  local index = nx_number(string.sub(self.Name, -1, -1))
  local lbl_obj = self.Parent:Find("lbl_" .. nx_string(index))
  if nx_is_valid(lbl_obj) then
    lbl_obj.ForeColor = "255,255,255,255"
  end
end
function on_lbl_click(btn)
  nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_domain", "request_data", CUSTOMMSG_GET_GUILD_DOMAIN_INFO, btn.domainID, get_all_domain_info)
  nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_domain", "FindNodeByMark", btn.domainID, true)
  btn.ParentForm.Visible = false
end
