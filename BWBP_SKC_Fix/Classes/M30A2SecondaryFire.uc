//=============================================================================
// M30A2SecondaryFire.
//
// Gauss fire. Magnetic acceleration. Physics. Pv=nRT. A1V1=A2V2. Llammas.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class M30A2SecondaryFire extends BallisticInstantFire;


function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	super.DoDamage(Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount, WaterHitLocation);
	if (Mover(Other) != None || Vehicle(Other) != None)
		return;
	M30A2AssaultRifle(BW).TargetedHurtRadius(96, 40, DamageType, 0, HitLocation, Pawn(Other));
}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(96, 40, DamageType, 0, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}


//Do the spread on the client side
function PlayFiring()
{
	if (BW.MagAmmo - ConsumedLoad < 2)
	{
		BW.IdleAnim = 'Idle';
		BW.ReloadAnim = 'Reload';
		FireAnim = 'Fire';
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
     TraceRange=(Min=15000.000000,Max=20000.000000)
     WaterRangeFactor=0.900000
     PDamageFactor=0.800000
     WallPDamageFactor=0.800000
     MaxWallSize=64.000000
     MaxWalls=4
     Damage=80
     DamageHead=135
     DamageLimb=40
     RangeAtten=0.900000
     WaterRangeAtten=0.700000
     DamageType=Class'BWBP_SKC_Fix.DTM30A1AssaultPwr'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTM30A1AssaultHeadPwr'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTM30A1AssaultLimbPwr'
     KickForce=27500
     PenetrateForce=600
     bPenetrate=True
     MuzzleFlashClass=Class'BallisticFix.M806FlashEmitter'
     FlashScaleFactor=1.600000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassBone="tip"
     BrassOffset=(X=-30.000000,Y=1.000000)
     RecoilPerShot=2048.000000
     XInaccuracy=1.000000
     YInaccuracy=1.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.M50A2.M50A2-SilenceFire',Volume=6.700000)
     FireEndAnim=
     TweenTime=0.000000
     FireRate=1.500000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_42HVG'
     ShakeRotMag=(X=400.000000,Y=32.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
     aimerror=800.000000
}
