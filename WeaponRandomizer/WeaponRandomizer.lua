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
    AddTraitToHero({ TraitName = newWeaponAspect.Name, Rarity = "Legendary" })
    ModUtil.Hades.PrintOverhead("Equipped " .. newWeaponAspect.FriendlyName, 2)
  end
end

function WR.GetEquippedWeaponAspect()
  for i, currentWeaponData in ipairs(WR.WeaponAspectData) do
    for i, aspectTrait in ipairs(currentWeaponData.Aspects) do
      if HeroHasTrait(aspectTrait.Name) then
        return {
          Weapon = currentWeaponData.Name,
          Aspect = aspectTrait.Name,
        }
      end
    end
  end 
end

WR.WeaponAspectData = {
  [1] = {
      Name = "SwordWeapon",
      Aspects = {
         [1] = { 
          Name="SwordBaseUpgradeTrait",
          FriendlyName="Zagreus Sword"
         },
         [2] = { 
          Name="SwordCriticalParryTrait",
          FriendlyName="Nemesis Sword"
         },
         [3] = { 
          Name="DislodgeAmmoTrait",
          FriendlyName="Poseidon Sword"
         },
         [4] = { 
          Name="SwordConsecrationTrait",
          FriendlyName="Arthur Sword"
         }
      }
  },
  [2] = {
      Name = "SpearWeapon",
      Aspects = {
          [1] = { 
            Name="SpearBaseUpgradeTrait",
            FriendlyName="Zagreus Spear"
           },
          [2] = { 
            Name="SpearTeleportTrait",
            FriendlyName="Achilles Spear"
           },
          [3] = { 
            Name="SpearWeaveTrait",
            FriendlyName="Hades Spear"
           },
          [4] = { 
            Name="SpearSpinTravel", 
            FriendlyName="Guan Yu Spear"
           }      
      }
  },
  [3] = {
      Name = "ShieldWeapon",
      Aspects = {
          [1] = { 
            Name="ShieldBaseUpgradeTrait",
            FriendlyName="Zagreus Shield"
           },
          [2] = { 
            Name="ShieldRushBonusProjectileTrait",
            FriendlyName="Chaos Shield"
           },
          [3] = { 
            Name="ShieldTwoShieldTrait",
            FriendlyName="Zeus Shield"
           },
          [4] = { 
            Name="ShieldLoadAmmoTrait",
            FriendlyName="Beowulf Shield"
           }
      }
  },
  [4] = {
      Name = "BowWeapon",
      Aspects = {
          [1] = { 
            Name="BowBaseUpgradeTrait",
            FriendlyName="Zagreus Bow"
           },
          [2] = { 
            Name="BowMarkHomingTrait",
            FriendlyName="Chiron Bow"
           },
          [3] = { 
            Name="BowLoadAmmoTrait",
            FriendlyName="Hera Bow"
           },
          [4] = { 
            Name="BowBondTrait",
            FriendlyName="Rama Bow"
           }
      }
  },
  [5] = {
      Name = "FistWeapon",
      Aspects = {
          [1] = { 
            Name="FistBaseUpgradeTrait",
            FriendlyName="Zagreus Fists"
           },
          [2] = { 
            Name="FistVacuumTrait",
            FriendlyName="Talos Fists"
           },
          [3] = { 
            Name="FistWeaveTrait",
            FriendlyName="Demeter Fists"
           },
          [4] = { 
            Name="FistDetonateTrait",
            FriendlyName="Gilgamesh Fists"
           }
      }
  },
  [6] = {
      Name = "GunWeapon",
      Aspects = {
          [1] = { 
            Name="GunBaseUpgradeTrait",
            FriendlyName="Zagreus Rail"
           },
          [2] = { 
            Name="GunGrenadeSelfEmpowerTrait",
            FriendlyName="Eris Rail"
           },
          [3] = { 
            Name="GunManualReloadTrait",
            FriendlyName="Hestia Rail"
           },
          [4] = { 
            Name="GunLoadedGrenadeTrait",
            FriendlyName="Lucifer Rail"
           }
      }
  }
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
