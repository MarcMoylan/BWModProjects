//=============================================================================
// LK05PrimaryFire.
//
// Rapid fire CQC fire. Uses up ammo very quickly. 
// Very controllable, and packs a decent punch.
//
//
// Has accuracy and damage drop off issues due to CQC Barrel.
// Rounds detonate on target and do not penetrate.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class LK05PrimaryFire extends BallisticInstantFire;

var() sound	FireSoundLoop;
var() sound	FireSoundLoopBegin;
var() sound	FireSoundLoopEnd;

var bool bFiring;

var() Actor						SMuzzleFlash;		// Silenced Muzzle flash stuff
var() class<Actor>				SMuzzleFlashClass;
var() Name						SFlashBone;
var() float						SFlashScaleFactor;


simulated function bool AllowFire()
{
	if (level.TimeSeconds < LK05Carbine(Weapon).SilencerSwitchTime)
	{
		if (bFiring)
		{
			StopFiring();
			Instigator.AmbientSound = BW.UsedAmbientSound;
		}
		return false;
	}
	if (!super.AllowFire())
	{
		if (bFiring)
		{
			StopFiring();
			Instigator.AmbientSound = BW.UsedAmbientSound;
		}
		return false;
	}
	return super.AllowFire();

}

//Trigger muzzleflash emitter
function FlashMuzzleFlash()
{
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;
    if (!LK05Carbine(Weapon).bSilenced && MuzzleFlash != None)
        MuzzleFlash.Trigger(Weapon, Instigator);
    else if (LK05Carbine(Weapon).bSilenced && SMuzzleFlash != None)
        SMuzzleFlash.Trigger(Weapon, Instigator);

	if (!bBrassOnCock)
		EjectBrass();
}

// Remove effects
simulated function DestroyEffects()
{
	Super.DestroyEffects();

	class'BUtil'.static.KillEmitterEffect (MuzzleFlash);
	class'BUtil'.static.KillEmitterEffect (SMuzzleFlash);
}

function InitEffects()
{
	if (AIController(Instigator.Controller) != None)
		return;
    if ((MuzzleFlashClass != None) && ((MuzzleFlash == None) || MuzzleFlash.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, Weapon.DrawScale*FlashScaleFactor, weapon, FlashBone);
    if ((SMuzzleFlashClass != None) && ((SMuzzleFlash == None) || SMuzzleFlash.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (SMuzzleFlash, SMuzzleFlashClass, Weapon.DrawScale*SFlashScaleFactor, weapon, SFlashBone);
}

simulated function SendFireEffect(Actor Other, vector HitLocation, vector HitNormal, int Surf, optional vector WaterHitLoc)
{
	BallisticAttachment(Weapon.ThirdPersonActor).BallisticUpdateHit(Other, HitLocation, HitNormal, Surf, LK05Carbine(Weapon).bSilenced, WaterHitLoc);
}

function ServerPlayFiring()
{
	if (LK05Carbine(Weapon) != None && LK05Carbine(Weapon).bSilenced && SilencedFireSound.Sound != None)
		Weapon.PlayOwnedSound(SilencedFireSound.Sound,SilencedFireSound.Slot,SilencedFireSound.Volume,SilencedFireSound.bNoOverride,SilencedFireSound.Radius,SilencedFireSound.Pitch,SilencedFireSound.bAtten);
	else if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius,BallisticFireSound.Pitch,BallisticFireSound.bAtten);

	if (LK05Carbine(Weapon).bSilenced)
	{
		Weapon.SetBoneScale (0, 1.0, LK05Carbine(Weapon).SilencerBone);
	}
	else
	{
		Weapon.SetBoneScale (0, 0.0, LK05Carbine(Weapon).SilencerBone);
	}
    if (FireCount > 0)
    {
        if (Weapon.HasAnim(FireLoopAnim))
            BW.SafePlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0, ,"FIRE");
        else
            BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");
    }
    else
        BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");

	CheckClipFinished();
}

//Do the spread on the client side
function PlayFiring()
{
	if (LK05Carbine(Weapon).bSilenced)
	{
		Weapon.SetBoneScale (0, 1.0, LK05Carbine(Weapon).SilencerBone);
	}
	else
	{
            	Instigator.AmbientSound = BW.UsedAmbientSound;
		Weapon.SetBoneScale (0, 0.0, LK05Carbine(Weapon).SilencerBone);
	}

	if (BW.MagAmmo - ConsumedLoad < 1)
	{
		BW.IdleAnim = 'OpenIdle';
		BW.ReloadAnim = 'ReloadEmpty';
    		if (LK05Carbine(Weapon).bScopeView)
			FireAnim = 'OpenSightFire';
		else
			FireAnim = 'OpenFire';
	}
	else
	{
		BW.IdleAnim = 'Idle';
		BW.ReloadAnim = 'Reload';
    		if (LK05Carbine(Weapon).bScopeView)
			FireAnim = 'SightFire';
		else
			FireAnim = 'Fire';
	}

	BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");
    ClientPlayForceFeedback(FireForce);  // jdf

    	if (!bFiring)
		bFiring=true;
    FireCount++;

	if (LK05Carbine(Weapon) != None && LK05Carbine(Weapon).bSilenced && SilencedFireSound.Sound != None)
	{
		if (LK05Carbine(Weapon).CurrentWeaponMode == 0 || LK05Carbine(Weapon).CurrentWeaponMode == 1)
			Weapon.PlayOwnedSound(SilencedFireSound.Sound,SilencedFireSound.Slot,SilencedFireSound.Volume,,SilencedFireSound.Radius,,true);
	}
	else if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,,BallisticFireSound.Radius);

	CheckClipFinished();
}

