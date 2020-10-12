//=============================================================================
// Mk781PrimaryFire.
//
// Moderately weak shotgun with excellent accuracy and good RoF.
// Is about half as strong as the other shotguns - usually requires more shots.
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Mk781PrimaryFire extends BallisticShotgunFire;


var() Actor						SMuzzleFlash;		// Silenced Muzzle flash stuff
var() class<Actor>				SMuzzleFlashClass;
var() Name						SFlashBone;
var() float						SFlashScaleFactor;

simulated function bool AllowFire()
{
	if (level.TimeSeconds < Mk781Shotgun(Weapon).SilencerSwitchTime)
		return false;
	if (Mk781Shotgun(Weapon).bReady)
		return false;
	return super.AllowFire();
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

//Trigger muzzleflash emitter
function FlashMuzzleFlash()
{
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;
    if (!Mk781Shotgun(Weapon).bSilenced && MuzzleFlash != None)
        MuzzleFlash.Trigger(Weapon, Instigator);
    else if (Mk781Shotgun(Weapon).bSilenced && SMuzzleFlash != None)
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
// End effect functions ----------------------------------------------------
function float GetDamage (Actor Other, vector HitLocation, vector Dir, out Actor Victim, optional out class<DamageType> DT)
{
	if (Mk781Shotgun(Weapon).bSilenced)
		return Super.GetDamage (Other, HitLocation, Dir, Victim, DT) * 0.85;
	else
		return Super.GetDamage (Other, HitLocation, Dir, Victim, DT);
}

function ServerPlayFiring()
{
	if (Mk781Shotgun(Weapon) != None && Mk781Shotgun(Weapon).bSilenced && SilencedFireSound.Sound != None)
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


simulated function SwitchSilencerMode(bool bSilenced)
{
	if (bSilenced == true)
	{
			XInaccuracy=200;
			YInaccuracy=150;
			FireRate=0.750000;
//			RecoilPerShot=256;
			RecoilPerShot=512;
//			if (Mk781Shotgun(Weapon) != None)
//				Mk781Shotgun(Weapon).AimSpread *= 2.00;
	}
	
	else
	{
			XInaccuracy=default.XInaccuracy;
			YInaccuracy=default.YInaccuracy;
			FireRate=default.FireRate;
			RecoilPerShot=default.RecoilPerShot;
//			if (Mk781Shotgun(Weapon) != None)
//				Mk781Shotgun(Weapon).AimSpread = default.Mk781Shotgun(Weapon).AimSpread;
	}

}


//Do the spread on the client side
function PlayFiring()
{
//	if (Mk781Shotgun(Weapon).bSilenced)
//		Weapon.SetBoneScale (0, 1.0, Mk781Shotgun(Weapon).SilencerBone);
//	else
//		Weapon.SetBoneScale (0, 0.0, Mk781Shotgun(Weapon).SilencerBone);
	Mk781Shotgun(Weapon).UpdateBones();

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
    FireCount++;

	if (Mk781Shotgun(Weapon) != None && Mk781Shotgun(Weapon).bSilenced && SilencedFireSound.Sound != None)
		Weapon.PlayOwnedSound(SilencedFireSound.Sound,SilencedFireSound.Slot,SilencedFireSound.Volume,,SilencedFireSound.Radius,,true);
	else if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,,BallisticFireSound.Radius);

	CheckClipFinished();
}


defaultproperties
{
     SMuzzleFlashClass=Class'BallisticFix.XK2SilencedFlash'
     SFlashBone="tip2"
     SFlashScaleFactor=1.000000
     TraceCount=10
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_Flechette'
     ImpactManager=Class'BallisticFix.IM_Shell'
     TraceRange=(Min=3000.000000,Max=5000.000000)
     Damage=15
//     Damage=(Min=15.000000,Max=30.000000)
     DamageHead=30
     DamageLimb=5
//     RangeAtten=0.850000
     RangeAtten=0.600000
     DamageType=Class'BWBP_SKC_Fix.DTM781Shotgun'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTM781ShotgunHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTM781Shotgun'
     KickForce=8000
     PenetrateForce=100
     bPenetrate=True
//     bCockAfterEmpty=True
     MuzzleFlashClass=Class'BWBP_SKC_Fix.Mk781FlashEmitter'
     FlashScaleFactor=2.000000
     BrassClass=Class'BWBP_SKC_Fix.Brass_ShotgunFlechette'
     BrassOffset=(X=-1.000000,Z=-1.000000)
     RecoilPerShot=768.000000
     VelocityRecoil=180.000000
     XInaccuracy=400.000000
     YInaccuracy=350.000000
//     SilencedFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.MK781.Mk781-FireSil',Volume=2.300000,Radius=24.000000,bAtten=True)
     SilencedFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.MK781.Mk781-FireSil',Volume=2.300000)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.MK781.Mk781-Fire',Volume=1.300000)
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.400000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_10GaugeDart'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
