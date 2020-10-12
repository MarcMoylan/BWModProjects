//=============================================================================
// CoachGunSecondaryFire.
//
// Melee attack for coach gun.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class CoachGunSecondaryFire extends BallisticMeleeFire;

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
//Check Sounds and damage types.

defaultproperties
{
     SwipePoints(0)=(Weight=6,offset=(Pitch=6000,Yaw=4000))
     SwipePoints(1)=(Weight=5,offset=(Pitch=4500,Yaw=3000))
     SwipePoints(2)=(Weight=4,offset=(Pitch=3000))
     SwipePoints(3)=(Weight=3,offset=(Pitch=1500,Yaw=1000))
     SwipePoints(4)=(Weight=2,offset=(Pitch=0,Yaw=0))
     SwipePoints(5)=(Weight=1,offset=(Pitch=-1500,Yaw=-1500))
     SwipePoints(6)=(offset=(Yaw=-3000))
     WallHitPoint=4
     Damage=75
     DamageHead=110
     DamageLimb=35
     DamageType=Class'BWBP_SKC_Fix.DTCoachMelee'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTCoachMeleeHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTCoachMelee'
     KickForce=2000
     bUseWeaponMag=False
     bReleaseFireOnDie=False
     bIgnoreReload=True
     ScopeDownOn=SDO_PreFire
     BallisticFireSound=(Sound=Sound'BWBP4-Sounds.Marlin.Mar-Melee',Radius=32.000000,bAtten=True)
     bAISilent=True
     bFireOnRelease=True
     PreFireAnim="PrepMelee"
     FireAnim="Melee"
     PreFireAnimRate=1.300000
     FireAnimRate=1.200000
     TweenTime=0.000000
     FireRate=0.700000
     AmmoClass=Class'BallisticFix.Ammo_MRS138Shells'
//     AmmoClass=Class'BWBP_SKC_Fix.Ammo_SuperMagnumSlug'
     AmmoPerFire=0
     ShakeRotTime=1.000000
     ShakeOffsetMag=(X=5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.050000
}
