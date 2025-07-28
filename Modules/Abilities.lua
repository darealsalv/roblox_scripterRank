local m = {}

local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()
local repStorage = game:GetService("ReplicatedStorage")
local events = repStorage:WaitForChild("Events")

local plr, gui, absFrame

if isClient then
	local Players = game:GetService("Players")
	plr = Players.LocalPlayer
	gui = plr.PlayerGui:WaitForChild("Abilities")
	absFrame = gui:WaitForChild("AbilitiesFrame")
else
	plr = nil
	gui = nil
	absFrame = nil
end


local ts = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local cooldownTweens = {}

m.AbilitySquaresInfo = {
	BackgroundColor = Color3.fromRGB(71, 71, 71),
	Transparency = 0.4,
	Size = UDim2.fromScale(0.039, 1),
	AnchorPoint = Vector2.new(0.5, 0.5)
}

m.TextsInfo = {
	Font = Font.new("rbxassetid://12187375716"),
	Scaled = true,
	Color = Color3.fromRGB(255, 255, 255)
}

local function CreateNewAbilitySquare(abilityName, layoutOrder)	
	local newFrame = Instance.new("Frame")	

	newFrame.Name = abilityName
	newFrame.LayoutOrder = layoutOrder
	newFrame.BackgroundColor3 = m.AbilitySquaresInfo.BackgroundColor
	newFrame.Transparency = m.AbilitySquaresInfo.Transparency
	newFrame.Size = m.AbilitySquaresInfo.Size
	newFrame.AnchorPoint = m.AbilitySquaresInfo.AnchorPoint
	newFrame.Parent = absFrame
	newFrame.ClipsDescendants = true
	newFrame:AddTag("Ability")

	local newText = Instance.new("TextLabel")
	
	newText.Name = "AbilityName"
	newText.FontFace = m.TextsInfo.Font
	newText.BackgroundTransparency = 1
	newText.TextScaled = m.TextsInfo.Scaled
	newText.TextColor3 = m.TextsInfo.Color
	newText.Text = abilityName
	newText.Size = UDim2.fromScale(0.9, 1)
	newText.AnchorPoint = Vector2.new(0.5, 0.5)
	newText.Position = UDim2.fromScale(0.5, 0.5)
	newText.Parent = newFrame
	
	local sizeConstraint = Instance.new("UITextSizeConstraint")
	sizeConstraint.MinTextSize = 28
	sizeConstraint.MaxTextSize = 30
	sizeConstraint.Parent = newText

	return newFrame
end

local function StartCooldownAnimation(abilitySquare, duration)	
	local alreadyInCooldown = false

	for i, cooldownTable in cooldownTweens do
		if cooldownTable[1] == abilitySquare then
			alreadyInCooldown = true
		end
	end

	if alreadyInCooldown then return end

	local redSquare = Instance.new("Frame")
	redSquare.BackgroundColor3 = Color3.fromRGB(255, 87, 90)
	redSquare.Size = UDim2.fromScale(1, 1)
	redSquare.Transparency = 0.65
	redSquare.AnchorPoint = Vector2.new(0.5, 0.5)
	redSquare.Position = UDim2.fromScale(0.5, 0.5)
	redSquare.Parent = abilitySquare

	local twInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tween = ts:Create(redSquare, twInfo, {Position = UDim2.fromScale(0.5, 1.5)})

	local infoToInsert = {
		abilitySquare,
		tween,
	}

	table.insert(cooldownTweens, infoToInsert)

	tween:Play()

	repeat task.wait()
	until tween.PlaybackState ~= Enum.PlaybackState.Playing and tween.PlaybackState ~= Enum.PlaybackState.Begin

	tween:Destroy()
	
	-- made like this to ensure in case tables are replaced and therefore their "Unique IDs" aren't the same
	for i, cooldownTable in cooldownTweens do 
		if cooldownTable[1] == abilitySquare then
			table.remove(cooldownTweens, i)
			break
		end
	end
	
	return
end

local function GetAbilityPath(targetAbility)
	for characterAbName, characterAb in m.Abilities do
		for abilityName, ability in characterAb do
			if ability == targetAbility then
				return characterAbName, abilityName
			end
		end
	end
end

local function FindHumanoidFromCharacterModel(part)
	local targetModel
	local targetHumanoid
	
	if not part then return end
	if not part.Parent then return end
	
	targetModel = part.Parent

	if not targetModel:IsA("Model") then
		if not targetModel.Parent then return end
		
		targetModel = part.Parent.Parent

		if not targetModel:IsA("Model") then return end -- assumes the target wasn't part of a character
	end

	return targetModel:FindFirstChildWhichIsA("Humanoid")
end

--[[ Abilities template:
		["AbilityName"] = {
			Keybind = Enum.KeyCode.REPLACEWITHKEYBIND,
			LayoutOrder = 1,
			Cooldown = 50,
			OnCooldown = false,
			-- you can add more values here if you want
			Function = function(abilitySquare)
				local characterAb = m.Abilities.REPLACEWITHCHARACTERNAME
				local abilityReference = characterAb.AbilityName

				local characterAbName, abilityName = GetAbilityPath(abilityReference)
				if not characterAbName or not abilityName then warn("Failed to get the character or ability name! Did you make a typo in the code?") return end
				
				if abilityReference.OnCooldown then return end
				abilityReference.OnCooldown = true

				task.spawn(StartCooldownAnimation, abilitySquare, abilityReference.Cooldown)

				print("Hello from client at ability:", abilityName.."!")
				
				events:WaitForChild("Ability"):FireServer(characterAbName, abilityName, {"Replace with a table of values you want to pass to the server", "String"})

				task.wait(abilityReference.Cooldown)
				abilityReference.OnCooldown = false

				return
			end,

			ServerFunction = function(abName, extraInfo: {})
				local characterAbName = m.Abilities.REPLACEWITHCHARACTERNAME
				local abilityReference = characterAbName.AbilityName

				print("Hello from server at ability:", abName.."!")
				print("This are the values received from the client:", extraInfo)
			end,
		},
]]

