if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local requests = http_request or request
local inventory = game:GetService("ReplicatedStorage").Remotes.GetInventory:InvokeServer()
local plr = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

getgenv().data = {
    Username = plr.Name, 
    units = {}, 
    Story = "",
    Level = 0,
    Trait_Crystal = 0,
    first_gem = nil,
    risky_dice = 0,
    last_gem = 0,
    time = 0,
    Status = "Lobby",
}

function getunits() 
    local a = {}
    for i,v in pairs(inventory.Units) do
        table.insert(a, v.Type)
    end
    return a
end

function getinfomap()
    local a = 0
    for i,v in pairs(inventory.Chapters) do
        if v.Unlocked == true and i ~= "FooshaVillage_Infinite" and string.find(tostring(i), "FooshaVillage") then
            a = a + 1
        end
    end
    return a
end

local function sendMessageToServer(data)
    local Url = 'http://103.176.24.132:2008/sendMessage'
    
    local jsonData = HttpService:JSONEncode(data)

    local Response = requests {
        Method = 'POST',
        Url = Url,
        Headers = {
            ['Content-Type'] = 'application/json',
        },
        Body = jsonData,
    }

    print("Server Response Status: " .. Response.StatusCode)
    if Response.StatusCode ~= 200 then 
        print("Failed to send the message. Server responded with: " .. Response.Body)
        return false 
    end

    print("Message sent successfully!")
    return Response.Body
end

while true do 
    wait(15)
    local LocalPlayer = game.Players.LocalPlayer
    local playerData = {
        Username = LocalPlayer.Name,
        units = getunits(),
        Story = getinfomap() .. "/6",
        Level = inventory.Level,
        Trait_Crystal = inventory.Items["Trait Crystal"] or 0,
        risky_dice = inventory.Items["Risky Dice"] or 0,
        Status = (game.PlaceId == 17764698696) and "Lobby" or "In Game",
    }

    debugLog("Sending player data to the server.")
    sendMessageToServer(playerData)  -- Gửi dữ liệu người chơi đến máy chủ
end
