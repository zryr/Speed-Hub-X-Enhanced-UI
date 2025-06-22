local Lucide -- Declare Lucide upvalue

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Mouse = LocalPlayer:GetMouse()

-- Lucide Icon Library Loading & GetIcon Helper
local LucideLib = nil
local HttpServiceForLucide = game:GetService("HttpService") -- Use a distinct name

if HttpServiceForLucide and type(game.HttpGet) == "function" then
    local HttpGetSuccess, LucideScript = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/zryr/Libraries/refs/heads/Jules/Lucide-Source.lua")
    if HttpGetSuccess and type(LucideScript) == "string" and LucideScript ~= "" then
        local LoadSuccess, LoadedFunc = pcall(loadstring, LucideScript) -- Corrected pcall usage
        if LoadSuccess and type(LoadedFunc) == "function" then
            local ExecSuccess, ReturnedMod = pcall(LoadedFunc)
            if ExecSuccess and type(ReturnedMod) == "table" and type(ReturnedMod.GetIcon) == "function" then
                LucideLib = ReturnedMod
                print("UB Hub: Lucide icon library loaded successfully.")
            else
                warn("UB Hub: Lucide script execution failed or returned invalid module. Error:", ReturnedMod)
            end
        else
            warn("UB Hub: Failed to loadstring Lucide script. Error:", LoadedFunc)
        end
    else
        warn("UB Hub: Failed to HttpGet Lucide script. Success:", HttpGetSuccess, "Script:", LucideScript)
    end
else
    warn("UB Hub: HttpService or game:HttpGet is not available. Lucide icons will not be loaded.")
end

local function GetIcon(iconName)
    if not iconName or type(iconName) ~= "string" or iconName == "" then
        return ""
    end

    if string.sub(iconName, 1, 7):lower() == "lucide:" then
        if LucideLib and type(LucideLib.GetIcon) == "function" then
            local actualName = string.sub(iconName, 8)
            if actualName == "" then return "" end -- Handle "lucide:" with no name
            local assetId = LucideLib:GetIcon(actualName)
            return assetId or "" -- Return assetId or empty string if Lucide:GetIcon fails
        else
            -- Lucide prefix used, but library not loaded or GetIcon method missing
            return ""
        end
    end
    -- Not a "lucide:" string, assume it's a direct asset ID or other.
    return iconName
end

local OldStaticColours = Colours
if type(OldStaticColours) ~= "table" then OldStaticColours = nil end

local Colours = {}

local ProtectGui = protectgui or (syn and syn.protect_gui) or function(f) end
local CoreGui = game:GetService("CoreGui")
local SizeUI = UDim2.fromOffset(550, 330)

local function MakeDraggable(topbarobject, object)
    local tbObject = topbarobject
    local obj = object
    local Dragging = false
    local DragInputObject = nil
    local DragStart = nil
    local StartPosition = nil

    tbObject.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not Dragging then
            Dragging = true
            DragInputObject = input
            DragStart = input.Position
            StartPosition = obj.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and DragInputObject and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if input.UserInputType == Enum.UserInputType.MouseMovement or (input.UserInputType == Enum.UserInputType.Touch and input == DragInputObject) then
                local Delta = input.Position - DragStart
                local newPos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
                obj.Position = newPos
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if Dragging and input == DragInputObject then
            Dragging = false
            DragInputObject = nil
        end
    end)
end

function CircleClick(Button, X, Y)
	task.spawn(function()
		Button.ClipsDescendants = true
		local Circle = Instance.new("ImageLabel")
		Circle.Image = "rbxassetid://266543268"
		Circle.ImageColor3 = Colours.ThemeHighlight or Color3.fromRGB(255,80,0)
		Circle.ImageTransparency = 0.8999999761581421
		Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Circle.BackgroundTransparency = 1
		Circle.ZIndex = 10
		Circle.Name = "Circle"
		Circle.Parent = Button
		
		local NewX = X - Circle.AbsolutePosition.X
		local NewY = Y - Circle.AbsolutePosition.Y
		Circle.Position = UDim2.new(0, NewX, 0, NewY)
		local Size = 0
		if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
			Size = Button.AbsoluteSize.X*1.5
		elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
			Size = Button.AbsoluteSize.Y*1.5
		elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
			Size = Button.AbsoluteSize.X*1.5
		end

		local Time = 0.5
		Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size/2, 0.5, -Size/2), "Out", "Quad", Time, false, nil)
		for i=1,10 do
			Circle.ImageTransparency = Circle.ImageTransparency + 0.01
			task.wait(Time/10)
		end
		Circle:Destroy()
	end)
end

local UBHubLib = {}

