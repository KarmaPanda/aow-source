require("form_stage_main\\form_map\\map_logic")
require("util_functions")
function main_form_init(form)
  return 1
end
function on_main_form_open(form)
  form.map_query = nx_value("MapQuery")
  local groupbbox = form.groupbox_1
  local btns = groupbbox:GetChildControlList()
  for _, btn in ipairs(btns) do
    if nx_is_valid(btn) then
      local scene_name = btn.DataSource
      if nil ~= scene_name and "" ~= scene_name then
        scene_name = nx_string(scene_name)
        if form.map_query:IsSceneVisited(scene_name) then
          btn.NormalImage = form.map_query:GetCityImage(scene_name, "YesNormalImage")
          btn.FocusImage = form.map_query:GetCityImage(scene_name, "YesFocusImage")
          btn.PushImage = form.map_query:GetCityImage(scene_name, "YesPushImage")
        else
          btn.NormalImage = form.map_query:GetCityImage(scene_name, "NoNormalImage")
          btn.FocusImage = form.map_query:GetCityImage(scene_name, "NoFocusImage")
          btn.PushImage = form.map_query:GetCityImage(scene_name, "NoPushImage")
        end
      end
    end
  end
  local groupbox_4 = nx_custom(form, "groupbox_4")
  if nx_is_valid(groupbox_4) then
    local lbls = groupbox_4:GetChildControlList()
    for _, lbl in ipairs(lbls) do
      if nx_is_valid(lbl) then
        local scene_pair = lbl.DataSource
        if nil ~= scene_pair and "" ~= scene_pair then
          scene_pair = util_split_string(nx_string(scene_pair), ",")
          local scene1 = scene_pair[1]
          local scene2 = scene_pair[2]
          local flag = form.map_query:IsSceneVisited(scene1) and form.map_query:IsSceneVisited(scene2)
          lbl.BackImage = form.map_query:GetPathImage(scene1, scene2, flag)
        end
      end
    end
  end
