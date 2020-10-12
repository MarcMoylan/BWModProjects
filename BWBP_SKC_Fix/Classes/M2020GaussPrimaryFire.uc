//=============================================================================
// M2020GaussPrimaryFire.
//
// Gauss fire. Magnetic acceleration. Physics. Pv=nRT. A1V1=A2V2. Llammas.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class M2020GaussPrimaryFire extends BallisticInstantFire;
var() sound		SpecialFireSound;
var() sound		LowPowerFireSound;
var bool		bFlashAlt;
var() Actor						MuzzleFlash2;		// ALT: The muzzleflash actor
var() class<Actor>				MuzzleFlashClass2;	// ALT: The actor to use for this fire's muzzleflash

//Disable fire anim when scoped
function PlayFiring()
{
	if (ScopeDownOn == SDO_Fire)
		BW.TemporaryScopeDown(0.5, 0.9);
	// Slightly modified Code from original PlayFiring()
    if (!BW.bScopeView)
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
	// End code from normal PlayFiring()

	if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius,BallisticFireSound.Pitch,BallisticFireSound.bAtten);

	CheckClipFinished();
}


// Effect related functions ------------------------------------------------
// Spawn the muzzleflash actor
function InitEffects()
{
	if (AIController(Instigator.Controller) != None)
		return;
    if ((MuzzleFlashClass != None) && ((MuzzleFlash == None) || MuzzleFlash.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, Weapon.DrawScale*FlashScaleFactor, weapon, FlashBone);
    if ((MuzzleFlashClass2 != None) && ((MuzzleFlash2 == None) || MuzzleFlash2.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlash2, MuzzleFlashClass2, Weapon.DrawScale*FlashScaleFactor, weapon, FlashBone);

}

// Remove effects
simulated function DestroyEffects()
{
	Super.DestroyEffects();

	class'BUtil'.static.KillEmitterEffect (MuzzleFlash);
	class'BUtil'.static.KillEmitterEffect (MuzzleFlash2);
}


//Trigger muzzleflash emitter
function FlashMuzzleFlash()
{
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;
    	if (MuzzleFlash != None && !bFlashAlt)
        	MuzzleFlash.Trigger(Weapon, Instigator);
    	else if (MuzzleFlash2 != None && bFlashAlt)
        	MuzzleFlash2.Trigger(Weapon, Instigator);
	if (!bBrassOnCock)
		EjectBrass();
}


simulated function SwitchCannonMode (byte NewMode)
{
	if (NewMode == 0)
	{
		     BallisticFireSound.Sound=default.BallisticFireSound.sound;
			RecoilPerShot=default.RecoilPerShot;
			VelocityRecoil=default.VelocityRecoil;
			FireAnim=default.FireAnim;
     			PDamageFactor=default.PDamageFactor;
     			WallPDamageFactor=default.WallPDamageFactor;

		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
     			FlashScaleFactor=default.FlashScaleFactor;
			bFlashAlt=false;
			M2020GaussAttachment(Weapon.ThirdPersonActor).bNoEffect=false;
			MaxWalls=default.MaxWalls;
			FireRate=Default.FireRate;
			RangeAtten=default.RangeAtten;
	}
	
	else if (NewMode == 1)
	{
		     BallisticFireSound.Sound=SpecialFireSound;
     			RecoilPerShot=4096.000000;
     			VelocityRecoil=120.000000;
     			FireAnim='FirePowered';
			FireRate=2.000000;
     			PDamageFactor=0.850000;
     			WallPDamageFactor=0.850000;
     			Damage=110.000000;
     			DamageHead=135.000000;
     			DamageLimb=65.000000;
     			FlashScaleFactor=1.600000;
			bFlashAlt=false;
			M2020GaussAttachment(Weapon.ThirdPersonActor).bNoEffect=false;
			MaxWalls=5;
     			RangeAtten=0.950000;
	}
	else if (NewMode == 2 || NewMode == 3)
	{
		     BallisticFireSound.Sound=LowPowerFireSound;
     			RecoilPerShot=172.000000;
     			VelocityRecoil=10.000000;
    		 	FlashScaleFactor=1.000000;
     			PDamageFactor=0.600000;
     			WallPDamageFactor=0.400000;
			bFlashAlt=true;
			M2020GaussAttachment(Weapon.ThirdPersonActor).bNoEffect=true;
			if (NewMode ==2)
     				FireAnim='FireUnPowered';
			else
				FireAnim='FireShield';
			FireRate=0.400000;
     			Damage=40.000000;
     			DamageHead=100.000000;
     			DamageLimb=25.000000;
			MaxWalls=3;
     			RangeAtten=0.850000;
	}
	else
	{
		     BallisticFireSound.Sound=default.BallisticFireSound.sound;
			RecoilPerShot=default.RecoilPerShot;
			VelocityRecoil=default.VelocityRecoil;
     			PDamageFactor=default.PDamageFactor;
     			WallPDamageFactor=default.WallPDamageFactor;

		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
			bFlashAlt=false;
			M2020GaussAttachment(Weapon.ThirdPersonActor).bNoEffect=false;
			MaxWalls=default.MaxWalls;
			FireRate=Default.FireRate;
			RangeAtten=default.RangeAtten;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.75;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

}



defaultproperties
{
     SpecialFireSound=Sound'BWBP_SKC_SoundsExp.M2020.M2020-GaussFireSuper'
     LowPowerFireSound=Sound'BWBP_SKC_SoundsExp.M2020.M2020-GaussFireLow'
     TraceRange=(Min=15000.000000,Max=20000.000000)
     WaterRangeFactor=0.900000
     MaxWallSize=64.000000
     MaxWalls=4
     PDamageFactor=0.750000
     WallPDamageFactor=0.750000
     Damage=80
     DamageHead=135
     DamageLimb=40
     RangeAtten=0.900000
     WaterRangeAtten=0.700000
     DamageType=Class'BWBP_SKC_Fix.DT_M2020Pwr'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_M2020HeadPwr'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_M2020LimbPwr'
     KickForce=27500
     PenetrateForce=600
     bPenetrate=True
     FireAnim="Fire"
     FlashScaleFactor=1.200000
     MuzzleFlashClass=Class'BWBP_SKC_Fix.M2020FlashEmitter'
     MuzzleFlashClass2=Class'BallisticFix.M50FlashEmitter'
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassBone="tip"
     BrassOffset=(X=-30.000000,Y=1.000000)
     RecoilPerShot=2048.000000
     XInaccuracy=1.000000
     YInaccuracy=1.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.M2020.M2020-GaussFire',Volume=3.700000)
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.850000
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
