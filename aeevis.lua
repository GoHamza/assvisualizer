-- vars
breaker = false

plr =  game.Players.LocalPlayer
chr = plr.Character
hum = chr.Humanoid

a = 0

move1 = {}
move2 = {}

-- funcs
function newinst(class, parent, name) -- better implementation of roblox instancing
   local inst = Instance.new(class)

   if parent == 1 then
      inst.Parent = gethui()
   else
      inst.Parent = parent
   end

   if name then
      inst.Name = name
   end

   return inst
end

-- instances
local theme = newinst("Sound", workspace, "doomtheme")
local basstheme = newinst("Sound", workspace, "bassydoomtheme")

local scrgui = newinst("ScreenGui", 1, "Visualizer")
local overlay = newinst("ImageLabel", scrgui)
local square = newinst("Frame", scrgui)

-- normal music
theme.SoundId = getcustomasset("aeer.mp3")
theme.Volume = 0
theme:Play()

-- filtered music (bass only)
basstheme.SoundId = getcustomasset("aeerbass.mp3")
basstheme.Volume = 1
basstheme:Play()

-- scrgui
scrgui.IgnoreGuiInset = true

-- vignette
overlay.AnchorPoint = Vector2.new(0.5,0.5)
overlay.BackgroundTransparency= 1
overlay.Image = "rbxasset://textures/ui/TopBar/WhiteOverlayAsset.png"
overlay.Size = UDim2.new(1.2,0,1.2,0)
overlay.Position = UDim2.new(0.5,0,0.5,0)

-- rotating square
square.AnchorPoint = Vector2.new(0.5,0.5)
square.BackgroundTransparency= 0
square.Size = UDim2.new(0,800,0,800)
square.Position = UDim2.new(0.5,0,-0.2,0)---
square.BorderSizePixel = 0
square.BackgroundTransparency = 0.2
square.ZIndex = 1

-- initialize visualizer bars at bottom of screen
for i = 0, 40, 1 do
    -- if i is even number then make bass visualizer, else make normal visualizer
   if i % 2 == 0 then
      local vis1 = newinst("Frame", scrgui) -- bass visualizer
      vis1.AnchorPoint = Vector2.new(0.5,0.5)
      vis1.BackgroundTransparency= 0
      vis1.Size = UDim2.new(0,100,0,60)
      vis1.Position = UDim2.new(0,(i*60),1,0)
      vis1.BorderSizePixel = 0
      vis1.BackgroundColor3 = Color3.fromHSV(theme.PlaybackLoudness/255, 2,1)
      vis1.BackgroundTransparency = 0.3
      vis1.ZIndex = 2

      game:GetService('RunService'):BindToRenderStep("vis1 number "..i, 1, function()
        vis1:TweenSize(UDim2.new(0, 100, 0, basstheme.PlaybackLoudness*3), Enum.EasingDirection.Out,Enum.EasingStyle.Sine, 0.03, true)
        vis1.BackgroundColor3 = vis1.BackgroundColor3:lerp(Color3.fromHSV(theme.PlaybackLoudness/255, 2,1), 0.1)
      end)
   else
      local vis2 = newinst("Frame", scrgui) -- normal visualizer
      vis2.AnchorPoint = Vector2.new(0.5,0.5)
      vis2.BackgroundTransparency= 0
      vis2.Size = UDim2.new(0,100,0,60)
      vis2.Position = UDim2.new(0,(i*60),1,0)
      vis2.BorderSizePixel = 0
      vis2.BackgroundColor3 = Color3.fromHSV(theme.PlaybackLoudness/255, 2,1)
      vis2.BackgroundTransparency = 0.3

      game:GetService('RunService'):BindToRenderStep("vis2 number "..i, 1, function()
        vis2:TweenSize(UDim2.new(0, 100, 0, theme.PlaybackLoudness*3), Enum.EasingDirection.Out,Enum.EasingStyle.Sine, 0.2, true)
        vis2.BackgroundColor3 = vis2.BackgroundColor3:lerp(Color3.fromHSV(basstheme.PlaybackLoudness/255, 2,1), 0.1)
      end)
   end
end

-- enable breaker when humanoid is dead (continue 1)
hum.Died:Connect(function()
    breaker = true
end)

while true do
    -- counter for sine wave and other purposes
    a += 1

    -- when breaker is enabled, destroy all instances and break loop (continued 1)
    if breaker == true then
        bassydoomtheme:Destroy()
        doomtheme:Destroy()
        scrgui:Destroy()
        break
    end
   
    if theme.PlaybackLoudness >= 120 then
        if a % 2 == 0 then
            -- create lines that move to the center of the screen
            local ab = newinst("Frame", scrgui)
            ab.AnchorPoint = Vector2.new(0.5,0.5)
            ab.BackgroundTransparency= 0
            ab.Size = UDim2.new(0,3,1,0)
            ab.Position = UDim2.new(1,0,0.5,0)
            ab.BorderSizePixel = 0
            ab.BackgroundColor3 = Color3.fromHSV(theme.PlaybackLoudness/255, 2,1)
            table.insert(move1, ab)

            -- create lines that move to center of screen
            local ab = newinst("Frame", scrgui)
            ab.AnchorPoint = Vector2.new(0.5,0.5)
            ab.BackgroundTransparency= 0
            ab.Size = UDim2.new(0,3,1,0)
            ab.Position = UDim2.new(0,0,0.5,0)
            ab.BorderSizePixel = 0
            ab.BackgroundColor3 = Color3.fromHSV(theme.PlaybackLoudness/255, 2,1)
            table.insert(move2, ab)

            -- clone rotating square twice and make them move in two directions opposite
            local sq = square:Clone()
            sq.Parent = scrgui
            table.insert(move1, sq)
            local sq2 = square:Clone()
            sq2.Parent = scrgui
            table.insert(move2, sq2)
        end

        -- vignette
        overlay.ImageTransparency = 0
        overlay.Rotation = basstheme.PlaybackLoudness / 50
        overlay.ImageColor3 = overlay.ImageColor3:lerp(Color3.fromHSV(theme.PlaybackLoudness/255, 2,1), 0.1)

        -- camera shaking effect for bass
        hum.CameraOffset = Vector3.new(0, basstheme.PlaybackLoudness/230 ,0)
    else
        -- fade vignette out
        overlay.ImageTransparency  +=  0.1

        -- reset camera positioning
        hum.CameraOffset = Vector3.zero()
    end

    -- fade and move instances in move1
    for i, v in next, move1 do
        -- increment position and transparency
        v.Position -= UDim2.new(0,9,0,0)
        v.BackgroundTransparency += 0.01
 
        -- if transparency is equal to or more than 1 then destroy instance
        if v.BackgroundTransparency >= 1 then
            v:Destroy()
        end
    end

    -- fade and move instances in move2
    for i, v in next, move2 do
        -- increment position and transparency
        v.Position -= UDim2.new(0,-9,0,0)
        v.BackgroundTransparency += 0.01

        -- if transparency is equal to or more than 1 then destroy instance
        if v.BackgroundTransparency >= 1 then
            v:Destroy()
        end
    end

    -- rotate square according to theme loudness
    square.Rotation += 3 + theme.PlaybackLoudness/150

    -- anti-crash your roblox client :troll:
    task.wait()
end
