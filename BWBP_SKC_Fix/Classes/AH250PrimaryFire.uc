//=============================================================================
// AH250EnhancedFire.
//
// Accurate scopeable fartable SNAZZY
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class AH250PrimaryFire extends BallisticInstantFire;

//Do the spread on the client side
function PlayFiring()
{
	if (BW.MagAmmo - ConsumedLoad < 1)
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
     TraceRange=(Min=8000.000000,Max=9000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=32.000000
     MaxWalls=2
     Damage=80
     DamageHead=115
     DamageLimb=30
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DTAH250Pistol'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTAH250PistolHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTAH250Pistol'
     KickForce=30000
     PenetrateForce=200
     bPenetrate=True
     MuzzleFlashClass=Class'BallisticFix.D49FlashEmitter'
     FlashScaleFactor=0.500000
     BrassClass=Class'BallisticFix.Brass_Pistol'
     BrassBone="tip"
     BrassOffset=(X=-30.000000,Y=1.000000)
     RecoilPerShot=2048.000000
     VelocityRecoil=150.000000
//     FireChaos=0.800000
     XInaccuracy=4.000000
     YInaccuracy=4.000000
     FireRate=0.550000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-Fire3',Volume=4.100000)
     FireEndAnim=
     TweenTime=0.000000
     AmmoClass=Class'BallisticFix.Ammo_44Magnum'
     ShakeRotMag=(X=64.000000,Y=32.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
