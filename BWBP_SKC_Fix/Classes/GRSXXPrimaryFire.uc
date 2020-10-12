//=============================================================================
// GRSXXPrimaryFire.
//
// Med power, med range, low recoil pistol fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class GRSXXPrimaryFire extends BallisticInstantFire;

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
     TraceRange=(Max=16000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=64.000000
     MaxWalls=4
     Damage=45
     DamageHead=100
     DamageLimb=20
     RangeAtten=0.200000
     WaterRangeAtten=0.500000
     DamageType=Class'BWBP_SKC_Fix.DTGRSXXPistol'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTGRSXXPistolHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTGRSXXPistol'
     KickForce=8000
     PenetrateForce=600
     bPenetrate=True
     MuzzleFlashClass=Class'BallisticFix.XK2FlashEmitter'
//     MuzzleFlashClass=Class'BWBP_SKC_Fix.PlasmaFlashEmitter'
     FlashScaleFactor=1.500000
     BrassClass=Class'BallisticFix.Brass_GRSNine'
     BrassBone="tip"
     BrassOffset=(X=-30.000000,Y=1.000000)
     RecoilPerShot=768.000000
     FireChaos=0.008000
     XInaccuracy=2.000000
     YInaccuracy=2.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.Glock_Gold.G-Glk-Fire',Volume=1.200000)
     bModeExclusive=False
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.100000
     AmmoClass=Class'BallisticFix.Ammo_GRSNine'
     ShakeRotMag=(X=64.000000,Y=32.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
