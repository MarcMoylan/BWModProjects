//=============================================================================
// F2000PrimaryFire.
//
// Very automatic, bullet style instant hit. Shots have medium range and poor
// power. Accuracy and ammo goes quickly with its SUPA FAST ROF.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class F2000PrimaryFire extends BallisticInstantFire;
	
var bool bFiring;

var() Actor						SMuzzleFlash;		// Silenced Muzzle flash stuff
var() class<Actor>				SMuzzleFlashClass;
var() Name						SFlashBone;
var() float						SFlashScaleFactor;


simulated function bool AllowFire()
{
	if (level.TimeSeconds < F2000AssaultRifle(Weapon).SilencerSwitchTime)
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
    if (!F2000AssaultRifle(Weapon).bSilenced && MuzzleFlash != None)
        MuzzleFlash.Trigger(Weapon, Instigator);
    else if (F2000AssaultRifle(Weapon).bSilenced && SMuzzleFlash != None)
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
	BallisticAttachment(Weapon.ThirdPersonActor).BallisticUpdateHit(Other, HitLocation, HitNormal, Surf, F2000AssaultRifle(Weapon).bSilenced, WaterHitLoc);
}

function ServerPlayFiring()
{
	if (F2000AssaultRifle(Weapon) != None && F2000AssaultRifle(Weapon).bSilenced && SilencedFireSound.Sound != None)
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
	if (F2000AssaultRifle(Weapon).bSilenced)
		Weapon.SetBoneScale (0, 1.0, F2000AssaultRifle(Weapon).SilencerBone);
	else
		Weapon.SetBoneScale (0, 0.0, F2000AssaultRifle(Weapon).SilencerBone);

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

	if (F2000AssaultRifle(Weapon) != None && F2000AssaultRifle(Weapon).bSilenced && SilencedFireSound.Sound != None)
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
     SMuzzleFlashClass=Class'BWBP_SKC_Fix.LK05SilencedFlash'
     SFlashBone="tip2"
     SFlashScaleFactor=1.000000
     TraceRange=(Min=10500.000000,Max=12500.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=32.000000
     MaxWalls=2
     FireAnimRate=2.000000
     Damage=22
     DamageHead=75
     DamageLimb=11
     WaterRangeAtten=0.800000
     RangeAtten=0.850000
     DamageType=Class'BWBP_SKC_Fix.DT_MARS3Assault'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_MARS3AssaultHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_MARS3Assault'
     KickForce=10000
     PenetrateForce=150
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bCockAfterEmpty=False
     MuzzleFlashClass=Class'BWBP_SKC_Fix.MJ51FlashEmitter'
     FlashScaleFactor=0.500000
     BrassClass=Class'BallisticFix.Brass_MG'
     BrassBone="ejector"
     BrassOffset=(X=-25.000000,Y=1.000000)
//     RecoilPerShot=162.000000
     RecoilPerShot=96.000000
     XInaccuracy=32.500000
     YInaccuracy=32.300000
     SilencedFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.MARS.F2000-SilFire2',Volume=1.100000,Radius=24.000000,bAtten=True)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.MARS.MARS-RapidFire',Volume=1.100000,Slot=SLOT_Interact,bNoOverride=False)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.070000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_545mmSTANAG'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
