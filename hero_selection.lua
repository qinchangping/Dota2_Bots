local utils = require(GetScriptDirectory() .. "/util")

-- mandate that the bots will pick these heroes - for testing purposes
requiredHeroes = {
    --'npc_dota_hero_rattletrap';
    'npc_dota_hero_meepo';
    'npc_dota_hero_puck';
    --'npc_dota_hero_monkey_king';
    --'npc_dota_hero_bane';
    --'npc_dota_hero_lina';
    --'npc_dota_hero_nevermore';
};

-- change quickMode to true for testing
-- quickMode eliminates the 30s delay before picks begin
-- it also eliminates the delay between bot picks
quickMode = true;

allBotHeroes = {
        'npc_dota_hero_axe',
        'npc_dota_hero_bane',
        'npc_dota_hero_bloodseeker',
        'npc_dota_hero_bounty_hunter',
        'npc_dota_hero_bristleback',
        'npc_dota_hero_chaos_knight',
        'npc_dota_hero_crystal_maiden',
        'npc_dota_hero_dazzle',
        'npc_dota_hero_death_prophet',
        'npc_dota_hero_dragon_knight',
        'npc_dota_hero_drow_ranger',
        'npc_dota_hero_earthshaker',
        'npc_dota_hero_jakiro',
        'npc_dota_hero_juggernaut',
        'npc_dota_hero_kunkka',
        'npc_dota_hero_lich',
        'npc_dota_hero_lina',
        'npc_dota_hero_lion',
        'npc_dota_hero_luna',
        'npc_dota_hero_meepo',
        'npc_dota_hero_necrolyte',
        'npc_dota_hero_nevermore',
        'npc_dota_hero_omniknight',
        'npc_dota_hero_oracle',
        'npc_dota_hero_phantom_assassin',
        'npc_dota_hero_puck',
        'npc_dota_hero_pudge',
        'npc_dota_hero_razor',
        'npc_dota_hero_sand_king',
        'npc_dota_hero_skeleton_king',
        'npc_dota_hero_skywrath_mage',
        'npc_dota_hero_sniper',
        'npc_dota_hero_sven',
        'npc_dota_hero_tidehunter',
        'npc_dota_hero_tiny',
        'npc_dota_hero_vengefulspirit',
        'npc_dota_hero_viper',
        'npc_dota_hero_warlock',
        'npc_dota_hero_windrunner',
        'npc_dota_hero_witch_doctor',
        'npc_dota_hero_zuus'
};

picks = {};
maxPlayerID = 15;
-- CHANGE THESE VALUES IF YOU'RE GETTING BUGS WITH BOTS NOT PICKING (or infinite loops)
-- To find appropriate values, start a game, open a console, and observe which slots are
-- being used by which players/teams. maxPlayerID shoulud just be the highest-numbered
-- slot in use.

slots = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
-- TODO
-- 1. determine which slots contain players - don't pick for those slots
-- 2. determine what heroes have already been picked - don't pick those heroes - DONE
-- 4. copy the default behavior of picking everything at once after players have picked, though
-- 5. add some jitter, so the bots pick at slightly more random times
-- 6. reimplement farm priority based system
function Think()
    for _,i in pairs(slots) do
        if IsPlayerInHeroSelectionControl(i) then
            if IsPlayerBot(i) then
                hero = GetRandomHero()
                SelectHero(i, hero);
            end
        end
    end
end

function IsTeamsTurnToPick(team)
  local radiantHeroCount = 0;
  local direHeroCount = 0;
  for pickedSlot, hero in pairs(picks) do
    if slotBelongsToTeam(pickedSlot, TEAM_RADIANT) then
      radiantHeroCount = radiantHeroCount + 1;
    else
      direHeroCount = direHeroCount + 1;
    end
  end
  if (team == TEAM_RADIANT) then
    return (radiantHeroCount <= direHeroCount);
  else
    return (direHeroCount <= radiantHeroCount);
  end
end

function IsSlotEmpty(slot)
  local slotEmpty = true;
  for pickedSlot, hero in pairs(picks) do
    -- print("pickedSlot is", pickedSlot);
    -- print("hero is", hero);
        if (pickedSlot == slot) then
            slotEmpty = false;
        end
  end
  -- print("slotempty is ", slotEmpty);
  return slotEmpty;
end

function PickHero(slot)
  local hero = GetRandomHero();
  --print("picking hero ", hero, " for slot ", slot);
  SelectHero(slot, hero);
end

