//=============================================================================
// R78NSPrimaryFire.
//
// Very accurate, long ranged and powerful bullet fire. Headshots are
// especially dangerous.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class R78NSPrimaryFire extends BallisticInstantFire;
var() sound		PowerFireSound;
var() sound		SuperFireSound;
var() sound		MegaFireSound;
var() sound		SpecialFireSound;

simulated event ModeDoFire()
{
	if (R78NSRifle(Weapon).CamoIndex == 8) 
		     BallisticFireSound.Sound=PowerFireSound;
	else if (R78NSRifle(Weapon).CamoIndex == 5 || R78NSRifle(Weapon).CamoIndex == 4) 
		     BallisticFireSound.Sound=SuperFireSound;
	else if (R78NSRifle(Weapon).CamoIndex == 7) 
		     BallisticFireSound.Sound=MegaFireSound;
	else if (R78NSRifle(Weapon).CamoIndex == 6) 
		     BallisticFireSound.Sound=SpecialFireSound;
	Super.ModeDoFire();

}

defaultproperties
{
     TraceRange=(Min=12500.000000,Max=12500.000000)
     PowerFireSound=Sound'BWBP_SKC_Sounds.X82.X82-Fire3'
     SuperFireSound=Sound'BWBP_SKC_Sounds.R78NS.R78NS-Fire2'
     MegaFireSound=Sound'BWBP_SKC_Sounds.R78NS.R78NS-Fire3'
     SpecialFireSound=Sound'BWBP_SKC_Sounds.R78NS.R78NS-Fire4'
     WaterRangeFactor=0.800000
     MaxWallSize=40.000000
     MaxWalls=3
     Damage=100
     DamageHead=150
     DamageLimb=40
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DTR98Rifle'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTR98RifleHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTR98Rifle'
     KickForce=25000
     PenetrateForce=125
     bPenetrate=True
     bCockAfterFire=True
     MuzzleFlashClass=Class'BallisticFix.R78FlashEmitter'
     BrassClass=Class'BallisticFix.Brass_Rifle'
     bBrassOnCock=True
     BrassOffset=(X=-10.000000,Y=1.000000,Z=-1.000000)
     RecoilPerShot=2048.000000
     FireChaos=1.250000
     XInaccuracy=2.500000
     YInaccuracy=4.500000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.R78NS.R78NS-Fire')
     FireEndAnim=
     FireAnimRate=1.500000
     TweenTime=0.000000
     FireRate=0.300000
     AmmoClass=Class'BallisticFix.Ammo_42Rifle'
     ShakeRotMag=(X=400.000000,Y=32.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.200000
     WarnTargetPct=0.050000
     aimerror=400.000000
}
