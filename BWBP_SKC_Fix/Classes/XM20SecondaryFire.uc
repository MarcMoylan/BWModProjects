//=============================================================================
// XM20SecondaryFire.
//
// Burning laser fire that fires while altfire is held. Uses a special recharging
// ammo counter with a small limiting delay after releasing fire.
// Switches on weapon's laser sight when firing for effects.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class XM20SecondaryFire extends BallisticInstantFire;

var() sound		FireSoundLoop;
var   float		StopFireTime;
var   bool		bLaserFiring;
var   bool		bOvercharged;
var   Actor		MuzzleFlashBlue;

var() name		PreFireAnimCharged;
var() name		FireLoopAnimCharged;
var() name		FireEndAnimCharged;

var   float LaserCharge;
var   float ChargeRate;
var   float MaxCharge;
var   int SoundAdjust;
var()   sound	ChargeSound;
var() sound		PowerFireSound;
var() sound		RegularFireSound;

// Charge Beam Code
simulated function bool AllowFire()
{
	if (LaserCharge > 0 && LaserCharge < MaxCharge)
	{
		return false;
	}

	if (!super.AllowFire())
	{
		if (bLaserFiring)
			StopFiring();
		return false;
	}
	return true;
}

// Used to delay ammo consumtion
simulated event Timer()
{
	super.Timer();

	if (bLaserFiring && !IsFiring())
	{
		class'BUtil'.static.KillEmitterEffect (MuzzleFlashBlue);
		MuzzleFlashBlue=None;
		bLaserFiring=false;
		//Weapon.AmbientSound = None;
	}
}


simulated function PlayPreFire()
{    
    Weapon.AmbientSound = ChargeSound;
    Weapon.ThirdPersonActor.AmbientSound = ChargeSound;
	super.PlayPreFire();

}

//Intent is for the laser to begin firing once it has spooled up
simulated event ModeDoFire()
{
    if (!AllowFire())
        return;
		
	BallisticFireSound.Sound = None;
	
    if (LaserCharge + 0.01 >= MaxCharge || AIController(Instigator.Controller) != None ) //Fire at max charge, bots ignore charging
    {
        super.ModeDoFire();
        XM20Carbine(BW).CoolRate = XM20Carbine(BW).default.CoolRate;
    }
    else
    {
        XM20Carbine(BW).CoolRate = XM20Carbine(BW).default.CoolRate * 3;
    }

	//Overheat and lock the gun for a bit
    //XM20Carbine(BW).Overheat(LaserCharge);
    //LaserCharge = 0;
}

simulated function ModeTick(float DT)
{
	Super.ModeTick(DT);

	if ( XM20Carbine(BW).Heat > 0 || !bIsFiring || XM20Carbine(BW).MagAmmo == 0 )
	{
		LaserCharge = FMax(0.0, LaserCharge - XM20Carbine(BW).CoolRate*DT);
		return;
	}
	LaserCharge = FMin(LaserCharge + ChargeRate*DT, MaxCharge);

}

simulated function SwitchLaserMode (byte NewMode)
{
		if (NewMode == 2) //overcharged
        {
			bOvercharged=true;
			FireRate=0.013000;
			ChargeRate=0.600000;
			PreFireAnim=PreFireAnimCharged;
			FireLoopAnim=FireLoopAnimCharged;
			FireEndAnim=FireEndAnimCharged;
        }
        else
        {
			bOvercharged=false;
			FireRate=default.FireRate;
			ChargeRate=default.ChargeRate;
			PreFireAnim=default.PreFireAnim;
			FireLoopAnim=default.FireLoopAnim;
			FireEndAnim=default.FireEndAnim;
        }

        Load=AmmoPerFire;
}


//effects code

function InitEffects()
{
	if (AIController(Instigator.Controller) != None)
		return;
    if (MuzzleFlashBlue == None || MuzzleFlashBlue.bDeleteMe )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlashBlue, class'HMCRedEmitter', Weapon.DrawScale*FlashScaleFactor, weapon, FlashBone);
	MuzzleFlash = MuzzleFlashBlue;
}

