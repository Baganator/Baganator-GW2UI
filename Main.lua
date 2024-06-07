local _, addonTable = ...
local GW = GW2_ADDON

local function ConvertTags(tags)
  local res = {}
  for _, tag in ipairs(tags) do
    res[tag] = true
  end
  return res
end

Baganator.Constants.ButtonFrameOffset = 0

local function SkinContainerFrame(frame, topButtons, topRightButtons)
  frame:GwStripTextures()
  GW.CreateFrameHeaderWithBody(frame, frame:GetTitleText(), "Interface/AddOns/GW2_UI/textures/bag/bagicon", {})
  frame.gwHeader:ClearAllPoints()
  frame.gwHeader:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -25)
  frame.gwHeader:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -25)
  frame.gwHeader.windowIcon:ClearAllPoints()
  frame.gwHeader.windowIcon:SetPoint("CENTER", frame, "TOPLEFT", -16, 0)
  frame.gwHeader.windowIcon:SetSize(84, 84)
  frame.CloseButton:GwSkinButton(true)
  frame.CloseButton:SetPoint("TOPRIGHT", -10, 4)
  frame.CloseButton:SetSize(20, 20)

  frame:GetTitleText():ClearAllPoints()
  frame:GetTitleText():SetPoint("BOTTOMLEFT", frame.gwHeader, "BOTTOMLEFT", 35, 10)

  frame.footer = frame:CreateTexture(nil, "BACKGROUND", nil, 7)
  frame.footer:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagfooter")
  frame.footer:SetHeight(55)
  frame.footer:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 30)
  frame.footer:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 30)

  frame.panelLeft = frame:CreateTexture(nil, "BACKGROUND", nil, 7)
  frame.panelLeft:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagleftpanel")
  frame.panelLeft:SetWidth(40)
  frame.panelLeft:SetPoint("TOPRIGHT", frame, "TOPLEFT", 0, 25)
  frame.panelLeft:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 0, 25)

  frame.borderBottomRight = frame:CreateTexture(nil, "BORDER")
  frame.borderBottomRight:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bottom-right")
  frame.borderBottomRight:SetSize(128, 128)
  frame.borderBottomRight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

  frame:SetHitRectInsets(-40, 0, -25, 0)

  hooksecurefunc(frame.SearchWidget, "SetSpacing", function(_, sideSpacing)
    frame.SearchWidget:ClearAllPoints()
    frame.SearchWidget.SearchBox:SetPoint("RIGHT", frame, -sideSpacing - 36, 0)
    frame.SearchWidget.SearchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", Baganator.Constants.ButtonFrameOffset, - 28)
  end)
  frame.SearchWidget.SearchBox:SetHeight(22)

  local buttonOffsetX = -36
  local buttonOffsetY = -30
  local buttonHeight = topButtons[1]:GetHeight()

  for index, button in ipairs(topButtons) do
    local button = topButtons[index]
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", buttonOffsetX, buttonOffsetY)
    buttonOffsetY = buttonOffsetY - buttonHeight - 5
  end

  local block = false
  local function SetupRightButtons()
    local buttonOffsetY = buttonOffsetY - 40
    for index = #topRightButtons, 1, -1 do
      local button = topRightButtons[index]
      if button:IsShown() then
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", buttonOffsetX, buttonOffsetY)
        buttonOffsetY = buttonOffsetY - buttonHeight - 5
      end
    end
  end

  for _, button in ipairs(topRightButtons) do
    hooksecurefunc(button, "Show", SetupRightButtons)
    hooksecurefunc(button, "Hide", SetupRightButtons)
    hooksecurefunc(button, "SetShown", SetupRightButtons)
    hooksecurefunc(button, "SetPoint", function()
      if not block then
        block = true
        SetupRightButtons()
        block = false
      end
    end)
  end
end

local function SetupIconButton(button, texture)
  local iconSizeX, iconSizeY = button.Icon:GetSize()
  if button.Icon2 then
    button.Icon2:Hide()
  end
  button:SetSize(30, 30)
  button.Icon:SetSize(30, 30)
  button.Left:Hide()
  button.Right:Hide()
  button.Middle:Hide()
  button:ClearHighlightTexture()

  button.Icon:SetTexture(texture)
  button.Icon:SetTexCoord(0,1,0,1)
