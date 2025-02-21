if not _G.UI then
    _G.UI = {}
end

if not _G.UI.AdminPage then
    _G.UI.AdminPage = {}
end

local AceGUI = LibStub("AceGUI-3.0")

-- Helper function to clamp a widget's frame inside its parent's boundaries.
local function ClampWidgetToContainer(widget)
    local selfFrame = widget.frame
    local parentFrame = selfFrame:GetParent()
    if not parentFrame then
        return
    end

    local pLeft, pBottom, pRight, pTop = parentFrame:GetLeft(), parentFrame:GetBottom(), parentFrame:GetRight(), parentFrame:GetTop()
    local wLeft, wBottom, wRight, wTop = selfFrame:GetLeft(), selfFrame:GetBottom(), selfFrame:GetRight(), selfFrame:GetTop()

    -- If any coordinate is nil (shouldn't happen), bail out.
    if not (pLeft and pBottom and pRight and pTop and wLeft and wBottom and wRight and wTop) then
        return
    end

    -- If the widget's frame is even slightly out of the parent's bounds, reset its position.
    if (wLeft < pLeft) or (wRight > pRight) or (wTop > pTop) or (wBottom < pBottom) then
        selfFrame:ClearAllPoints()
        selfFrame:SetPoint("TOP", parentFrame, "TOP", 0, -20)
    end
end

-- Create a draggable button for a given name.
local function CreateDraggableName(name)
    local widget = AceGUI:Create("Button")
    widget:SetText(name)
    widget:SetWidth(200)
    -- Make the underlying frame movable.
    widget.frame:SetMovable(true)
    widget.frame:EnableMouse(true)
    widget.frame:RegisterForDrag("LeftButton")

    widget.frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    widget.frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        ClampWidgetToContainer(widget)
    end)

    return widget
end

-- Create the main frame that holds the draggable names.
local function CreateDragDropFrame()
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Draggable Names")
    frame:SetLayout("Flow")
    frame:SetWidth(400)
    frame:SetHeight(400)
    frame.frame:SetClampedToScreen(true)
    

    -- Create a container for the draggable names.
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetFullWidth(true)
    container:SetFullHeight(true)
    container.frame:SetClampedToScreen(true)
    frame:AddChild(container)
    
    local bg = container.frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(container.frame)
    bg:SetColorTexture(0, 0, 1, 0.5)

    local names = { "Alice", "Bob", "Charlie", "Diana", "Edward" }
local startY = -50          -- vertical offset from the top edge of the container
local verticalSpacing = 30  -- spacing between each name

for i, name in ipairs(names) do
    local draggable = CreateDraggableName(name)
    container:AddChild(draggable)
    draggable.frame:ClearAllPoints()
    -- Anchor each widget at the container's TOP center.
    draggable.frame:SetPoint("TOP", container.frame, "TOP", 0, startY - ((i - 1) * verticalSpacing))
end

    return frame
end

-- Draw the Admin Page inside the given container.
function _G.UI.AdminPage:DrawAdminPage(container)
    container:ReleaseChildren()
    local adminFrame = CreateDragDropFrame()
    container:AddChild(adminFrame)
end
