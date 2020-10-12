//=============================================================================
// AS50PrimaryFire.
//
// Accurate, long ranged and powerful bullet fire. Very high recoil. Fast RoF.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AS50PrimaryFire extends BallisticInstantFire;
var() sound		RapidFireSound;
var() sound		UltraFireSound;


simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(5, 96, DamageType, 1, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}


simulated event ModeDoFire()
{
	if (AS50Rifle(Weapon).CamoIndex == 1) 
		     BallisticFireSound.Sound=UltraFireSound;
	else if (AS50Rifle(Weapon).bRapidFire) 
		BallisticFireSound.Sound=RapidFireSound;
	else 
		BallisticFireSound.Sound=default.BallisticFireSound.Sound;
	Super.ModeDoFire();

}
defaultproperties
{
     UltraFireSound=Sound'BWBP_SKC_Sounds.X82.X82-Fire'
     RapidFireSound=Sound'BWBP_SKC_SoundsExp.AS50.AS50-F1'
     TraceRange=(Min=7500000.000000,Max=7500000.000000)
     PDamageFactor=0.800000
     WallPDamageFactor=0.8500000
     WaterRangeFactor=0.800000
     MaxWallSize=64.000000
     MaxWalls=3
     Damage=75
     DamageHead=175
     DamageLimb=50
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DT_AS50Torso'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_AS50Head'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_AS50Limb'
     KickForce=45000
     PenetrateForce=220
     bPenetrate=True
     MuzzleFlashClass=Class'BallisticFix.M925FlashEmitter'
     BrassClass=Class'BWBP_SKC_Fix.Brass_BMGInc'
     BrassBone="breach"
     BrassOffset=(X=-10.000000,Y=1.000000,Z=-1.000000)
     RecoilPerShot=2300.000000
     VelocityRecoil=255.000000
     FireChaos=1.500000
     XInaccuracy=2.000000
     YInaccuracy=2.500000
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_SoundsExp.AS50.AS50-Fire',Pitch=1.000000,Volume=5.100000,Slot=SLOT_Interact,bNoOverride=False)
     FireEndAnim=
     FireAnim="CFire"
     TweenTime=0.000000
     FireRate=0.200000
//     FireRate=0.150000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_50Inc'
     ShakeRotMag=(X=450.000000,Y=64.000000)
     ShakeRotRate=(X=12400.000000,Y=12400.000000,Z=12400.000000)
     ShakeRotTime=2.500000
     ShakeOffsetMag=(X=-5.500000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.250000
     BotRefireRate=0.300000
     WarnTargetPct=0.050000
     aimerror=950.000000
}
