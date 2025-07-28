local plr = game:GetService("Players").LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

local gui = plr.PlayerGui:WaitForChild("Abilities")
local absFrame = gui:WaitForChild("AbilitiesFrame")

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local repStorage = game:GetService("ReplicatedStorage")
local textChatService = game:GetService("TextChatService")
local events = repStorage:WaitForChild("Events")
local modules = repStorage:WaitForChild("Modules")
local UIS = game:GetService("UserInputService")

local abilitiesModule = require(modules:WaitForChild("Abilities"))

local currentChar = "char1"
abilitiesModule:LoadCharAbilities("Character_1")

local function InputBegan(input: InputObject, isTyping)
	if isTyping then return end

	local charAbilities = abilitiesModule.Abilities[currentChar]
	if not charAbilities then return end

	for abilityName, ability in pairs(charAbilities) do
		if ability.Keybind == input.KeyCode then
			local abilitySquare = absFrame:FindFirstChild(abilityName)
			ability.Function(abilitySquare, ability.Cooldown)
		end
	end
end

local function ChangeCharacter(charToSet)
	warn("Changed character to:", charToSet)
	abilitiesModule:LoadCharAbilities(charToSet)
	currentChar = charToSet
	return
end

UIS.InputBegan:Connect(InputBegan)
events:WaitForChild("ChangeCharacter").OnClientEvent:Connect(ChangeCharacter)

textChatService.OnIncomingMessage = function(message, channelName)
	if message.TextSource and message.TextSource.UserId == plr.UserId then
		local text = message.Text

		if text:sub(1,1) == "/" then
			message.Text = ""
			
			local space = string.find(text, " ") or #text
			
			if string.sub(text, 2, space - 1) == "setChar" then
				events:WaitForChild("ChangeCharacter"):FireServer(string.sub(text, space + 1))
			end
		end
	end
end
