//=============================================================================
// E23PrimaryFire.
//
// Multi mode plasma fire for the E23
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class HMCSecondaryFire extends BallisticInstantFire;

var   bool		bLaserFiring;
var   Actor		MuzzleFlashBeam;

var   Actor		MuzzleFlashBlue;
var   Actor		MuzzleFlashRed;

var() sound		ChargeSound;
var() bool	bDoOverCharge;
//var() BUtil.FullSound	FireSoundLoop;
var() sound		FireSoundLoop;
var() sound		FireSoundLoopRed;
var   int SoundAdjust;
var   float		StopFireTime;
var   Emitter          LaserDot;

// Used to delay ammo consumtion
simulated event Timer()
{
	super.Timer();

	if (bLaserFiring && !IsFiring())
	{
		class'BUtil'.static.KillEmitterEffect (MuzzleFlashBlue);
		MuzzleFlashBlue=None;
		bLaserFiring=false;
		Instigator.AmbientSound = None;
	}
}

function InitEffects()
{
	if (AIController(Instigator.Controller) != None)
		return;
    if (MuzzleFlashBlue == None || MuzzleFlashBlue.bDeleteMe )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlashBlue, class'HMCFlashEmitter', Weapon.DrawScale*FlashScaleFactor, weapon, FlashBone);
    if (MuzzleFlashRed == None || MuzzleFlashRed.bDeleteMe )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlashRed, class'HMCRedEmitter', Weapon.DrawScale*FlashScaleFactor, weapon, FlashBone);
	MuzzleFlash = MuzzleFlashBlue;
}

// Remove effects
simulated function DestroyEffects()
{
	Super(WeaponFire).DestroyEffects();

//	class'BUtil'.static.KillEmitterEffect (MuzzleFlashRed);
//	class'BUtil'.static.KillEmitterEffect (MuzzleFlashBlue);
}

simulated function bool AllowFire()
{
	if ((HMCBeamCannon(Weapon).Heat >= 1.0) || HMCBeamCannon(Weapon).bIsCharging || !super.AllowFire())
	{
		if (bLaserFiring)
			PlayFireEnd();
		return false;
	}
	return super.AllowFire();

}
function PlayFireEnd()
{
	if (bLaserFiring || bIsFiring)
	{
		super.PlayFireEnd();
		super.StopFiring();
	}
	StopFiring();
}


simulated function SpawnLaserDot(vector Loc)
{
     	if (LaserDot == None)
	{
	  	if ( (Instigator.PlayerReplicationInfo.Team != None) && (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0) || HMCBeamCannon(BW).bRedTeam )
			LaserDot = Spawn(class'BallisticFix.IE_GRS9LaserHit',,,Loc);
		else
          		LaserDot = Spawn(class'BWBP_SKC_Fix.IE_HMCLase',,,Loc);
	}
}

function DoFireEffect()
{
	HMCBeamCannon(Weapon).ServerSwitchLaser(true);
	bLaserFiring=true;
	if (level.Netmode == NM_DedicatedServer)
	{
		if ( (Instigator != None) && (Instigator.PlayerReplicationInfo != None) && (Instigator.PlayerReplicationInfo.Team != None) )
			HMCBeamCannon(BW).AddHeat(0.010);
		else if (HMCBeamCannon(BW).bRedTeam)
			HMCBeamCannon(BW).AddHeat(0.015);
		else
			HMCBeamCannon(BW).AddHeat(0.025);
	}
	super.DoFireEffect();
}

function PlayFiring()
{
	if ( (Instigator != None) && (Instigator.PlayerReplicationInfo != None) && (Instigator.PlayerReplicationInfo.Team != None) )
		HMCBeamCannon(BW).AddHeat(0.010);
	else if (HMCBeamCannon(BW).bRedTeam)
		HMCBeamCannon(BW).AddHeat(0.015);
	else
		HMCBeamCannon(BW).AddHeat(0.025);
	super.PlayFiring();
	if (FireSoundLoop != None)
	{
		if ( (Instigator.PlayerReplicationInfo.Team != None) && (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0) || HMCBeamCannon(BW).bRedTeam )
			Instigator.AmbientSound = FireSoundLoopRed;
		else
			Instigator.AmbientSound = FireSoundLoop;
	}
	Instigator.SoundVolume = 255;
	Instigator.SoundRadius = 255;
	bLaserFiring=true;
}


function StopFiring()
{
	bLaserFiring=false;
	Weapon.AmbientSound = None;
	Instigator.SoundVolume = Weapon.default.SoundVolume;
	Instigator.SoundRadius = Weapon.default.SoundRadius;
	HMCBeamCannon(Weapon).ServerSwitchLaser(false);
	StopFireTime = level.TimeSeconds;
	super.StopFiring();
	StopLaser();
}

