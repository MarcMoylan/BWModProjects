//=============================================================================
// AK47PrimaryFire.
//
// High powered automatic fire. Hits like the SRS but has less accuracy.
// Good for close and mid range, bad at long range.
// Has better than average penetration.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AK47PrimaryFire extends BallisticInstantFire;
var() sound		GoldFireSound;
// Burst Mode -----------------------------------------------------------------
var int ShotsFired;         // Number of shots fired in this burst thus far
var bool bRapidMode;        // Weapon fires bursts
var float RapidFireRate;


// ModeDoFire from WeaponFire.uc, but with a few changes
simulated event ModeDoFire()
{
	if (AK47AssaultRifle(Weapon).CamoIndex == 6) 
		     BallisticFireSound.Sound=GoldFireSound;
	/*
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

	ShotsFired++;
	// set the next firing time. must be careful here so client and server do not get out of sync
	if (bFireOnRelease)
	{
        	if (bIsFiring)
			NextFireTime += MaxHoldTime + FireRate;
        	else
            		NextFireTime = Level.TimeSeconds + FireRate;
    	}
    	else
    	{
     		if (ShotsFired < 2)
     		{
      			NextFireTime += RapidFireRate;
			RecoilPerShot = 128;
     			NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
     		}
     		else
     		{
      			NextFireTime += FireRate;
			RecoilPerShot = default.RecoilPerShot;
      			NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    		}
    	}
//    	else
//    	{
//        	NextFireTime += FireRate;
//        	NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
//    	}
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
	*/
	super.ModeDoFire();
}
/*

function StopFiring()
{
	Super.StopFiring();
	ShotsFired = 0;
	NextFireTime = Level.TimeSeconds + FireRate;
}*/


defaultproperties
{
     GoldFireSound=Sound'BWBP_SKC_Sounds.Misc.AIMS-Fire1'
     TraceRange=(Min=12000.000000,Max=13000.000000)
     WaterRangeFactor=0.800000
     PDamageFactor=0.600000
     WallPDamageFactor=0.600000
//     RangeAtten=0.950000
     RangeAtten=0.800000
     MaxWallSize=70.000000
     MaxWalls=4
//     Damage=(Min=25.000000,Max=35.000000)
     Damage=35
     DamageHead=100
     DamageLimb=20
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DT_AK47Assault'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_AK47AssaultHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_AK47Assault'
     KickForce=22000
     PenetrateForce=180
     bPenetrate=True
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bCockAfterEmpty=False
     MuzzleFlashClass=Class'BallisticFix.XK2FlashEmitter'
     FlashScaleFactor=0.800000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassBone="tip"
     BrassOffset=(X=-80.000000,Y=1.000000)
     RecoilPerShot=256.000000
     XInaccuracy=12.200000
     YInaccuracy=12.200000
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_SoundsExp.ak47.ak47-Fire',Volume=1.500000,Slot=SLOT_Interact,bNoOverride=False)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.140000
     RapidFireRate=0.033000;
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_AK762mm'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