simulated function SwitchSilencerMode (bool bNewMode)
{
	if (bNewMode == true)
	{
     			Damage=23;
     			DamageHead=70;
     			DamageLimb=11;
			RangeAtten=0.800000;
     			DamageType=Class'BWBP_SKC_Fix.DT_LK05SilAssault';
     			DamageTypeHead=Class'BWBP_SKC_Fix.DT_LK05SilAssaultHead';
     			DamageTypeArm=Class'BWBP_SKC_Fix.DT_LK05SilAssault';

	}
	
	else
	{
		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
			RangeAtten=default.RangeAtten;
     			DamageType=Class'BWBP_SKC_Fix.DT_LK05Assault';
     			DamageTypeHead=Class'BWBP_SKC_Fix.DT_LK05AssaultHead';
     			DamageTypeArm=Class'BWBP_SKC_Fix.DT_LK05Assault';
	}

}

simulated event ModeDoFire()
{
	if (LK05Carbine(Weapon).bSilenced)
	{
    		if (!AllowFire())
		{
			StopFiring();
       			return;
		}
	}

	Super.ModeDoFire();
}

simulated function ModeTick(float DT)
{
	Super.ModeTick(DT);


        if (bIsFiring && LK05Carbine(Weapon).bSilenced && LK05Carbine(Weapon).CurrentWeaponMode != 0 && LK05Carbine(Weapon).CurrentWeaponMode != 1)
            Instigator.AmbientSound = FireSoundLoop;
        else
            Instigator.AmbientSound = BW.UsedAmbientSound;
}


function DoFireEffect()
{
	Super.DoFireEffect();
	bFiring=true;
}

function StopFiring()
{
	bFiring=false;
     	Instigator.AmbientSound = BW.UsedAmbientSound;
	super.StopFiring();
}


defaultproperties
{
     SMuzzleFlashClass=Class'BWBP_SKC_Fix.LK05SilencedFlash'
     SFlashBone="tip2"
     SFlashScaleFactor=1.000000
     FireSoundLoop=Sound'BWBP_SKC_Sounds.Misc.F2000-FireLoopSil'
     FireSoundLoopBegin=Sound'BWBP_SKC_Sounds.Misc.F2000-SilFire'
//     TraceRange=(Min=9000.000000,Max=11000.000000)
     TraceRange=(Min=10000.000000,Max=12000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=32.000000
     MaxWalls=3
//     Damage=(Min=21.000000,Max=33.000000)
//     DamageHead=(Min=65.000000,Max=90.000000)
//     DamageLimb=(Min=8.000000,Max=15.000000)
     Damage=24
     DamageHead=75
     DamageLimb=13
     WaterRangeAtten=0.700000
     RangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DT_LK05Assault'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_LK05AssaultHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_LK05Assault'
     KickForce=18000
     PenetrateForce=75
     bPenetrate=False
     HookStopFactor=0.2
     HookPullForce=-10
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bCockAfterEmpty=False
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     FlashScaleFactor=0.800000
     BrassClass=Class'BWBP_SKC_Fix.Brass_RifleAlt'
     BrassBone="ejector"
     BrassOffset=(X=-20.000000,Y=1.000000)
     RecoilPerShot=128.000000
     XInaccuracy=96.000000
     YInaccuracy=96.000000
//     XInaccuracy=2.400000
//     YInaccuracy=2.400000
     SilencedFireSound=(Sound=Sound'BWBP_SKC_Sounds.Misc.F2000-SilFire',Volume=1.100000,Radius=24.000000,bAtten=True)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.LK05.LK05-RapidFire',Volume=1.200000)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
//     FireRate=0.122500
     FireRate=0.080000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_68mm'
     ShakeRotMag=(X=64.000000,Y=32.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=1.000000
     ShakeOffsetMag=(X=-10.000000)
     ShakeOffsetRate=(X=-500.000000)
     ShakeOffsetTime=1.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
