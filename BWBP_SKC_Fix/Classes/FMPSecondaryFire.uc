//=============================================================================
// FMPSecondaryFire.
//
// Installs the elemental amp on the weapon
//
// by Sarge
// Copyright(c) 2020 Sarge. All rights Sarge.
//=============================================================================
class FMPSecondaryFire extends BallisticFire;

event ModeDoFire()
{
	if (Weapon.Role == ROLE_Authority)
		FMPMachinePistol(Weapon).WeaponSpecial();
}

defaultproperties
{
     bUseWeaponMag=False
     bWaitForRelease=True
     bModeExclusive=False
     FireRate=0.200000
     AmmoClass=Class'BallisticFix.Ammo_XRS10Bullets'
     AmmoPerFire=0
     BotRefireRate=0.300000
}
