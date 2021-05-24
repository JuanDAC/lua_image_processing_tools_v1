local getn
getn = table.getn
do
  local _class_0
  local _base_0 = {
    pIds = {
      length = 0
    },
    pColor = {
      length = 0
    },
    pButton = {
      length = 0
    },
    pCheck = {
      length = 0
    },
    pCombobox = {
      length = 0
    },
    pEntry = {
      length = 0
    },
    pLabel = {
      length = 0
    },
    pNumber = {
      length = 0
    },
    pRadio = {
      length = 0
    },
    pSeparator = {
      length = 0
    },
    getId = function(self)
      return self.pIds.length
    end,
    setId = function(self)
      self.pIds.length = self.pIds.length + 1
    end,
    mColor = function(self, label)
      if label == nil then
        label = "Color " .. tostring(self.pColor.length)
      end
      self.pDlg:color({
        id = "color_" .. tostring(self.pColor.length),
        label = label,
        color = app.Color
      })
      self.pColor.length = self.pColor.length + 1
    end,
    mButton = function(self, label, text, onclick, selected, focus)
      if label == nil then
        label = "Button " .. tostring(self.pButton.length)
      end
      if text == nil then
        text = "Button " .. tostring(self.pButton.length)
      end
      if onclick == nil then
        onclick = function()
          return app.alert(text)
        end
      end
      if selected == nil then
        selected = false
      end
      if focus == nil then
        focus = false
      end
      self.pDlg:button({
        id = "button_" .. tostring(self.pButton.length),
        label = label,
        text = text,
        selected = selected,
        focus = focus,
        onclick = onclick
      })
      self.pButton.length = self.pButton.length + 1
    end,
    mCheck = function(self, label, text, onclick, selected)
      if label == nil then
        label = "Check " .. tostring(self.pCheck.length)
      end
      if text == nil then
        text = "Check " .. tostring(self.pCheck.length)
      end
      if onclick == nil then
        onclick = function()
          return app.alert(text)
        end
      end
      if selected == nil then
        selected = false
      end
      self.pDlg:check({
        id = "check_" .. tostring(self.pCheck.length),
        label = label,
        text = text,
        selected = selected,
        onclick = onclick
      })
      self.pCheck.length = self.pCheck.length + 1
    end,
    mPosition = function(self, x, y)
      self.pDlg.bounds = Rectangle(x, y, self.pDlg.bounds.width, self.pDlg.bounds.height)
    end,
    mCombobox = function(self, label, option, options)
      if label == nil then
        label = "Combobox " .. tostring(self.pCombobox.length)
      end
      if option == nil then
        option = "Combobox"
      end
      if options == nil then
        options = {
          "Combobox",
          "Combobox"
        }
      end
      self.pDlg:combobox({
        id = "combobox_" .. tostring(self.pCombobox.length),
        label = label,
        option = option,
        options = options
      })
      self.pCombobox.length = self.pCombobox.length + 1
    end,
    mEntry = function(self, label, text, focus)
      if label == nil then
        label = "Entry " .. tostring(self.pEntry.length)
      end
      if text == nil then
        text = "Entry " .. tostring(self.pEntry.length)
      end
      if focus == nil then
        focus = false
      end
      self.pDlg:entry({
        id = "entry_" .. tostring(self.pEntry.length),
        label = label,
        text = text,
        focus = focus
      })
      self.pEntry.length = self.pEntry.length + 1
    end,
    mLabel = function(self, label, text)
      if label == nil then
        label = "Label " .. tostring(self.pLabel.length)
      end
      if text == nil then
        text = "Label " .. tostring(self.pLabel.length)
      end
      self.pDlg:label({
        id = "label_" .. tostring(self.pLabel.length),
        label = label,
        text = text
      })
      self.pLabel.length = self.pLabel.length + 1
    end,
    mNumber = function(self, label, text, decimals)
      if label == nil then
        label = "Number " .. tostring(self.pNumber.length)
      end
      if text == nil then
        text = self.pNumber.length
      end
      if decimals == nil then
        decimals = 10
      end
      self.pDlg:number({
        id = "number_" .. tostring(self.pNumber.length),
        label = label,
        text = text,
        decimals = decimals
      })
      self.pNumber.length = self.pNumber.length + 1
    end,
    mRadio = function(self, label, text, onclick, selected, focus)
      if label == nil then
        label = "Radio " .. tostring(self.pRadio.length)
      end
      if text == nil then
        text = "Radio " .. tostring(self.pRadio.length)
      end
      if onclick == nil then
        onclick = function()
          return app.alert(text)
        end
      end
      if selected == nil then
        selected = false
      end
      if focus == nil then
        focus = false
      end
      self.pDlg:radio({
        id = "radio_" .. tostring(self.pRadio.length),
        label = label,
        text = text,
        selected = selected,
        focus = focus,
        onclick = onclick
      })
      self.pRadio.length = self.pRadio.length + 1
    end,
    mLanguageManager = function(self)
      return self.pDlg:combobox({
        id = "lang",
        label = "Idioma",
        option = "es",
        options = {
          "en",
          "es"
        }
      })
    end,
    mSeparator = function(self, label, text)
      if label == nil then
        label = "Separator " .. tostring(self.pSeparator.length)
      end
      if text == nil then
        text = "Separator " .. tostring(self.pSeparator.length)
      end
      self.pDlg:separator({
        id = "separator_" .. tostring(self.pSeparator.length),
        label = label,
        text = text
      })
      self.pSeparator.length = self.pSeparator.length + 1
    end,
    mOK = function(self, label, text, onclick, selected, focus)
      if label == nil then
        label = false
      end
      if text == nil then
        text = "OK"
      end
      if onclick == nil then
        onclick = function()
          return app.alert(text)
        end
      end
      if selected == nil then
        selected = false
      end
      if focus == nil then
        focus = false
      end
      local cuurentClick
      cuurentClick = function()
        if self.pDlg.data.ok then
          return onclick(self.pDlg.data)
				else
					app.alert(self.pDlg.data.lang)
          return app.alert("Datos incompletos")
        end
      end
      return self:mButton(label, text, cuurentClick, selected, focus)
    end,
    mNewrow = function(self)
      return self.pDlg:newrow()
    end,
    mShow = function(self)
      return self.pDlg:show({weit = false})
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, title)
      self:setId()
      self.pId = self:getId()
      self.pDlg = Dialog(title)
    end,
    __base = _base_0,
    __name = "Interface"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Interface = _class_0
end
local interface = Interface('Language')
interface:mLanguageManager()
interface:mColor()
interface:mColor()
interface:mColor()
interface:mButton()
interface:mButton()
interface:mButton()
interface:mCheck()
interface:mCheck()
interface:mCheck()
interface:mCombobox()
interface:mCombobox()
interface:mCombobox()
interface:mEntry()
interface:mEntry()
interface:mEntry()
interface:mLabel()
interface:mLabel()
interface:mLabel()
interface:mNumber()
interface:mNumber()
interface:mNumber()
interface:mRadio()
interface:mRadio()
interface:mRadio()
interface:mSeparator()
interface:mSeparator()
interface:mSeparator()
interface:mOK()
interface:mPosition(80, 10)
return interface:mShow()
