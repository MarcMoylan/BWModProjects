//=============================================================================
// M30PrimaryFire.
//
//[11:09:19 PM] Captain Xavious: make sure its noted to be an assault rifle
//[11:09:26 PM] Marc Moylan: lol Calypto
//[11:09:28 PM] Matteo 'Azarael': mp40 effective range
//[11:09:29 PM] Matteo 'Azarael': miles
//=============================================================================
class FMPPrimaryFire extends BallisticInstantFire;

var() sound		AmpRedFireSound;
var() sound		AmpGreenFireSound;
var() sound		RegularFireSound;
var bool		bFlashRed;
var bool		bFlashGreen;
var() Actor						MuzzleFlashRed;		// ALT: The muzzleflash actor
var() class<Actor>				MuzzleFlashClassRed;	// ALT: The actor to use for this fire's muzzleflash
var() Actor						MuzzleFlashGreen;		// ALT: The muzzleflash actor
var() class<Actor>				MuzzleFlashClassGreen;	// ALT: The actor to use for this fire's muzzleflash
var() Name						AmpFlashBone;
var() float						AmpFlashScaleFactor;

// Effect related functions ------------------------------------------------
// Spawn the muzzleflash actor
function InitEffects()
{
	if (AIController(Instigator.Controller) != None)
		return;
    if ((MuzzleFlashClass != None) && ((MuzzleFlash == None) || MuzzleFlash.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, Weapon.DrawScale*FlashScaleFactor, weapon, FlashBone);
    if ((MuzzleFlashClassRed != None) && ((MuzzleFlashRed == None) || MuzzleFlashRed.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlashRed, MuzzleFlashClassRed, Weapon.DrawScale*FlashScaleFactor, weapon, FlashBone);
    if ((MuzzleFlashClassGreen != None) && ((MuzzleFlashGreen == None) || MuzzleFlashGreen.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlashGreen, MuzzleFlashClassGreen, Weapon.DrawScale*AmpFlashScaleFactor, weapon, FlashBone);

}

// Remove effects
simulated function DestroyEffects()
{
	Super.DestroyEffects();

	class'BUtil'.static.KillEmitterEffect (MuzzleFlash);
	class'BUtil'.static.KillEmitterEffect (MuzzleFlashRed);
	class'BUtil'.static.KillEmitterEffect (MuzzleFlashGreen);
}


//Trigger muzzleflash emitter
function FlashMuzzleFlash()
{
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;
    if (MuzzleFlash != None && !bFlashRed && !bFlashGreen)
        MuzzleFlash.Trigger(Weapon, Instigator);
    else if (MuzzleFlashRed != None && bFlashRed)
       	MuzzleFlashRed.Trigger(Weapon, Instigator);
    else if (MuzzleFlashGreen != None && bFlashGreen)
        MuzzleFlashGreen.Trigger(Weapon, Instigator);
	if (!bBrassOnCock)
		EjectBrass();
}


simulated function SwitchWeaponMode (byte NewMode)
{
	if (NewMode == 0) //Standard Fire
	{
		BallisticFireSound.Sound=default.BallisticFireSound.sound;
		BallisticFireSound.Volume=default.BallisticFireSound.Volume;
		RecoilPerShot=default.RecoilPerShot;
		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
		FireRate=Default.FireRate;
		MaxWalls=default.MaxWalls;
		FlashScaleFactor=default.FlashScaleFactor;
		bFlashRed=false;
		bFlashGreen=false;
		FMPAttachment(Weapon.ThirdPersonActor).bRedAmp=false;
		FMPAttachment(Weapon.ThirdPersonActor).bGreenAmp=false;
		RangeAtten=default.RangeAtten;
	}
	
	else if (NewMode == 1) //Incendiary Amp
	{
		BallisticFireSound.Sound=AmpRedFireSound;
		BallisticFireSound.Volume=1.900000;
		RecoilPerShot=512.000000;
		Damage=30.000000;
		DamageHead=90.000000;
		DamageLimb=20.000000;
		FireRate=0.235000;
		MaxWalls=0;
		FlashScaleFactor=1.100000;
		bFlashRed=true;
		bFlashGreen=false;
		FMPAttachment(Weapon.ThirdPersonActor).bRedAmp=true;
		FMPAttachment(Weapon.ThirdPersonActor).bGreenAmp=false;
		RangeAtten=1.000000;
	}
	else if (NewMode == 2) //Corrosive Amp
	{
		BallisticFireSound.Sound=AmpGreenFireSound;
		BallisticFireSound.Volume=1.200000;
		RecoilPerShot=128.000000;
		Damage=15.000000;
		DamageHead=60.000000;
		DamageLimb=10.000000;
		FireRate=0.122500;
		MaxWalls=0;
		FlashScaleFactor=0.400000;
		bFlashRed=false;
		bFlashGreen=true;
		FMPAttachment(Weapon.ThirdPersonActor).bRedAmp=false;
		FMPAttachment(Weapon.ThirdPersonActor).bGreenAmp=true;
		RangeAtten=1.000000;
	}
	else
	{
		BallisticFireSound.Sound=default.BallisticFireSound.sound;
		BallisticFireSound.Volume=default.BallisticFireSound.Volume;
		RecoilPerShot=default.RecoilPerShot;
		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
		FireRate=Default.FireRate;
		MaxWalls=default.MaxWalls;
		FlashScaleFactor=default.FlashScaleFactor;
		bFlashRed=false;
		bFlashGreen=false;
		FMPAttachment(Weapon.ThirdPersonActor).bRedAmp=false;
		FMPAttachment(Weapon.ThirdPersonActor).bGreenAmp=false;
		RangeAtten=default.RangeAtten;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.75;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	if (bFlashRed)
	{
		Weapon.HurtRadius(10, 92, DamageType, 1, HitLocation);
	}
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}

//Do the spread on the client side
function PlayFiring()
{
    	if (FMPMachinePistol(Weapon).bScopeView)
		FireAnim = 'SightFire';
	else
		FireAnim = 'Fire';
	super.PlayFiring();
}

defaultproperties
{
     AmpRedFireSound=SoundGroup'BWBP_SKC_SoundsExp.MP40.MP40-HotFire'
     AmpGreenFireSound=SoundGroup'BWBP_SKC_SoundsExp.MP40.MP40-AcidFire'
     TraceRange=(Min=9000.000000,Max=9000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=16.000000
     MaxWalls=1
     Damage=20
     DamageHead=70
     DamageLimb=10
     WaterRangeAtten=0.700000
     RangeAtten=0.700000
     DamageType=Class'BWBP_SKC_Fix.DT_MP40Chest'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_MP40Head'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_MP40Chest'
     KickForce=18000
     PenetrateForce=150
     bPenetrate=False
     HookStopFactor=0.2
     HookPullForce=-10
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bCockAfterEmpty=False
     MuzzleFlashClass=Class'BallisticFix.XK2FlashEmitter'
     MuzzleFlashClassRed=Class'BallisticFix.M50FlashEmitter'
     MuzzleFlashClassGreen=Class'BallisticFix.A500FlashEmitter'
     FlashScaleFactor=0.900000
     AmpFlashScaleFactor=0.250000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassBone="tip"
	 AmpFlashBone="tip2"
     BrassOffset=(X=-50.000000,Y=1.000000)
     RecoilPerShot=128.000000
     XInaccuracy=28.000000
     YInaccuracy=28.000000
//     XInaccuracy=2.400000
//     YInaccuracy=2.400000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.MP40.MP40-Fire',Volume=1.000000)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.122500
//     FireRate=0.080000
     AmmoClass=Class'BallisticFix.Ammo_XRS10Bullets'
     ShakeRotMag=(X=64.000000,Y=32.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=1.500000
     ShakeOffsetMag=(X=-3.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.500000
     aimerror=900.000000
}
