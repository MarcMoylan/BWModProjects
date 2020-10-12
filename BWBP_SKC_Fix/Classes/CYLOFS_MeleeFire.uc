//=============================================================================
// A73SecondaryFire.
//
// Bayonette melee attack for the A73
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class CYLOFS_MeleeFire extends BallisticInstantFire;

simulated event ModeDoFire()
{
	super.ModeDoFire();
	BW.GunLength = BW.default.GunLength;
}
simulated event ModeHoldFire()
{
	super.ModeHoldFire();
	BW.GunLength=1;
}

defaultproperties
{
     TraceRange=(Min=110.000000,Max=110.000000)
     Damage=(Min=50.000000,Max=80.000000)
     DamageHead=(Min=80.000000,Max=120.000000)
     DamageLimb=(Min=20.000000,Max=40.000000)
     DamageType=Class'BWBP_SKC_Fix.DTCYLOMk2Stab'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTCYLOMk2StabHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTCYLOMk2Stab'
     KickForce=100
     HookStopFactor=1.700000
     HookPullForce=100.000000
     bUseRunningDamage=True
     RunningSpeedThresh=1000.000000
     bUseWeaponMag=False
     bReleaseFireOnDie=False
     bIgnoreReload=True
     ScopeDownOn=SDO_PreFire
     BallisticFireSound=(Sound=Sound'BallisticSounds3.A73.A73Stab',Radius=32.000000,Pitch=1.250000,bAtten=True)
     bAISilent=True
     bFireOnRelease=True
     PreFireAnim="PrepMelee"
     FireAnim="Melee"
     TweenTime=0.000000
     FireRate=0.300000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_CYLOInc'
     AmmoPerFire=0
     ShakeRotTime=1.000000
     ShakeOffsetMag=(X=5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=0.700000
     WarnTargetPct=0.050000
}
