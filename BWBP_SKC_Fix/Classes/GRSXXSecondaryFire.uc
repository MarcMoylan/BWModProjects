//=============================================================================
// GRSXXSecondaryFire.
//
// Burning laser fire that fires while altfire is held. Uses a special recharging
// ammo counter with a small limiting delay after releasing fire.
// Switches on weapon's laser sight when firing for effects.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class GRSXXSecondaryFire extends BallisticInstantFire;

var() sound		FireSoundLoop;
var   float		StopFireTime;
var   bool		bLaserFiring;

simulated function bool AllowFire()
{
	if (level.TimeSeconds - StopFireTime < 0.8 || GRSXXPistol(Weapon).LaserAmmo <= 0 || !super.AllowFire())
	{
		if (bLaserFiring)
			StopFiring();
		return false;
	}
	return true;
}

simulated function bool HasAmmo()
{
	return GRSXXPistol(Weapon).LaserAmmo > 0;
}

simulated function bool CheckWeaponMode()
{
	if (Weapon.IsInState('DualAction') || Weapon.IsInState('PendingDualAction'))
		return false;
	return true;
}

function DoFireEffect()
{
	GRSXXPistol(Weapon).LaserAmmo -= 0.06;
	GRSXXPistol(Weapon).ServerSwitchLaser(true);
	bLaserFiring=true;
	super.DoFireEffect();
}

function PlayFiring()
{
	super.PlayFiring();
	if (FireSoundLoop != None)
		Instigator.AmbientSound = FireSoundLoop;
	bLaserFiring=true;
}

function StopFiring()
{
	bLaserFiring=false;
	Instigator.AmbientSound = None;
	GRSXXPistol(Weapon).ServerSwitchLaser(false);
	StopFireTime = level.TimeSeconds;
}

simulated event ModeDoFire()
{
	if (GRSXXPistol(Weapon).bBigLaser)
		BallisticFireSound.Sound = default.BallisticFireSound.Sound;
	else
		BallisticFireSound.Sound = None;
	super.ModeDoFire();
}

simulated function FireRecoil ()
{
	if (BW != None)
		BW.AddRecoil(RecoilPerShot, ThisModeNum);
}
function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	super.DoDamage(Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount, WaterHitLocation);
	if (Mover(Other) != None || Vehicle(Other) != None)
		return;
	GRSXXPistol(BW).TargetedHurtRadius(7, 20, class'DTGRSXXLaser', 0, HitLocation, Pawn(Other));
}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(7, 20, DamageType, 0, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}


defaultproperties
{
     FireSoundLoop=Sound'BWBP_SKC_Sounds.Glock_Gold.G-Glk-LaserBurn'
     WaterRangeFactor=0.700000
     Damage=35
     DamageHead=60
     DamageLimb=15
     RangeAtten=0.350000
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DTGRSXXLaser'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTGRSXXLaserHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTGRSXXLaser'
     PenetrateForce=300
     bPenetrate=True
     bUseWeaponMag=False
     FlashBone="tip2"
     XInaccuracy=0.000001
     YInaccuracy=0.000001
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.Glock_Gold.G-Glk-LaserFire',Volume=1.200000)
     bModeExclusive=False
     FireAnim="Idle"
     TweenTime=0.000000
     FireRate=0.080000
     AmmoClass=Class'BallisticFix.Ammo_GRSNine'
     AmmoPerFire=0
     BotRefireRate=0.999000
     WarnTargetPct=0.010000
     aimerror=1.000000
}