end
function on_lbl_copy_get_capture(self)
  local ini = nx_execute("util_functions", "get_ini", "gui\\map\\scene_clones.ini")
  if not nx_is_valid(ini) then
    return
  end
  local scene = self.DataSource
  local sect = ini:FindSectionIndex(scene)
  if sect < 0 then
    return
  end
  local data = ini:ReadString(sect, "copy", "")
  if data == "" then
    return
  end
  local gui = nx_value("gui")
  local text = nx_widestr("")
  local tuple = util_split_string(data, ",")
  for _, val in ipairs(tuple) do
    text = text .. gui.TextManager:GetText("scene_" .. val) .. nx_widestr("<br>")
  end
  if text == nx_widestr("") then
    text = gui.TextManager:GetText(data)
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft + self.Width / 2, self.AbsTop - 30, self.ParentForm)
end
function on_lbl_copy_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function fix_area_form(form_scene, form_area)
  local abs_left = form_scene.lbl_back.AbsLeft + 0
  local abs_top = form_scene.lbl_back.AbsTop + 1
  local abs_width = form_scene.lbl_back.Width - 4
  local abs_height = form_scene.lbl_back.Height - 3
  form_area.AbsLeft = abs_left
  form_area.AbsTop = abs_top
  form_area.DrawMode = "FitWindow"
  form_area.ani_1.Visible = false
  form_area.ani_1:Stop()
  local rateX = nx_float(abs_width / form_area.Width)
  local rateY = nx_float(abs_height / form_area.Height)
  form_area.Width = abs_width
  form_area.Height = abs_height
  local itemtable = form_area.groupbox_1:GetChildControlList()
  local labletalbe = form_area.groupbox_2:GetChildControlList()
  local animationtable = form_area.groupbox_3:GetChildControlList()
  local teamtable = {}
  if nx_find_custom(form_area, "groupbox_5") then
    teamtable = form_area.groupbox_5:GetChildControlList()
  end
  form_area.ani_1:Stop()
  form_area.ani_1:Play()
  form_area:ToFront(form_area.groupbox_1)
  form_area.groupbox_1.Transparent = true
  if nx_find_custom(form_area, "groupbox_5") then
    form_area:ToFront(form_area.groupbox_5)
    form_area.groupbox_5.Transparent = true
  end
  if nx_find_custom(form_area, "groupbox_6") then
    form_area:ToFront(form_area.groupbox_6)
    form_area.groupbox_6.Transparent = true
  end
  for i = 1, table.getn(itemtable) do
    local newleft = itemtable[i].Left * rateX
    local newtop = itemtable[i].Top * rateY
    local newwidth = itemtable[i].Width * rateX
    local newheight = itemtable[i].Height * rateY
    itemtable[i].Left = newleft
    itemtable[i].Top = newtop
    itemtable[i].Width = newwidth
    itemtable[i].Height = newheight
    itemtable[i].Visible = true
    itemtable[i].form = form_scene
    nx_bind_script(itemtable[i], "form_stage_main\\form_map\\form_map_scene")
    nx_callback(itemtable[i], "on_click", "on_click_btn")
  end
  for i = 1, table.getn(labletalbe) do
    local labelnewleft = labletalbe[i].Left * rateX
    local labelnewtop = labletalbe[i].Top * rateY
    local labelnewwidth = labletalbe[i].Width * rateX
    local labelnewheight = labletalbe[i].Height * rateY
    labletalbe[i].Left = labelnewleft
    labletalbe[i].Top = labelnewtop
    labletalbe[i].Width = labelnewwidth
    labletalbe[i].Height = labelnewheight
    labletalbe[i].Visible = true
  end
  for i = 1, table.getn(animationtable) do
    local animationnewleft = animationtable[i].Left * rateX
    local animationnewtop = animationtable[i].Top * rateY
    local animationnewwidth = animationtable[i].Width * rateX
    local animationnewheight = animationtable[i].Height * rateY
    animationtable[i].Left = animationnewleft
    animationtable[i].Top = animationnewtop
    animationtable[i].Visible = true
  end
  for i = 1, table.getn(teamtable) do
    local newleft = teamtable[i].Left * rateX
    local newtop = teamtable[i].Top * rateY
    local newwidth = teamtable[i].Width * rateX
    local newheight = teamtable[i].Height * rateY
    teamtable[i].Left = newleft
    teamtable[i].Top = newtop
    teamtable[i].Width = newwidth
    teamtable[i].Height = newheight
    teamtable[i].Visible = true
    teamtable[i].ClickEvent = true
    teamtable[i].Transparent = false
    teamtable[i].form = form_scene
    nx_bind_script(teamtable[i], "form_stage_main\\form_map\\form_map_scene")
    nx_callback(teamtable[i], "on_get_capture", "on_lbl_team_get_capture")
    nx_callback(teamtable[i], "on_lost_capture", "on_lbl_team_lost_capture")
  end
  if nx_find_custom(form_area, "groupbox_7") then
    local copytable = form_area.groupbox_7:GetChildControlList()
    for i = 1, table.getn(copytable) do
      local newleft = copytable[i].Left * rateX
      local newtop = copytable[i].Top * rateY
      local newwidth = copytable[i].Width * rateX
      local newheight = copytable[i].Height * rateY
      copytable[i].Left = newleft
      copytable[i].Top = newtop
      copytable[i].Width = newwidth
      copytable[i].Height = newheight
      copytable[i].Visible = true
      copytable[i].ClickEvent = true
      copytable[i].Transparent = false
      copytable[i].form = form_scene
      nx_bind_script(copytable[i], nx_current())
      nx_callback(copytable[i], "on_get_capture", "on_lbl_copy_get_capture")
      nx_callback(copytable[i], "on_lost_capture", "on_lbl_copy_lost_capture")
    end
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("OpenMapRec") then
    return
  end
  local max_rows = client_player:GetRecordRows("OpenMapRec")
  for i = 1, max_rows do
    local maplist = client_player:QueryRecord("OpenMapRec", i - 1, 0)
    local numlist = nx_function("ext_int_to_byte", maplist)
    local current_area = form_scene.current_map
    local count = table.getn(numlist)
    for j = 1, count do
      if numlist[j] == 1 then
        local cityname = form_area.map_query:GetSceneName((i - 1) * 32 + j)
        local area_name = form_area.map_query:GetAreaOfScene(cityname)
        if area_name == current_area then
          local cityindex = form_area.map_query:GetSceneIndexInArea(cityname)
          if nx_is_valid(itemtable[cityindex]) then
            itemtable[cityindex].Visible = true
          end
          if nx_is_valid(labletalbe[cityindex]) then
            labletalbe[cityindex].Visible = true
          end
          if nx_is_valid(animationtable[cityindex]) then
            animationtable[cityindex].Visible = true
            animationtable[cityindex]:Stop()
            animationtable[cityindex]:Play()
          end
        end
      end
    end
  end
end
