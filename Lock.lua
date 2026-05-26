local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuración de Perspectiva
local CAMERA_DISTANCE = 12 
local CAMERA_HEIGHT = 4   
local AimlockEnabled = false
local Target = nil
local MenuExpanded = true

-- --- INTERFAZ GUI (BLACK & WHITE MINIMALIST) ---
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIStroke = Instance.new("UIStroke")
local AimButton = Instance.new("TextButton")
local ButtonStroke = Instance.new("UIStroke")
local TitleButton = Instance.new("TextButton") -- Cambiado a TextButton para interactuar
local TargetLabel = Instance.new("TextLabel")

ScreenGui.Name = "NULL_JJS_Lock"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -85)
MainFrame.Size = UDim2.new(0, 200, 0, 160)

UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- El título ahora es un botón que abre/cierra la GUI
TitleButton.Name = "TitleButton"
TitleButton.Parent = MainFrame
TitleButton.BackgroundTransparency = 1
TitleButton.Position = UDim2.new(0, 0, 0, 0)
TitleButton.Size = UDim2.new(1, 0, 0, 45) -- Cubre la zona superior del título
TitleButton.Font = Enum.Font.RobotoMono
TitleButton.Text = "NULL JJS LOCK"
TitleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleButton.TextSize = 17

TargetLabel.Parent = MainFrame
TargetLabel.BackgroundTransparency = 1
TargetLabel.Position = UDim2.new(0, 0, 0, 42)
TargetLabel.Size = UDim2.new(1, 0, 0, 20)
TargetLabel.Font = Enum.Font.SourceSans
TargetLabel.Text = "target: none"
TargetLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
TargetLabel.TextSize = 13

AimButton.Name = "AimButton"
AimButton.Parent = MainFrame
AimButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
AimButton.Position = UDim2.new(0.1, 0, 0.55, 0)
AimButton.Size = UDim2.new(0.8, 0, 0, 45)
AimButton.Font = Enum.Font.RobotoMono
AimButton.Text = "LOCK: OFF"
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.TextSize = 15
AimButton.BorderSizePixel = 0

ButtonStroke.Parent = AimButton
ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
ButtonStroke.Thickness = 1

-- --- LÓGICA DE APERTURA / CIERRE (TOGGLE AL TOCAR EL NOMBRE) ---
TitleButton.MouseButton1Click:Connect(function()
    MenuExpanded = not MenuExpanded
    
    if MenuExpanded then
        -- Expandir ventana
        MainFrame.Size = UDim2.new(0, 200, 0, 160)
        TargetLabel.Visible = true
        AimButton.Visible = true
    else
        -- Colapsar ventana (Solo se ve el título)
        MainFrame.Size = UDim2.new(0, 200, 0, 45)
        TargetLabel.Visible = false
        AimButton.Visible = false
    end
end)

-- --- ARRASTRE SUAVE Y SEGURO (CON FILTRO PARA EL NOMBRE) ---
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- EVITA EL DRAG SI SE HACE CLICK EN EL NOMBRE
        local mousePos = input.Position
        local titleMinY = TitleButton.AbsolutePosition.Y
        local titleMaxY = TitleButton.AbsolutePosition.Y + TitleButton.AbsoluteSize.Y
        
        if mousePos.Y >= titleMinY and mousePos.Y <= titleMaxY then
            return -- Si toca la zona del título, rompe la función y no arrastra
        end
        
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        dragging = false 
    end 
end)

-- --- LÓGICA DE FIJACIÓN ESTABLE ---
local function GetClosestPlayer()
    local dist = math.huge
    local temp = nil
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            if v.Character.Humanoid.Health > 0 then
                local mag = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if mag < dist then 
                    dist = mag
                    temp = v 
                end
            end
        end
    end
    return temp
end

AimButton.MouseButton1Click:Connect(function()
    AimlockEnabled = not AimlockEnabled
    
    if AimlockEnabled then
        Target = GetClosestPlayer()
        
        if Target then
            AimButton.Text = "LOCK: ON"
            AimButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            AimButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            TargetLabel.Text = "target: " .. Target.Name:lower()
        else
            AimlockEnabled = false
            TargetLabel.Text = "target: no one near"
        end
    else
        Target = nil
        AimButton.Text = "LOCK: OFF"
        AimButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TargetLabel.Text = "target: none"
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.AutoRotate = not AimlockEnabled
    end
end)

RunService.RenderStepped:Connect(function()
    if AimlockEnabled and Target then
        if not Target.Character or not Target.Character:FindFirstChild("HumanoidRootPart") or not Target.Character:FindFirstChild("Humanoid") or Target.Character.Humanoid.Health <= 0 then
            Target = GetClosestPlayer()
            if Target then
                TargetLabel.Text = "target: " .. Target.Name:lower()
            else
                AimButton.MouseButton1Click:Fire()
                return
            end
        end

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local MyHRP = LocalPlayer.Character.HumanoidRootPart
            local EnemyHRP = Target.Character.HumanoidRootPart
            local MyHum = LocalPlayer.Character:FindFirstChild("Humanoid")

            local targetPos = Vector3.new(EnemyHRP.Position.X, MyHRP.Position.Y, EnemyHRP.Position.Z)
            MyHRP.CFrame = CFrame.lookAt(MyHRP.Position, targetPos)

            local directionToEnemy = (EnemyHRP.Position - MyHRP.Position).Unit
            local newCamPos = MyHRP.Position - (directionToEnemy * CAMERA_DISTANCE) + Vector3.new(0, CAMERA_HEIGHT, 0)
            
            Camera.CFrame = CFrame.lookAt(newCamPos, EnemyHRP.Position + Vector3.new(0, 1, 0))
            
            if MyHum.AutoRotate then MyHum.AutoRotate = false end
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if not LocalPlayer.Character.Humanoid.AutoRotate then
                LocalPlayer.Character.Humanoid.AutoRotate = true
            end
        end
    end
end)
