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
class JSOCPrimaryFire extends BallisticInstantFire;

var bool bFiring;

var() Actor						SMuzzleFlash;		// Silenced Muzzle flash stuff
var() class<Actor>				SMuzzleFlashClass;
var() Name						SFlashBone;
var() float						SFlashScaleFactor;


simulated function bool AllowFire()
{
	if (level.TimeSeconds < JSOCMachineGun(Weapon).SilencerSwitchTime)
		return false;
	return super.AllowFire();
}


//Trigger muzzleflash emitter
function FlashMuzzleFlash()
{
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;
    if (!JSOCMachineGun(Weapon).bSilenced && MuzzleFlash != None)
        MuzzleFlash.Trigger(Weapon, Instigator);
    else if (JSOCMachineGun(Weapon).bSilenced && SMuzzleFlash != None)
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
	BallisticAttachment(Weapon.ThirdPersonActor).BallisticUpdateHit(Other, HitLocation, HitNormal, Surf, JSOCMachineGun(Weapon).bSilenced, WaterHitLoc);
}

function ServerPlayFiring()
{
	if (JSOCMachineGun(Weapon) != None && JSOCMachineGun(Weapon).bSilenced && SilencedFireSound.Sound != None)
		Weapon.PlayOwnedSound(SilencedFireSound.Sound,SilencedFireSound.Slot,SilencedFireSound.Volume,SilencedFireSound.bNoOverride,SilencedFireSound.Radius,SilencedFireSound.Pitch,SilencedFireSound.bAtten);
	else if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius,BallisticFireSound.Pitch,BallisticFireSound.bAtten);

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
	if (JSOCMachineGun(Weapon).bSilenced)
		Weapon.SetBoneScale (0, 1.0, JSOCMachineGun(Weapon).SilencerBone);
	else
		Weapon.SetBoneScale (0, 0.0, JSOCMachineGun(Weapon).SilencerBone);

    if (FireCount > 0)
    {
        if (Weapon.HasAnim(FireLoopAnim))
            BW.SafePlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0, ,"FIRE");
        else
            BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");
    }
    else
        BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");
    ClientPlayForceFeedback(FireForce);  // jdf

    	if (!bFiring)
		bFiring=true;
    FireCount++;

	if (JSOCMachineGun(Weapon) != None && JSOCMachineGun(Weapon).bSilenced && SilencedFireSound.Sound != None)
		Weapon.PlayOwnedSound(SilencedFireSound.Sound,SilencedFireSound.Slot,SilencedFireSound.Volume,,SilencedFireSound.Radius,,true);
	else if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,,BallisticFireSound.Radius);

	CheckClipFinished();
}

simulated function SwitchSilencerMode (bool bNewMode)
{
	if (bNewMode == true)
	{
     			Damage=20;
     			DamageHead=75;
     			DamageLimb=9;
	}
	
	else
	{
		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
	}

}

function DoFireEffect()
{
	Super.DoFireEffect();
	bFiring=true;
}

function StopFiring()
{
	bFiring=false;
	super.StopFiring();
}

defaultproperties
{
     TraceRange=(Min=12000.000000,Max=15000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=32.000000
     MaxWalls=3
     Damage=24
     DamageHead=70
     DamageLimb=15
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
     RecoilPerShot=128.000000
     XInaccuracy=3.000000
     YInaccuracy=3.750000
     SilencedFireSound=(Sound=SoundGroup'BWBP_SKC_SoundsExp.JSOC.JSOC-SuppressedFire',Volume=1.500000,Radius=24.000000,bAtten=True)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.JSOC.JSOC-Fire',Volume=1.500000,Slot=SLOT_Interact,bNoOverride=False)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.085000
     AmmoClass=Class'BallisticFix.Ammo_556mm'
     ShakeRotMag=(X=64.000000,Y=64.000000)
     ShakeRotRate=(X=7000.000000,Y=7000.000000,Z=55000.000000)
     ShakeRotTime=1.500000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
