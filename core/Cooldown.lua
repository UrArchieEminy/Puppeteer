PTUtil.SetEnvironment(Puppeteer)
local _G = getfenv(0)
local util = PTUtil
local SplitString = util.SplitString
local compost = AceLibrary("Compost-2.0")

local allBookSpells = {}

TRACKED_COOLDOWNS = {
    -- PALADIN GENERAL
    ["Hand of Freedom"] = {
        name = "Hand of Freedom",
        texture = "Interface\\Icons\\spell_holy_sealofvalor",
        duration = 24,
    },
    ["Hand of Protection"] = {
        name = "Hand of Protection",
        texture = "Interface\\Icons\\spell_holy_sealofprotection",
        duration = 5 * 60,
    },
    ["Divine Shield"] = {
        name = "Divine Shield",
        texture = "Interface\\Icons\\spell_holy_divineintervention",
        duration = 5 * 60,
    },
    ["Divine Intervention"] = {
        name = "Divine Intervention",
        texture = "Interface\\Icons\\spell_nature_timestop",
        duration = 60 * 60,
    },
    ["Lay on Hands"] = {
        name = "Lay on Hands",
        texture = "Interface\\Icons\\spell_holy_layonhands",
        duration = 60 * 60,
    },
    ["Hammer of Justice"] = {
        name = "Hammer of Justice",
        texture = "Interface\\Icons\\spell_holy_sealofmight",
        duration = 60,
    },
    -- TANK
    ["Bulwark of the Righteous"] = {
        name = "Bulwark of the Righteous",
        texture = "Interface\\Icons\\ability_warrior_victoryrush",
        duration = 5 * 60,
    },
    -- HEALER
    ["Holy Shock"] = {
        name = "Holy Shock",
        texture = "Interface\\Icons\\spell_holy_searinglight",
        duration = 15,
    },
    -- WARRIOR
    ["Last Stand"] = {
        name = "Last Stand",
        texture = "Interface\\Icons\\spell_holy_ashestoashes",
        duration = 10 * 60,
    },
    ["Shield Wall"] = {
        name = "Shield Wall",
        texture = "Interface\\Icons\\ability_warrior_shieldwall",
        duration = 30 * 60,
    },
    ["Death Wish"] = {
        name = "Death Wish",
        texture = "Interface\\Icons\\spell_shadow_deathpact",
        duration = 3 * 60,
    },
    ["Challenging Shout"] = {
        name = "Challenging Shout",
        texture = "Interface\\Icons\\ability_bullrush",
        duration = 2 * 60,
    },
    ["Mocking Blow"] = {
        name = "Mocking Blow",
        texture = "Interface\\Icons\\ability_warrior_punishingblow",
        duration = 2 * 60,
    },
    -- TANK
    ["Taunt"] = {
        name = "Taunt",
        texture = "Interface\\Icons\\spell_nature_reincarnation",
        duration = 10,
    },
    -- PRIEST GENERAL
    ["Power Word: Shield"] = {
        name = "Power Word: Shield",
        texture = "Interface\\Icons\\spell_holy_powerwordshield",
        duration = 4,
    },
    ["Fear Ward"] = {
        name = "Fear Ward",
        texture = "Interface\\Icons\\spell_holy_excorcism",
        duration = 30,
    },
    -- PRIEST HEALER
    ["Ascendance"] = {
        name = "Ascendance",
        texture = "Interface\\Icons\\spell_holy_purify",
        duration = 5 * 60,
    },
    --DRUID GENERAL
    ["Rebirth"] = {
        name = "Rebirth",
        texture = "Interface\\Icons\\spell_nature_reincarnation",
        duration = 30 * 60,
    },
    ["Innervate"] = {
        name = "Innervate",
        texture = "Interface\\Icons\\spell_nature_lightning",
        duration = 6 * 60,
    },
    ["Tranquility"] = {
        name = "Tranquility",
        texture = "Interface\\Icons\\spell_nature_tranquility",
        duration = 30 * 60,
    },
    -- DRUID HEALER
    ["Swiftmend"] = {
        name = "Swiftmend",
        texture = "Interface\\Icons\\inv_relics_idolofrejuvenation",
        duration = 15,
    },
    -- DRUID TANK
    ["BarkSkin(Feral)"] = {
        name = "BarkSkin(Feral)",
        texture = "Interface\\Icons\\spell_nature_stoneclawtotem",
        duration = 60 * 10,
    },
    ["Challenging Roar"] = {
        name = "Challenging Roar",
        texture = "Interface\\Icons\\ability_druid_challangingroar",
        duration = 10 * 60,
    },
    ["Frenzied Regeneration"] = {
        name = "Frenzied Regeneration",
        texture = "Interface\\Icons\\ability_bullrush",
        duration = 5 * 60,
    },
    ["Enrage"] = {
        name = "Enrage",
        texture = "Interface\\Icons\\ability_druid_enrage",
        duration = 60,
    },
    ["Feral Charge"] = {
        name = "Feral Charge",
        texture = "Interface\\Icons\\ability_hunter_pet_bear",
        duration = 15,
    },
    -- HUNTER
    ["Tranquilizing Shot"] = {
        name = "Tranquilizing Shot",
        texture = "Interface\\Icons\\spell_nature_drowsy",
        duration = 20,
    },
    -- WARLOCK
    ["Create Soulstone (Major)"] = {
        name = "Create Soulstone (Major)",
        texture = "Interface\\Icons\\spell_shadow_soulgem",
        duration = 30 * 60
    },
    -- SHAMAN HEALER
    ["Spirit Link"] = {
        name = "Spirit Link",
        texture = "Interface\\Icons\\spell_holy_purify",
        duration = 10 * 60
    }
}

