//=============================================================================
// M154PrimaryFire.
//
// Very automatic, bullet style instant hit. Shots are long ranged, powerful
// and accurate when used carefully. The dissadvantages are severely screwed up
// accuracy after firing a shot or two and the rapid rate of fire means ammo
// dissapeares quick.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MG33PrimaryFire extends BallisticInstantFire;

defaultproperties
{
     TraceRange=(Min=12000.000000,Max=15000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=32.000000
     MaxWalls=3
     Damage=22
     DamageHead=70
     DamageLimb=13
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DT_MG33LMG'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_MG33LMGHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_MG33LMG'
     KickForce=20000
     PenetrateForce=150
     bPenetrate=True
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bCockAfterEmpty=True
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     FlashScaleFactor=0.800000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassBone="tip"
     BrassOffset=(X=-80.000000,Y=1.000000)
     RecoilPerShot=64.000000
     XInaccuracy=3.000000
     YInaccuracy=3.750000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.M514H.M514H-Fire',Pitch=1.200000,Volume=1.500000,Slot=SLOT_Interact,bNoOverride=False)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.120000
     AmmoClass=Class'BallisticFix.Ammo_556mm'
     ShakeRotMag=(X=128.000000,Y=128.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
