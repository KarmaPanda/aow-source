require("util_functions")
yy_pic = {
  school_shaolin_img = "d.g.yy.com/role_info/7/img/shaolin.png",
  school_wudang_img = "d.g.yy.com/role_info/7/img/wudang.png",
  school_emei_img = "d.g.yy.com/role_info/7/img/emei.png",
  school_junzitang_img = "d.g.yy.com/role_info/7/img/junzitang.png",
  school_jinyiwei_img = "d.g.yy.com/role_info/7/img/jinyiwei.png",
  school_jilegu_img = "d.g.yy.com/role_info/7/img/jilegu.png",
  school_gaibang_img = "d.g.yy.com/role_info/7/img/gaibang.png",
  school_tangmen_img = "d.g.yy.com/role_info/7/img/tangmen.png",
  force_yihua_img = "d.g.yy.com/role_info/7/img/yihuagong.png",
  force_taohua_img = "d.g.yy.com/role_info/7/img/taohuadao.png",
  force_xujia_img = "d.g.yy.com/role_info/7/img/xujiazhuang.png",
  force_wanshou_img = "d.g.yy.com/role_info/7/img/wanshoushanzhuang.png",
  force_jinzhen_img = "d.g.yy.com/role_info/7/img/jinzhenshenjia.png",
  force_wugen_img = "d.g.yy.com/role_info/7/img/wugen.png",
  ui_task_school_null_img = "d.g.yy.com/role_info/7/img/wumenpai.png",
  school_shaolin_ico = "d.g.yy.com/role_info/7/icon/shaolin.png",
  school_wudang_ico = "d.g.yy.com/role_info/7/icon/wudang.png",
  school_emei_ico = "d.g.yy.com/role_info/7/icon/emei.png",
  school_junzitang_ico = "d.g.yy.com/role_info/7/icon/junzitang.png",
  school_jinyiwei_ico = "d.g.yy.com/role_info/7/icon/jinyiwei.png",
  school_jilegu_ico = "d.g.yy.com/role_info/7/icon/jilegu.png",
  school_gaibang_ico = "d.g.yy.com/role_info/7/icon/gaibang.png",
  school_tangmen_ico = "d.g.yy.com/role_info/7/icon/tangmen.png",
  force_yihua_ico = "d.g.yy.com/role_info/7/icon/yihuagong.png",
  force_taohua_ico = "d.g.yy.com/role_info/7/icon/taohuadao.png",
  force_xujia_ico = "d.g.yy.com/role_info/7/icon/xujiazhuang.png",
  force_wanshou_ico = "d.g.yy.com/role_info/7/icon/wanshoushanzhuang.png",
  force_jinzhen_ico = "d.g.yy.com/role_info/7/icon/jinzhenshenjia.png",
  force_wugen_ico = "d.g.yy.com/role_info/7/icon/wugen.png",
  ui_task_school_null_ico = "d.g.yy.com/role_info/7/icon/wumenpai.png"
}
function on_main_form_init(form)
  form.Fixed = false
  form.last_time = 0
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  local im_id = form.ipt_im.Text
  local code_id = form.ipt_code.Text
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  if nx_string(im_id) == "" then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("91127"), 2)
    return
  end
  if nx_string(code_id) == "" then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("91128"), 2)
    return
  end
  local cur_time = nx_function("ext_get_tickcount")
  if cur_time - form.last_time < 30000 then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("91131"), 2)
    return
  end
  form.last_time = cur_time
  if game_config.bind_yy_num > 10 then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("91132"), 2)
    return
  end
  send_to_yy(im_id, code_id)
  game_config.bind_yy_num = game_config.bind_yy_num + 1
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function send_to_yy(im_id, code_id)
  local gui = nx_value("gui")
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local name = client_player:QueryProp("Name")
  local school = ""
  if client_player:FindProp("School") then
    school = client_player:QueryProp("School")
  end
  if school == "" and client_player:FindProp("Force") then
    school = client_player:QueryProp("Force")
  end
  local school_name = gui.TextManager:GetText(school)
  if school == "" then
    school = "ui_task_school_null"
    school_name = gui.TextManager:GetText("91129")
  end
  local power_level = client_player:QueryProp("LevelTitle")
  gui.TextManager:Format_SetIDName("91130")
  gui.TextManager:Format_AddParam(gui.TextManager:GetText("desc_" .. power_level))
  local level_name = gui.TextManager:Format_GetText()
  local guild_name = ""
  if client_player:FindProp("GuildName") then
    guild_name = client_player:QueryProp("GuildName")
  end
  if guild_name == "" then
    guild_name = gui.TextManager:GetText("91129")
  end
  local famous = client_player:QueryProp("FamousNeiGongName")
  local famous_ng_name = nx_widestr("")
  if famous == nil or famous == 0 or nx_widestr(famous) == nx_widestr("") then
    famous_ng_name = gui.TextManager:GetText("91129")
  else
    local tbl_famous = util_split_wstring(famous, ",")
    local famous_ng_id = nx_string(tbl_famous[1])
    famous_ng_name = gui.TextManager:GetText(famous_ng_id)
  end
  local param_table = nx_function("ext_split_wstring", game_config.server_name, nx_widestr("-"))
  local server_name = nx_widestr("")
  if table.getn(param_table) == 2 then
    server_name = param_table[2]
  end
  if yy_pic[school .. "_ico"] == nil or yy_pic[school .. "_ico"] == "" or yy_pic[school .. "_img"] == nil or yy_pic[school .. "_img"] == "" then
    return
  end
  nx_function("ext_yy_http_post", "http://101.226.185.144/card_binder.php", game_config.login_account_id, name, level_name, server_name, school_name, famous_ng_name, guild_name, im_id, code_id, yy_pic[school .. "_ico"], yy_pic[school .. "_img"])
end
function open_form()
  local form = nx_execute("util_gui", "util_get_form", "form_common\\form_bind_yy", true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
  form:Show()
end