local cooldownRegister = CreateFrame("Frame")
cooldownRegister:RegisterEvent("CHAT_MSG_ADDON")
cooldownRegister:SetScript("OnEvent", function()
    if arg1 == "TW_CHAT_MSG_WHISPER" then
        local message = arg2
        local sender = arg4

        if string.find(message, "CDShow;", 1, true) then -- person who is asked to get cooldowns from
            local spell = SplitString(message, ";")[2]
            local _, guid = UnitExists("player")
            if HasSpell(spell) then
                local start, duration = GetSpellCooldown(spell, "BOOKTYPE_SPELL")
                
                if not TRACKED_COOLDOWNS[spell] then
                    local _ , _, id = GetSpellName(spell)
                    local _, _, iconPath = SpellInfo(id)
                    local remain = start > 0 and duration - (GetTime() - start) or 0
                    local icon = string.sub(iconPath, 17)

                    SendAddonMessage("TW_CHAT_MSG_WHISPER<"..sender..">", "CDInfo;"..guid..";"..spell..";"..remain..";"..duration..";"..icon, "GUILD")
                    return
                end
                if start > 0 then
                    local remain = duration - (GetTime() - start)
                    SendAddonMessage("TW_CHAT_MSG_WHISPER<"..sender..">", "CDInfo;"..guid..";"..spell..";"..remain, "GUILD")
                end
            else
                SendAddonMessage("TW_CHAT_MSG_WHISPER<"..sender..">", "CDInfoBlacklist;"..guid..";"..spell, "GUILD")
            end
        end
        
        if string.find(message, "CDInfo;", 1, true) then -- person who sent the request to know the cooldowns
            local split = SplitString(message, ';')
            local unit = split[2]
            local spell = split[3]
            local remain = tonumber(split[4])
            if getn(split) > 4 then
                local duration = tonumber(split[5])
                local icon = "Interface\\Icons\\"..split[6]

                if not TRACKED_COOLDOWNS[spell] or TRACKED_COOLDOWNS[spell].duration == 0 then
                    TRACKED_COOLDOWNS[spell] = {["name"] = spell, ["texture"] = icon, ["duration"] = duration}
                end
            end

            for ui in UnitFrames(unit) do
                ui.currentCD[spell] = remain
            end
        end
        if string.find(message, "CDInfoBlacklist;", 1, true) then
            local split = SplitString(message, ';')
            local unit = split[2]
            local spell = split[3]

            for ui in UnitFrames(unit) do
                if not util.ArrayContains(ui.CooldownBlacklist, spell) then
                    table.insert(ui.CooldownBlacklist, spell)
                end
            end
        end

        if string.find(message, "CDShowEnd;", 1, true) then
            local _, guid = UnitExists("player")
            SendAddonMessage("TW_CHAT_MSG_WHISPER<"..sender..">", "CDEnd;"..guid, "GUILD")
        end
        if string.find(message, "CDEnd;", 1, true) then
            local split = SplitString(message, ';')
            local unit = split[2]

            for ui in UnitFrames(unit) do
                ui:GenerateCooldownFrames()
            end
        end
    end
end)

function getUnitCooldown(name, spells)
    for i, spell in ipairs(spells) do
        SendAddonMessage("TW_CHAT_MSG_WHISPER<"..name..">", "CDShow;"..spell, "GUILD")
        if i == getn(spells) then
            SendAddonMessage("TW_CHAT_MSG_WHISPER<"..name..">", "CDShowEnd;", "GUILD")
        end
    end
end

function PopulateBookSpells()
    for i = 1, GetNumSpellTabs() do
        local tabName, _, offset, n = GetSpellTabInfo(i)
        if tabName ~= "General" and tabName ~= "Companions" and tabName ~= "Mounts" and tabName ~= "Toys" then
            for i = offset + 1, offset + n do
                local spell = GetSpellName(i, "BS")
                if not util.ArrayContains(allBookSpells, spell) then
                    table.insert(allBookSpells, spell)
                end
            end
        end
    end
end

function HasSpell(spell)
    return util.ArrayContains(allBookSpells, spell)
end