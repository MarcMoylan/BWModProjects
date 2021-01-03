//=============================================================================
// SRSM2SecondaryFire.
//
// Installs the elemental amp on the weapon
//
// by Sarge
// Copyright(c) 2020 Sarge. All rights Sarge.
//=============================================================================
class SRSM2SecondaryFire extends BallisticFire;

event ModeDoFire()
{
	if (Weapon.Role == ROLE_Authority)
		SRSM2BattleRifle(Weapon).ToggleAmplifier();
}

defaultproperties
{
     bUseWeaponMag=False
     bWaitForRelease=True
     bModeExclusive=False
     FireRate=0.200000
     AmmoClass=Class'BallisticFix.Ammo_RS762mm'
     AmmoPerFire=0
     BotRefireRate=0.300000
}