end

local skinners = {
  ItemButton = function(frame)
    -- Fix for GW2 assuming named frames have a named cooldown
    if frame:GetName() and not _G[frame:GetName().."Cooldown"] then
      CreateFrame("Cooldown", frame:GetName().."Cooldown", frame)
    end
    GW.SkinBagItemButton(frame:GetName(), frame, 37)
    -- Ensure item icon and border is set GW2 style
    if frame.SetItemButtonQuality then
      hooksecurefunc(frame, "SetItemButtonQuality", GW.SetBagItemButtonQualitySkin)
    end
    -- Show white border if none is shown, like default GW2
    if Baganator.Constants.IsClassic and frame.SetItemDetails then
      hooksecurefunc(frame, "SetItemDetails", function(self, details)
        if details.itemID and not frame.IconBorder:IsShown() then
          frame.IconBorder:Show()
        end
      end)
    end
  end,
  IconButton = function(button, tags)
    if tags.sort then
      SetupIconButton(button, "Interface/AddOns/GW2_UI/textures/icons/BagMicroButton-Up")
    elseif tags.bank then
      SetupIconButton(button, "Interface/AddOns/GW2_UI/textures/icons/microicons/CollectionsMicroButton-Up")
    elseif tags.guildBank then
      SetupIconButton(button, "Interface/AddOns/GW2_UI/textures/icons/microicons/GuildMicroButton-Up")
    elseif tags.allCharacters then
      SetupIconButton(button, "Interface/AddOns/GW2_UI/textures/icons/microicons/LFDMicroButton-Up")
    elseif tags.customise then
      SetupIconButton(button, "Interface/AddOns/GW2_UI/textures/icons/microicons/MainMenuMicroButton-Up")
    elseif tags.bagSlots then
      SetupIconButton(button, "Interface/AddOns/GW2_UI/textures/icons/microicons/BagMicroButton-Up")
    else
      button.Icon:SetDrawLayer("OVERLAY")
      if button.Icon2 then
        button.Icon2:SetDrawLayer("OVERLAY")
      end
      button.Left:Hide()
      button.Right:Hide()
      button.Middle:Hide()
      button:ClearHighlightTexture()
    end
  end,
  Button = function(frame)
    frame:GwSkinButton(false, true, false, false, false, false)
  end,
  ButtonFrame = function(frame, tags)
    frame:SetFrameStrata("HIGH")
    if tags.backpack then
      SkinContainerFrame(frame, frame.TopButtons, frame.AllFixedButtons)
      frame.BagSlots:ClearAllPoints()
      frame.BagSlots:SetPoint("BOTTOM", frame, "TOP", 0, 8)
      frame.BagSlots:SetPoint("LEFT", frame:GetTitleText(), "RIGHT")
    elseif tags.bank then
      SkinContainerFrame(frame, frame.Character.TopButtons, frame.AllFixedButtons)
      frame.Character.BagSlots:ClearAllPoints()
      frame.Character.BagSlots:SetPoint("BOTTOM", frame, "TOP", 0, 8)
      frame.Character.BagSlots:SetPoint("LEFT", frame:GetTitleText(), "RIGHT")
    elseif tags.guild then
      SkinContainerFrame(frame, {frame.ToggleTabTextButton, frame.ToggleTabLogsButton, frame.ToggleGoldLogsButton}, frame.AllFixedButtons)
      frame.LogsFrame:SetFrameStrata("DIALOG")
      frame.TabTextFrame:SetFrameStrata("DIALOG")
    else
      GW.HandlePortraitFrame(frame, true)
    end
  end,
  SearchBox = function(frame)
    if GW.SkinBagSearchBox then
      GW.SkinBagSearchBox(frame)
    else
      frame:SetFont(UNIT_NAME_FONT, 14, "")
      GW.SkinTextBox(frame.Middle, frame.Left, frame.Right)
      frame:SetHeight(26)
      frame.searchIcon:Hide()
      frame:SetFont(UNIT_NAME_FONT, 14, "")
      frame.Instructions:SetFont(UNIT_NAME_FONT, 14, "")
      frame.Instructions:SetTextColor(178 / 255, 178 / 255, 178 / 255)
    end
  end,
  EditBox = function(frame)
    GW.SkinTextBox(frame.Middle, frame.Left, frame.Right)
  end,
  TabButton = function(frame)
    frame:GwStripTextures()
    frame:GwSkinButton(false, true, false, false, false, false)
  end,
  TopTabButton = function(frame)
    frame:GwStripTextures()
    frame:GwSkinButton(false, true, false, false, false, false)
  end,
  SideTabButton = function(frame)
    --Not available in GW2
  end,
  TrimScrollBar = function(frame)
    GW.HandleTrimScrollBar(frame)
  end,
  CheckBox = function(frame)
    frame:GwSkinCheckButton()
    frame:SetPoint("TOP", 0, -12)
    frame:SetSize(15, 15)
  end,
  Slider = function(frame)
    frame:GwSkinSliderFrame()
    frame:GetThumbTexture():SetSize(16, 16)
    frame.tex:SetDrawLayer("ARTWORK")
    frame.tex:SetPoint("TOPLEFT", -10, 2)
    frame.tex:SetPoint("BOTTOMRIGHT", 10, -2)
  end,
  InsetFrame = function(frame)
    frame.Bg:Hide()
    frame:GwStripTextures()
    if frame.NineSlice then
      frame.NineSlice:Hide()
    end
    Mixin(frame, BackdropTemplateMixin)
    frame:SetBackdrop(GW.BackdropTemplates.ColorableBorderOnly)
    frame:SetBackdropBorderColor(0, 0, 0, 1)
  end,
  Divider = function(tex)
    tex:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
    tex:SetHeight(1)
    tex:SetColorTexture(1, 0.93, 0.73, 0.45)
  end,
  CategoryLabel = function(btn)
    btn:GetFontString():SetFont(UNIT_NAME_FONT, 11)
    btn:GetFontString():SetTextColor(1, 1, 1)
  end
}

