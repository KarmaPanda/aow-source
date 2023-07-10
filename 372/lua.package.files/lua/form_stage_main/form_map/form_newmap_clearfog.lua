require("share\\client_custom_define")
require("util_functions")
function main_form_init(form)
end
function on_main_form_open(form)
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return false
  end
  local scene_name = client_scene:QueryProp("Resource")
  form.Fixed = false
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "share\\Rule\\map_mask.ini"
  ini:LoadFromFile()
  local arg1 = ini:ReadInteger(scene_name, "cost", 0)
  arg1 = nx_int(arg1) / nx_int(1000)
  local arg2_str = ini:ReadString(scene_name, "item", "")
  local list = util_split_string(arg2_str, ",")
  local num = table.getn(list)
  local arg2 = ""
  local arg3 = ""
  if num == 2 then
    arg2 = list[1]
    arg3 = list[2]
  end
  nx_destroy(ini)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) * 2 / 6
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("ui_newworld_clearfog", arg1, arg2, nx_int(arg3))
  form.mltbox_1:Clear()
  form.mltbox_1:AddHtmlText(text, -1)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_moidfy_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MAP_MASK), nx_int(1))
end
function on_btn_start_stop_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MAP_MASK), nx_int(2))
end
