function form_goods_car_Init(self)
  self.Fixed = false
end
function form_goods_car_Open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