function StopLaser()
{
	bLaserFiring=false;
	if (MuzzleFlash != None)
	{	
//		Emitter(MuzzleFlash).Kill();
		MuzzleFlash = None;	
	}
	Instigator.AmbientSound = BW.UsedAmbientSound;
	Instigator.SoundVolume = Weapon.default.SoundVolume;
}

simulated event ModeDoFire()
{
	if (!AllowFire())
		return;
	if (HMCBeamCannon(Weapon).Heat >= 1.0)
	{
		NextFireTime += 2.75;
		if (level.Netmode != NM_Standalone)
		{
			DoJam();
			BW.ClientJamMode(1);
		}
	}
    	BallisticFireSound.Sound = None;
    	BallisticFireSound.Volume=0.7;
    	BallisticFireSound.Radius=280.0;
	super.ModeDoFire();
	if (HMCBeamCannon(BW).Heat >= 1.0)
		NextFireTime += 2.75;


}

simulated event ModeTick(float DT)
{
	if (level.Netmode != NM_Standalone)
	{
		if (HMCBeamCannon(Weapon).Heat > 1.0)
		{
			HMCBeamCannon(Weapon).ClientOverCharge();
			HMCBeamCannon(Weapon).ServerStopFire(1);
			DoJam();
			BW.ClientJamMode(1);
			NextFireTime = 2.75;
		}
	}
	if ( (Instigator.PlayerReplicationInfo.Team != None) && (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0) || HMCBeamCannon(BW).bRedTeam )
		MuzzleFlash = MuzzleFlashRed;
	else
		MuzzleFlash = MuzzleFlashBlue;
	super.ModeTick(DT);
	if (!bIsFiring)
		return;
	if (Instigator.PhysicsVolume.bWaterVolume)
		HMCBeamCannon(Weapon).AddHeat(DT*3);
	if (Weapon.Role == Role_Authority && HMCBeamCannon(BW).Heat > 1.0)
	{
		HMCBeamCannon(BW).ClientOverCharge();
		Weapon.ServerStopFire(ThisModeNum);
	}

}
simulated function ModeHoldFire()
{
	Instigator.SoundVolume = 255;
	Instigator.SoundRadius = 280;
	Super.ModeHoldFire();
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
	HMCBeamCannon(BW).TargetedHurtRadius(32, 20, class'DTHMCBeam', 0, HitLocation, Pawn(Other));
}


simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(32, 20, DamageType, 0, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}
/*
simulated function TargetedHurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation, Optional actor Victim )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( Weapon.bHurtEntry )
		return;

	Weapon.bHurtEntry = true;
	foreach Weapon.VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && UnrealPawn(Victim)==None && (!Victims.IsA('FluidSurfaceInfo')) && Victims != Victim)
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			class'BallisticDamageType'.static.GenericHurt
			(
				Victims,
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
		}
	}
	Weapon.bHurtEntry = false;
}*/

defaultproperties
{
     ChargeSound=Sound'BWBP_SKC_Sounds.BeamCannon.Beam-Loop'
     FireSoundLoop=Sound'BWBP_SKC_Sounds.BeamCannon.Beam-Loop'
     FireSoundLoopRed=Sound'BWBP_SKC_Sounds.BeamCannon.RedBeam-Loop'
     TraceRange=(Min=4000.000000,Max=8000.000000)
     WaterRangeFactor=0.600000
     MaxWalls=1
     Damage=15
     DamageHead=27
     DamageLimb=10
     RangeAtten=0.750000
     WaterRangeAtten=0.600000
     DamageType=Class'BWBP_SKC_Fix.DTHMCBeam'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTHMCBeamHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTHMCBeam'
     PenetrateForce=200
     bPenetrate=True
     MuzzleFlashClass=Class'BWBP_SKC_Fix.HMCFlashEmitter'
     FlashScaleFactor=0.700000
     RecoilPerShot=0.005000
     FireChaos=0.000500
     XInaccuracy=0.000500
     YInaccuracy=0.000500
     BallisticFireSound=(Sound=Sound'BallisticSounds3.A73.A73Fire',Volume=1.200000,Slot=SLOT_Interact,bNoOverride=False)
     bModeExclusive=False
     FireAnim="FireLoop"
     UnjamMethod=UJM_Fire
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.080000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_HVPCCells'
     BotRefireRate=0.999000
     WarnTargetPct=0.010000
     aimerror=400.000000
}
