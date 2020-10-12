//=============================================================================
// MRDRPrimaryFire.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class MRDRPrimaryFire extends BallisticInstantFire;

//Do the spread on the client side
function PlayFiring()
{
	if (BW.MagAmmo - ConsumedLoad < 2)
	{
		BW.IdleAnim = 'OpenIdle';
		BW.ReloadAnim = 'OpenReload';
		FireAnim = 'OpenFire';
	}
	else
	{
		BW.IdleAnim = 'Idle';
		BW.ReloadAnim = 'Reload';
		FireAnim = 'Fire';
	}
	super.PlayFiring();
}


defaultproperties
{
     WaterRangeFactor=0.400000
     MaxWallSize=16.000000
     MaxWalls=1
     Damage=18
     DamageHead=57
     DamageLimb=7
     RangeAtten=0.600000
     WaterRangeAtten=0.300000
     DamageType=Class'BWBP_SKC_Fix.DT_MRDR88Body'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_MRDR88Head'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_MRDR88Body'
     KickForce=5000
     PenetrateForce=135
     bPenetrate=True
     ClipFinishSound=(Sound=Sound'BallisticSounds3.Misc.ClipEnd-2',Volume=0.800000,Radius=48.000000,bAtten=True)
     DryFireSound=(Sound=Sound'BallisticSounds3.Misc.DryPistol',Volume=0.700000)
     bDryUncock=False
     MuzzleFlashClass=Class'BWBP_SKC_Fix.MRDRFlashEmitter'
     FlashScaleFactor=0.600000
     BrassClass=Class'BallisticFix.Brass_Pistol'
     BrassOffset=(X=-20.000000,Z=-5.000000)
     RecoilPerShot=16.000000
     XInaccuracy=128.000000
     YInaccuracy=128.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.MRDR.MRDR-Fire')
     bPawnRapidFireAnim=True
     TweenTime=0.000000
     FireRate=0.180000
     AmmoClass=Class'BallisticFix.Ammo_9mm'
     ShakeRotMag=(X=64.000000,Y=32.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-3.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.500000
}
