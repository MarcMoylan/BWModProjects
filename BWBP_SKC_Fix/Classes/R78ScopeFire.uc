//=============================================================================
// BallisticScopeFire.
//
// Use this for when a firemode should use the scope or sights.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class R78ScopeFire extends BallisticFire;

// Match ammo to other mode
simulated function PostBeginPlay()
{
	if (ThisModeNum == 0 && Weapon.AmmoClass[1] != None)
		AmmoClass = Weapon.AmmoClass[1];
	else if (Weapon.AmmoClass[0] != None)
		AmmoClass = Weapon.AmmoClass[0];
	super.PostBeginPlay();
}
// Send sight key release event to weapon
simulated event ModeDoFire()
{
	if (AllowFire() && Instigator.IsLocallyControlled() && BW != None)
    	BW.ScopeViewRelease();
}
// Send sight key press event to weapon
simulated function PlayPreFire()
{
	if (Instigator.IsLocallyControlled() && BW != None)
		BW.ScopeView();
}

defaultproperties
{
     bUseWeaponMag=False
     bFireOnRelease=True
     bModeExclusive=False
     FireAnim=
     TweenTime=0.000000
     FireRate=0.200000
     AmmoPerFire=0
     BotRefireRate=0.300000
}
