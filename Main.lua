local _, addonTable = ...
local GW = GW2_ADDON

hooksecurefunc("SetItemButtonQuality", GW.SetBagItemButtonQualitySkin)

local function ConvertTags(tags)
  local res = {}
  for _, tag in ipairs(tags) do
    res[tag] = true
  end
  return res
end

Baganator.Constants.ButtonFrameOffset = 0

local function SkinContainerFrame(frame)
  frame:GwStripTextures()
  GW.CreateFrameHeaderWithBody(frame, frame:GetTitleText(), "Interface/AddOns/GW2_UI/textures/bag/bagicon", {})
  frame.gwHeader:ClearAllPoints()
  frame.gwHeader:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -25)
  frame.gwHeader:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -25)
  frame.gwHeader.windowIcon:ClearAllPoints()
  frame.gwHeader.windowIcon:SetPoint("CENTER", frame.gwHeader.BGLEFT, "LEFT", 21, -7)
  frame.CloseButton:GwSkinButton(true)
  frame.CloseButton:SetPoint("TOPRIGHT", 0, 7)
  hooksecurefunc(frame.SearchWidget, "SetSpacing", function(_, sideSpacing)
    frame.SearchWidget:ClearAllPoints()
    frame.SearchWidget.SearchBox:SetPoint("RIGHT", frame, -sideSpacing - 36, 0)
    frame.SearchWidget.SearchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", Baganator.Constants.ButtonFrameOffset + 64, - 28)
  end)
  frame.SearchWidget.SearchBox:SetHeight(22)
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
  IconButton = function(frame)
    -- As the icon isn't available immediately on collapsing bag section icons
    C_Timer.After(0, function()
      if frame.icon then
        frame.icon:SetDrawLayer("OVERLAY")
      end
    end)
    -- Ensure button icons display
    for _, r in ipairs({frame:GetRegions()}) do
      if r:IsObjectType("Texture") then
        r:SetDrawLayer("OVERLAY")
      end
    end
    frame:ClearHighlightTexture()
    frame:GwSkinButton(false, true, false, false, false, true)
  end,
  Button = function(frame)
    frame:GwSkinButton(false, true, false, false, false, false)
  end,
  ButtonFrame = function(frame, tags)
    frame:SetFrameStrata("HIGH")
    if tags.backpack then
      SkinContainerFrame(frame)
      frame.TopButtons[1]:ClearAllPoints()
      frame.TopButtons[1]:SetPoint("TOPLEFT", frame:GetTitleText(), "TOPRIGHT", 10, 0)
      frame.BagSlots:ClearAllPoints()
      frame.BagSlots:SetPoint("BOTTOM", frame, "TOP", 0, 8)
      frame.BagSlots:SetPoint("LEFT", frame.TopButtons[1])
    elseif tags.bank then
      SkinContainerFrame(frame)
      frame.Character.TopButtons[1]:ClearAllPoints()
      frame.Character.TopButtons[1]:SetPoint("TOPLEFT", frame:GetTitleText(), "TOPRIGHT", 10, 0)
      frame.Character.BagSlots:ClearAllPoints()
      frame.Character.BagSlots:SetPoint("BOTTOM", frame, "TOP", 0, 8)
      frame.Character.BagSlots:SetPoint("LEFT", frame.Character.TopButtons[1], "RIGHT")
    elseif tags.guild then
      SkinContainerFrame(frame)
      frame.LiveButtons[1]:ClearAllPoints()
      frame.LiveButtons[1]:SetPoint("TOPLEFT", frame:GetTitleText(), "TOPRIGHT", 10, 0)
      frame.LogsFrame:SetFrameStrata("DIALOG")
      frame.TabTextFrame:SetFrameStrata("DIALOG")
    else
      GW.HandlePortraitFrame(frame, true)
    end
  end,
  SearchBox = function(frame)
    frame:SetFont(UNIT_NAME_FONT, 14, "")
    GW.SkinTextBox(frame.Middle, frame.Left, frame.Right)
    frame:SetHeight(26)
    frame.searchIcon:Hide()
    frame:SetFont(UNIT_NAME_FONT, 14, "")
    frame.Instructions:SetFont(UNIT_NAME_FONT, 14, "")
    frame.Instructions:SetTextColor(178 / 255, 178 / 255, 178 / 255)

  end,
  EditBox = function(frame)
    GW.SkinTextBox(frame.Middle, frame.Left, frame.Right)
  end,
  TabButton = function(frame)
    if Baganator.Constants.IsClassic then
      frame:GwSkinButton(false, true, false, false, false, false)
    else
      frame:GwSkinTab("down")
    end
  end,
  TopTabButton = function(frame)
    -- Don't skin tabs without a name, assumed to be named by GW2 classic
    if Baganator.Constants.IsClassic then
      frame:GwSkinButton(false, true, false, false, false, false)
    else
      frame:GwSkinTab()
    end
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
}

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

  Baganator.Config.Set(Baganator.Config.Options.ICON_TEXT_QUALITY_COLORS, true)
  Baganator.Config.Set(Baganator.Config.Options.EMPTY_SLOT_BACKGROUND, true)

  for _, details in ipairs(Baganator.API.Skins.GetAllFrames()) do
    SkinFrame(details)
  end

  DisableGW2Defaults()
  HideBagButtons()
end)
