local normal_image = "gui\\special\\keyboard\\btn_s_out.png"
local focus_image = "gui\\special\\keyboard\\btn_s_on.png"
local push_image = "gui\\special\\keyboard\\btn_s_down.png"
local all_key = {
  [1] = {
    name = "`",
    caps = "~",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [2] = {
    name = "1",
    caps = "!",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [3] = {
    name = "2",
    caps = "@",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [4] = {
    name = "3",
    caps = "#",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [5] = {
    name = "4",
    caps = "$",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [6] = {
    name = "5",
    caps = "%",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [7] = {
    name = "6",
    caps = "^",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [8] = {
    name = "7",
    caps = "&",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [9] = {
    name = "8",
    caps = "*",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [10] = {
    name = "9",
    caps = "(",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [11] = {
    name = "0",
    caps = ")",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [12] = {
    name = "-",
    caps = "_",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [13] = {
    name = "=",
    caps = "+",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [14] = {
    name = "[",
    caps = "{",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [15] = {
    name = "]",
    caps = "}",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [16] = {
    name = ";",
    caps = ":",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [17] = {
    name = ",",
    caps = "<",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [18] = {
    name = ".",
    caps = ">",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [19] = {
    name = "/",
    caps = "?",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [20] = {
    name = "a",
    caps = "A",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [21] = {
    name = "b",
    caps = "B",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [22] = {
    name = "c",
    caps = "C",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [23] = {
    name = "d",
    caps = "D",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [24] = {
    name = "e",
    caps = "E",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [25] = {
    name = "f",
    caps = "F",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [26] = {
    name = "g",
    caps = "G",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [27] = {
    name = "h",
    caps = "H",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [28] = {
    name = "i",
    caps = "I",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [29] = {
    name = "j",
    caps = "J",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [30] = {
    name = "k",
    caps = "K",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [31] = {
    name = "l",
    caps = "L",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [32] = {
    name = "m",
    caps = "M",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [33] = {
    name = "n",
    caps = "N",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [34] = {
    name = "o",
    caps = "O",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [35] = {
    name = "p",
    caps = "P",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [36] = {
    name = "q",
    caps = "Q",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [37] = {
    name = "r",
    caps = "R",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [38] = {
    name = "s",
    caps = "S",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [39] = {
    name = "t",
    caps = "T",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [40] = {
    name = "u",
    caps = "U",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [41] = {
    name = "v",
    caps = "V",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [42] = {
    name = "w",
    caps = "W",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [43] = {
    name = "x",
    caps = "X",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [44] = {
    name = "y",
    caps = "Y",
    nimage = "",
    fimage = "",
    pimage = ""
  },
  [45] = {
    name = "z",
    caps = "Z",
    nimage = "",
    fimage = "",
    pimage = ""
  }
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local bcaps = false
function main_form_init(self)
  self.Fixed = false
  self.file_name = ""
  return 1
end
function on_main_form_open(self)
  random_key(45)
  local gui = nx_value("gui")
  local size = 13
  local size_old = 13
  local count = 13
  local n = 0
  local row = 0
  for i = 1, table.getn(all_key) do
    local button = nx_null()
    button = gui:Create("Button")
    self:Add(button)
    button.Name = "btn" .. i
    button.fname = all_key[i].name
    button.caps = all_key[i].caps
    button.Text = nx_widestr(all_key[i].name)
    button.NormalImage = normal_image
    button.FocusImage = focus_image
    button.PushImage = push_image
    button.ForeColor = "255,255,255,255"
    button.Font = "hyshtj16"
    button.DrawMode = "FitWindow"
    button.AutoSize = true
    if i > size then
      count = count - 1
      size = size + count
      size_old = size - count
      row = row + 1
      n = n + 1
      if row == 1 then
        n = n - 1
      end
    end
    button.Left = 8 + (i - 1) % size_old * 28 + n * 28
    button.Top = 38 + row * 28
    nx_bind_script(button, nx_current())
    nx_callback(button, "on_click", "on_click_btn")
  end
end
function on_main_form_close(self)
  nx_destroy(self)
  return 1
end
function random_key(times)
  for i = 1, times do
    local index1 = math.random(table.getn(all_key))
    local index2 = math.random(table.getn(all_key))
    all_key[index1], all_key[index2] = all_key[index2], all_key[index1]
  end
end
function on_btn_close_click(self)
  local form = self.Parent
  form.Visible = false
  form:Close()
end
function on_btn_caps_click(self)
  local form = self.Parent
  if bcaps == false then
    for i = 1, table.getn(all_key) do
      local crlname = "btn" .. i
      local button = form:Find(crlname)
      if nx_is_valid(button) then
        button.Text = nx_widestr(button.caps)
      end
    end
    bcaps = true
  else
    for i = 1, table.getn(all_key) do
      local crlname = "btn" .. i
      local button = form:Find(crlname)
      if nx_is_valid(button) then
        button.Text = nx_widestr(button.fname)
      end
    end
    bcaps = false
  end
end
function on_btn_enter_click(self)
  local form = self.Parent
end
function input_key(form, form_parent, key)
  nx_execute(form.file_name, "on_in_put_key", form_parent, key)
end
function on_btn_backspace_click(self)
  local form = self.Parent
  local form_parent = form.Parent
  nx_execute(form.file_name, "on_del_key", form_parent)
end
function on_click_btn(self)
  local key = self.Text
  local form = self.Parent
  local form_parent = form.Parent
  input_key(form, form_parent, key)
end