if C_AddOns.IsAddOnLoaded("Masque") then
  skinners.ItemButton = function() end
else
  hooksecurefunc("SetItemButtonQuality", GW.SetBagItemButtonQualitySkin)
end

local function SkinFrame(details)
  local func = skinners[details.regionType]
  if func then
    func(details.region, details.tags and #details.tags > 0 and ConvertTags(details.tags) or {})
  end
end

local function DisableGW2Defaults()
  if Baganator.Constants.IsClassic then
    GW.SetSetting("BAG_SHOW_EQUIPMENT_SET_NAME",  false)
    GW.SetSetting("BAG_ITEM_JUNK_ICON_SHOW",  false)
    GW.SetSetting("BAG_ITEM_UPGRADE_ICON_SHOW",  false)
    -- overwrites border from baganator to always show something at least white
    GW.SetSetting("BAG_ITEM_QUALITY_BORDER_SHOW",  true)
    GW.SetSetting("BAG_PROFESSION_BAG_COLOR",  false)
    GW.SetSetting("BAG_SHOW_ILVL",  false)
  else
    GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME =  false
    GW.settings.BAG_ITEM_JUNK_ICON_SHOW =  false
    GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW =  false
    -- needs to be on otherwise hides border used in Baganator
    GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW =  true
    GW.settings.BAG_PROFESSION_BAG_COLOR =  false
    GW.settings.BAG_SHOW_ILVL =  false
  end
end

local function HideBagButtons()
  MainMenuBarBackpackButton:SetParent(GW.HiddenFrame)
  for i = 0, 3 do
      _G["CharacterBag" .. i .. "Slot"]:SetParent(GW.HiddenFrame)
  end
  if CharacterReagentBag0Slot then
    CharacterReagentBag0Slot:SetParent(GW.HiddenFrame)
  end
  if BagBarExpandToggle then
    BagBarExpandToggle:SetParent(GW.HiddenFrame)
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
  Baganator.API.Skins.RegisterListener(SkinFrame)

  Baganator.Config.Set(Baganator.Config.Options.EMPTY_SLOT_BACKGROUND, true)

  for _, details in ipairs(Baganator.API.Skins.GetAllFrames()) do
    SkinFrame(details)
  end

  DisableGW2Defaults()
  HideBagButtons()
end)
