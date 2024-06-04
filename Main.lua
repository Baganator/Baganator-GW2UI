local _, addonTable = ...
local GW = GW2_ADDON

hooksecurefunc("SetItemButtonQuality", GW.SetBagItemButtonQualitySkin)

local skinners = {
  ItemButton = function(frame)
    GW.SkinBagItemButton(frame:GetName(), frame, 37)
    if frame.SetItemButtonQuality then
      hooksecurefunc(frame, "SetItemButtonQuality", GW.SetBagItemButtonQualitySkin)
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
  ButtonFrame = function(frame)
    GW.HandlePortraitFrame(frame, true)
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
    frame:GwSkinTab()
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
    --Tricky in GW2
  end,
}

local function SkinFrame(details)
  local func = skinners[details.regionType]
  if func then
    func(details.region)
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
  Baganator.API.Skins.RegisterListener(SkinFrame)

  for _, details in ipairs(Baganator.API.Skins.GetAllFrames()) do
    SkinFrame(details)
  end
end)
