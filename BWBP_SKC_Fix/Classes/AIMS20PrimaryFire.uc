//=============================================================================
// AIMS20PrimaryFire.
//
// Extremely powerful and accurate rifle fire. Various firemodes to choose from.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AIMS20PrimaryFire extends BallisticShotgunFire;

var() sound		SpecialFireSound;

// Burst Mode -----------------------------------------------------------------
var int ShotsFired;         // Number of shots fired in this burst thus far
var bool bRapidMode;        // Weapon fires bursts


// ModeDoFire from WeaponFire.uc, but with a few changes
simulated event ModeDoFire()
{
	if (!AllowFire())
		return;
	if (bIsJammed)
	{
		if (BW.FireCount == 0)
		{
			bIsJammed=false;
			if (bJamWastesAmmo && Weapon.Role == ROLE_Authority)
			{
				ConsumedLoad += Load;
				Timer();
			}
			if (UnjamMethod == UJM_FireNextRound)
			{
				NextFireTime += FireRate;
				NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
				BW.FireCount++;
				return;
			}
			if (!AllowFire())
				return;
     		}
		else
		{
			NextFireTime += FireRate;
			NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
			return;
		}
	}

	if (BW != None)
	{
		BW.bPreventReload=true;
		BW.FireCount++;

		if (BW.ReloadState != RS_None)
		{
			if (weapon.Role == ROLE_Authority)
			BW.bServerReloading=false;
			BW.ReloadState = RS_None;
		}
	}

	if (MaxHoldTime > 0.0)
		HoldTime = FMin(HoldTime, MaxHoldTime);

	ConsumedLoad += Load;
	SetTimer(FMin(0.1, FireRate/2), false);
	// server
	if (Weapon.Role == ROLE_Authority)
	{
		DoFireEffect();
 		if ( (Instigator == None) || (Instigator.Controller == None) )
			return;
		if ( AIController(Instigator.Controller) != None )
			AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);
 		Instigator.DeactivateSpawnProtection();
	}
	else if (!BW.bScopeView && !BW.bUseNetAim)
		FireRecoil();
 
	BW.LastFireTime = Level.TimeSeconds;


	// client
	if (Instigator.IsLocallyControlled())
	{
		ShakeView();
		PlayFiring();
        	FlashMuzzleFlash();
        	StartMuzzleSmoke();
	}
	else // server
	{
        	ServerPlayFiring();
	}

	// set the next firing time. must be careful here so client and server do not get out of sync
	if (bFireOnRelease)
	{
        	if (bIsFiring)
			NextFireTime += MaxHoldTime + FireRate;
        	else
            		NextFireTime = Level.TimeSeconds + FireRate;
    	}
    	else if (bRapidMode)
    	{
     		if (ShotsFired > 3)
     		{
      			NextFireTime += 0.25;
      			NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
      			Weapon.StopFire(ThisModeNum);
      			ShotsFired = 0;
     		}
     		else
     		{
      			NextFireTime += 0.1;
     			NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    		}
    	}
    	else
    	{
        	NextFireTime += FireRate;
        	NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    	}

    	Load = AmmoPerFire;
    	HoldTime = 0;

    	if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    	{
        	bIsFiring = false;
        	Weapon.PutDown();
    	}

 	if (BW != None)
 	{
  		BW.bNeedReload = BW.MayNeedReload(ThisModeNum, ConsumedLoad);
  		if (bCockAfterFire || (bCockAfterEmpty && BW.MagAmmo - ConsumedLoad < 1))
   			BW.bNeedCock=true;
	}
}

function StopFiring()
{
	Super.StopFiring();
	if (bRapidMode)
	{
		ShotsFired = 0;
		NextFireTime = Level.TimeSeconds + 0.25;
	}
}



simulated function SwitchCannonMode (byte NewMode)
{
	if (NewMode == 3)
	{
		BallisticFireSound.Sound=SpecialFireSound;
		FireRate = 0.063;
		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
		AmmoPerFire=10;
     		AIMS20AssaultRifle(Weapon).RecoilXFactor = 0.1;
     		AIMS20AssaultRifle(Weapon).RecoilYFactor = 0.6;
	}
	else if (NewMode == 2)
	{
		BallisticFireSound.Sound=default.BallisticFireSound.sound;
		FireRate = 0.15;
		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
		AmmoPerFire=10;
     		AIMS20AssaultRifle(Weapon).RecoilXFactor = 0.4;
     		AIMS20AssaultRifle(Weapon).RecoilYFactor = 0.1;
	}
	else if (NewMode == 1)
	{
		BallisticFireSound.Sound=default.BallisticFireSound.sound;
		FireRate = 0.1;
		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
		AmmoPerFire=10;
     		AIMS20AssaultRifle(Weapon).RecoilXFactor = 0.2;
     		AIMS20AssaultRifle(Weapon).RecoilYFactor = 0.2;
	}
	else if (NewMode == 0)
	{
		BallisticFireSound.Sound=default.BallisticFireSound.sound;
		FireRate = 0.35;
		Damage = 105;
		DamageHead = 300;
		DamageLimb = 55;
		AmmoPerFire=30;
     		AIMS20AssaultRifle(Weapon).RecoilXFactor = 0.1;
     		AIMS20AssaultRifle(Weapon).RecoilYFactor = 0.1;
	} 
/*	else if (NewMode == 0)
	{
		BallisticFireSound.Sound=default.BallisticFireSound.sound;
		FireRate = 0.05;
     		AIMS20AssaultRifle(Weapon).RecoilXFactor = 0.1;
     		AIMS20AssaultRifle(Weapon).RecoilYFactor = 0.1;
	} */
	else
	{
		BallisticFireSound.Sound=default.BallisticFireSound.sound;
		FireRate = default.FireRate;
		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
		AmmoPerFire=1;
     		AIMS20AssaultRifle(Weapon).RecoilXFactor	= 0.1;
     		AIMS20AssaultRifle(Weapon).RecoilYFactor	= 0.1;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.50;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

	Load=AmmoPerFire;
}



defaultproperties
{
     SpecialFireSound=Sound'BWBP_SKC_Sounds.Misc.AIMS-Fire3'
     TraceRange=(Min=12000.000000,Max=15000.000000)
     TraceCount=5
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_AIMS'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     WaterRangeFactor=0.800000
     MaxWallSize=48.000000
     MaxWalls=2
//     Damage=(Min=30.000000,Max=40.000000)
//     DamageHead=(Min=80.000000,Max=120.000000)
//     DamageLimb=(Min=15.000000,Max=20.000000)
     Damage=8
     DamageHead=20
     DamageLimb=6
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DT_AIMS20Body'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTM30A2AssaultHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_AIMS20Body'
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
     RecoilPerShot=96.000000
//     XInaccuracy=1.500000
//     YInaccuracy=1.600000
     XInaccuracy=64.000000
     YInaccuracy=64.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.Misc.AIMS-Fire1',Volume=2.100000,Slot=SLOT_Interact,bNoOverride=False)
     bPawnRapidFireAnim=True
     AmmoPerFire=10
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.060000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_MetalStorm'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=2.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