// Remove effects
simulated function DestroyEffects()
{
	Super(WeaponFire).DestroyEffects();

//	class'BUtil'.static.KillEmitterEffect (MuzzleFlashRed);
//	class'BUtil'.static.KillEmitterEffect (MuzzleFlashBlue);
}


//Server fire
function DoFireEffect()
{
	XM20Carbine(Weapon).ServerSwitchLaser(true);
	if (!bLaserFiring)
	{
		if (bOvercharged)
			Weapon.PlayOwnedSound(PowerFireSound,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius,BallisticFireSound.Pitch,BallisticFireSound.bAtten);
		else
			Weapon.PlayOwnedSound(RegularFireSound,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius,BallisticFireSound.Pitch,BallisticFireSound.bAtten);
	}
	bLaserFiring=true;
	super.DoFireEffect();
}

//Client fire
function PlayFiring()
{
	super.PlayFiring();
	if (FireSoundLoop != None)
	{
		Weapon.AmbientSound = FireSoundLoop;
		Weapon.ThirdPersonActor.AmbientSound = FireSoundLoop;
	}
	if (!bLaserFiring)
	{
		if (bOvercharged)
			Weapon.PlayOwnedSound(PowerFireSound,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius,BallisticFireSound.Pitch,BallisticFireSound.bAtten);
		else
			Weapon.PlayOwnedSound(RegularFireSound,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius,BallisticFireSound.Pitch,BallisticFireSound.bAtten);
	}
	bLaserFiring=true;
}

function StopFiring()
{
    Weapon.AmbientSound = XM20Carbine(BW).UsedAmbientSound;
	Weapon.ThirdPersonActor.AmbientSound = None;
//    HoldTime = 0;
	bLaserFiring=false;
	XM20Carbine(Weapon).ServerSwitchLaser(false);
	StopFireTime = level.TimeSeconds;
//	LaserCharge = 0;
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
	TargetedHurtRadius(7, 20, class'DT_XM20Body', 0, HitLocation, Other);
}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	TargetedHurtRadius(7, 20, class'DT_XM20Body', 0, HitLocation, Other);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}

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
}

defaultproperties
{
     ChargeRate=2.400000
     MaxCharge=1.000000
	 FireSoundLoop=Sound'BWBP_SKC_Sounds.XM20.XM20-Lase'
     ChargeSound=Sound'BWBP_SKC_Sounds.XM20.XM20-SpartanChargeSound'
//	 ChargeSound=Sound'BWBP_SKC_Sounds.BeamCannon.Beam-Charge'
     PowerFireSound=Sound'BWBP_SKC_Sounds.XM20.XM20-Overcharge'
     RegularFireSound=Sound'BWBP_SKC_Sounds.XM20.XM20-LaserStart'
	 
     WaterRangeFactor=0.700000
     Damage=20
     DamageHead=25
     DamageLimb=15
     RangeAtten=0.350000
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DT_XM20Body'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_XM20Head'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_XM20Body'
     PenetrateForce=300
     bPenetrate=True
     FlashBone="tip"
     XInaccuracy=0.000001
     YInaccuracy=0.000001
     FlashScaleFactor=0.500000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.XM20.XM20-LaserStart',Volume=1.200000)
     bModeExclusive=False
     FireAnim="Fire"
     PreFireAnim="LoopStart"
	 FireLoopAnim="LoopFire"
	 FireEndAnim="LoopEnd"
	 PreFireAnimCharged="LoopOpenStart"
	 FireLoopAnimCharged="LoopOpenFire"
	 FireEndAnimCharged="LoopOpenEnd"
     TweenTime=0.000000
	 PreFireTime=0.100000
     FireRate=0.060000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_Laser'
     AmmoPerFire=1
     BotRefireRate=0.999000
     WarnTargetPct=0.010000
     aimerror=1.000000
}
