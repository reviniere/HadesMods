ModUtil.Mod.Register( "WeaponRandomizer" )

local WR = WeaponRandomizer

ModUtil.Path.Wrap( "LeaveRoom",
  function ( base, ... )
    WR.RandomWeapon()
    base(...)
  end
)

ModUtil.Path.Wrap( "StartRoom", 
  function ( base, ... )
    WR.CustomAnvil()
    base(...)
  end
)

function WR.RandomWeapon()
  local currentWeapon = WR.GetEquippedWeaponAspect()
  local newWeaponData = GetRandomValue( WR.WeaponAspectData )
  local newWeaponAspect = GetRandomValue( newWeaponData.Aspects )
  if newWeaponData then
    RemoveTrait(CurrentRun.Hero, currentWeapon.Aspect)
    EquipPlayerWeapon( WeaponData[newWeaponData.Name], { PreLoadBinks = true } )
    AddTraitToHero({ TraitName = newWeaponAspect, Rarity = "Legendary" })
  end
end

function WR.GetEquippedWeaponAspect()
  for i, currentWeaponData in ipairs(WR.WeaponAspectData) do
    for i, aspectTrait in ipairs(currentWeaponData.Aspects) do
      if HeroHasTrait(aspectTrait) then
        return {
          Weapon = currentWeaponData.Name,
          Aspect = aspectTrait,
        }
      end
    end
  end 
end

WR.WeaponAspectData = {
  [1] = {
      Name = "SwordWeapon",
      Aspects = {
         [1] = "SwordBaseUpgradeTrait",
         [2] = "SwordCriticalParryTrait",
         [3] = "DislodgeAmmoTrait",
         [4] = "SwordConsecrationTrait",
      }
  },
  [2] = {
      Name = "SpearWeapon",
      Aspects = {
          [1] = "SpearBaseUpgradeTrait",
          [2] = "SpearTeleportTrait",
          [3] = "SpearWeaveTrait",
          [4] = "SpearSpinTravel",            
      }
  },
  [3] = {
      Name = "ShieldWeapon",
      Aspects = {
          [1] = "ShieldBaseUpgradeTrait",
          [2] = "ShieldRushBonusProjectileTrait",
          [3] = "ShieldTwoShieldTrait",
          [4] = "ShieldLoadAmmoTrait",
      }
  },
  [4] = {
      Name = "BowWeapon",
      Aspects = {
          [1] = "BowBaseUpgradeTrait",
          [2] = "BowMarkHomingTrait",
          [3] = "BowLoadAmmoTrait",
          [4] = "BowBondTrait",
      }
  },
  [5] = {
      Name = "FistWeapon",
      Aspects = {
          [1] = "FistBaseUpgradeTrait",
          [2] = "FistVacuumTrait",
          [3] = "FistWeaveTrait",
          [4] = "FistDetonateTrait",
      }
  },
  [6] = {
      Name = "GunWeapon",
      Aspects = {
          [1] = "GunBaseUpgradeTrait",
          [2] = "GunGrenadeSelfEmpowerTrait",
          [3] = "GunManualReloadTrait",
          [4] = "GunLoadedGrenadeTrait",
      }
  },
}

function WR.CustomAnvil()
	local hammerTraits = {}
	local addedTraits = {}
  local numTraits = 0

	for i, trait in pairs( CurrentRun.Hero.Traits ) do
		if LootData.WeaponUpgrade.TraitIndex[trait.Name] then
			table.insert(hammerTraits, trait.Name )
      numTraits = numTraits + 1
		end
	end

	local removedTraitNames = {}
  for i = 1 , numTraits do
    if not IsEmpty( hammerTraits ) then
      removedTraitName = RemoveRandomValue( hammerTraits )
      table.insert(removedTraitNames, removedTraitName)
      RemoveWeaponTrait( removedTraitName )
    end
  end

	for i = 1, numTraits do
		local validTraitNames = {}
		for i, traitName in pairs( LootData.WeaponUpgrade.Traits ) do
			if IsTraitEligible(CurrentRun, TraitData[traitName]) and not Contains(removedTraitNames, traitName) and not Contains(hammerTraits, traitName) then
				table.insert( validTraitNames, traitName )
			end
		end

		if not IsEmpty( validTraitNames ) then
			local newTraitName = RemoveRandomValue( validTraitNames )
			AddTraitToHero({ TraitName =  newTraitName })
			table.insert( hammerTraits, newTraitName )
			table.insert( addedTraits, newTraitName )
		end
	end
		
	thread( WR.CustomAnvilPresentation, removedTraitNames, addedTraits )
end

function WR.CustomAnvilPresentation( traitsRemoved, traitsAdded )
  wait(1)
  local offsetY = -80
  for _, traitRemoved in pairs( traitsRemoved ) do
    CreateAnimation({ Name = "ItemGet_PomUpgraded", DestinationId = CurrentRun.Hero.ObjectId, Scale = 2.0 })
    thread( InCombatTextArgs, { TargetId = CurrentRun.Hero.ObjectId, Text = "ChaosAnvilRemove_CombatText", SkipRise = false, SkipFlash = false, ShadowScale = 0.75, OffsetY = offsetY, Duration = 1.5, LuaKey = "TempTextData", LuaValue = { Name = traitRemoved }})
    wait(0.25)
    offsetY = offsetY - 60
  end
  for _, traitName in pairs( traitsAdded ) do
    PlaySound({ Name = "/SFX/WeaponUpgradeHammerPickup", DestinationId = CurrentRun.Hero.ObjectId })
    CreateAnimation({ Name = "ItemGet_PomUpgraded", DestinationId = CurrentRun.Hero.ObjectId, Scale = 2.0 })
    thread( InCombatTextArgs, { TargetId = CurrentRun.Hero.ObjectId, Text = "ChaosAnvilAdd_CombatText", SkipRise = false, SkipFlash = false, ShadowScale = 0.75, OffsetY = offsetY, Duration = 1.5, LuaKey = "TempTextData", LuaValue = { Name = traitName }})
    wait(0.25)
    offsetY = offsetY - 60
  end
end
