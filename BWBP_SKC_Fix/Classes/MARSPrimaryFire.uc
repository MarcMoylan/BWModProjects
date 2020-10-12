//=============================================================================
// MARSPrimaryFire.
//
// Very automatic, bullet style instant hit. Shots have medium range and good
// power. Accuracy and ammo goes quickly with its faster than normal rate of fire.
//
// Has damage drop off due to shorter barrel.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MARSPrimaryFire extends BallisticInstantFire;
var() sound		SuperFireSound;
var() sound		UltraFireSound;
var() sound	FireSoundLoop;
var() sound	FireSoundLoopBegin;
var() sound	FireSoundLoopEnd;
	

defaultproperties
{
     FireSoundLoop=Sound'BWBP_SKC_Sounds.Misc.F2000-FireLoopSil'
     FireSoundLoopBegin=Sound'BWBP_SKC_Sounds.Misc.F2000-SilFire'
     SuperFireSound=Sound'BWBP_SKC_Sounds.M514H.M514H-Fire2'
     UltraFireSound=Sound'BWBP_SKC_Sounds.M514H.M514H-Fire3'
     TraceRange=(Min=11000.000000,Max=14000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=32.000000
     MaxWalls=2
     Damage=24
     DamageHead=75
     DamageLimb=12
//     Damage=(Min=20.000000,Max=25.000000)
//     DamageHead=(Min=65.000000,Max=95.000000)
//     DamageLimb=(Min=8.000000,Max=13.000000)
     WaterRangeAtten=0.800000
     RangeAtten=0.950000
     DamageType=Class'BWBP_SKC_Fix.DT_MARSAssault'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_MARSAssaultHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_MARSAssault'
     KickForce=18000
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bCockAfterEmpty=False
     MuzzleFlashClass=Class'BWBP_SKC_Fix.MARSFlashEmitter'
     FlashScaleFactor=0.900000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassBone="ejector"
     BrassOffset=(X=-25.000000,Y=1.000000)
     RecoilPerShot=200.000000
     XInaccuracy=16.000000
     YInaccuracy=16.000000
     SilencedFireSound=(Sound=Sound'BWBP_SKC_Sounds.Misc.F2000-SilFire',Volume=1.100000,Radius=24.000000,bAtten=True)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.M514H.M514H-Fire',Volume=1.500000,Slot=SLOT_Interact,bNoOverride=False)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
//     FireRate=0.080000
//     FireRate=0.082500
     FireRate=0.085700
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
