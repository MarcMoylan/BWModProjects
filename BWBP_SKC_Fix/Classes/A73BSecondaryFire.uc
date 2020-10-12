//=============================================================================
// A73SecondaryFire.
//
// Bayonette melee attack for the A73
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class A73BSecondaryFire extends BallisticInstantFire;

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
     TraceRange=(Min=160.000000,Max=160.000000)
     Damage=(Min=75.000000,Max=95.000000)
     DamageHead=(Min=100.000000,Max=150.000000)
     DamageLimb=(Min=35.000000,Max=55.000000)
     DamageType=Class'BWBP_SKC_Fix.DTA73bStab'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTA73bStabHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTA73bStab'
     KickForce=100
     HookStopFactor=1.700000
     HookPullForce=100.000000
     bUseRunningDamage=True
     RunningSpeedThresh=1000.000000
     bUseWeaponMag=False
     bReleaseFireOnDie=False
     bIgnoreReload=True
     ScopeDownOn=SDO_PreFire
     BallisticFireSound=(Sound=SoundGroup'BallisticSounds3.EKS43.EKS-Slash',Radius=32.000000,bAtten=True)
     bAISilent=True
     bFireOnRelease=True
     PreFireAnim="PrepStab"
     FireAnim="Stab"
     TweenTime=0.000000
     FireRate=0.300000
     AmmoClass=Class'BallisticFix.Ammo_Cells'
     AmmoPerFire=0
     ShakeRotTime=1.000000
     ShakeOffsetMag=(X=5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=0.700000
     WarnTargetPct=0.050000
}
