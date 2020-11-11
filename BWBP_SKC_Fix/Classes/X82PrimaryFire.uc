//=============================================================================
// X82PrimaryFire.
//
// Very accurate, long ranged and powerful bullet fire. Headshots are
// especially dangerous.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class X82PrimaryFire extends BallisticInstantFire;

var() sound		UltraFireSound;

simulated function PreBeginPlay()
{
	if (X82Rifle_TW(Weapon) != None)
		FireChaos = 0.03;
	super.PreBeginPlay();
}

function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	super.DoDamage(Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount, WaterHitLocation);
	if (Mover(Other) != None || Vehicle(Other) != None)
		return;
	X82Rifle(BW).TargetedHurtRadius(14, 20, class'DT_X82Torso', 0, HitLocation, Pawn(Other));
}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(14, 20, DamageType, 500, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}

defaultproperties
{
     UltraFireSound=Sound'BWBP_SKC_Sounds.X82.X82-Fire5'
     TraceRange=(Min=10000000.000000,Max=10000000.000000)
     WaterRangeFactor=0.800000
     PDamageFactor=0.900000
     WallPDamageFactor=0.900000
     MaxWallSize=72.000000
     MaxWalls=4
     Damage=145
     DamageHead=310
     DamageLimb=85
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DT_X82Torso'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_X82Head'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_X82Torso'
     KickForce=45000
     PenetrateForce=450
     bPenetrate=True
     MuzzleFlashClass=Class'BallisticFix.M925FlashEmitter'
     BrassClass=Class'BWBP_SKC_Fix.Brass_BMG'
     BrassBone="breach"
     BrassOffset=(X=-10.000000,Y=1.000000,Z=-1.000000)
     RecoilPerShot=1950.000000
     VelocityRecoil=255.000000
     FireChaos=1.500000
     XInaccuracy=0.500000
     YInaccuracy=0.500000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.X82.X82-Fire3',Volume=12.100000,Radius=450.000000)
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.450000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_50BMG'
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