m.Abilities = {
	["char1"] = {
		["Heal"] = {
			Keybind = Enum.KeyCode.One,
			LayoutOrder = 1,
			Cooldown = 5,
			OnCooldown = false,
			HealAmount = 50,
			Function = function(abilitySquare)
				local characterAb = m.Abilities.char1
				local abilityReference = characterAb.Heal

				local characterAbName, abilityName = GetAbilityPath(abilityReference)
				if not characterAbName or not abilityName then warn("Failed to get the character or ability name! Did you make a typo in the code?") return end

				local mouse = plr:GetMouse()
				local target = mouse.Target

				local targetHumanoid = FindHumanoidFromCharacterModel(target)
				if not targetHumanoid then return end -- assumes it was not a valid character

				if abilityReference.OnCooldown then return end
				abilityReference.OnCooldown = true

				task.spawn(StartCooldownAnimation, abilitySquare, abilityReference.Cooldown)

				events:WaitForChild("Ability"):FireServer(characterAbName, abilityName, {targetHumanoid})

				task.wait(abilityReference.Cooldown)
				abilityReference.OnCooldown = false

				return
			end,

			ServerFunction = function(abName, extraInfo: {any})
				local characterAbName = m.Abilities.char1
				local abilityReference = characterAbName.Heal

				extraInfo[1].Health += abilityReference.HealAmount
			end,
		},
		
		["Kill"] = {
			Keybind = Enum.KeyCode.Two,
			LayoutOrder = 2,
			Cooldown = 25,
			OnCooldown = false,
			Function = function(abilitySquare)
				local characterAb = m.Abilities.char1
				local abilityReference = characterAb.Kill

				local characterAbName, abilityName = GetAbilityPath(abilityReference)

				local mouse = plr:GetMouse()
				local target = mouse.Target
				
				local targetHumanoid = FindHumanoidFromCharacterModel(target)
				if not targetHumanoid then return end -- assumes it was not a valid character

				if abilityReference.OnCooldown then return end
				abilityReference.OnCooldown = true

				task.spawn(StartCooldownAnimation, abilitySquare, abilityReference.Cooldown)

				events:WaitForChild("Ability"):FireServer(characterAbName, abilityName, {targetHumanoid})

				task.wait(abilityReference.Cooldown)
				abilityReference.OnCooldown = false

				return
			end,
			
			ServerFunction = function(abName, extraInfo: {})
				local characterAbName = m.Abilities.char1
				local abilityReference = characterAbName.Heal

				extraInfo[1]:TakeDamage(math.huge)
			end,
		}
	},
	
	["char2"] = {
		["Explosion"] = {
			Keybind = Enum.KeyCode.One,
			LayoutOrder = 1,
			Cooldown = 25,
			OnCooldown = false,
			Function = function(abilitySquare)
				local characterAb = m.Abilities.char2
				local abilityReference = characterAb.Explosion

				local characterAbName, abilityName = GetAbilityPath(abilityReference)
				if not characterAbName or not abilityName then warn("Failed to get the character or ability name! Did you make a typo in the character reference or the ability reference?") return end
				
				local mouse = plr:GetMouse()
				local target = mouse.Target
				
				local humanoid = FindHumanoidFromCharacterModel(target)
				if not humanoid then return end
				
				if abilityReference.OnCooldown then return end
				abilityReference.OnCooldown = true

				task.spawn(StartCooldownAnimation, abilitySquare, abilityReference.Cooldown)

				events:WaitForChild("Ability"):FireServer(characterAbName, abilityName, {humanoid, humanoid.Parent:FindFirstChildWhichIsA("Part").Position})

				task.wait(abilityReference.Cooldown)
				abilityReference.OnCooldown = false

				return
			end,

			ServerFunction = function(abName, extraInfo: {})
				local characterAbName = m.Abilities.char2
				local abilityReference = characterAbName.Explosion

				local newExplosion = Instance.new("Explosion")
				newExplosion.Position = extraInfo[2]
				newExplosion.Parent = workspace
			end,
		},
	}
}

local function RemoveOldAbilities()
	for i, v in absFrame:GetChildren() do
		if v:IsA("Frame") and v:HasTag("Ability") then
			v:Destroy()
		end
	end
	
	return
end

function m:LoadCharAbilities(charNameToLoad)
	local charAbilities = self.Abilities[charNameToLoad]
	
	if not charAbilities or next(charAbilities) == nil then
		warn("Couldn't load character abilities: "..charNameToLoad.." because the character doesn't have any set of abilities or it doesn't exist!")
		return
	end
	
	RemoveOldAbilities()
	
	for i, ability in self.Abilities[charNameToLoad] do
		CreateNewAbilitySquare(i, ability.LayoutOrder)
	end
end

return m
