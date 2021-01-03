//=============================================================================
// SX45PrimaryFire.
//
// Potent, but slow .45 fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class SX45PrimaryFire extends BallisticInstantFire;

var() sound		Amp1FireSound; //Cyro, Blue
var() sound		Amp2FireSound; //Rad, Yellow
var() sound		RegularFireSound;
var bool		bFlashAmp1;
var bool		bFlashAmp2;
var() Actor						MuzzleFlashAmp1;		
var() class<Actor>				MuzzleFlashClassAmp1;	
var() Actor						MuzzleFlashAmp2;		
var() class<Actor>				MuzzleFlashClassAmp2;	
var() Name						AmpFlashBone;
var() float						Amp1FlashScaleFactor;
var() float						Amp2FlashScaleFactor;

simulated function bool AllowFire()
{
	if (level.TimeSeconds < SX45Pistol(Weapon).AmplifierSwitchTime)
		return false;
	return super.AllowFire();
}

// Effect related functions ------------------------------------------------
// Spawn the muzzleflash actor
function InitEffects()
{
	if (AIController(Instigator.Controller) != None)
		return;
    if ((MuzzleFlashClass != None) && ((MuzzleFlash == None) || MuzzleFlash.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, Weapon.DrawScale*FlashScaleFactor, weapon, FlashBone);
    if ((MuzzleFlashClassAmp1 != None) && ((MuzzleFlashAmp1 == None) || MuzzleFlashAmp1.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlashAmp1, MuzzleFlashClassAmp1, Weapon.DrawScale*Amp1FlashScaleFactor, weapon, AmpFlashBone);
    if ((MuzzleFlashClassAmp2 != None) && ((MuzzleFlashAmp2 == None) || MuzzleFlashAmp2.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlashAmp2, MuzzleFlashClassAmp2, Weapon.DrawScale*Amp2FlashScaleFactor, weapon, AmpFlashBone);

}

// Remove effects
simulated function DestroyEffects()
{
	Super.DestroyEffects();

	class'BUtil'.static.KillEmitterEffect (MuzzleFlash);
	class'BUtil'.static.KillEmitterEffect (MuzzleFlashAmp1);
	class'BUtil'.static.KillEmitterEffect (MuzzleFlashAmp2);
}


//Trigger muzzleflash emitter
function FlashMuzzleFlash()
{
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;
    if (MuzzleFlash != None && !bFlashAmp1 && !bFlashAmp2)
        MuzzleFlash.Trigger(Weapon, Instigator);
    else if (MuzzleFlashAmp1 != None && bFlashAmp1)
       	MuzzleFlashAmp1.Trigger(Weapon, Instigator);
    else if (MuzzleFlashAmp2 != None && bFlashAmp2)
        MuzzleFlashAmp2.Trigger(Weapon, Instigator);
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
		bFlashAmp1=false;
		bFlashAmp2=false;
		SX45Attachment(Weapon.ThirdPersonActor).bAmp1=false;
		SX45Attachment(Weapon.ThirdPersonActor).bAmp2=false;
		RangeAtten=default.RangeAtten;
	}
	else if (NewMode == 1) //Cryo Amp
	{
		BallisticFireSound.Sound=Amp1FireSound;
		BallisticFireSound.Volume=1.700000;
		RecoilPerShot=512.000000;
		Damage=70.000000;
		DamageHead=100.000000;
		DamageLimb=35.000000;
		FireRate=0.400000;
		MaxWalls=0;
		FlashScaleFactor=1.100000;
		bFlashAmp1=true;
		bFlashAmp2=false;
		SX45Attachment(Weapon.ThirdPersonActor).bAmp1=true;
		SX45Attachment(Weapon.ThirdPersonActor).bAmp2=false;
		RangeAtten=1.000000;
	}
	else if (NewMode == 2) //Radiation Amp
	{
		BallisticFireSound.Sound=Amp2FireSound;
		BallisticFireSound.Volume=1.200000;
		RecoilPerShot=128.000000;
		Damage=70.000000;
		DamageHead=100.000000;
		DamageLimb=35.000000;
		FireRate=0.500000;
		MaxWalls=0;
		bFlashAmp1=false;
		bFlashAmp2=true;
		SX45Attachment(Weapon.ThirdPersonActor).bAmp1=false;
		SX45Attachment(Weapon.ThirdPersonActor).bAmp2=true;
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
		bFlashAmp1=false;
		bFlashAmp2=false;
		SX45Attachment(Weapon.ThirdPersonActor).bAmp1=false;
		SX45Attachment(Weapon.ThirdPersonActor).bAmp2=false;
		RangeAtten=default.RangeAtten;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.75;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	if (bFlashAmp1)
	{
		Weapon.HurtRadius(10, 92, DamageType, 1, HitLocation);
	}
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}

//Do the spread on the client side
function PlayFiring()
{

	if (BW.MagAmmo - ConsumedLoad < 1)
	{
		BW.IdleAnim = 'IdleOpen';
		BW.ReloadAnim = 'ReloadOpen';
		if (SX45Pistol(Weapon).bScopeView)
		{
			if (bFlashAmp1 || bFlashAmp2)
				FireAnim = 'FireOpen';
			else
				FireAnim = 'SightFireOpen';
		}
		else
		{
			FireAnim = 'FireOpen';
		}
	}
	else
	{
		BW.IdleAnim = 'Idle';
		BW.ReloadAnim = 'Reload';
		if (SX45Pistol(Weapon).bScopeView)
		{
			if (bFlashAmp1 || bFlashAmp2)
				FireAnim = 'Fire';
			else
				FireAnim = 'SightFire';
		}
		else
		{
			FireAnim = 'Fire';
		}
	}

	BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");

    ClientPlayForceFeedback(FireForce);  // jdf
    FireCount++;

	if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,,BallisticFireSound.Radius);

}

defaultproperties
{
     Amp1FireSound=Sound'BWBP_SKC_SoundsExp.SX45.SX45-FrostFire'
     Amp2FireSound=Sound'BWBP_SKC_SoundsExp.SX45.SX45-RadFire'

	 AmpFlashBone="tip2"
     Amp1FlashScaleFactor=0.750000
     Amp2FlashScaleFactor=6.000000
     TraceRange=(Max=5500.000000)
     WaterRangeFactor=0.600000
     MaxWallSize=32.000000
     MaxWalls=2
     Damage=32
     DamageHead=85
     DamageLimb=12
     RangeAtten=0.900000
     WaterRangeAtten=0.500000
     DamageType=Class'BWBP_SKC_Fix.DTM1911Pistol'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTM1911PistolHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTM1911Pistol'
     KickForce=15000
     PenetrateForce=150
     bPenetrate=True
     MuzzleFlashClass=Class'BallisticFix.XK2FlashEmitter'
     MuzzleFlashClassAmp1=Class'BWBP_SKC_Fix.SX45CryoFlash'
     MuzzleFlashClassAmp2=Class'BWBP_SKC_Fix.SX45RadMuzzleFlash'
     BrassClass=Class'BallisticFix.Brass_Pistol'
     BrassBone="ejector"
     BrassOffset=(X=-25.000000,Y=0.000000)
     RecoilPerShot=640.000000
     FireChaos=0.050000
     XInaccuracy=11.500000
     YInaccuracy=11.500000
     SilencedFireSound=(Sound=Sound'BWBP_SKC_Sounds.M1911.M1911-FireSil',Volume=0.800000,Radius=24.000000,bAtten=True)
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_SoundsExp.SX45.SX45-Fire',Volume=1.600000)
     bModeExclusive=False
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.250000
     AmmoClass=Class'BallisticFix.Ammo_45HV'
     ShakeRotMag=(X=64.000000,Y=32.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-3.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=0.300000
     WarnTargetPct=0.100000
}
