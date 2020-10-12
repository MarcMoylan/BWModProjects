//=============================================================================
// M806SecondaryFire.
//
// Activates laser sight for pistol
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AH104SecondaryFire extends BallisticFire;

event ModeDoFire()
{
	if (Weapon.Role == ROLE_Authority)
		AH104Pistol(Weapon).ServerSwitchlaser(!AH104Pistol(Weapon).bLaserOn);
}

defaultproperties
{
     bUseWeaponMag=False
     bWaitForRelease=True
     bModeExclusive=False
     FireRate=0.200000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_600HEAP'
     AmmoPerFire=0
     BotRefireRate=0.300000
}
