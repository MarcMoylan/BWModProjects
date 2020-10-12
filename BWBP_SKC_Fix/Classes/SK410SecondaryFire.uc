//=============================================================================
// SK410SecondaryFire.
//
// Melee attack for shotgun.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SK410SecondaryFire extends BallisticMeleeFire;

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
     SwipePoints(0)=(Weight=6,offset=(Pitch=6000,Yaw=4000))
     SwipePoints(1)=(Weight=5,offset=(Pitch=4500,Yaw=3000))
     SwipePoints(2)=(Weight=4,offset=(Pitch=3000))
     SwipePoints(3)=(Weight=3,offset=(Pitch=1500,Yaw=1000))
     SwipePoints(4)=(Weight=2,offset=(Pitch=0,Yaw=0))
     SwipePoints(5)=(Weight=1,offset=(Pitch=-1500,Yaw=-1500))
     SwipePoints(6)=(offset=(Yaw=-3000))
     WallHitPoint=4
     Damage=70
     DamageHead=105
     DamageLimb=35
     DamageType=Class'BWBP_SKC_Fix.DT_SK410Hit'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_SK410HitHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_SK410Hit'
     bUseWeaponMag=False
     bReleaseFireOnDie=False
     bIgnoreReload=True
     ScopeDownOn=SDO_PreFire
     BallisticFireSound=(Sound=Sound'BallisticSounds3.M763.M763Swing',Radius=32.000000,Pitch=0.800000,bAtten=True)
     bAISilent=True
     bFireOnRelease=True
     PreFireAnim="PrepBash"
     FireAnim="Bash"
     TweenTime=0.000000
     FireRate=0.700000
     PreFireAnimRate=2.000000
     FireAnimRate=1.500000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_8GaugeHE'
     AmmoPerFire=0
     ShakeRotTime=1.000000
     ShakeOffsetMag=(X=5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.050000
}
