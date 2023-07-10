DMC_SUBMSG_FIRSTPAY_DATAINFO = 0
DMC_SUBMSG_FIRSTPAY_REWARD = 1
DMC_SUBMSG_FAVOUR_DATAINFO = 2
DMC_SUBMSG_FAVOUR_BUYITEM = 3
DMC_SUBMSG_TOTAL_DATAINFO = 4
DMC_SUBMSG_TOTAL_GAINITEM = 5
DMC_SUBMSG_GUILD_AUTH_SEE = 11
DMC_SUBMSG_GUILD_AUTH_SEE_MEMBER = 12
DMC_SUBMSG_GUILD_AUTH = 13
DMC_SUBMSG_GUILD_AUTH_L = 14
DMS_SUBMSG_FIRSTPAY_DATAINFO = 0
DMS_SUBMSG_FAVOUR_DATAINFO = 1
DMS_SUBMSG_TOTAL_DATAINFO = 2
DMS_SUBMSG_GUILD_AUTH_SEE = 11
DMS_SUBMSG_GUILD_AUTH_SEE_MEMBER = 12
DMI_SUBMSG_FIRSTPAY_SENDREWARD = 0
REBATE_IMAGE = {
  [5] = "gui\\language\\ChineseS\\dbomall\\label_5.png",
  [6] = "gui\\language\\ChineseS\\dbomall\\label_6.png",
  [7] = "gui\\language\\ChineseS\\dbomall\\label_7.png",
  [8] = "gui\\language\\ChineseS\\dbomall\\label_8.png",
  [9] = "gui\\language\\ChineseS\\dbomall\\label_9.png",
  [10] = "gui\\language\\ChineseS\\dbomall\\label_10.png",
  [11] = "gui\\language\\ChineseS\\dbomall\\label_11.png",
  [12] = "gui\\language\\ChineseS\\dbomall\\label_12.png",
  [13] = "gui\\language\\ChineseS\\dbomall\\label_13.png",
  [14] = "gui\\language\\ChineseS\\dbomall\\label_14.png",
  [15] = "gui\\language\\ChineseS\\dbomall\\label_15.png",
  [16] = "gui\\language\\ChineseS\\dbomall\\label_16.png",
  [17] = "gui\\language\\ChineseS\\dbomall\\label_17.png",
  [18] = "gui\\language\\ChineseS\\dbomall\\label_18.png"
}
function get_photo(config_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  local photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo"))
  local sex = client_player:QueryProp("Sex")
  if 0 ~= sex then
    local tmp_photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "FemalePhoto"))
    if nil ~= tmp_photo and "" ~= tmp_photo then
      photo = tmp_photo
    end
  end
  return photo
end
