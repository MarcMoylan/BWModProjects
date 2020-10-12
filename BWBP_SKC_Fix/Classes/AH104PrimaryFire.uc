//  =============================================================================
//   AH104PrimaryFire.
//  
//   Very powerful, long range bullet attack.
//  
//   You'll be attacked with bullets.
//   Hello whoever is reading this.
//  =============================================================================
class AH104PrimaryFire extends BallisticInstantFire;

var() sound		SuperFireSound;
var() sound		UltraFireSound;

simulated event ModeDoFire()
{
	if (AH104Pistol(Weapon).bIsSuper) 
		     BallisticFireSound.Sound=SuperFireSound;
	else if (AH104Pistol(Weapon).bIsUltra) 
		     BallisticFireSound.Sound=UltraFireSound;
	Super.ModeDoFire();

}
function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	super.DoDamage(Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount, WaterHitLocation);
	if (Mover(Other) != None || Vehicle(Other) != None)
		return;
	AH104Pistol(BW).TargetedHurtRadius(10, 20, class'DTAH104Pistol', 0, HitLocation, Pawn(Other));
}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(10, 20, DamageType, 0, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}


defaultproperties
{
     SuperFireSound=Sound'BWBP_SKC_Sounds.AH104.AH104-Blast2'
     UltraFireSound=Sound'BWBP_SKC_Sounds.AH104.AH104-Blast'
     TraceRange=(Min=6000.000000,Max=6500.000000)
     WaterRangeFactor=0.500000
     MaxWallSize=32.000000
     MaxWalls=4
     PDamageFactor=0.800000
     WallPDamageFactor=0.800000
     Damage=100
     DamageHead=147
     DamageLimb=70
     RangeAtten=0.350000
     WaterRangeAtten=0.600000
     DamageType=Class'BWBP_SKC_Fix.DTAH104Pistol'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTAH104PistolHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTAH104Pistol'
     KickForce=35000
     PenetrateForce=250
     bPenetrate=True
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bDryUncock=True
     MuzzleFlashClass=Class'BallisticFix.M925FlashEmitter'
     FlashScaleFactor=1.100000
     BrassClass=Class'BallisticFix.Brass_Pistol'
     BrassBone="tip"
     BrassOffset=(X=-30.000000,Y=1.000000)
     RecoilPerShot=4096.000000
     VelocityRecoil=175.000000
     FireChaos=-10.000000
     XInaccuracy=3.000000
     YInaccuracy=3.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.AH104.AH104-Super',Volume=7.100000)
     FireEndAnim=
     TweenTime=0.000000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_600HEAP'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