-- haven't found a better way to get already-picked heroes than just looping over all the players
function GetPicks()
    local selectedHeroes = {};
  local pickedSlots = {};
    for i=0, maxPlayerID do
        local hName = GetSelectedHeroName(i);
        if (hName ~= nil and hName ~= "") then
            selectedHeroes[i] = hName;
        end
    end
    return selectedHeroes;
end

-- PLACEHOLDER
-- need to figure out an actual way to determine this, not just hardcoding it
function slotBelongsToTeam(slot, team)
  if (team == TEAM_RADIANT) then
    for index,rSlot in pairs(radiantSlots) do
      if (slot == rSlot) then
        return true;
      end;
    end
  elseif (team == TEAM_DIRE) then
    for index,dSlot in pairs(direSlots) do
      if (slot == dSlot) then
        return true;
      end
    end
  end
    return false;
end

-- first, check the list of required heroes and pick from those
-- then try the whole bot pool
function GetRandomHero()
    local hero;
    local picks = GetPicks();
  local selectedHeroes = {};
  for slot, hero in pairs(picks) do
    selectedHeroes[hero] = true;
  end

    --force required to dire
    --if GetTeam() == 3 then
        hero = requiredHeroes[RandomInt(1, #requiredHeroes)];
    --end

    if (hero == nil) then
        hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
    end

    while ( selectedHeroes[hero] == true ) do
        --print("repicking because " .. hero .. " was taken.")
        hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
    end

    return hero;
end

function UpdateLaneAssignments()    
    local lanecount = {
        [LANE_NONE] = 5,
        [LANE_MID] = 1,
        [LANE_TOP] = 2,
        [LANE_BOT] = 2,
    };

    local lanes = {
        [1] = LANE_MID,
        [2] = LANE_TOP,
        [3] = LANE_TOP,
        [4] = LANE_BOT,
        [5] = LANE_BOT,
        };

    local playercount = 0

    if ( GetTeam() == TEAM_RADIANT )
    then 
        local ids = GetTeamPlayers(TEAM_RADIANT)
        for i,v in pairs(ids) do
            --print(tostring(IsPlayerBot(v)))
            if not IsPlayerBot(v) then
                playercount = playercount + 1
            end
        end

        for i=1,playercount do
            local lane = GetLane( TEAM_RADIANT,GetTeamMember( TEAM_RADIANT, i ) )
            lanecount[lane] = lanecount[lane] - 1
            lanes[i] = lane 
        end

        for i=(playercount + 1), 5 do
            if lanecount[LANE_MID] > 0 then
                lanes[i] = LANE_MID
                lanecount[LANE_MID] = lanecount[LANE_MID] - 1
            elseif lanecount[LANE_TOP] > 0 then
                lanes[i] = LANE_TOP
                lanecount[LANE_TOP] = lanecount[LANE_TOP] - 1
            else
                lanes[i] = LANE_BOT
            end
        end
        return lanes
    elseif ( GetTeam() == TEAM_DIRE )
    then
        local ids = GetTeamPlayers(TEAM_DIRE)
        for i,v in pairs(ids) do
            --print(tostring(IsPlayerBot(v)))
            if not IsPlayerBot(v) then
                playercount = playercount + 1
            end
        end

        for i=1,playercount do
            local lane = GetLane( TEAM_DIRE, GetTeamMember( TEAM_DIRE, i ) )
            lanecount[lane] = lanecount[lane] - 1
            lanes[i] = lane 
        end

        for i=(playercount + 1), 5 do
            if lanecount[LANE_MID] > 0 then
                lanes[i] = LANE_MID
                lanecount[LANE_MID] = lanecount[LANE_MID] - 1
            elseif lanecount[LANE_TOP] > 0 then
                lanes[i] = LANE_TOP
                lanecount[LANE_TOP] = lanecount[LANE_TOP] - 1
            else
                lanes[i] = LANE_BOT
            end
        end
        --utils.print_r(lanes)
        return lanes
    end
end

function GetLane( nTeam ,hHero )

        local vBot = GetLaneFrontLocation(nTeam, LANE_BOT, 0)
        local vTop = GetLaneFrontLocation(nTeam, LANE_TOP, 0)
        local vMid = GetLaneFrontLocation(nTeam, LANE_MID, 0)
        --print(GetUnitToLocationDistance(hHero, vMid))
        if GetUnitToLocationDistance(hHero, vBot) < 2500 then
            return LANE_BOT
        end
        if GetUnitToLocationDistance(hHero, vTop) < 2500 then
            return LANE_TOP
        end
        if GetUnitToLocationDistance(hHero, vMid) < 2500 then
            return LANE_MID
        end
        return LANE_NONE
end