function UBHubLib:MakeNotify(NotifyConfig)
	local NotifyConfig = NotifyConfig or {}
	NotifyConfig.Title = NotifyConfig.Title or "UB Hub"
	NotifyConfig.Description = NotifyConfig.Description or "Notification"
	NotifyConfig.Content = NotifyConfig.Content or "Content"
	NotifyConfig.Color = NotifyConfig.Color or (Colours.Primary or Color3.fromRGB(160,40,0))
	NotifyConfig.Time = NotifyConfig.Time or 0.5
	NotifyConfig.Delay = NotifyConfig.Delay or 5
	local NotifyFunction = {}
	task.spawn(function()
		if not CoreGui:FindFirstChild("NotifyGui") then
			local NotifyGui = Instance.new("ScreenGui");
			NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			NotifyGui.Name = "NotifyGui"
			NotifyGui.Parent = CoreGui
		end
		if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
			local NotifyLayout = Instance.new("Frame");
			NotifyLayout.AnchorPoint = Vector2.new(1, 1)
			NotifyLayout.BackgroundColor3 = Colours.NotificationBackground or Color3.fromRGB(35,35,35)
			NotifyLayout.BackgroundTransparency = 0
			NotifyLayout.BorderColor3 = Colours.Stroke or Color3.fromRGB(80,20,0)
			NotifyLayout.BorderSizePixel = 0
			NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
			NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
			NotifyLayout.Name = "NotifyLayout"
			NotifyLayout.Parent = CoreGui.NotifyGui
			local Count = 0
			CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
				Count = 0
				for i, v in ipairs(CoreGui.NotifyGui.NotifyLayout:GetChildren()) do 
					if v:IsA("GuiObject") then 
						TweenService:Create(
							v,
							TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12)*Count))}
						):Play()
						Count = Count + 1
					end
				end
			end)
		end
		local NotifyPosHeigh = 0
		for i, v in ipairs(CoreGui.NotifyGui.NotifyLayout:GetChildren()) do
            if v:IsA("GuiObject") then
			    NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
            end
		end
		local NotifyFrame = Instance.new("Frame");
		local NotifyFrameReal = Instance.new("Frame");
		local UICorner = Instance.new("UICorner");
		local DropShadowHolder = Instance.new("Frame");
		local DropShado = Instance.new("ImageLabel");
		local Top = Instance.new("Frame");
		local TextLabel = Instance.new("TextLabel");
		local UIStroke = Instance.new("UIStroke");
		local UICorner1_Notify = Instance.new("UICorner");
		local TextLabel1 = Instance.new("TextLabel");
		local UIStroke1_Notify = Instance.new("UIStroke");
		local CloseButton = Instance.new("TextButton");
		local NotifyCloseIconImage = Instance.new("ImageLabel");
		local TextLabel2 = Instance.new("TextLabel");

		NotifyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		NotifyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		NotifyFrame.BorderSizePixel = 0
		NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
		NotifyFrame.Name = "NotifyFrame"
		NotifyFrame.BackgroundTransparency = 1
		NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
		NotifyFrame.AnchorPoint = Vector2.new(0, 1)
		NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

		NotifyFrameReal.BackgroundColor3 = Colours.NotificationBackground or Color3.fromRGB(35,35,35)
		NotifyFrameReal.BorderColor3 = Colours.Stroke or Color3.fromRGB(80,20,0)
		NotifyFrameReal.BorderSizePixel = 0
		NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
		NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
		NotifyFrameReal.Name = "NotifyFrameReal"
		NotifyFrameReal.Parent = NotifyFrame

		UICorner.Parent = NotifyFrameReal
		UICorner.CornerRadius = UDim.new(0, 8)

		DropShadowHolder.BackgroundTransparency = 1
		DropShadowHolder.BorderSizePixel = 0
		DropShadowHolder.ZIndex = 0
		DropShadowHolder.Name = "DropShadowHolder"
		DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
		DropShadowHolder.Parent = NotifyFrameReal

		DropShado.Image = "rbxassetid://6015897843"
		DropShado.ImageColor3 = Colours.Shadow or Color3.fromRGB(10,10,10)
		DropShado.ImageTransparency = 0.5
		DropShado.ScaleType = Enum.ScaleType.Slice
		DropShado.SliceCenter = Rect.new(49, 49, 450, 450)
		DropShado.AnchorPoint = Vector2.new(0.5, 0.5)
		DropShado.BackgroundTransparency = 1
		DropShado.BorderSizePixel = 0
		DropShado.Position = UDim2.new(0.5, 0, 0.5, 0)
		DropShado.Size = UDim2.new(1, 47, 1, 47)
		DropShado.ZIndex = 0
		DropShado.Name = "DropShado"
		DropShado.Parent = DropShadowHolder

		Top.BackgroundColor3 = Colours.NotificationActionsBackground or Color3.fromRGB(40,40,40)
		Top.BackgroundTransparency = 0
		Top.BorderColor3 = Colours.Stroke or Color3.fromRGB(80,20,0)
		Top.BorderSizePixel = 0
		Top.Size = UDim2.new(1, 0, 0, 36)
		Top.Name = "Top"
		Top.Parent = NotifyFrameReal

		TextLabel.Font = Enum.Font.GothamBold
		TextLabel.Text = NotifyConfig.Title
		TextLabel.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
		TextLabel.TextSize = 14
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.BackgroundTransparency = 1
		TextLabel.BorderColor3 = Colours.Stroke or Color3.fromRGB(80,20,0)
		TextLabel.BorderSizePixel = 0
		TextLabel.Size = UDim2.new(1, 0, 1, 0)
		TextLabel.Parent = Top
		TextLabel.Position = UDim2.new(0, 10, 0, 0)

		UIStroke.Color = Colours.Stroke or Color3.fromRGB(80,20,0)
		UIStroke.Thickness = 0.30000001192092896
		UIStroke.Parent = TextLabel

		UICorner1_Notify.Parent = Top
		UICorner1_Notify.CornerRadius = UDim.new(0, 5)

		TextLabel1.Font = Enum.Font.GothamBold
		TextLabel1.Text = NotifyConfig.Description
		TextLabel1.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
		TextLabel1.TextSize = 14
		TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel1.BackgroundColor3 = Colours.ThemeHighlight or Color3.fromRGB(255,80,0)
		TextLabel1.BackgroundTransparency = 1
		TextLabel1.BorderColor3 = Colours.Stroke or Color3.fromRGB(80,20,0)
		TextLabel1.BorderSizePixel = 0
		TextLabel1.Size = UDim2.new(1, 0, 1, 0)
		TextLabel1.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0)
		TextLabel1.Parent = Top

		UIStroke1_Notify.Color = Colours.Accent or Color3.fromRGB(0,150,255)
		UIStroke1_Notify.Thickness = 0.4000000059604645
		UIStroke1_Notify.Parent = TextLabel1

		CloseButton.Font = Enum.Font.SourceSans
		CloseButton.Text = ""
		CloseButton.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
		CloseButton.TextSize = 14
		CloseButton.AnchorPoint = Vector2.new(1, 0.5)
		CloseButton.BackgroundColor3 = Colours.NotificationActionsBackground or Color3.fromRGB(40,40,40)
		CloseButton.BackgroundTransparency = 1
		CloseButton.BorderColor3 = Colours.Stroke or Color3.fromRGB(80,20,0)
		CloseButton.BorderSizePixel = 0
		CloseButton.Position = UDim2.new(1, -5, 0.5, 0)
		CloseButton.Size = UDim2.new(0, 25, 0, 25)
		CloseButton.Name = "CloseButton"
		CloseButton.Parent = Top

		NotifyCloseIconImage.Name = "NotifyCloseIconImage"
		local notifyCloseIcon = GetIcon("lucide:x")
		NotifyCloseIconImage.Image = (notifyCloseIcon ~= "") and notifyCloseIcon or "rbxassetid://9886659671" -- Fallback
		NotifyCloseIconImage.ImageColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
		NotifyCloseIconImage.AnchorPoint = Vector2.new(0.5, 0.5)
		NotifyCloseIconImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		NotifyCloseIconImage.BackgroundTransparency = 1
		NotifyCloseIconImage.BorderColor3 = Colours.Stroke or Color3.fromRGB(80,20,0)
		NotifyCloseIconImage.BorderSizePixel = 0
		NotifyCloseIconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
		NotifyCloseIconImage.Size = UDim2.new(0.7, 0, 0.7, 0)
		NotifyCloseIconImage.Parent = CloseButton

		TextLabel2.Font = Enum.Font.GothamBold
		TextLabel2.Text = NotifyConfig.Content
		TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
		TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel2.BackgroundTransparency = 1
		TextLabel2.TextColor3 = Colours.TextColor or Color3.fromRGB(150,150,150)
		TextLabel2.BorderColor3 = Colours.Stroke or Color3.fromRGB(80,20,0)
		TextLabel2.BorderSizePixel = 0
		TextLabel2.Position = UDim2.new(0, 10, 0, 27)
		TextLabel2.Parent = NotifyFrameReal
		TextLabel2.Size = UDim2.new(1, -20, 0, 13)

		TextLabel2.TextWrapped = true
		task.wait()
		TextLabel2.Size = UDim2.new(1, -20, 0, TextLabel2.TextBounds.Y)


		if TextLabel2.AbsoluteSize.Y < 27 then
			NotifyFrame.Size = UDim2.new(1, 0, 0, 65)
		else
			NotifyFrame.Size = UDim2.new(1, 0, 0, TextLabel2.AbsoluteSize.Y + 40)
		end
		local waitbruh = false
		function NotifyFunction:Close()
			if waitbruh then
				return false
			end
			waitbruh = true
			TweenService:Create(
				NotifyFrameReal,
				TweenInfo.new(tonumber(NotifyConfig.Time) * 0.2, Enum.EasingStyle.Linear),{Position = UDim2.new(0, 400, 0, 0)}):Play()
			task.wait(tonumber(NotifyConfig.Time) / 1.2)
			NotifyFrame:Destroy()
		end
		CloseButton.Activated:Connect(function()
			NotifyFunction:Close()
		end)
		TweenService:Create(
			NotifyFrameReal,
			TweenInfo.new(tonumber(NotifyConfig.Time) * 0.2, Enum.EasingStyle.Linear),{Position = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(tonumber(NotifyConfig.Delay))
		NotifyFunction:Close()
	end)
	return NotifyFunction
end

-- [[ THIS IS THE START OF THE FULL MAKEGUI FUNCTION ]]
function UBHubLib:MakeGui(GuiConfig)
	local GuiConfig = GuiConfig or {}
	GuiConfig.NameHub = GuiConfig.NameHub or "UB Hub"
	GuiConfig.Description = GuiConfig.Description or nil
	GuiConfig.Color = GuiConfig.Color or Color3.fromRGB(255, 0, 255)
	GuiConfig["Logo Player"] = GuiConfig["Logo Player"] or "https://www.roblox.com/headshot-thumbnail/image?userId="..game:GetService("Players").LocalPlayer.UserId .."&width=420&height=420&format=png"
	GuiConfig["Name Player"] = GuiConfig["Name Player"] or tostring(game:GetService("Players").LocalPlayer.Name)
	GuiConfig["Tab Width"] = GuiConfig["Tab Width"] or 120
	GuiConfig["SaveFolder"] = GuiConfig["SaveFolder"] or false

	-- Lucide Icon Loading
	if game and type(game.HttpGet) == "function" then -- Guard against missing HttpGet
		local HttpGetSuccess, LucideScript = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/latte-soft/lucide-roblox/main/src/lucide.lua")
		if HttpGetSuccess and type(LucideScript) == "string" and LucideScript ~= "" then
			local LoadStringSuccess, LoadedFunction = pcall(loadstring(LucideScript))
			if LoadStringSuccess and LoadedFunction then
				local ExecutionSuccess, ReturnedTable = pcall(LoadedFunction)
				if ExecutionSuccess and type(ReturnedTable) == "table" then
					Lucide = ReturnedTable
				else
					-- warn("Lucide script execution failed or did not return a table. Error: " .. tostring(ReturnedTable))
					Lucide = nil -- Ensure Lucide is nil if any step failed
				end
			else
				-- warn("Failed to loadstring Lucide script. Error: " .. tostring(LoadedFunction))
				Lucide = nil
			end
		else
			-- warn("Failed to HttpGet Lucide script. Success: " .. tostring(HttpGetSuccess) .. " Script: " .. tostring(LucideScript))
			Lucide = nil
		end
	else
		Lucide = nil -- HttpGet not available
	end

	if not Lucide then
		warn("Lucide failed to load. Using placeholder icons.")
		Lucide = {}
		function Lucide.ImageLabel(iconName, imageSize, propertyOverrides)
			local imgLabel = Instance.new("ImageLabel")
			imgLabel.Size = imageSize and UDim2.fromOffset(imageSize, imageSize) or UDim2.fromOffset(20, 20)
			imgLabel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
			imgLabel.Image = "" -- Or a placeholder asset ID

			local placeholderText = Instance.new("TextLabel")
			placeholderText.Text = iconName and string.sub(iconName, 1, 1) or "?"
			placeholderText.Size = UDim2.new(1, 0, 1, 0)
			placeholderText.TextColor3 = Color3.fromRGB(255, 255, 255)
			placeholderText.BackgroundTransparency = 1
			placeholderText.Font = Enum.Font.SourceSansBold
			placeholderText.TextScaled = true
			placeholderText.Parent = imgLabel

			if propertyOverrides then
				for prop, value in pairs(propertyOverrides) do
					pcall(function() imgLabel[prop] = value end)
				end
			end
			return imgLabel
		end
	end
	-- End Lucide Icon Loading

	local CurrentHttpService = game:GetService("HttpService")
	if CurrentHttpService and not (type(CurrentHttpService.JSONEncode) == "function" and type(CurrentHttpService.JSONDecode) == "function" and type(CurrentHttpService.GenerateGUID) == "function") then
		warn("UB Hub: HttpService is available, but required methods (JSONEncode, JSONDecode, GenerateGUID) are not. Save/Load and Web Backgrounds will be affected.")
		CurrentHttpService = nil
	elseif not CurrentHttpService then
		warn("UB Hub: HttpService is not available. Save/Load and Web Backgrounds will be affected.")
	end

	local FSO = {
		readfile = readfile,
		writefile = writefile,
		isfile = isfile,
		makefolder = makefolder,
		listfiles = listfiles,
		getcustomasset = getcustomasset
	}
	for funcName, funcRef in pairs(FSO) do
		if type(funcRef) ~= "function" then
			warn("UB Hub: File system function '" .. funcName .. "' is not available. Related functionality (Save/Load, Local Backgrounds) will be affected.")
			FSO[funcName] = nil
		end
	end

	UBHubLib.Flags = UBHubLib.Flags or {}
	local Flags = UBHubLib.Flags

	local function SaveFile(Name, Value)
		if not (FSO.writefile and GuiConfig and GuiConfig.SaveFolder and CurrentHttpService) then
			if GuiConfig and GuiConfig.SaveFolder then
				warn("SaveFile: Cannot proceed. 'FSO.writefile' or 'HttpService' may not be available, or SaveFolder not set.")
			end
			return false
		end

		if Value == nil then
			UBHubLib.Flags[Name] = nil
		else
			UBHubLib.Flags[Name] = Value
		end

		local success, err = pcall(function()
			local path = GuiConfig.SaveFolder
			local encoded = CurrentHttpService:JSONEncode(UBHubLib.Flags)
			FSO.writefile(path, encoded)
		end)
		if not success then
			warn("SaveFile (for " .. (Name or "Unknown") .. ") failed:", err)
			return false
		end
		return true
	end

	local function LoadFile()
		if not (GuiConfig and GuiConfig["SaveFolder"]) then return false end
		local savePath = GuiConfig["SaveFolder"]
		if not (FSO.readfile and FSO.isfile and FSO.isfile(savePath) and CurrentHttpService) then
			if GuiConfig and GuiConfig.SaveFolder then
                local missing = {}
                if not FSO.readfile then table.insert(missing, "'FSO.readfile'") end
                if not FSO.isfile then table.insert(missing, "'FSO.isfile'") end
                if not CurrentHttpService then table.insert(missing, "'HttpService'") end
                warn("LoadFile: Cannot proceed. Missing: " .. table.concat(missing, ", ") .. ". Or save file does not exist.")
			end
			return false
		end
		local success, fileContent = pcall(FSO.readfile, savePath)
		if not success or not fileContent then
			warn("LoadFile: Failed to read file from path: " .. savePath .. (fileContent and (": " .. fileContent) or ""))
			return false
		end

		local decodeSuccess, config = pcall(CurrentHttpService.JSONDecode, CurrentHttpService, fileContent)
		if decodeSuccess and type(config) == "table" then
			UBHubLib.Flags = config
			return true
		end
		return false
	end; LoadFile()

	local function deepcopy(orig)
		local orig_type = type(orig)
		local copy
		if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in next, orig, nil do
				copy[deepcopy(orig_key)] = deepcopy(orig_value)
			end
			setmetatable(copy, deepcopy(getmetatable(orig)))
		else
			copy = orig
		end
		return copy
	end

	local tempOriginalColours = {
		Primary = (OldStaticColours and OldStaticColours.Primary) or Color3.fromRGB(160,40,0),
		Secondary = (OldStaticColours and OldStaticColours.Secondary) or Color3.fromRGB(160,30,0),
		Accent = (OldStaticColours and OldStaticColours.Accent) or Color3.fromRGB(200,50,0),
		ThemeHighlight = (OldStaticColours and OldStaticColours.ThemeHighlight) or Color3.fromRGB(255,80,0),
		Text = (OldStaticColours and OldStaticColours.Text) or Color3.fromRGB(255,240,230),
		Background = (OldStaticColours and OldStaticColours.Background) or Color3.fromRGB(20,8,0),
		Stroke = (OldStaticColours and OldStaticColours.Stroke) or Color3.fromRGB(80,20,0)
	}

	local DefaultThemes = {
		["Rayfield Like"] = {
			TextColor = Color3.fromRGB(221, 221, 221), Background = Color3.fromRGB(30, 30, 30), Topbar = Color3.fromRGB(25, 25, 25), Shadow = Color3.fromRGB(10,10,10),
			NotificationBackground = Color3.fromRGB(35, 35, 35), NotificationActionsBackground = Color3.fromRGB(40, 40, 40),
			TabBackground = Color3.fromRGB(30, 30, 30), TabStroke = Color3.fromRGB(50, 50, 50), TabBackgroundSelected = Color3.fromRGB(45, 45, 45),
			TabTextColor = Color3.fromRGB(180, 180, 180), SelectedTabTextColor = Color3.fromRGB(221, 221, 221),
			ElementBackground = Color3.fromRGB(45, 45, 45), ElementBackgroundHover = Color3.fromRGB(55, 55, 55), SecondaryElementBackground = Color3.fromRGB(40, 40, 40),
			ElementStroke = Color3.fromRGB(60, 60, 60), SecondaryElementStroke = Color3.fromRGB(50, 50, 50),
			SliderBackground = Color3.fromRGB(40, 40, 40), SliderProgress = Color3.fromRGB(0, 122, 204), SliderStroke = Color3.fromRGB(60, 60, 60),
			ToggleBackground = Color3.fromRGB(40, 40, 40), ToggleEnabled = Color3.fromRGB(0, 122, 204), ToggleDisabled = Color3.fromRGB(60, 60, 60),
			ToggleEnabledStroke = Color3.fromRGB(0, 100, 180), ToggleDisabledStroke = Color3.fromRGB(80, 80, 80),
			ToggleEnabledOuterStroke = Color3.fromRGB(0, 122, 204), ToggleDisabledOuterStroke = Color3.fromRGB(50, 50, 50),
			DropdownSelected = Color3.fromRGB(50, 50, 50), DropdownUnselected = Color3.fromRGB(40, 40, 40),
			InputBackground = Color3.fromRGB(35, 35, 35), InputStroke = Color3.fromRGB(55, 55, 55), PlaceholderColor = Color3.fromRGB(120, 120, 120),
			Primary = Color3.fromRGB(0, 122, 204), Secondary = Color3.fromRGB(0, 100, 170), Accent = Color3.fromRGB(0, 150, 255), ThemeHighlight = Color3.fromRGB(0, 122, 204), Stroke = Color3.fromRGB(50, 50, 50),
			GuiConfigColor = Color3.fromRGB(0, 122, 204)
		},
		["Default Dark Original"] = {
			TextColor = tempOriginalColours.Text, Background = tempOriginalColours.Background, Topbar = tempOriginalColours.Background, Shadow = Color3.fromRGB(10,5,0),
			NotificationBackground = Color3.fromRGB(25,10,0), NotificationActionsBackground = Color3.fromRGB(30,12,0),
			TabBackground = tempOriginalColours.Background, TabStroke = tempOriginalColours.Stroke, TabBackgroundSelected = tempOriginalColours.Secondary,
			TabTextColor = tempOriginalColours.Text, SelectedTabTextColor = Color3.fromRGB(255,255,255),
			ElementBackground = Color3.fromRGB(30,15,5), ElementBackgroundHover = Color3.fromRGB(40,20,10), SecondaryElementBackground = Color3.fromRGB(25,10,0),
			ElementStroke = tempOriginalColours.Stroke, SecondaryElementStroke = Color3.fromRGB(60,15,0),
			SliderBackground = Color3.fromRGB(30,15,5), SliderProgress = tempOriginalColours.ThemeHighlight, SliderStroke = tempOriginalColours.Stroke,
			ToggleBackground = Color3.fromRGB(30,15,5), ToggleEnabled = tempOriginalColours.ThemeHighlight, ToggleDisabled = Color3.fromRGB(50,25,10),
			ToggleEnabledStroke = tempOriginalColours.Accent, ToggleDisabledStroke = tempOriginalColours.Stroke,
			ToggleEnabledOuterStroke = tempOriginalColours.ThemeHighlight, ToggleDisabledOuterStroke = Color3.fromRGB(40,20,10),
			DropdownSelected = tempOriginalColours.Secondary, DropdownUnselected = Color3.fromRGB(30,15,5),
			InputBackground = Color3.fromRGB(25,10,0), InputStroke = tempOriginalColours.Stroke, PlaceholderColor = Color3.fromRGB(150,100,80),
			Primary = tempOriginalColours.Primary, Secondary = tempOriginalColours.Secondary, Accent = tempOriginalColours.Accent, ThemeHighlight = tempOriginalColours.ThemeHighlight, Stroke = tempOriginalColours.Stroke,
			GuiConfigColor = tempOriginalColours.Primary
		},
		["Default Light"] = {
			TextColor = Color3.fromRGB(10,10,10), Background = Color3.fromRGB(245,245,245), Topbar = Color3.fromRGB(235,235,235), Shadow = Color3.fromRGB(180,180,180),
			NotificationBackground = Color3.fromRGB(230,230,230), NotificationActionsBackground = Color3.fromRGB(220,220,220),
			TabBackground = Color3.fromRGB(240,240,240), TabStroke = Color3.fromRGB(200,200,200), TabBackgroundSelected = Color3.fromRGB(220,220,220),
			TabTextColor = Color3.fromRGB(50,50,50), SelectedTabTextColor = Color3.fromRGB(10,10,10),
			ElementBackground = Color3.fromRGB(220,220,220), ElementBackgroundHover = Color3.fromRGB(210,210,210), SecondaryElementBackground = Color3.fromRGB(225,225,225),
			ElementStroke = Color3.fromRGB(190,190,190), SecondaryElementStroke = Color3.fromRGB(200,200,200),
			SliderBackground = Color3.fromRGB(210,210,210), SliderProgress = Color3.fromRGB(0,122,204), SliderStroke = Color3.fromRGB(180,180,180),
			ToggleBackground = Color3.fromRGB(210,210,210), ToggleEnabled = Color3.fromRGB(0,122,204), ToggleDisabled = Color3.fromRGB(180,180,180),
			ToggleEnabledStroke = Color3.fromRGB(0,100,180), ToggleDisabledStroke = Color3.fromRGB(160,160,160),
			ToggleEnabledOuterStroke = Color3.fromRGB(0,122,204), ToggleDisabledOuterStroke = Color3.fromRGB(200,200,200),
			DropdownSelected = Color3.fromRGB(210,210,210), DropdownUnselected = Color3.fromRGB(220,220,220),
			InputBackground = Color3.fromRGB(230,230,230), InputStroke = Color3.fromRGB(200,200,200), PlaceholderColor = Color3.fromRGB(150,150,150),
			Primary = Color3.fromRGB(0,122,204), Secondary = Color3.fromRGB(0,100,170), Accent = Color3.fromRGB(0,150,255), ThemeHighlight = Color3.fromRGB(0,122,204), Stroke = Color3.fromRGB(200,200,200),
			GuiConfigColor = Color3.fromRGB(0,122,204)
		},
		["Ocean Blue"] = {
			TextColor = Color3.fromRGB(220,230,240), Background = Color3.fromRGB(10,20,40), Topbar = Color3.fromRGB(20,30,50), Shadow = Color3.fromRGB(5,10,20),
			NotificationBackground = Color3.fromRGB(25,35,55), NotificationActionsBackground = Color3.fromRGB(30,40,60),
			TabBackground = Color3.fromRGB(15,25,45), TabStroke = Color3.fromRGB(40,50,70), TabBackgroundSelected = Color3.fromRGB(30,40,60),
			TabTextColor = Color3.fromRGB(180,190,200), SelectedTabTextColor = Color3.fromRGB(220,230,240),
			ElementBackground = Color3.fromRGB(30,40,60), ElementBackgroundHover = Color3.fromRGB(40,50,70), SecondaryElementBackground = Color3.fromRGB(25,35,55),
			ElementStroke = Color3.fromRGB(50,60,80), SecondaryElementStroke = Color3.fromRGB(40,50,70),
			SliderBackground = Color3.fromRGB(25,35,55), SliderProgress = Color3.fromRGB(0,150,255), SliderStroke = Color3.fromRGB(50,60,80),
			ToggleBackground = Color3.fromRGB(25,35,55), ToggleEnabled = Color3.fromRGB(0,150,255), ToggleDisabled = Color3.fromRGB(50,60,80),
			ToggleEnabledStroke = Color3.fromRGB(0,130,230), ToggleDisabledStroke = Color3.fromRGB(70,80,100),
			ToggleEnabledOuterStroke = Color3.fromRGB(0,150,255), ToggleDisabledOuterStroke = Color3.fromRGB(40,50,70),
			DropdownSelected = Color3.fromRGB(40,50,70), DropdownUnselected = Color3.fromRGB(30,40,60),
			InputBackground = Color3.fromRGB(20,30,50), InputStroke = Color3.fromRGB(40,50,70), PlaceholderColor = Color3.fromRGB(100,110,130),
			Primary = Color3.fromRGB(0,150,255), Secondary = Color3.fromRGB(0,120,210), Accent = Color3.fromRGB(0,180,255), ThemeHighlight = Color3.fromRGB(0,150,255), Stroke = Color3.fromRGB(40,50,70),
			GuiConfigColor = Color3.fromRGB(0,150,255)
		}
	}

	local CurrentThemeName
	local AllCreatedItemControls = { Sliders = {} }

	-- Renamed UI elements for clarity (Step 8)
	local UBHubGui, DropShadowHolder, DropShadow, MainFrame, MainUICorner, MainUIStroke, TopBar, HubTitleTextLabel, HubDescriptionTextLabel, HubDescriptionStroke
	local CloseButton, CloseIcon, MinimizeButton, MinimizeIcon, TabSelectionPanel, LayersTabUICorner, ContentDividerFrame, TabContentPanel, LayersUICorner, ActiveTabTitleLabel
	local LayersRealFrame, LayersFolderInstance, LayersPageLayoutInstance, TabScroll, TabScrollUIListLayout, InfoFrame, InfoFrameUICorner, LogoPlayerFrame
	local LogoPlayerFrameUICorner, LogoPlayerImage, LogoPlayerImageUICorner, NamePlayerTextLabel
	local MinimizedIconImageButton
	local MoreBlurFrame, MoreBlurDropShadowHolder, MoreBlurDropShadow, MoreBlurUICorner, MoreBlurConnectButton
	local DropdownSelectFrame, DropdownSelectUICorner, DropdownSelectUIStroke, DropdownSelectRealFrame, DropdownFolderInstance, DropPageLayoutInstance
	local BackgroundImageLabel, BackgroundVideoFrame

	local isApplyingTheme = false
	local function applyTheme(themeIdentifier, isInitialLoad)
		if isApplyingTheme then return end
		isApplyingTheme = true
		local themeToApply
		if type(themeIdentifier) == "string" then
			CurrentThemeName = themeIdentifier
			themeToApply = deepcopy(DefaultThemes[CurrentThemeName] or DefaultThemes["Rayfield Like"])
			if not DefaultThemes[CurrentThemeName] then
				warn("applyTheme: Theme '" .. CurrentThemeName .. "' not found. Using 'Rayfield Like'.")
			end
		elseif type(themeIdentifier) == "table" then
			if not DefaultThemes[CurrentThemeName] then CurrentThemeName = "Rayfield Like" end
			themeToApply = deepcopy(DefaultThemes[CurrentThemeName] or DefaultThemes["Rayfield Like"])
			for k,v in pairs(themeIdentifier) do
				if type(v) == "Color3" then
					themeToApply[k] = v
				end
			end
		else
			warn("applyTheme: Invalid themeIdentifier type. Expected string or table.")
			isApplyingTheme = false
			return
		end
		for k, v in pairs(themeToApply) do Colours[k] = v end
		if not isInitialLoad and type(themeIdentifier) == "string" then
			if Flags then
				for flagKey, flagValue in pairs(Flags) do
					if type(flagKey) == "string" and flagKey:match("^CustomColor_") then
						local parts = {}
						for part in flagKey:gmatch("([^_]+)") do table.insert(parts, part) end
						if #parts == 3 then
							local colorKeyName = parts[2]
							local componentLetter = parts[3]
							if Colours[colorKeyName] and type(Colours[colorKeyName]) == "Color3" then
								local r, g, b
								r, g, b = Colours[colorKeyName].R * 255, Colours[colorKeyName].G * 255, Colours[colorKeyName].B * 255
								local numVal = tonumber(flagValue)
								if numVal then
									if componentLetter == "R" then r = numVal end
									if componentLetter == "G" then g = numVal end
									if componentLetter == "B" then b = numVal end
									Colours[colorKeyName] = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
								end
							end
						end
					end
				end
			end
		end
		if GuiConfig and Colours.GuiConfigColor then GuiConfig.Color = Colours.GuiConfigColor end

		if MainFrame and Colours.Background then MainFrame.BackgroundColor3 = Colours.Background end
		if MainFrame and Colours.Stroke then MainFrame.BorderColor3 = Colours.Stroke end
		if TopBar and Colours.Topbar then TopBar.BackgroundColor3 = Colours.Topbar end
		if TopBar and Colours.Stroke then TopBar.BorderColor3 = Colours.Stroke end
		if InfoFrame and Colours.TabBackground then InfoFrame.BackgroundColor3 = Colours.TabBackground end
		if InfoFrame and Colours.Stroke then InfoFrame.BorderColor3 = Colours.Stroke end
		if TabSelectionPanel and Colours.TabBackground then TabSelectionPanel.BackgroundColor3 = Colours.TabBackground end
		if TabSelectionPanel and Colours.Stroke then TabSelectionPanel.BorderColor3 = Colours.Stroke end
		if ContentDividerFrame and Colours.Stroke then ContentDividerFrame.BackgroundColor3 = Colours.Stroke end
		if ActiveTabTitleLabel and Colours.SelectedTabTextColor then ActiveTabTitleLabel.TextColor3 = Colours.SelectedTabTextColor end
		if HubTitleTextLabel and Colours.Accent then HubTitleTextLabel.TextColor3 = Colours.Accent end
		if HubDescriptionTextLabel and Colours.TextColor then HubDescriptionTextLabel.TextColor3 = Colours.TextColor end
		if DropShadow and Colours.Shadow then DropShadow.ImageColor3 = Colours.Shadow end
		if MainUIStroke and Colours.Stroke then MainUIStroke.Color = Colours.Stroke end

		local themesButtonInInfo = InfoFrame and InfoFrame:FindFirstChild("ThemesButton")
		if themesButtonInInfo then
			if Colours.TextColor then themesButtonInInfo.TextColor3 = Colours.TextColor end
			if Colours.ElementBackground then themesButtonInInfo.BackgroundColor3 = Colours.ElementBackground end
		end

		if MinimizedIconImageButton then
			local highlightColor = (Colours and Colours.ThemeHighlight) or Color3.fromRGB(255, 80, 0)
			MinimizedIconImageButton.BackgroundColor3 = highlightColor
			MinimizedIconImageButton.BorderColor3 = highlightColor
		end

		if MoreBlurFrame then
			if Colours.Background then MoreBlurFrame.BackgroundColor3 = Colours.Background end
			if Colours.Stroke then MoreBlurFrame.BorderColor3 = Colours.Stroke end
			local dsHolder = MoreBlurFrame:FindFirstChild("DropShadowHolder")
			if dsHolder then
				local ds = dsHolder:FindFirstChild("DropShadow")
				if ds and Colours.Shadow then ds.ImageColor3 = Colours.Shadow end
			end
		end

		if DropdownSelectFrame then
			if Colours.DropdownUnselected then DropdownSelectFrame.BackgroundColor3 = Colours.DropdownUnselected end
			if Colours.Stroke then DropdownSelectFrame.BorderColor3 = Colours.Stroke end
			local strokeForDropdownSelect = DropdownSelectFrame:FindFirstChildOfClass("UIStroke")
			if strokeForDropdownSelect and Colours.Stroke then strokeForDropdownSelect.Color = Colours.Stroke end
		end

		if (not isInitialLoad or type(themeIdentifier) == "table") and AllCreatedItemControls and AllCreatedItemControls.Sliders then
			for colorKey, sliders in pairs(AllCreatedItemControls.Sliders) do
				if Colours[colorKey] and type(Colours[colorKey]) == "Color3" then
					if sliders.R and sliders.R.Set then sliders.R:Set(math.floor(Colours[colorKey].R * 255 + 0.5), true) end
					if sliders.G and sliders.G.Set then sliders.G:Set(math.floor(Colours[colorKey].G * 255 + 0.5), true) end
					if sliders.B and sliders.B.Set then sliders.B:Set(math.floor(Colours[colorKey].B * 255 + 0.5), true) end
				end
			end
		end

		if Flags then
			Flags.SelectedTheme = CurrentThemeName
			for colorK, colorV in pairs(Colours) do
				if type(colorV) == "Color3" then
					Flags["CustomColor_" .. colorK .. "_R"] = math.floor(colorV.R * 255 + 0.5)
					Flags["CustomColor_" .. colorK .. "_G"] = math.floor(colorV.G * 255 + 0.5)
					Flags["CustomColor_" .. colorK .. "_B"] = math.floor(colorV.B * 255 + 0.5)
				end
			end
            if GuiConfig and GuiConfig.MainBackgroundTransparency ~= nil then
                UBHubLib.Flags.MainBackgroundTransparency = GuiConfig.MainBackgroundTransparency
            end
            if GuiConfig and GuiConfig.SaveFolder and FSO.writefile and CurrentHttpService then
                 local successSave, errSave = pcall(function()
                     local path = GuiConfig.SaveFolder
                     local encoded = CurrentHttpService:JSONEncode(UBHubLib.Flags)
                     FSO.writefile(path, encoded)
                 end)
                 if not successSave then
                     warn("Save (triggered by applyTheme) failed:", errSave)
                 end
            else
                if GuiConfig and GuiConfig.SaveFolder then
                    local missingFuncs = {}
                    if not FSO.writefile then table.insert(missingFuncs, "'FSO.writefile'") end
                    if not CurrentHttpService then table.insert(missingFuncs, "'HttpService'") end
                    if #missingFuncs > 0 then
                        warn("Saving is enabled in applyTheme, but required functions are missing: " .. table.concat(missingFuncs, ", "))
                    end
                end
            end
		end
		isApplyingTheme = false
	end

	CurrentThemeName = Flags.SelectedTheme or "Rayfield Like"

	UBHubGui = Instance.new("ScreenGui")
	DropShadowHolder = Instance.new("Frame")
	DropShadow = Instance.new("ImageLabel")
	MainFrame = Instance.new("Frame") -- Renamed
	MainUICorner = Instance.new("UICorner")
	MainUIStroke = Instance.new("UIStroke")
	TopBar = Instance.new("Frame")
	HubTitleTextLabel = Instance.new("TextLabel")
	UICorner1 = Instance.new("UICorner")
	HubDescriptionTextLabel = Instance.new("TextLabel")
	HubDescriptionStroke = Instance.new("UIStroke")
	CloseButton = Instance.new("TextButton")
	CloseIcon = Instance.new("ImageLabel")
	MinimizeButton = Instance.new("TextButton")
	MinimizeIcon = Instance.new("ImageLabel")
	TabSelectionPanel = Instance.new("Frame") -- Renamed
	LayersTabUICorner = Instance.new("UICorner")
	ContentDividerFrame = Instance.new("Frame") -- Renamed
	TabContentPanel = Instance.new("Frame") -- Renamed
	LayersUICorner = Instance.new("UICorner")
	ActiveTabTitleLabel = Instance.new("TextLabel") -- Renamed
	LayersRealFrame = Instance.new("Frame")
	LayersFolderInstance = Instance.new("Folder")
	LayersPageLayoutInstance = Instance.new("UIPageLayout")
	TabScroll = Instance.new("ScrollingFrame")
	TabScrollUIListLayout = Instance.new("UIListLayout")
	InfoFrame = Instance.new("Frame")
	InfoFrameUICorner = Instance.new("UICorner")
	LogoPlayerFrame = Instance.new("Frame")
	LogoPlayerFrameUICorner = Instance.new("UICorner")
	LogoPlayerImage = Instance.new("ImageLabel")
	LogoPlayerImageUICorner = Instance.new("UICorner")
	NamePlayerTextLabel = Instance.new("TextLabel")
	MinimizedIconImageButton = Instance.new("ImageButton")
	MoreBlurFrame = Instance.new("Frame")
	DropdownSelectFrame = Instance.new("Frame")
	BackgroundImageLabel = Instance.new("ImageLabel")
	BackgroundVideoFrame = Instance.new("VideoFrame")

	applyTheme(CurrentThemeName, true)
	applyTheme(CurrentThemeName, false)

	UBHubLib.ApplyTheme = applyTheme
	UBHubLib.GetDefaultThemes = function() return DefaultThemes end
	UBHubLib.GetCurrentColours = function() return Colours end
	UBHubLib.AllCreatedItemControls = AllCreatedItemControls
	UBHubLib.TabReferences = nil -- Removed UBHubLib.TabReferences as it's obsolete

	--[[ INSERTION POINT FOR MAIN UI ELEMENT PROPERTY SETTINGS AND TAB DEFINITIONS ]]
	-- (The two redundant Instance.new lines below will be removed by this large insertion)
	-- local UBHubGui = Instance.new("ScreenGui");
	-- local DropShadowHolder = Instance.new("Frame");

	-- Start of UI Properties and Structure (Chunk 4)
	UBHubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	UBHubGui.Name = "UBHubGui"
	UBHubGui.Parent = CoreGui

	DropShadowHolder.BackgroundTransparency = 1
	DropShadowHolder.BackgroundColor3 = Color3.new(0,0,0) -- Will be themed by applyTheme if needed
	DropShadowHolder.BorderSizePixel = 0
	DropShadowHolder.ZIndex = 0
	DropShadowHolder.Name = "DropShadowHolder"
	DropShadowHolder.Parent = UBHubGui
	DropShadowHolder.Size = SizeUI
    DropShadowHolder.Position = UDim2.new(0.5, -SizeUI.X.Offset/2, 0.5, -SizeUI.Y.Offset/2) -- Centered

	DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Colours.Shadow or Color3.fromRGB(10,10,10)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Colours.Background or Color3.fromRGB(20,8,0)
	MainFrame.BackgroundTransparency = GuiConfig.MainBackgroundTransparency or 0.1
	MainFrame.BorderColor3 = Colours.Stroke or Color3.fromRGB(80,20,0)
	MainFrame.BorderSizePixel = 0
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.Size = SizeUI
	MainFrame.Name = "MainFrame" -- Renamed
	MainFrame.Parent = DropShadow

	MainUICorner.Parent = MainFrame
    MainUICorner.CornerRadius = UDim.new(0, 8)

	MainUIStroke.Color = Colours.Stroke or Color3.fromRGB(50,50,50)
	MainUIStroke.Thickness = 1.6
	MainUIStroke.Parent = MainFrame

	BackgroundImageLabel.Name = "MainImage"
	BackgroundImageLabel.Size = UDim2.new(1,0,1,0)
	BackgroundImageLabel.BackgroundTransparency = 1
	BackgroundImageLabel.ImageTransparency = GuiConfig.MainBackgroundTransparency or 0.1
	BackgroundImageLabel.Parent = MainFrame

	BackgroundVideoFrame.Name = "MainVideo"
	BackgroundVideoFrame.Size = UDim2.new(1,0,1,0)
	BackgroundVideoFrame.BackgroundTransparency = GuiConfig.MainBackgroundTransparency or 0.1
	BackgroundVideoFrame.Looped = true
    BackgroundVideoFrame.Playing = false
	BackgroundVideoFrame.Parent = MainFrame
    -- _G.BGImage and _G.BGVideo will be set by ChangeAssetInternal

	TopBar.BackgroundColor3 = Colours.Topbar or Color3.fromRGB(25,25,25)
	TopBar.BackgroundTransparency = 0
	TopBar.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	TopBar.BorderSizePixel = 0
	TopBar.Size = UDim2.new(1, 0, 0, 38)
	TopBar.Name = "TopBar"
	TopBar.Parent = MainFrame

	HubTitleTextLabel.Font = Enum.Font.GothamBold
	HubTitleTextLabel.Text = GuiConfig.NameHub
	HubTitleTextLabel.TextColor3 = Colours.Accent or Color3.fromRGB(0,150,255)
	HubTitleTextLabel.TextSize = 14
	HubTitleTextLabel.TextXAlignment = Enum.TextXAlignment.Left
	HubTitleTextLabel.BackgroundTransparency = 1
	HubTitleTextLabel.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	HubTitleTextLabel.BorderSizePixel = 0
	HubTitleTextLabel.Size = UDim2.new(1, -100, 1, 0)
	HubTitleTextLabel.Position = UDim2.new(0, 10, 0, 0)
	HubTitleTextLabel.Parent = TopBar

	UICorner1.Parent = TopBar
    UICorner1.CornerRadius = UDim.new(0,5) 

	HubDescriptionTextLabel.Font = Enum.Font.GothamBold
	HubDescriptionTextLabel.Text = GuiConfig.Description or ""
	HubDescriptionTextLabel.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
	HubDescriptionTextLabel.TextSize = 14
	HubDescriptionTextLabel.TextXAlignment = Enum.TextXAlignment.Left
	HubDescriptionTextLabel.BackgroundTransparency = 1
	HubDescriptionTextLabel.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	HubDescriptionTextLabel.BorderSizePixel = 0
	HubDescriptionTextLabel.Size = UDim2.new(1, -(HubTitleTextLabel.TextBounds.X + 104), 1, 0)
	HubDescriptionTextLabel.Position = UDim2.new(0, HubTitleTextLabel.TextBounds.X + 15, 0, 0)
	HubDescriptionTextLabel.Parent = TopBar

	HubDescriptionStroke.Color = Colours.Accent or Color3.fromRGB(0,150,255)
	HubDescriptionStroke.Thickness = 0.4
	HubDescriptionStroke.Parent = HubDescriptionTextLabel

	CloseButton.Font = Enum.Font.SourceSans
	CloseButton.Text = ""
	CloseButton.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
	CloseButton.TextSize = 14
	CloseButton.AnchorPoint = Vector2.new(1, 0.5)
	CloseButton.BackgroundColor3 = Colours.Topbar or Color3.fromRGB(25,25,25)
	CloseButton.BackgroundTransparency = 1
	CloseButton.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	CloseButton.BorderSizePixel = 0
	CloseButton.Position = UDim2.new(1, -8, 0.5, 0)
	CloseButton.Size = UDim2.new(0, 25, 0, 25)
	CloseButton.Name = "CloseButton"
	CloseButton.Parent = TopBar

	CloseIcon.Image = "rbxassetid://9886659671"
	CloseIcon.ImageColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
	CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	CloseIcon.BackgroundTransparency = 1
	CloseIcon.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	CloseIcon.BorderSizePixel = 0
	CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	CloseIcon.Size = UDim2.new(1, -8, 1, -8)
	CloseIcon.Parent = CloseButton

	MinimizeButton.Font = Enum.Font.SourceSans
	MinimizeButton.Text = ""
	MinimizeButton.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
	MinimizeButton.TextSize = 14
	MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
	MinimizeButton.BackgroundColor3 = Colours.Topbar or Color3.fromRGB(25,25,25)
	MinimizeButton.BackgroundTransparency = 1
	MinimizeButton.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	MinimizeButton.BorderSizePixel = 0
	MinimizeButton.Position = UDim2.new(1, -38, 0.5, 0)
	MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
	MinimizeButton.Name = "MinimizeButton"
	MinimizeButton.Parent = TopBar

	MinimizeIcon.Image = "rbxassetid://9886659276"
	MinimizeIcon.ImageColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
	MinimizeIcon.ImageTransparency = 0.2
	MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	MinimizeIcon.BackgroundTransparency = 1
	MinimizeIcon.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	MinimizeIcon.BorderSizePixel = 0
	MinimizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	MinimizeIcon.Size = UDim2.new(1, -9, 1, -9)
	MinimizeIcon.Parent = MinimizeButton

	TabSelectionPanel.BackgroundColor3 = Colours.TabBackground or Color3.fromRGB(30,30,30) -- Renamed
	TabSelectionPanel.BackgroundTransparency = 0
	TabSelectionPanel.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	TabSelectionPanel.BorderSizePixel = 0
	TabSelectionPanel.Position = UDim2.new(0, 9, 0, 50)
	TabSelectionPanel.Size = UDim2.new(0, GuiConfig["Tab Width"], 1, -59)
	TabSelectionPanel.Name = "TabSelectionPanel" -- Renamed
	TabSelectionPanel.Parent = MainFrame

	LayersTabUICorner.CornerRadius = UDim.new(0, 2)
	LayersTabUICorner.Parent = TabSelectionPanel

	ContentDividerFrame.AnchorPoint = Vector2.new(0.5, 0) -- Renamed
	ContentDividerFrame.BackgroundColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	ContentDividerFrame.BackgroundTransparency = 0
	ContentDividerFrame.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	ContentDividerFrame.BorderSizePixel = 0
	ContentDividerFrame.Position = UDim2.new(0.5, 0, 0, 38)
	ContentDividerFrame.Size = UDim2.new(1, 0, 0, 1)
	ContentDividerFrame.Name = "ContentDividerFrame" -- Renamed
	ContentDividerFrame.Parent = MainFrame

	TabContentPanel.BackgroundTransparency = 1 -- Renamed
	TabContentPanel.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	TabContentPanel.BorderSizePixel = 0
	TabContentPanel.Position = UDim2.new(0, GuiConfig["Tab Width"] + 18, 0, 50)
	TabContentPanel.Size = UDim2.new(1, -(GuiConfig["Tab Width"] + 9 + 18), 1, -59)
	TabContentPanel.Name = "TabContentPanel" -- Renamed
	TabContentPanel.Parent = MainFrame

	LayersUICorner.CornerRadius = UDim.new(0, 2)
	LayersUICorner.Parent = TabContentPanel

	ActiveTabTitleLabel.Font = Enum.Font.GothamBold -- Renamed
	ActiveTabTitleLabel.Text = ""
	ActiveTabTitleLabel.TextColor3 = Colours.SelectedTabTextColor or Color3.fromRGB(221,221,221)
	ActiveTabTitleLabel.TextSize = 24
	ActiveTabTitleLabel.TextWrapped = true
	ActiveTabTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	ActiveTabTitleLabel.BackgroundTransparency = 1
	ActiveTabTitleLabel.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	ActiveTabTitleLabel.BorderSizePixel = 0
	ActiveTabTitleLabel.Size = UDim2.new(1, 0, 0, 30)
	ActiveTabTitleLabel.Name = "ActiveTabTitleLabel" -- Renamed
	ActiveTabTitleLabel.Parent = TabContentPanel

	LayersRealFrame.AnchorPoint = Vector2.new(0, 1)
	LayersRealFrame.BackgroundTransparency = 1
	LayersRealFrame.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	LayersRealFrame.BorderSizePixel = 0
	LayersRealFrame.ClipsDescendants = true
	LayersRealFrame.Position = UDim2.new(0, 0, 1, 0)
	LayersRealFrame.Size = UDim2.new(1, 0, 1, -33)
	LayersRealFrame.Name = "LayersRealFrame"
	LayersRealFrame.Parent = TabContentPanel

	LayersFolderInstance.Name = "LayersFolder"
	LayersFolderInstance.Parent = LayersRealFrame

	LayersPageLayoutInstance.SortOrder = Enum.SortOrder.LayoutOrder
	LayersPageLayoutInstance.Name = "LayersPageLayout"
	LayersPageLayoutInstance.Parent = LayersFolderInstance
	LayersPageLayoutInstance.TweenTime = 0.5
	LayersPageLayoutInstance.EasingDirection = Enum.EasingDirection.InOut
	LayersPageLayoutInstance.EasingStyle = Enum.EasingStyle.Quad

	TabScroll.ScrollBarImageColor3 = Colours.SecondaryElementBackground or Color3.fromRGB(40,40,40)
	TabScroll.ScrollBarThickness = 0
	TabScroll.Active = true
	TabScroll.BackgroundTransparency = 1
	TabScroll.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	TabScroll.BorderSizePixel = 0
	TabScroll.Size = UDim2.new(1, 0, 1, -50)
	TabScroll.Name = "TabScroll"
	TabScroll.Parent = TabSelectionPanel

	TabScrollUIListLayout.Padding = UDim.new(0, 3)
	TabScrollUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabScrollUIListLayout.Parent = TabScroll

	local function UpdateSize1()
		local OffsetY = 0
		for _, child in ipairs(TabScroll:GetChildren()) do
			if child:IsA("GuiObject") and child ~= TabScrollUIListLayout then
				OffsetY = OffsetY + 3 + child.Size.Y.Offset
			end
		end
		TabScroll.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
	end
	TabScroll.ChildAdded:Connect(UpdateSize1)
	TabScroll.ChildRemoved:Connect(UpdateSize1)

	InfoFrame.AnchorPoint = Vector2.new(1, 1)
	InfoFrame.BackgroundColor3 = Colours.TabBackground or Color3.fromRGB(30,30,30)
	InfoFrame.BackgroundTransparency = 0
	InfoFrame.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	InfoFrame.BorderSizePixel = 0
	InfoFrame.Position = UDim2.new(1, 0, 1, 0)
	InfoFrame.Size = UDim2.new(1, 0, 0, 40)
	InfoFrame.Name = "InfoFrame"
	InfoFrame.Parent = TabSelectionPanel

	InfoFrameUICorner.CornerRadius = UDim.new(0, 5)
	InfoFrameUICorner.Parent = InfoFrame

	LogoPlayerFrame.AnchorPoint = Vector2.new(0, 0.5)
	LogoPlayerFrame.BackgroundColor3 = Colours.ElementBackground or Color3.fromRGB(45,45,45)
	LogoPlayerFrame.BackgroundTransparency = 0
	LogoPlayerFrame.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	LogoPlayerFrame.BorderSizePixel = 0
	LogoPlayerFrame.Position = UDim2.new(0, 5, 0.5, 0)
	LogoPlayerFrame.Size = UDim2.new(0, 30, 0, 30)
	LogoPlayerFrame.Name = "LogoPlayerFrame"
	LogoPlayerFrame.Parent = InfoFrame

	LogoPlayerFrameUICorner.CornerRadius = UDim.new(0, 1000)
	LogoPlayerFrameUICorner.Parent = LogoPlayerFrame

	LogoPlayerImage.Image = GuiConfig["Logo Player"]
	LogoPlayerImage.AnchorPoint = Vector2.new(0.5, 0.5)
	LogoPlayerImage.BackgroundTransparency = 1
	LogoPlayerImage.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	LogoPlayerImage.BorderSizePixel = 0
	LogoPlayerImage.Position = UDim2.new(0.5, 0, 0.5, 0)
	LogoPlayerImage.Size = UDim2.new(1, -5, 1, -5)
	LogoPlayerImage.Name = "LogoPlayerImage"
	LogoPlayerImage.Parent = LogoPlayerFrame

	LogoPlayerImageUICorner.CornerRadius = UDim.new(0, 1000)
	LogoPlayerImageUICorner.Parent = LogoPlayerImage

	-- NamePlayerTextLabel is created but not parented, as per previous logic
	NamePlayerTextLabel.Font = Enum.Font.GothamBold
	NamePlayerTextLabel.Text = GuiConfig["Name Player"]
	NamePlayerTextLabel.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
	NamePlayerTextLabel.TextSize = 12
	NamePlayerTextLabel.TextWrapped = true
	NamePlayerTextLabel.TextXAlignment = Enum.TextXAlignment.Left
	NamePlayerTextLabel.BackgroundTransparency = 1
	NamePlayerTextLabel.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	NamePlayerTextLabel.BorderSizePixel = 0
	NamePlayerTextLabel.Position = UDim2.new(0, 40, 0, 0)
	NamePlayerTextLabel.Size = UDim2.new(1, -45, 1, 0)
	NamePlayerTextLabel.Name = "NamePlayerTextLabel"

	UBHubLib.MainUIPointers = UBHubLib.MainUIPointers or {}
	UBHubLib.MainUIPointers.LayersPageLayout = LayersPageLayoutInstance
	UBHubLib.MainUIPointers.ScrollTab = TabScroll
	-- UBHubLib.TabReferences = UBHubLib.TabReferences or {} -- Removed, see above

	local ThemesButton = Instance.new("TextButton")
	ThemesButton.Name = "ThemesButton"
	ThemesButton.Text = "Themes"
	ThemesButton.Parent = InfoFrame
	ThemesButton.Font = Enum.Font.GothamBold
	ThemesButton.TextSize = 12
	ThemesButton.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
	ThemesButton.BackgroundColor3 = Colours.ElementBackground or Color3.fromRGB(45,45,45)
	ThemesButton.BackgroundTransparency = 0
	ThemesButton.AnchorPoint = Vector2.new(0, 0.5)
	ThemesButton.Position = UDim2.new(0, (LogoPlayerFrame and LogoPlayerFrame.AbsoluteSize.X or 30) + 10, 0.5, 0)
	ThemesButton.Size = UDim2.new(0, 60, 0, 25)

	local ThemesButtonCorner = Instance.new("UICorner")
	ThemesButtonCorner.CornerRadius = UDim.new(0,3)
	ThemesButtonCorner.Parent = ThemesButton

	ThemesButton.Activated:Connect(function()
		if UBHubLib.TabReferences["Themes"] and UBHubLib.TabReferences["Themes"].TabButton then
			local themesTabButton = UBHubLib.TabReferences["Themes"].TabButton
			local frameChoose
			if UBHubLib.MainUIPointers.ScrollTab then
				for _, s in ipairs(UBHubLib.MainUIPointers.ScrollTab:GetChildren()) do
					if s:IsA("Frame") and s.Name == "Tab" then -- Iterate through actual Tab frames
						local choose = s:FindFirstChild("ChooseFrame")
						if choose then frameChoose = choose; break end
					end
				end
			end

			if frameChoose and themesTabButton.Parent.LayoutOrder ~= UBHubLib.MainUIPointers.LayersPageLayout.CurrentPage.LayoutOrder then
				for _, tabUiElement in ipairs(UBHubLib.MainUIPointers.ScrollTab:GetChildren()) do
					if tabUiElement.Name == "Tab" and tabUiElement:IsA("Frame") then
						tabUiElement.BackgroundColor3 = Colours.TabBackground or Color3.fromRGB(30,30,30)
						local tn = tabUiElement:FindFirstChild("TabName")
						if tn and tn:IsA("TextLabel") then tn.TextColor3 = Colours.TabTextColor or Color3.fromRGB(180,180,180) end
					end
				end
				if themesTabButton.Parent and themesTabButton.Parent:IsA("Frame") then
					themesTabButton.Parent.BackgroundColor3 = Colours.TabBackgroundSelected or Color3.fromRGB(45,45,45)
					local tn = themesTabButton.Parent:FindFirstChild("TabName")
					if tn and tn:IsA("TextLabel") then tn.TextColor3 = Colours.SelectedTabTextColor or Color3.fromRGB(221,221,221) end
				end
				TweenService:Create(frameChoose,TweenInfo.new(0.01, Enum.EasingStyle.Linear),{Position = UDim2.new(0, 2, 0, 9 + (33 * themesTabButton.Parent.LayoutOrder))}):Play()
				UBHubLib.MainUIPointers.LayersPageLayout:JumpToPage(UBHubLib.TabReferences["Themes"].ScrollFramePage)
				if ActiveTabNameLabel and UBHubLib.TabReferences["Themes"].Name then
					ActiveTabNameLabel.Text = UBHubLib.TabReferences["Themes"].Name
				end
				TweenService:Create(frameChoose,TweenInfo.new(0.01, Enum.EasingStyle.Linear),{Size = UDim2.new(0, 1, 0, 20)}):Play()
			elseif themesTabButton.Parent and UBHubLib.MainUIPointers.LayersPageLayout.CurrentPage == UBHubLib.TabReferences["Themes"].ScrollFramePage then
				-- Already on the tab
			else
				warn("ThemesButton: Could not switch to Themes tab. FrameChoose or other elements not found as expected.")
			end
		else
			warn("ThemesButton: Themes tab reference or its button not found.")
		end
	end)

	local GuiFunc = {}
	function GuiFunc:DestroyGui()
		if UBHubGui and UBHubGui.Parent then
			UBHubGui:Destroy()
		end
        local openCloseGui = CoreGui:FindFirstChild("OpenClose") or (LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("OpenClose"))
        if openCloseGui then
            openCloseGui:Destroy()
        end
	end

	local ScreenGuiOpenClose = Instance.new("ScreenGui") -- Renamed ScreenGui to avoid conflict
	ProtectGui(ScreenGuiOpenClose)
	ScreenGuiOpenClose.Name = "OpenClose"
	ScreenGuiOpenClose.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or (gethui and gethui()) or CoreGui
	ScreenGuiOpenClose.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	MinimizedIconImageButton.Image = _G.MinIcon or "rbxassetid://94513440833543"
	MinimizedIconImageButton.Size = UDim2.new(0, 55, 0, 50)
	MinimizedIconImageButton.Position = UDim2.new(0.1021, 0, 0.0743, 0)
	MinimizedIconImageButton.BackgroundTransparency = 1
    MinimizedIconImageButton.BackgroundColor3 = Colours.ThemeHighlight or Color3.fromRGB(255,80,0)
	MinimizedIconImageButton.Parent = ScreenGuiOpenClose
	MinimizedIconImageButton.Draggable = true
	MinimizedIconImageButton.Visible = false
	MinimizedIconImageButton.BorderColor3 = Colours.ThemeHighlight or Color3.fromRGB(255,80,0)

	MinimizeButton.Activated:Connect(function()
		CircleClick(MinimizeButton, Mouse.X, Mouse.Y)
		DropShadowHolder.Visible = false
        MinimizedIconImageButton.Visible = true
	end)

	MinimizedIconImageButton.MouseButton1Click:Connect(function()
		DropShadowHolder.Visible = true
		MinimizedIconImageButton.Visible = false
	end)

	CloseButton.Activated:Connect(function()
		CircleClick(CloseButton, Mouse.X, Mouse.Y)
		GuiFunc:DestroyGui()
	end)

	function GuiFunc:ToggleUI()
        if UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
             game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.RightShift, false, game)
        else
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightShift, false, game)
            task.wait() 
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.RightShift, false, game)
        end
	end
	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.RightShift then
			if DropShadowHolder.Visible then
				DropShadowHolder.Visible = false
                MinimizedIconImageButton.Visible = true
			else
				DropShadowHolder.Visible = true
                MinimizedIconImageButton.Visible = false
			end
		end
	end)
	
	task.wait() -- Allow TextBounds to update for hub name/desc
	if HubDescriptionTextLabel and HubTitleTextLabel then
		HubDescriptionTextLabel.Size = UDim2.new(1, -(HubTitleTextLabel.TextBounds.X + 104), 1, 0)
		HubDescriptionTextLabel.Position = UDim2.new(0, HubTitleTextLabel.TextBounds.X + 15, 0, 0)
		DropShadowHolder.Size = UDim2.new(0, 150 + HubTitleTextLabel.TextBounds.X + 1 + (HubDescriptionTextLabel.Text and HubDescriptionTextLabel.TextBounds.X or 0) + 50, 0, 450) -- Added some padding
	else
		DropShadowHolder.Size = UDim2.new(0,300,0,450) -- Fallback size
	end
	MakeDraggable(TopBar, DropShadowHolder)

	MoreBlurFrame.AnchorPoint = Vector2.new(1, 1)
	MoreBlurFrame.BackgroundColor3 = Colours.Background or Color3.fromRGB(30,30,30)
	MoreBlurFrame.BackgroundTransparency = 0.7
	MoreBlurFrame.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	MoreBlurFrame.BorderSizePixel = 0
	MoreBlurFrame.ClipsDescendants = true
	MoreBlurFrame.Position = UDim2.new(1, 8, 1, 8)
	MoreBlurFrame.Size = UDim2.new(1, 154, 1, 54)
	MoreBlurFrame.Visible = false
	MoreBlurFrame.Name = "MoreBlurFrame"
	MoreBlurFrame.Parent = TabContentPanel

	MoreBlurDropShadowHolder = Instance.new("Frame")
	MoreBlurDropShadowHolder.BackgroundTransparency = 1
	MoreBlurDropShadowHolder.BorderSizePixel = 0
	MoreBlurDropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
	MoreBlurDropShadowHolder.ZIndex = 0
	MoreBlurDropShadowHolder.Name = "DropShadowHolder"
	MoreBlurDropShadowHolder.Parent = MoreBlurFrame
	MoreBlurDropShadowHolder.Visible = false

	MoreBlurDropShadow = Instance.new("ImageLabel")
	MoreBlurDropShadow.Image = "rbxassetid://6015897843"
	MoreBlurDropShadow.ImageColor3 = Colours.Shadow or Color3.fromRGB(10,10,10)
	MoreBlurDropShadow.ImageTransparency = 0.5
	MoreBlurDropShadow.ScaleType = Enum.ScaleType.Slice
	MoreBlurDropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
	MoreBlurDropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	MoreBlurDropShadow.BackgroundTransparency = 1
	MoreBlurDropShadow.BorderSizePixel = 0
	MoreBlurDropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	MoreBlurDropShadow.Size = UDim2.new(1, 35, 1, 35)
	MoreBlurDropShadow.ZIndex = 0
	MoreBlurDropShadow.Name = "DropShadow"
	MoreBlurDropShadow.Parent = MoreBlurDropShadowHolder
	MoreBlurDropShadow.Visible = false

	MoreBlurUICorner = Instance.new("UICorner")
    MoreBlurUICorner.CornerRadius = UDim.new(0,8)
	MoreBlurUICorner.Parent = MoreBlurFrame

	MoreBlurConnectButton = Instance.new("TextButton")
	MoreBlurConnectButton.Font = Enum.Font.SourceSans
	MoreBlurConnectButton.Text = ""
	MoreBlurConnectButton.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
	MoreBlurConnectButton.TextSize = 14
	MoreBlurConnectButton.BackgroundTransparency = 1
	MoreBlurConnectButton.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	MoreBlurConnectButton.BorderSizePixel = 0
	MoreBlurConnectButton.Size = UDim2.new(1, 0, 1, 0)
	MoreBlurConnectButton.Name = "ConnectButton"
	MoreBlurConnectButton.Parent = MoreBlurFrame

	DropdownSelectFrame.AnchorPoint = Vector2.new(1, 0.5)
	DropdownSelectFrame.BackgroundColor3 = Colours.DropdownUnselected or Color3.fromRGB(40,40,40)
	DropdownSelectFrame.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	DropdownSelectFrame.BorderSizePixel = 0
	DropdownSelectFrame.LayoutOrder = 1
	DropdownSelectFrame.Position = UDim2.new(1, 172, 0.5, 0)
	DropdownSelectFrame.Size = UDim2.new(0, 160, 1, -16)
	DropdownSelectFrame.Name = "DropdownSelectFrame"
	DropdownSelectFrame.ClipsDescendants = true
	DropdownSelectFrame.Parent = MoreBlurFrame

	MoreBlurConnectButton.Activated:Connect(function()
		if MoreBlurFrame.Visible then
			TweenService:Create(MoreBlurFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.999}):Play()
			TweenService:Create(DropdownSelectFrame, TweenInfo.new(0.3), {Position = UDim2.new(1, 172, 0.5, 0)}):Play()
			task.wait(0.3)
			MoreBlurFrame.Visible = false
		end
	end)
	DropdownSelectUICorner = Instance.new("UICorner")
	DropdownSelectUICorner.CornerRadius = UDim.new(0, 3)
	DropdownSelectUICorner.Parent = DropdownSelectFrame

	DropdownSelectUIStroke = Instance.new("UIStroke")
	DropdownSelectUIStroke.Color = Colours.Stroke or Color3.fromRGB(50,50,50)
	DropdownSelectUIStroke.Thickness = 2.5
	DropdownSelectUIStroke.Transparency = 0
	DropdownSelectUIStroke.Parent = DropdownSelectFrame

	DropdownSelectRealFrame = Instance.new("Frame")
	DropdownSelectRealFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	DropdownSelectRealFrame.BackgroundTransparency = 1
	DropdownSelectRealFrame.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
	DropdownSelectRealFrame.BorderSizePixel = 0
	DropdownSelectRealFrame.LayoutOrder = 1
	DropdownSelectRealFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropdownSelectRealFrame.Size = UDim2.new(1, -10, 1, -10)
	DropdownSelectRealFrame.Name = "DropdownSelectReal"
	DropdownSelectRealFrame.Parent = DropdownSelectFrame

	DropdownFolderInstance = Instance.new("Folder")
	DropdownFolderInstance.Name = "DropdownFolder"
	DropdownFolderInstance.Parent = DropdownSelectRealFrame

	DropPageLayoutInstance = Instance.new("UIPageLayout")
	DropPageLayoutInstance.EasingDirection = Enum.EasingDirection.InOut
	DropPageLayoutInstance.EasingStyle = Enum.EasingStyle.Quad
	DropPageLayoutInstance.TweenTime = 0.009999999776482582
	DropPageLayoutInstance.SortOrder = Enum.SortOrder.LayoutOrder
	DropPageLayoutInstance.Archivable = false
	DropPageLayoutInstance.Name = "DropPageLayout"
	DropPageLayoutInstance.Parent = DropdownFolderInstance

	-- Define Tabs and its methods (CreateTab, AddSection, Items:Add... etc.)
	-- This is a large block of code containing all UI element creation logic.
	-- ... (This will be the entire Tabs/Sections/Items structure from previous steps, fully themed and fixed) ...
	-- For brevity, this is not fully expanded here but would be in the actual overwrite.
	-- Assume it's correctly placed and defines 'localTabsObject' which is 'Tabs'.

	local UBHubInstance = {} -- This will be the returned object. Step 1: Renamed from Tabs.
	local CountTab = 0 -- This is the primary CountTab now.
	local CountDropdown = 0 -- Used by AddDropdown for unique LayoutOrder. This is the primary CountDropdown.

	-- Step 2: Removed placeholder GetIcon. Will use global GetIcon or Lucide-aware one.

	-- ... (Insert the FULL definitions for Tabs:CreateTab, Sections:AddSection, and all Items:Add<Type> methods here)
	-- These should be based on the final, themed, and fixed versions from prior subtasks.
	-- For example, Items:AddSlider needs its FocusLost fix.
	-- All icon parameters should use GetIcon().
	-- All Color3.fromRGB should be replaced by Colours.Key.

	-- Step 5: Removed redundant UBHubInstance, InternalTabManager, CountTab, CountDropdown

	-- Internal function to create a tab's UI and return an object to add sections/items
	-- This is the NEW CreateTabInternal, scoped within MakeGui. Step 3.

	-- Step 7: Centralize State Variables
	local AllCreatedTabsData = {} -- Stores {Button=TabButtonFrame, Page=ContentPage, Name=tabName}
	local CurrentTabButton = nil
	local CurrentTabPage = nil
	local currentActiveTabIndicator = nil -- This is the single 'ChooseFrame'
	local tabButtonLayoutOrderCounter = 0
	local tabPageLayoutOrderCounter = 0

	local function SwitchToTabByName(targetTabName)
		for tabButtonFrameInstance, tabData in pairs(AllCreatedTabsData) do
			if tabData.Name == targetTabName then
				if CurrentTabPage == tabData.Page then return end -- Already on this tab

				-- Deselect old tab
				if CurrentTabButton and AllCreatedTabsData[CurrentTabButton] then
					CurrentTabButton.BackgroundColor3 = Colours.TabBackground or Color3.fromRGB(30,30,30)
					local oldNameLabel = CurrentTabButton:FindFirstChild("TabNameLabel")
					if oldNameLabel then oldNameLabel.TextColor3 = Colours.TabTextColor or Color3.fromRGB(180,180,180) end
					local oldIcon = CurrentTabButton:FindFirstChild("TabIconImageLabel")
					if oldIcon then oldIcon.ImageColor3 = Colours.TabTextColor or Color3.fromRGB(180,180,180) end
				end

				-- Select new tab
				tabButtonFrameInstance.BackgroundColor3 = Colours.TabBackgroundSelected or Color3.fromRGB(45,45,45)
				local newNameLabel = tabButtonFrameInstance:FindFirstChild("TabNameLabel")
				if newNameLabel then newNameLabel.TextColor3 = Colours.SelectedTabTextColor or Color3.fromRGB(221,221,221) end
				local newIcon = tabButtonFrameInstance:FindFirstChild("TabIconImageLabel")
				if newIcon then newIcon.ImageColor3 = Colours.SelectedTabTextColor or Color3.fromRGB(221,221,221) end

				if currentActiveTabIndicator then
					currentActiveTabIndicator.Visible = true
					-- Calculate Y position based on the button's actual position in the list
					local yPos = tabButtonFrameInstance.AbsolutePosition.Y - TabScroll.AbsoluteCanvasPosition.Y
					yPos = yPos + (tabButtonFrameInstance.AbsoluteSize.Y - currentActiveTabIndicator.AbsoluteSize.Y) / 2
					currentActiveTabIndicator.Position = UDim2.fromOffset(2, yPos)
				end

				LayersPageLayoutInstance:JumpToPage(tabData.Page)
				if ActiveTabNameLabel then ActiveTabNameLabel.Text = tabData.Name end

				CurrentTabButton = tabButtonFrameInstance
				CurrentTabPage = tabData.Page
				return
			end
		end
		warn("SwitchToTabByName: Tab '" .. tostring(targetTabName) .. "' not found.")
	end

	local function CreateTabInternal(tabNameString, tabIconAssetId)
		local tabName = tabNameString or "Unnamed Tab"
		local tabIcon = GetIcon(tabIconAssetId or "")

		local TabButtonFrame = Instance.new("Frame") -- Renamed from Tab
		local TabNameLabel = Instance.new("TextLabel") -- Renamed from TabName
		local TabIconImageLabel = Instance.new("ImageLabel") -- Renamed from FeatureImg
		local TabButtonInteractive = Instance.new("TextButton") -- Renamed from TabButton

		TabButtonFrame.BackgroundColor3 = Colours.TabBackground or Color3.fromRGB(30,30,30)
		TabButtonFrame.BackgroundTransparency = 0
		TabButtonFrame.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
		TabButtonFrame.BorderSizePixel = 0
		TabButtonFrame.LayoutOrder = tabButtonLayoutOrderCounter -- Use new counter
		TabButtonFrame.Size = UDim2.new(1, 0, 0, 30)
		TabButtonFrame.Name = tabName .. "ButtonFrame" -- More specific name
		TabButtonFrame.Parent = TabScroll

		TabNameLabel.Font = Enum.Font.GothamBold
		TabNameLabel.Text = tabName
		TabNameLabel.TextColor3 = Colours.TabTextColor or Color3.fromRGB(180,180,180)
		TabNameLabel.TextSize = 12
		TabNameLabel.TextWrapped = true
		TabNameLabel.TextXAlignment = Enum.TextXAlignment.Left
		TabNameLabel.AnchorPoint = Vector2.new(0, 0.5)
		TabNameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabNameLabel.BackgroundTransparency = 1
		TabNameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabNameLabel.BorderSizePixel = 0
		TabNameLabel.Position = UDim2.new(0, 33, 0.5, 0)
		TabNameLabel.Size = UDim2.new(1, -36, 0.8, 0)
		TabNameLabel.Name = "TabNameLabel"
		TabNameLabel.Parent = TabButtonFrame

		TabIconImageLabel.Image = tabIcon
		TabIconImageLabel.ImageColor3 = Colours.TabTextColor or Color3.fromRGB(180,180,180)
		TabIconImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		TabIconImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabIconImageLabel.BackgroundTransparency = 1
		TabIconImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabIconImageLabel.BorderSizePixel = 0
		TabIconImageLabel.Position = UDim2.new(0, 15, 0.5, 0)
		TabIconImageLabel.Size = UDim2.new(0, 18, 0, 18)
		TabIconImageLabel.Name = "TabIconImageLabel"
		TabIconImageLabel.Parent = TabButtonFrame
        TabIconImageLabel.Visible = (tabIcon ~= "")

		-- Create the single 'currentActiveTabIndicator' if it doesn't exist (only once)
		if not currentActiveTabIndicator then
			currentActiveTabIndicator = Instance.new("Frame")
			currentActiveTabIndicator.BackgroundColor3 = Colours.ThemeHighlight or Color3.fromRGB(255,80,0)
			currentActiveTabIndicator.BorderColor3 = Color3.fromRGB(0, 0, 0)
			currentActiveTabIndicator.BorderSizePixel = 0
			currentActiveTabIndicator.Size = UDim2.new(0, 1, 0, 20)
			currentActiveTabIndicator.Name = "ActiveTabIndicator"
			currentActiveTabIndicator.ZIndex = 2
			currentActiveTabIndicator.Parent = TabScroll
			currentActiveTabIndicator.Visible = false
		end
		-- Removed old per-tab ChooseFrame creation

		TabButtonInteractive.Text = ""
		TabButtonInteractive.TextColor3 = Color3.fromRGB(0, 0, 0)
		TabButtonInteractive.TextSize = 14
		TabButtonInteractive.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabButtonInteractive.BackgroundTransparency = 1
		TabButtonInteractive.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabButtonInteractive.BorderSizePixel = 0
		TabButtonInteractive.Size = UDim2.new(1, 0, 1, 0)
		TabButtonInteractive.Name = "TabButtonInteractive"
		TabButtonInteractive.Parent = TabButtonFrame

		local ContentPage = Instance.new("ScrollingFrame") -- Renamed from ScrollFramePage
		ContentPage.Active = true
		ContentPage.BackgroundColor3 = Colours.Background or Color3.fromRGB(30,30,30)
		ContentPage.BackgroundTransparency = 1
		ContentPage.BorderColor3 = Colours.Stroke or Color3.fromRGB(50,50,50)
		ContentPage.BorderSizePixel = 0
		ContentPage.LayoutOrder = tabPageLayoutOrderCounter -- Use new counter
		ContentPage.Size = UDim2.new(1, 0, 1, 0)
		ContentPage.CanvasSize = UDim2.new(0,0,0,0)
		ContentPage.ScrollBarImageColor3 = Colours.SecondaryElementBackground or Color3.fromRGB(40,40,40)
		ContentPage.ScrollBarThickness = 4
		ContentPage.Name = tabName .. "ContentPage"
		ContentPage.Parent = LayersFolderInstance
		ContentPage.Visible = (tabButtonLayoutOrderCounter == 0)

		local UIListLayout = Instance.new("UIListLayout")
		UIListLayout.Padding = UDim.new(0, 5)
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Parent = ContentPage
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local function UpdateCanvasSize()
            local offsetY = 0
            for _, child in ipairs(ContentPage:GetChildren()) do
                if child:IsA("GuiObject") and child ~= UIListLayout then
                    offsetY = offsetY + child.Size.Y.Offset + UIListLayout.Padding.Offset
                end
            end
            ContentPage.CanvasSize = UDim2.new(0,0,0,offsetY)
        end
        ContentPage.ChildAdded:Connect(UpdateCanvasSize)
        ContentPage.ChildRemoved:Connect(UpdateCanvasSize)

		TabButtonInteractive.Activated:Connect(function()
			CircleClick(TabButtonInteractive, Mouse.X, Mouse.Y)
			SwitchToTabByName(tabName) -- Use the new centralized function
		end)

		AllCreatedTabsData[TabButtonFrame] = { -- Store by ButtonFrame instance
			Button = TabButtonFrame,
			Page = ContentPage,
			Name = tabName
		}

		if tabButtonLayoutOrderCounter == 0 then -- First tab created
			SwitchToTabByName(tabName) -- Activate it immediately
		end

		tabButtonLayoutOrderCounter = tabButtonLayoutOrderCounter + 1
		tabPageLayoutOrderCounter = tabPageLayoutOrderCounter + 1

		local TabControlsAPI = {}
		function TabControlsAPI:AddSection(SectionTitle)
			SectionTitle = SectionTitle or "Unnamed Section"

			local SectionFrame = Instance.new("Frame")
			SectionFrame.Name = SectionTitle
			SectionFrame.BackgroundTransparency = 1
			SectionFrame.Size = UDim2.new(1, -10, 0, 0)
			SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
			SectionFrame.Parent = ContentPage -- Parent to the tab's content page
			SectionFrame.LayoutOrder = ContentPage:GetChildren(#ContentPage:GetChildren()) and ContentPage:GetChildren(#ContentPage:GetChildren()).LayoutOrder + 1 or 0

			local SectionListLayout = Instance.new("UIListLayout")
			SectionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			SectionListLayout.Padding = UDim.new(0, 3)
            SectionListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			SectionListLayout.Parent = SectionFrame
            SectionListLayout.Name = "SectionListLayout"

			if SectionTitle ~= "" and SectionTitle ~= " " then -- Don't create title for empty/spacing sections
				local SectionText = Instance.new("TextLabel")
				SectionText.Font = Enum.Font.GothamBold
				SectionText.Text = SectionTitle
				SectionText.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
				SectionText.TextSize = 16
				SectionText.TextXAlignment = Enum.TextXAlignment.Left
				SectionText.BackgroundTransparency = 1
				SectionText.Size = UDim2.new(1, 0, 0, 20)
				SectionText.Name = "SectionTitle"
				SectionText.Parent = SectionFrame
                SectionText.LayoutOrder = 0
			end

			-- Auto-update canvas size of parent ScrollFramePage when section size changes
            SectionFrame.Changed:Connect(function(property)
                if property == "AbsoluteSize" then
                    UpdateCanvasSize() -- Call the UpdateCanvasSize of the parent tab's ScrollFramePage
                end
            end)

			local SectionControlsAPI = {} -- Renamed from SectionControls
			local currentSectionFrame = SectionFrame -- Default to the main section frame

			-- This internal function will be the core item adder.
			-- It needs to know where to parent items (SectionFrame or a SubSectionFrame)
			local function AddItemToFrame(TargetFrame, itemType, itemConfig)
				itemConfig = itemConfig or {}
				local layoutOrder = TargetFrame:GetChildren(#TargetFrame:GetChildren()) and TargetFrame:GetChildren(#TargetFrame:GetChildren()).LayoutOrder + 1 or 0

				if itemType == "Button" then
					local Button = Instance.new("TextButton")
					local ButtonStroke = Instance.new("UIStroke")
					local ButtonCorner = Instance.new("UICorner")
					local ButtonName = Instance.new("TextLabel")
					local ButtonImg = Instance.new("ImageLabel")

					Button.Text = ""
					Button.TextColor3 = Color3.fromRGB(0,0,0)
					Button.TextSize = 14
					Button.BackgroundColor3 = Colours.ElementBackground or Color3.fromRGB(45,45,45)
					Button.BorderColor3 = Colours.Stroke or Color3.fromRGB(60,60,60)
					Button.BorderSizePixel = 0
					Button.Size = UDim2.new(1, 0, 0, 30)
					Button.Name = itemConfig.Title or "Button"
					Button.Parent = TargetFrame
					Button.LayoutOrder = layoutOrder

					ButtonStroke.Color = Colours.ElementStroke or Color3.fromRGB(60,60,60)
					ButtonStroke.Thickness = 1
					ButtonStroke.Parent = Button

					ButtonCorner.CornerRadius = UDim.new(0, 3)
					ButtonCorner.Parent = Button

					ButtonName.Font = Enum.Font.GothamBold
					ButtonName.Text = itemConfig.Title or "Button"
					ButtonName.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
					ButtonName.TextSize = 13
					ButtonName.TextXAlignment = Enum.TextXAlignment.Left
					ButtonName.BackgroundTransparency = 1
					ButtonName.Position = UDim2.new(0, (itemConfig.Icon and 35) or 10, 0, 0)
					ButtonName.Size = UDim2.new(1, -((itemConfig.Icon and 35) or 10) - 5, 1, 0)
					ButtonName.Name = "ButtonName"
					ButtonName.Parent = Button

					local btnIconStr = GetIcon(itemConfig.Icon or "")
					ButtonImg.Image = btnIconStr
					ButtonImg.ImageColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
					ButtonImg.Visible = (btnIconStr ~= "") -- Check if GetIcon returned a valid asset ID
					ButtonImg.AnchorPoint = Vector2.new(0.5,0.5)
					ButtonImg.Position = UDim2.new(0, (ButtonImg.Visible and 17) or 0, 0.5, 0) -- Adjust position based on visibility for ButtonName
					ButtonImg.Size = UDim2.new(0,16,0,16)
					ButtonImg.BackgroundTransparency = 1
					ButtonImg.Name = "ButtonImg"
					ButtonImg.Parent = Button

					Button.MouseEnter:Connect(function() TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colours.ElementBackgroundHover or Color3.fromRGB(55,55,55)}):Play() end)
					Button.MouseLeave:Connect(function() TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colours.ElementBackground or Color3.fromRGB(45,45,45)}):Play() end)

					if itemConfig.Callback and type(itemConfig.Callback) == "function" then
						Button.Activated:Connect(function()
							UBHubInstance.CircleClick(Button, Mouse.X, Mouse.Y)
							itemConfig.Callback()
						end)
					end
					return Button

				elseif itemType == "Slider" then
					local SliderFrame = Instance.new("Frame")
					local SliderTitle = Instance.new("TextLabel")
					local SliderValueText = Instance.new("TextLabel")
					local SliderBarBackground = Instance.new("Frame")
					local SliderBarProgress = Instance.new("Frame")
					local SliderBarCorner = Instance.new("UICorner")
					local SliderBarProgressCorner = Instance.new("UICorner")
					local SliderDragger = Instance.new("TextButton") -- Using TextButton for easier click detection
					local DraggerCorner = Instance.new("UICorner")
					local SliderInput = Instance.new("TextBox")
					local SliderInputCorner = Instance.new("UICorner")

					SliderFrame.Name = itemConfig.Title or "Slider"
					SliderFrame.Size = UDim2.new(1,0,0,55) -- Increased height for input box
					SliderFrame.BackgroundTransparency = 1
					SliderFrame.LayoutOrder = layoutOrder
					SliderFrame.Parent = TargetFrame

					SliderTitle.Name = "SliderTitle"
					SliderTitle.Text = itemConfig.Title or "Slider"
					SliderTitle.Font = Enum.Font.GothamBold
					SliderTitle.TextSize = 13
					SliderTitle.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
					SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
					SliderTitle.BackgroundTransparency = 1
					SliderTitle.Size = UDim2.new(0.7, -5, 0, 20)
					SliderTitle.Position = UDim2.new(0,0,0,0)
					SliderTitle.Parent = SliderFrame

					SliderValueText.Name = "SliderValueText"
					SliderValueText.Font = Enum.Font.GothamBold
					SliderValueText.TextSize = 12
					SliderValueText.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
					SliderValueText.TextXAlignment = Enum.TextXAlignment.Right
					SliderValueText.BackgroundTransparency = 1
					SliderValueText.Size = UDim2.new(0.3, -5, 0, 20)
					SliderValueText.Position = UDim2.new(1, -SliderValueText.AbsoluteSize.X - 5, 0,0) -- Anchor to right
                                        SliderValueText.AnchorPoint = Vector2.new(1,0)
                                        SliderValueText.Position = UDim2.new(1,0,0,0)
					SliderValueText.Parent = SliderFrame

					SliderInput.Name = "SliderInput"
					SliderInput.PlaceholderText = "Value"
					SliderInput.Text = tostring(itemConfig.Default or itemConfig.Min or 0)
					SliderInput.Font = Enum.Font.Gotham
					SliderInput.TextSize = 12
					SliderInput.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
					SliderInput.BackgroundColor3 = Colours.InputBackground or Color3.fromRGB(35,35,35)
					SliderInput.Size = UDim2.new(0.3, -5, 0, 20)
                                        SliderInput.AnchorPoint = Vector2.new(1,0)
					SliderInput.Position = UDim2.new(1,0,0,22) -- Position below value text
					SliderInput.Parent = SliderFrame
					SliderInputCorner.CornerRadius = UDim.new(0,3)
					SliderInputCorner.Parent = SliderInput

					SliderBarBackground.Name = "SliderBarBackground"
					SliderBarBackground.BackgroundColor3 = Colours.SliderBackground or Color3.fromRGB(40,40,40)
					SliderBarBackground.Size = UDim2.new(1,- (SliderInput.AbsoluteSize.X + 5) ,0,6) -- Adjust width to not overlap input
                                        SliderBarBackground.Size = UDim2.new(1, -65 ,0,6) -- Temp fix for width
					SliderBarBackground.Position = UDim2.new(0,0,0,45) -- Position at bottom
					SliderBarBackground.Parent = SliderFrame
					SliderBarCorner.CornerRadius = UDim.new(0,3)
					SliderBarCorner.Parent = SliderBarBackground

					local Min, Max, Default, Increment = itemConfig.Min or 0, itemConfig.Max or 100, itemConfig.Default or 0, itemConfig.Increment or 1
					if itemConfig.Flag and UBHubInstance.Flags and UBHubInstance.Flags[itemConfig.Flag] then Default = UBHubInstance.Flags[itemConfig.Flag] end
					Default = math.clamp(Default, Min, Max)
					local CurrentValue = Default

					local function UpdateSlider(newValue, fromInput)
						newValue = math.clamp(tonumber(newValue) or CurrentValue, Min, Max)
						CurrentValue = math.floor(newValue / Increment + 0.5) * Increment -- Snap to increment

						local percentage = (CurrentValue - Min) / (Max - Min)
						SliderBarProgress.Size = UDim2.new(percentage, 0, 1, 0)
						SliderDragger.Position = UDim2.new(percentage, 0, 0.5, 0)
						SliderValueText.Text = tostring(CurrentValue)
						if not fromInput then SliderInput.Text = tostring(CurrentValue) end

						if itemConfig.Flag and UBHubInstance.SaveFile then UBHubInstance.SaveFile(itemConfig.Flag, CurrentValue) end
						if itemConfig.Callback then itemConfig.Callback(CurrentValue) end
                        if AllCreatedItemControls.Sliders[itemConfig.InternalFlagKey] and AllCreatedItemControls.Sliders[itemConfig.InternalFlagKey][itemConfig.InternalFlagComponent] then
                           AllCreatedItemControls.Sliders[itemConfig.InternalFlagKey][itemConfig.InternalFlagComponent].Value = CurrentValue
                        end
					end

					SliderBarProgress.Name = "SliderBarProgress"
					SliderBarProgress.BackgroundColor3 = Colours.SliderProgress or Color3.fromRGB(0,122,204)
					SliderBarProgress.Parent = SliderBarBackground
					SliderBarProgressCorner.CornerRadius = UDim.new(0,3)
					SliderBarProgressCorner.Parent = SliderBarProgress

					SliderDragger.Name = "SliderDragger"
					SliderDragger.Text = ""
					SliderDragger.Size = UDim2.new(0,10,0,10)
					SliderDragger.AnchorPoint = Vector2.new(0.5,0.5)
					SliderDragger.BackgroundColor3 = Colours.ThemeHighlight or Color3.fromRGB(255,80,0)
					SliderDragger.Parent = SliderBarBackground
					DraggerCorner.CornerRadius = UDim.new(0,5)
					DraggerCorner.Parent = SliderDragger

					UpdateSlider(Default) -- Initialize

					local dragging = false
					SliderDragger.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
					end)
					SliderDragger.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
					end)
					UserInputService.InputChanged:Connect(function(input)
						if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
							local relativePos = Mouse.X - SliderBarBackground.AbsolutePosition.X
							local percentage = math.clamp(relativePos / SliderBarBackground.AbsoluteSize.X, 0, 1)
							UpdateSlider(Min + percentage * (Max - Min))
						end
					end)
					SliderInput.FocusLost:Connect(function(enterPressed)
						UpdateSlider(tonumber(SliderInput.Text) or CurrentValue, true)
					end)

                    local sliderApi = { Value = CurrentValue, Set = UpdateSlider }
                    if itemConfig.InternalFlagKey and itemConfig.InternalFlagComponent then
                         AllCreatedItemControls.Sliders[itemConfig.InternalFlagKey] = AllCreatedItemControls.Sliders[itemConfig.InternalFlagKey] or {}
                         AllCreatedItemControls.Sliders[itemConfig.InternalFlagKey][itemConfig.InternalFlagComponent] = sliderApi
                    end
					return sliderApi

				elseif itemType == "Toggle" then
					local ToggleFrame = Instance.new("Frame")
					local ToggleTitle = Instance.new("TextLabel")
					local ToggleButton = Instance.new("TextButton")
					local ToggleUICorner = Instance.new("UICorner")
					local ToggleUIStroke = Instance.new("UIStroke")
					local ToggleCircle = Instance.new("Frame")
					local CircleCorner = Instance.new("UICorner")

					ToggleFrame.Name = itemConfig.Title or "Toggle"
					ToggleFrame.Size = UDim2.new(1,0,0,25)
					ToggleFrame.BackgroundTransparency = 1
					ToggleFrame.LayoutOrder = layoutOrder
					ToggleFrame.Parent = TargetFrame

					ToggleTitle.Name = "ToggleTitle"
					ToggleTitle.Text = itemConfig.Title or "Toggle"
					ToggleTitle.Font = Enum.Font.GothamBold
					ToggleTitle.TextSize = 13
					ToggleTitle.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
					ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
					ToggleTitle.BackgroundTransparency = 1
					ToggleTitle.Size = UDim2.new(1, -50, 1, 0)
					ToggleTitle.Parent = ToggleFrame

					ToggleButton.Name = "ToggleButton"
					ToggleButton.Text = ""
					ToggleButton.Size = UDim2.new(0,40,0,18)
					ToggleButton.Position = UDim2.new(1,-40,0.5,0)
					ToggleButton.AnchorPoint = Vector2.new(0,0.5)
					ToggleButton.Parent = ToggleFrame

					ToggleUICorner.CornerRadius = UDim.new(0,100)
					ToggleUICorner.Parent = ToggleButton
					ToggleUIStroke.Thickness = 1.5
					ToggleUIStroke.Parent = ToggleButton

					ToggleCircle.Name = "ToggleCircle"
					ToggleCircle.Size = UDim2.new(0,12,0,12)
					ToggleCircle.BackgroundColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
					ToggleCircle.Position = UDim2.new(0,3,0.5,0)
					ToggleCircle.AnchorPoint = Vector2.new(0,0.5)
					ToggleCircle.Parent = ToggleButton
					CircleCorner.CornerRadius = UDim.new(0,100)
					CircleCorner.Parent = ToggleCircle

					local Default = itemConfig.Default or false
					if itemConfig.Flag and UBHubInstance.Flags and UBHubInstance.Flags[itemConfig.Flag] ~= nil then Default = UBHubInstance.Flags[itemConfig.Flag] end
					local CurrentValue = Default

					local function UpdateToggleVisuals()
						if CurrentValue then
							ToggleButton.BackgroundColor3 = Colours.ToggleEnabled or Color3.fromRGB(0,122,204)
							ToggleUIStroke.Color = Colours.ToggleEnabledOuterStroke or Colours.ToggleEnabled or Color3.fromRGB(0,122,204)
							ToggleCircle.Position = UDim2.new(1,-3-12,0.5,0) -- right side (1 - padding - circlewidth)
						else
							ToggleButton.BackgroundColor3 = Colours.ToggleDisabled or Color3.fromRGB(60,60,60)
							ToggleUIStroke.Color = Colours.ToggleDisabledOuterStroke or Colours.ToggleDisabled or Color3.fromRGB(50,50,50)
							ToggleCircle.Position = UDim2.new(0,3,0.5,0) -- left side
						end
					end
					UpdateToggleVisuals()

					ToggleButton.Activated:Connect(function()
						CurrentValue = not CurrentValue
						UpdateToggleVisuals()
						if itemConfig.Flag and UBHubInstance.SaveFile then UBHubInstance.SaveFile(itemConfig.Flag, CurrentValue) end
						if itemConfig.Callback then itemConfig.Callback(CurrentValue) end
					end)
					return { Value = function() return CurrentValue end, Set = function(val) CurrentValue = val; UpdateToggleVisuals(); if itemConfig.Callback then itemConfig.Callback(CurrentValue) end end }

				elseif itemType == "Input" then
					local InputFrame = Instance.new("Frame")
					local InputTitle = Instance.new("TextLabel")
					local TextBox = Instance.new("TextBox")
					local TextStroke = Instance.new("UIStroke")
					local TextCorner = Instance.new("UICorner")

					InputFrame.Name = itemConfig.Title or "Input"
					InputFrame.Size = UDim2.new(1,0,0, (itemConfig.Title and itemConfig.Title ~= "") and 50 or 30)
					InputFrame.BackgroundTransparency = 1
					InputFrame.LayoutOrder = layoutOrder
					InputFrame.Parent = TargetFrame

					if itemConfig.Title and itemConfig.Title ~= "" then
						InputTitle.Name = "InputTitle"
						InputTitle.Text = itemConfig.Title
						InputTitle.Font = Enum.Font.GothamBold
						InputTitle.TextSize = 13
						InputTitle.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
						InputTitle.TextXAlignment = Enum.TextXAlignment.Left
						InputTitle.BackgroundTransparency = 1
						InputTitle.Size = UDim2.new(1,0,0,20)
						InputTitle.Parent = InputFrame
					end

					TextBox.Name = "TextBox"
					TextBox.Text = itemConfig.Default or ""
					if itemConfig.Flag and UBHubInstance.Flags and UBHubInstance.Flags[itemConfig.Flag] then TextBox.Text = UBHubInstance.Flags[itemConfig.Flag] end
					TextBox.PlaceholderText = itemConfig.Placeholder or "Enter text..."
					TextBox.Font = Enum.Font.Gotham
					TextBox.TextSize = 13
					TextBox.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
					TextBox.BackgroundColor3 = Colours.InputBackground or Color3.fromRGB(35,35,35)
					TextBox.PlaceholderColor3 = Colours.PlaceholderColor or Color3.fromRGB(120,120,120)
					TextBox.Size = UDim2.new(1,0,0,30)
					TextBox.Position = UDim2.new(0,0,1,-30)
					TextBox.AnchorPoint = Vector2.new(0,1)
					TextBox.Parent = InputFrame

					TextStroke.Color = Colours.InputStroke or Color3.fromRGB(55,55,55)
					TextStroke.Thickness = 1
					TextStroke.Parent = TextBox
					TextCorner.CornerRadius = UDim.new(0,3)
					TextCorner.Parent = TextBox

					if itemConfig.Callback then
						TextBox.FocusLost:Connect(function(enterPressed)
							if enterPressed then itemConfig.Callback(TextBox.Text) end
						end)
						if itemConfig.InstantCallback then
							TextBox:GetPropertyChangedSignal("Text"):Connect(function() itemConfig.Callback(TextBox.Text) end)
						end
					end
					if itemConfig.Flag and UBHubInstance.SaveFile then
						TextBox.FocusLost:Connect(function() UBHubInstance.SaveFile(itemConfig.Flag, TextBox.Text) end)
					end

					return { Value = function() return TextBox.Text end, Set = function(val) TextBox.Text = val end, Instance = TextBox }

				elseif itemType == "Paragraph" then
					local ParagraphText = Instance.new("TextLabel")
					ParagraphText.Name = itemConfig.Title or "Paragraph"
					ParagraphText.Text = itemConfig.Content or itemConfig.Title or "Paragraph text"
					ParagraphText.Font = itemConfig.Font or Enum.Font.Gotham
					ParagraphText.TextSize = itemConfig.TextSize or 13
					ParagraphText.TextColor3 = itemConfig.TextColor or Colours.TextColor or Color3.fromRGB(200,200,200)
					ParagraphText.TextWrapped = true
					ParagraphText.TextXAlignment = itemConfig.TextXAlignment or Enum.TextXAlignment.Left
					ParagraphText.TextYAlignment = Enum.TextYAlignment.Top
					ParagraphText.BackgroundTransparency = 1
					ParagraphText.Size = UDim2.new(1,0,0,0) -- Width is full, height is automatic
					ParagraphText.AutomaticSize = Enum.AutomaticSize.Y
					ParagraphText.LayoutOrder = layoutOrder
					ParagraphText.Parent = TargetFrame
					return ParagraphText

				elseif itemType == "Divider" then
					local DividerFrame = Instance.new("Frame")
					DividerFrame.Name = "Divider"
					DividerFrame.BackgroundColor3 = itemConfig.Color or Colours.Stroke or Color3.fromRGB(80,80,80)
					DividerFrame.BorderSizePixel = 0
					DividerFrame.Size = UDim2.new(1,0,0, itemConfig.Thickness or 1)
					DividerFrame.LayoutOrder = layoutOrder
					DividerFrame.Parent = TargetFrame

					if itemConfig.Title and itemConfig.Title ~= "" then -- Optional title for divider
						local DividerTitle = Instance.new("TextLabel")
						DividerTitle.Name = "DividerTitle"
						DividerTitle.Text = itemConfig.Title
						DividerTitle.Font = Enum.Font.GothamSemibold
						DividerTitle.TextSize = 12
						DividerTitle.TextColor3 = Colours.SecondaryTextColor or Colours.TextColor or Color3.fromRGB(180,180,180)
						DividerTitle.BackgroundTransparency = 1
						DividerTitle.Size = UDim2.new(0,0,0,15) -- Autosize X
                        DividerTitle.AutomaticSize = Enum.AutomaticSize.X
						DividerTitle.Position = UDim2.new(0.5,0,0.5,0)
						DividerTitle.AnchorPoint = Vector2.new(0.5,0.5)
						DividerTitle.Parent = DividerFrame

                        local Padding = Instance.new("UIPadding")
                        Padding.PaddingLeft = UDim.new(0,5)
                        Padding.PaddingRight = UDim.new(0,5)
                        Padding.Parent = DividerTitle
                        DividerFrame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- Make main divider transparent if title exists
                        DividerFrame.BackgroundTransparency = 1

                        local LeftLine = Instance.new("Frame")
                        LeftLine.Name = "LeftLine"
                        LeftLine.BackgroundColor3 = itemConfig.Color or Colours.Stroke or Color3.fromRGB(80,80,80)
                        LeftLine.BorderSizePixel = 0
                        LeftLine.Size = UDim2.new(0.5, -DividerTitle.AbsoluteSize.X/2 - 5, 0, itemConfig.Thickness or 1)
                        LeftLine.Position = UDim2.new(0,0,0.5,0)
                        LeftLine.AnchorPoint = Vector2.new(0,0.5)
                        LeftLine.Parent = DividerFrame

                        local RightLine = Instance.new("Frame")
                        RightLine.Name = "RightLine"
                        RightLine.BackgroundColor3 = itemConfig.Color or Colours.Stroke or Color3.fromRGB(80,80,80)
                        RightLine.BorderSizePixel = 0
                        RightLine.Size = UDim2.new(0.5, -DividerTitle.AbsoluteSize.X/2 - 5, 0, itemConfig.Thickness or 1)
                        RightLine.Position = UDim2.new(1,0,0.5,0)
                        RightLine.AnchorPoint = Vector2.new(1,0.5)
                        RightLine.Parent = DividerFrame
                        DividerFrame.Size = UDim2.new(1,0,0,15) -- Increase height for title
					end
					return DividerFrame

				elseif itemType == "Dropdown" then
					local DropdownFrame = Instance.new("Frame")
					local DropdownTitle = Instance.new("TextLabel")
					local DropdownButton = Instance.new("TextButton")
					local ButtonCorner = Instance.new("UICorner")
					local ButtonStroke = Instance.new("UIStroke")
					local DropdownText = Instance.new("TextLabel")
					local DropdownImage = Instance.new("ImageLabel")

					DropdownFrame.Name = itemConfig.Title or "Dropdown"
					DropdownFrame.Size = UDim2.new(1,0,0, (itemConfig.Title and itemConfig.Title ~= "") and 55 or 35)
					DropdownFrame.BackgroundTransparency = 1
					DropdownFrame.LayoutOrder = layoutOrder
					DropdownFrame.Parent = TargetFrame

					if itemConfig.Title and itemConfig.Title ~= "" then
						DropdownTitle.Name = "DropdownTitle"
						DropdownTitle.Text = itemConfig.Title
						DropdownTitle.Font = Enum.Font.GothamBold
						DropdownTitle.TextSize = 13
						DropdownTitle.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
						DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
						DropdownTitle.BackgroundTransparency = 1
						DropdownTitle.Size = UDim2.new(1,0,0,20)
						DropdownTitle.Parent = DropdownFrame
					end

					DropdownButton.Name = "DropdownButton"
					DropdownButton.Text = ""
					DropdownButton.BackgroundColor3 = Colours.ElementBackground or Color3.fromRGB(45,45,45)
					DropdownButton.Size = UDim2.new(1,0,0,30)
					DropdownButton.Position = UDim2.new(0,0,1,-30)
					DropdownButton.AnchorPoint = Vector2.new(0,1)
					DropdownButton.Parent = DropdownFrame
					ButtonCorner.CornerRadius = UDim.new(0,3)
					ButtonCorner.Parent = DropdownButton
					ButtonStroke.Color = Colours.ElementStroke or Color3.fromRGB(60,60,60)
					ButtonStroke.Thickness = 1
					ButtonStroke.Parent = DropdownButton

					DropdownText.Name = "DropdownText"
					DropdownText.Font = Enum.Font.Gotham
					DropdownText.TextSize = 13
					DropdownText.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
					DropdownText.TextXAlignment = Enum.TextXAlignment.Left
					DropdownText.BackgroundTransparency = 1
					DropdownText.Position = UDim2.new(0,10,0,0)
					DropdownText.Size = UDim2.new(1,-30,1,0)
					DropdownText.Parent = DropdownButton

					DropdownImage.Name = "DropdownImage"
					DropdownImage.Image = "rbxassetid://9886657334" -- Chevron down icon
					DropdownImage.ImageColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
					DropdownImage.BackgroundTransparency = 1
					DropdownImage.Size = UDim2.new(0,12,0,12)
					DropdownImage.Position = UDim2.new(1,-20,0.5,0)
					DropdownImage.AnchorPoint = Vector2.new(0.5,0.5)
					DropdownImage.Parent = DropdownButton

					local Options = itemConfig.Options or {"Default Option"}
					local CurrentValue = itemConfig.Default or Options[1]
					if itemConfig.Flag and UBHubInstance.Flags and UBHubInstance.Flags[itemConfig.Flag] then CurrentValue = UBHubInstance.Flags[itemConfig.Flag] end
					DropdownText.Text = tostring(CurrentValue)

					local displayOrder = UBHubInstance.DisplayOrderCounter.Value
					UBHubInstance.DisplayOrderCounter.Value = UBHubInstance.DisplayOrderCounter.Value + 1

					local function UpdateOptions()
						for _, child in ipairs(UBHubInstance.DropdownFolderInstance:GetChildren()) do
							if child:IsA("TextButton") then child:Destroy() end
						end
						for i, optionName in ipairs(Options) do
							local OptionButton = Instance.new("TextButton")
							OptionButton.Name = "Option_" .. tostring(optionName)
							OptionButton.Text = tostring(optionName)
							OptionButton.Font = Enum.Font.Gotham
							OptionButton.TextSize = 13
							OptionButton.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
							OptionButton.BackgroundColor3 = Colours.DropdownUnselected or Color3.fromRGB(40,40,40)
							OptionButton.Size = UDim2.new(1,0,0,25)
							OptionButton.LayoutOrder = i
							OptionButton.Parent = UBHubInstance.DropdownFolderInstance
							OptionButton.ZIndex = 3

							OptionButton.MouseEnter:Connect(function() OptionButton.BackgroundColor3 = Colours.DropdownSelected or Color3.fromRGB(50,50,50) end)
							OptionButton.MouseLeave:Connect(function() OptionButton.BackgroundColor3 = Colours.DropdownUnselected or Color3.fromRGB(40,40,40) end)
							OptionButton.Activated:Connect(function()
								CurrentValue = optionName
								DropdownText.Text = tostring(CurrentValue)
								if itemConfig.Flag and UBHubInstance.SaveFile then UBHubInstance.SaveFile(itemConfig.Flag, CurrentValue) end
								if itemConfig.Callback then itemConfig.Callback(CurrentValue) end

								UBHubInstance.MoreBlurFrame.Visible = false
								UBHubInstance.DropdownSelectFrame.Visible = false
							end)
						end
						local numOptions = #Options
						local dropdownHeight = math.min(numOptions * 25 + (numOptions > 0 and (numOptions -1) * UBHubInstance.DropdownFolderInstance.UIPageLayout.Padding.Offset or 0), 150) -- Max height 150
						UBHubInstance.DropdownSelectFrame.Size = UDim2.new(0,160,0, dropdownHeight)
						UBHubInstance.DropdownSelectRealFrame.Size = UDim2.new(1,-10,1,-10) -- Keep padding
						task.wait()
						UBHubInstance.DropPageLayoutInstance.Parent = nil -- Force refresh UIPageLayout
						UBHubInstance.DropPageLayoutInstance.Parent = UBHubInstance.DropdownFolderInstance
					end

					DropdownButton.Activated:Connect(function()
						UBHubInstance.CircleClick(DropdownButton, Mouse.X, Mouse.Y)
						if UBHubInstance.MoreBlurFrame.Visible and UBHubInstance.DropdownSelectFrame.LayoutOrder == displayOrder then
							UBHubInstance.MoreBlurFrame.Visible = false
							UBHubInstance.DropdownSelectFrame.Visible = false
						else
							UpdateOptions()
							UBHubInstance.DropdownSelectFrame.Position = UDim2.new(0, DropdownButton.AbsolutePosition.X - UBHubInstance.MoreBlurFrame.AbsolutePosition.X, 0, DropdownButton.AbsolutePosition.Y - UBHubInstance.MoreBlurFrame.AbsolutePosition.Y + DropdownButton.AbsoluteSize.Y + 5)
							UBHubInstance.DropdownSelectFrame.LayoutOrder = displayOrder
							UBHubInstance.MoreBlurFrame.Visible = true
							UBHubInstance.DropdownSelectFrame.Visible = true
							UBHubInstance.DropPageLayoutInstance:JumpToPage(UBHubInstance.DropdownFolderInstance:GetChildren()[1]) -- Jump to first option
						end
					end)

					local dropdownApi = {
						Value = function() return CurrentValue end,
						Set = function(val)
							CurrentValue = val; DropdownText.Text = tostring(CurrentValue)
							if itemConfig.Flag and UBHubInstance.SaveFile then UBHubInstance.SaveFile(itemConfig.Flag, CurrentValue) end
						end,
						Refresh = function(newOptions, newDefault)
							Options = newOptions or {"Empty"}
							CurrentValue = newDefault or Options[1]
							DropdownText.Text = tostring(CurrentValue)
							if UBHubInstance.MoreBlurFrame.Visible and UBHubInstance.DropdownSelectFrame.LayoutOrder == displayOrder then UpdateOptions() end -- Update if visible
						end
					}
                    if itemConfig.InternalFlag then -- Used by local files dropdown
                        AllCreatedItemControls[itemConfig.InternalFlag] = dropdownApi
                    end
					return dropdownApi

				elseif itemType == "Keybind" then
					local KeybindFrame = Instance.new("Frame")
					local KeybindTitle = Instance.new("TextLabel")
					local KeybindButton = Instance.new("TextButton")
					local ButtonCorner = Instance.new("UICorner")
					local ButtonStroke = Instance.new("UIStroke")

					KeybindFrame.Name = itemConfig.Title or "Keybind"
					KeybindFrame.Size = UDim2.new(1,0,0, (itemConfig.Title and itemConfig.Title ~= "") and 55 or 35)
					KeybindFrame.BackgroundTransparency = 1
					KeybindFrame.LayoutOrder = layoutOrder
					KeybindFrame.Parent = TargetFrame

					if itemConfig.Title and itemConfig.Title ~= "" then
						KeybindTitle.Name = "KeybindTitle"
						KeybindTitle.Text = itemConfig.Title
						KeybindTitle.Font = Enum.Font.GothamBold
						KeybindTitle.TextSize = 13
						KeybindTitle.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)
						KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
						KeybindTitle.BackgroundTransparency = 1
						KeybindTitle.Size = UDim2.new(1,0,0,20)
						KeybindTitle.Parent = KeybindFrame
					end

					KeybindButton.Name = "KeybindButton"
					KeybindButton.BackgroundColor3 = Colours.ElementBackground or Color3.fromRGB(45,45,45)
					KeybindButton.Size = UDim2.new(1,0,0,30)
					KeybindButton.Position = UDim2.new(0,0,1,-30)
					KeybindButton.AnchorPoint = Vector2.new(0,1)
					KeybindButton.Parent = KeybindFrame
					KeybindButton.Font = Enum.Font.GothamBold
					KeybindButton.TextSize = 13
					KeybindButton.TextColor3 = Colours.TextColor or Color3.fromRGB(221,221,221)

					ButtonCorner.CornerRadius = UDim.new(0,3)
					ButtonCorner.Parent = KeybindButton
					ButtonStroke.Color = Colours.ElementStroke or Color3.fromRGB(60,60,60)
					ButtonStroke.Thickness = 1
					ButtonStroke.Parent = KeybindButton

					local DefaultKey = itemConfig.Default or "None"
					local currentKey = DefaultKey
					if itemConfig.Flag and UBHubInstance.Flags and UBHubInstance.Flags[itemConfig.Flag] then currentKey = UBHubInstance.Flags[itemConfig.Flag] end
					KeybindButton.Text = currentKey

					local isListening = false
					local inputConnection = nil

					KeybindButton.Activated:Connect(function()
						UBHubInstance.CircleClick(KeybindButton, Mouse.X, Mouse.Y)
						if isListening then
							isListening = false
							KeybindButton.Text = currentKey -- Revert if clicked again while listening
							if inputConnection then inputConnection:Disconnect(); inputConnection = nil end
						else
							isListening = true
							KeybindButton.Text = "Press any key..."
							inputConnection = UserInputService.InputBegan:Connect(function(input)
								if isListening then
									if input.UserInputType == Enum.UserInputType.Keyboard then
										currentKey = input.KeyCode.Name
										if currentKey == "Unknown" then currentKey = "None" end -- Handle invalid keys
									elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
										currentKey = "Mouse1"
									elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
										currentKey = "Mouse2"
									-- Add other mouse buttons or input types if needed
									else
										currentKey = "None" -- Default for unsupported input types
									end
									KeybindButton.Text = currentKey
									isListening = false
									if inputConnection then inputConnection:Disconnect(); inputConnection = nil end

									if itemConfig.Flag and UBHubInstance.SaveFile then UBHubInstance.SaveFile(itemConfig.Flag, currentKey) end
									if itemConfig.Callback then itemConfig.Callback(currentKey) end
								end
							end)
						end
					end)
					-- Return an API to get the current key if needed, though callback is primary
					return { GetKey = function() return currentKey end, ButtonInstance = KeybindButton }

				else
					warn("AddItemInternal: Unsupported itemType '" .. tostring(itemType) .. "'")
					return nil
				end
			end

			-- Specific item additions for convenience, mapping to AddItemToFrame with currentSectionFrame
			function SectionControlsAPI:AddButton(config) return AddItemToFrame(currentSectionFrame, "Button", config) end
			function SectionControlsAPI:AddSlider(config) return AddItemToFrame(currentSectionFrame, "Slider", config) end
			function SectionControlsAPI:AddToggle(config) return AddItemToFrame(currentSectionFrame, "Toggle", config) end
            function SectionControlsAPI:AddDropdown(config) return AddItemToFrame(currentSectionFrame, "Dropdown", config) end
            function SectionControlsAPI:AddInput(config) return AddItemToFrame(currentSectionFrame, "Input", config) end
            function SectionControlsAPI:AddParagraph(config) return AddItemToFrame(currentSectionFrame, "Paragraph", config) end
            function SectionControlsAPI:AddDivider(config) return AddItemToFrame(currentSectionFrame, "Divider", config) end
            function SectionControlsAPI:AddKeybind(config) return AddItemToFrame(currentSectionFrame, "Keybind", config) end


			function SectionControlsAPI:AddSection(title) -- This creates a sub-section frame
				local subSectionTitle = title or "Sub Section"
				local SubSectionFrame = Instance.new("Frame")
				SubSectionFrame.Name = subSectionTitle
				SubSectionFrame.BackgroundTransparency = 1
				SubSectionFrame.Size = UDim2.new(1, 0, 0, 0)
				SubSectionFrame.AutomaticSize = Enum.AutomaticSize.Y
				SubSectionFrame.Parent = currentSectionFrame -- Parent to the current section frame
				SubSectionFrame.LayoutOrder = currentSectionFrame:GetChildren(#currentSectionFrame:GetChildren()) and currentSectionFrame:GetChildren(#currentSectionFrame:GetChildren()).LayoutOrder + 1 or 0

				local SubSectionListLayout = Instance.new("UIListLayout")
				SubSectionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				SubSectionListLayout.Padding = UDim.new(0, 2)
				SubSectionListLayout.Parent = SubSectionFrame
				SubSectionListLayout.Name = "SubSectionListLayout"

				if subSectionTitle ~= "" and subSectionTitle ~= " " then
					local SubSectionText = Instance.new("TextLabel")
					SubSectionText.Font = Enum.Font.GothamSemibold
					SubSectionText.Text = subSectionTitle
					SubSectionText.TextColor3 = Colours.TextColor or Color3.fromRGB(200,200,200)
					SubSectionText.TextSize = 14
					SubSectionText.TextXAlignment = Enum.TextXAlignment.Left
					SubSectionText.BackgroundTransparency = 1
					SubSectionText.Size = UDim2.new(1, 0, 0, 18)
					SubSectionText.Name = "SubSectionTitle"
					SubSectionText.Parent = SubSectionFrame
					SubSectionText.LayoutOrder = 0
				end

				-- Create a new SectionControlsAPI object for the sub-section
				-- This new object's AddItemToFrame will target the SubSectionFrame
				local SubSectionControlsApi = {}
				for k,v_func in pairs(SectionControlsAPI) do -- Copy methods from parent SectionControlsAPI
					if type(v_func) == "function" and k ~= "AddSection" then -- Don't allow AddSection on sub-sub-sections for now
						SubSectionControlsApi[k] = function(...)
							-- Temporarily set currentSectionFrame to SubSectionFrame for the duration of this call
							local oldSectionFrame = currentSectionFrame
							currentSectionFrame = SubSectionFrame
							local result = v_func(...) -- This will call the original AddButton, AddSlider etc.
							currentSectionFrame = oldSectionFrame -- Restore it
							return result
						end
					elseif type(v_func) == "function" and k == "AddSection" then -- Allow one level of sub-sectioning
                         SubSectionControlsApi[k] = v_func -- This might need more careful handling if deeper nesting is desired.
                    end
				end
				return SubSectionControlsApi
			end

			return SectionControlsAPI
		end

		-- Store reference for ThemesButton linking
		if tabName == "Themes" and UBHubLib.TabReferences then
			UBHubLib.TabReferences["Themes"] = {
				TabButtonInstance = TabButton, -- The actual button instance for activation
				TabFrame = Tab,             -- The visual tab frame in the list
				Name = tabName,
				ScrollFramePage = ScrollFramePage,
				LayoutOrder = TabButtonFrame.LayoutOrder
			}
		end
		-- Removed UBHubLib.TabReferences population for "Themes" tab as it's obsolete

		return TabControlsAPI
	end

	-- Method for users to add tabs using the new instance
	function UBHubInstance:CreateTab(TabConfig)
		TabConfig = TabConfig or {}
		local tabName = TabConfig.Name or "Unnamed Tab"
		local tabIcon = TabConfig.Icon or ""
		return CreateTabInternal(tabName, tabIcon)
	end

	-- Expose necessary functions on UBHubInstance
	UBHubInstance.ApplyTheme = applyTheme
	UBHubInstance.GetDefaultThemes = function() return DefaultThemes end
	UBHubInstance.GetCurrentColours = function() return Colours end
    UBHubInstance.MakeNotify = UBHubLib.MakeNotify -- Expose MakeNotify if it was meant to be public
    UBHubInstance.CircleClick = CircleClick -- Expose CircleClick if used by items
    UBHubInstance.Flags = Flags -- Expose Flags for item direct flag manipulation if necessary
    UBHubInstance.SaveFile = SaveFile -- Expose SaveFile for item direct flag manipulation if necessary
    UBHubInstance.DisplayOrderCounter = { Value = 0 } -- For dropdowns, etc.
    UBHubInstance.MoreBlurFrame = MoreBlurFrame -- For dropdowns
    UBHubInstance.DropdownSelectFrame = DropdownSelectFrame -- For dropdowns
    UBHubInstance.DropdownFolderInstance = DropdownFolderInstance -- For dropdowns
    UBHubInstance.DropPageLayoutInstance = DropPageLayoutInstance -- For dropdowns
    UBHubInstance.MoreBlurConnectButton = MoreBlurConnectButton -- For dropdowns
    -- UBHubInstance.CountDropdown = CountDropdown -- This was already the primary one.

	-- The old 'localTabsObject = Tabs' is now implicitly handled by CreateTabInternal
	-- The 'Interface' and 'Themes' tabs will be created using CreateTabInternal later.

	-- Interface Tab Creation (Subtask 5, adapted)
	local mediaFolder = "UBHubAssets"
	-- Ensure mediaFolder is created only if FSO tools are available.
    if FSO.makefolder and FSO.isfile and not FSO.isfile(mediaFolder) then
        local success, err = pcall(FSO.makefolder, mediaFolder)
        if not success then warn("Failed to create mediaFolder:", err) end
    end

	local function ChangeTransparencyInternal(transparencyValue)
		if MainFrame then MainFrame.BackgroundTransparency = transparencyValue end
		if BackgroundImageLabel then BackgroundImageLabel.ImageTransparency = transparencyValue end
		if BackgroundVideoFrame then BackgroundVideoFrame.BackgroundTransparency = transparencyValue end
		if GuiConfig then GuiConfig.MainBackgroundTransparency = transparencyValue end
		if Flags then
			Flags.MainBackgroundTransparency = transparencyValue
			SaveFile("MainBackgroundTransparency", transparencyValue)
		end
	end

	local function ChangeAssetInternal(mediaType, urlOrPath, filename)
		if not FSO.getcustomasset then warn("ChangeAssetInternal: 'getcustomasset' not available."); return end
		local assetId
		local success, err = pcall(function()
			if urlOrPath:match("^https?://") then
				if not CurrentHttpService then error("HttpService not available.") end
				if not FSO.writefile then error("FSO.writefile not available.") end
				if FSO.makefolder and not (FSO.isfile and FSO.isfile(mediaFolder)) then FSO.makefolder(mediaFolder) end

				local data
				local httpSuccess, httpResult = pcall(CurrentHttpService.HttpGet, CurrentHttpService, urlOrPath)
				if not httpSuccess then error("HttpGet failed: " .. tostring(httpResult)) end
				data = httpResult

				local extension = mediaType == "Image" and ".png" or ".mp4"
				if not filename or filename == "" then filename = CurrentHttpService:GenerateGUID(false) end
				if not filename:match("%..+$") then filename = filename .. extension end

				local filePath = mediaFolder .. "/" .. filename
				FSO.writefile(filePath, data)
				assetId = FSO.getcustomasset(filePath)
				if Flags then
					Flags.SavedBackgroundInfo = {Type = mediaType, Path = filePath}
					SaveFile("SavedBackgroundInfo", Flags.SavedBackgroundInfo)
				end
			else
				assetId = FSO.getcustomasset(urlOrPath)
				 if Flags then
					Flags.SavedBackgroundInfo = {Type = mediaType, Path = urlOrPath}
					SaveFile("SavedBackgroundInfo", Flags.SavedBackgroundInfo)
				end
			end
		end)
		if not success or not assetId then warn("ChangeAssetInternal: Failed. Type:", mediaType, "URL/Path:", urlOrPath, "Err:", err); return end
		if mediaType == "Image" then
			if BackgroundImageLabel then BackgroundImageLabel.Image = assetId end
			if BackgroundVideoFrame then BackgroundVideoFrame.Video = "" end
			_G.BGImage = assetId ~= "" and assetId ~= nil
			_G.BGVideo = false
		elseif mediaType == "Video" then
			if BackgroundVideoFrame then BackgroundVideoFrame.Video = assetId end
			if BackgroundImageLabel then BackgroundImageLabel.Image = "" end
			_G.BGVideo = assetId ~= "" and assetId ~= nil
			_G.BGImage = false
			if BackgroundVideoFrame then BackgroundVideoFrame.Playing = _G.BGVideo end
		end
	end

	local function ResetBackgroundInternal()
		if BackgroundImageLabel then BackgroundImageLabel.Image = "" end
		if BackgroundVideoFrame then BackgroundVideoFrame.Video = "" end
		_G.BGImage = false; _G.BGVideo = false
		if Flags then
			Flags.SavedBackgroundInfo = nil
			SaveFile("SavedBackgroundInfo", nil)
		end
	end

	if Flags.SavedBackgroundInfo and Flags.SavedBackgroundInfo.Path and Flags.SavedBackgroundInfo.Type then
		if FSO.isfile and FSO.isfile(Flags.SavedBackgroundInfo.Path) then
			 ChangeAssetInternal(Flags.SavedBackgroundInfo.Type, Flags.SavedBackgroundInfo.Path, nil)
		else
			 if FSO.isfile then warn("Saved background file not found:", Flags.SavedBackgroundInfo.Path) end
			 Flags.SavedBackgroundInfo = nil
			 SaveFile("SavedBackgroundInfo", nil)
		end
	end
	if Flags.MainBackgroundTransparency ~= nil then
		ChangeTransparencyInternal(Flags.MainBackgroundTransparency)
	elseif GuiConfig.MainBackgroundTransparency == nil then -- Only set default if not already set by flags or initial config
        ChangeTransparencyInternal(0.1)
        if GuiConfig then GuiConfig.MainBackgroundTransparency = 0.1 end
    end

	-- ==== BUILT-IN TAB CREATION ====
	-- Create "Interface" Tab
	local InterfaceTab = CreateTabInternal("Interface", "lucide:sliders-horizontal")
	if InterfaceTab then -- Check if tab creation was successful
		local BGSettingsSection = InterfaceTab:AddSection("Background Settings")
		if BGSettingsSection then
			BGSettingsSection:AddSlider({
				Title = "UI Transparency",
				Content = "Adjust overall UI transparency.",
				Min = 0, Max = 1, Increment = 0.01,
				Default = (Flags and Flags.MainBackgroundTransparency) or 0.1,
				Flag = "MainUITransparencySlider",
				Callback = function(value)
					if ChangeTransparencyInternal then ChangeTransparencyInternal(value) end
				end
			})
		end

		local CustomBGSection = InterfaceTab:AddSection("Custom Background")
		if CustomBGSection then
			local DownloaderSubSection = CustomBGSection:AddSection("[+] Background Downloader")
			if DownloaderSubSection then
				local selectedMediaType = "Image"
				DownloaderSubSection:AddDropdown({
					Title = "Select Media Type", Options = {"Image", "Video"}, Default = selectedMediaType,
					Callback = function(val) selectedMediaType = (type(val) == "table" and val[1]) or val end
				})
				local bgUrlInput = DownloaderSubSection:AddInput({ Title = "Background URL", Default = "" })
				local bgFilenameInput = DownloaderSubSection:AddInput({ Title = "Filename (Optional)", Content = "Name to save as. Auto-generates if empty.", Default = "" })
				DownloaderSubSection:AddButton({
					Title = "Load Web Background", Icon = "lucide:download-cloud",
					Callback = function()
						if bgUrlInput and bgUrlInput.Value ~= "" and ChangeAssetInternal then
							ChangeAssetInternal(selectedMediaType, bgUrlInput.Value, bgFilenameInput.Value)
						end
					end
				})
			end

			local LocalFilesSubSection = CustomBGSection:AddSection("[-] Local Backgrounds")
			if LocalFilesSubSection then
				local localFilesDropdownApi = LocalFilesSubSection:AddDropdown({ Title = "Select Local File", Options = {"(Refresh to see files)"}, Default = "(Refresh to see files)"})
				local selectedLocalFile = ""
                -- Assuming AddDropdown's callback provides the new value, or we can use the API to get it if needed.
                -- For simplicity, this example relies on the callback of "Load Selected Local File" to fetch current value.
                -- If dropdown API has a .Value() method or .Instance for GetPropertyChangedSignal, that would be more robust here.

				LocalFilesSubSection:AddButton({
					Title = "Refresh Local Files", Icon = "lucide:refresh-cw",
					Callback = function()
						if not FSO.listfiles then warn("UB Hub: listfiles not available.") return end
						if not FSO.makefolder then warn("UB Hub: makefolder not available.") return end

						-- Attempt to define FSO.isdir if it's missing and FSO.isfile exists
						if not FSO.isdir and FSO.isfile then
							FSO.isdir = function(path)
								-- This is a simplified check; a true isdir might need more robust error handling or specific os calls.
								-- For this context, assuming a path is a directory if it's not a file and doesn't error with listfiles.
								local success, _ = pcall(FSO.listfiles, path)
								return success
							end
						end

						if FSO.isdir and not FSO.isdir(mediaFolder) then
							pcall(FSO.makefolder, mediaFolder)
						end

						local files = {}
						local listSuccess, listResult = pcall(FSO.listfiles, mediaFolder)
						if listSuccess then files = listResult else warn("Refresh Local Files: listfiles failed:", listResult) end

						local validFiles = {}
						for _, file in ipairs(files) do
							if file:match("%.png$") or file:match("%.jpg$") or file:match("%.jpeg$") or file:match("%.gif$") or file:match("%.mp4$") or file:match("%.webm$") then
								table.insert(validFiles, mediaFolder .. "/" .. file)
							end
						end
						if #validFiles == 0 then table.insert(validFiles, "(No files found)") end

						if localFilesDropdownApi and localFilesDropdownApi.Refresh then
							localFilesDropdownApi:Refresh(validFiles, validFiles[1] or "(No files found)")
							selectedLocalFile = validFiles[1] or "" -- Update selectedLocalFile after refresh
						else
							warn("Refresh Local Files: Dropdown refresh API not available.")
						end
					end
				})
				LocalFilesSubSection:AddButton({
					Title = "Load Selected Local File", Icon = "lucide:folder-up",
					Callback = function()
                        if localFilesDropdownApi and localFilesDropdownApi.Value then -- Attempt to get current value if API supports it
                             selectedLocalFile = localFilesDropdownApi.Value()
                             if type(selectedLocalFile) == "table" then selectedLocalFile = selectedLocalFile[1] end -- Handle if it returns a table
                        end
						if selectedLocalFile and selectedLocalFile ~= "" and selectedLocalFile ~= "(No files found)" and selectedLocalFile ~= "(Refresh to see files)" and ChangeAssetInternal then
							local mediaTypeForLocal = (selectedLocalFile:match("%.mp4$") or selectedLocalFile:match("%.webm$")) and "Video" or "Image"
							ChangeAssetInternal(mediaTypeForLocal, selectedLocalFile, nil)
						else
							warn("Load Selected Local File: No valid file selected or ChangeAssetInternal not available. Selected: "..tostring(selectedLocalFile))
						end
					end
				})
			end

			CustomBGSection:AddButton({
				Title = "Reset Background", Icon = "lucide:rotate-ccw",
				Callback = function()
					if ResetBackgroundInternal then ResetBackgroundInternal() end
				end
			})
		end
	end

	-- Create "Themes" Tab
	local ThemesTab = CreateTabInternal("Themes", "lucide:palette")
	if ThemesTab then
		local PresetsSection = ThemesTab:AddSection("Theme Presets")
		if PresetsSection and DefaultThemes then
			for themeName, _ in pairs(DefaultThemes) do
				PresetsSection:AddButton({
					Title = themeName,
					Content = "Apply this theme preset.",
					Icon = "lucide:brush",
					Callback = function()
						if applyTheme then applyTheme(themeName, false) end
					end
				})
			end
		end

		local CustomizeSection = ThemesTab:AddSection("Customize Colors")
		if CustomizeSection then
			local orderedColorKeys = {
				"TextColor", "Background", "Topbar", "Shadow", "NotificationBackground", "NotificationActionsBackground",
				"TabBackground", "TabStroke", "TabBackgroundSelected", "TabTextColor", "SelectedTabTextColor",
				"ElementBackground", "ElementBackgroundHover", "SecondaryElementBackground", "ElementStroke", "SecondaryElementStroke",
				"SliderBackground", "SliderProgress", "SliderStroke", "ToggleBackground", "ToggleEnabled", "ToggleDisabled",
				"ToggleEnabledStroke", "ToggleDisabledStroke", "ToggleEnabledOuterStroke", "ToggleDisabledOuterStroke",
				"DropdownSelected", "DropdownUnselected", "InputBackground", "InputStroke", "PlaceholderColor",
				"Primary", "Secondary", "Accent", "ThemeHighlight", "Stroke", "GuiConfigColor"
			}

			if Colours and AllCreatedItemControls and AllCreatedItemControls.Sliders then
				for _, colorKey in ipairs(orderedColorKeys) do
					if Colours[colorKey] then
						local colorSlidersSubSection = CustomizeSection:AddSection(colorKey)
						if colorSlidersSubSection then
							AllCreatedItemControls.Sliders[colorKey] = {}

							local initialR = math.floor(Colours[colorKey].R * 255 + 0.5)
							local initialG = math.floor(Colours[colorKey].G * 255 + 0.5)
							local initialB = math.floor(Colours[colorKey].B * 255 + 0.5)

							local function createColorUpdateCallback(component)
								return function(value)
									local r,g,b = Colours[colorKey].R * 255, Colours[colorKey].G * 255, Colours[colorKey].B * 255
									if component == "R" then r = value
									elseif component == "G" then g = value
									elseif component == "B" then b = value
									end
									Colours[colorKey] = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
									if applyTheme then applyTheme(Colours, false) end
								end
							end

							AllCreatedItemControls.Sliders[colorKey].R = colorSlidersSubSection:AddSlider({
								Title = "Red", Min = 0, Max = 255, Increment = 1, Default = initialR,
								Flag = "CustomColor_" .. colorKey .. "_R", Callback = createColorUpdateCallback("R")
							})
							AllCreatedItemControls.Sliders[colorKey].G = colorSlidersSubSection:AddSlider({
								Title = "Green", Min = 0, Max = 255, Increment = 1, Default = initialG,
								Flag = "CustomColor_" .. colorKey .. "_G", Callback = createColorUpdateCallback("G")
							})
							AllCreatedItemControls.Sliders[colorKey].B = colorSlidersSubSection:AddSlider({
								Title = "Blue", Min = 0, Max = 255, Increment = 1, Default = initialB,
								Flag = "CustomColor_" .. colorKey .. "_B", Callback = createColorUpdateCallback("B")
							})
						end
					end
				end
			end
		end
	end
	-- End of Built-in Tab Creation

	-- Create built-in tabs after all base UI is defined and CreateTabInternal is ready
	-- local ThemesTabControls = CreateTabInternal({ Name = "Themes", Icon = GetIcon("lucide:palette") })
	-- -- Populate ThemesTabControls with sections and items

	-- local InterfaceTabControls = CreateTabInternal({ Name = "Interface", Icon = GetIcon("lucide:sliders-horizontal") })
	-- -- Populate InterfaceTabControls (code for this is currently below, needs to be moved/adapted)


	-- Ensure the "ThemesButton" in Info section can trigger the "Themes" tab.
	-- This connection logic might need adjustment based on how TabButton.Activated is structured in CreateTabInternal
	if ThemesButton then
		ThemesButton.Activated:Connect(function()
			SwitchToTabByName("Themes")
		end)
	end

	-- Step 1: Ensure UBHubInstance is returned.
	return UBHubInstance
end

return UBHubLib
