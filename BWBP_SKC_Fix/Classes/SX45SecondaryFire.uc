//=============================================================================
// SX45SecondaryFire.
//
// Installs the elemental amp on the weapon
//
// by Sarge
// Copyright(c) 2020 Sarge. All rights reserved.
//=============================================================================
class SX45SecondaryFire extends BallisticFire;

event ModeDoFire()
{
	if (Weapon.Role == ROLE_Authority)
		SX45Pistol(Weapon).CommonSwitchAmplifier();
}

defaultproperties
{
     bUseWeaponMag=False
     bWaitForRelease=True
     bModeExclusive=False
     FireRate=0.200000
     AmmoClass=Class'BallisticFix.Ammo_45HV'
     AmmoPerFire=0
     BotRefireRate=0.300000
}
