//=============================================================================
// MJ51PrimaryFire.
//
// 3-Round burst. Shots are powerful and easy to follow up.
// Not very accurate at range, and hindered by burst fire up close.
// Excels at mid range combat.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MJ51PrimaryFire extends BallisticInstantFire;

simulated event ModeDoFire()
{
	if (MJ51Carbine(Weapon).bLoaded)
	{
		MJ51Carbine(Weapon).IndirectLaunch();
		return;
	}
	if (!AllowFire())
		return;
		
	super.ModeDoFire();
    

}

defaultproperties
{
     TraceRange=(Min=10000.000000,Max=13000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=32.000000
     MaxWalls=2
     Damage=24
     DamageHead=75
     DamageLimb=12
     WaterRangeAtten=0.700000
     RangeAtten=0.900000
     DamageType=Class'BWBP_SKC_Fix.DTMJ51Assault'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTMJ51AssaultHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTMJ51AssaultLimb'
     KickForce=18000
     PenetrateForce=150
     bPenetrate=True
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bCockAfterEmpty=False
     MuzzleFlashClass=Class'BWBP_SKC_Fix.MJ51FlashEmitter'
     FlashScaleFactor=1.000000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassBone="ejector"
     BrassOffset=(X=-20.000000,Y=1.000000)
     RecoilPerShot=128.000000
     XInaccuracy=8.000000
     YInaccuracy=8.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51Carbine-Fire')
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
//     FireRate=0.082500
     FireRate=0.075000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_556mmSTANAG'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
