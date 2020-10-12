//=============================================================================
// CX61 Primary Fire.
//
// 2-shot burst flechettes.
//
// by Azarael
//=============================================================================
class CX61PrimaryFire extends BallisticInstantFire;

var int ShotsFired;         // Number of shots fired in this burst thus far


// Checks if gun has fired too much for weapon mode. (e.g. more than one shot for single fire
// or more than the amount allowed in a burst) Returns false if it has
simulated function bool CheckWeaponMode()
{
	if (Instigator != None && AIController(Instigator.Controller) != None)
		return true;
	return CX61AssaultRifle(BW).CheckWeaponModeAlt();
}


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
     	if (ShotsFired > 2)
     	{
      		NextFireTime += 0.25;
      		NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
      		Weapon.StopFire(ThisModeNum);
      		ShotsFired = 0;
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
		ShotsFired = 0;
		NextFireTime = Level.TimeSeconds + 0.25;
}


defaultproperties
{
     aimerror=900.000000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_CX61Flechette'
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.CX61.CX61-Fire',Volume=1.500000,Slot=SLOT_Interact,bNoOverride=False)
     bCockAfterEmpty=False
     bPawnRapidFireAnim=True
     bPenetrate=True
     BrassBone="tip"
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassOffset=(X=-80.000000,Y=1.000000)
     Damage=50
     DamageHead=101
     DamageLimb=36
     DamageType=Class'BWBP_SKC_Fix.DT_CX61Chest'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_CX61Chest'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_CX61Head'
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     FireChaos=0.2
     FireEndAnim=
     FireRate=0.15000
     FlashScaleFactor=1
     KickForce=22000
     MaxWalls=2
     FireAnim="SightFire"
     MaxWallSize=64.000000
     MuzzleFlashClass=Class'BWBP_SKC_Fix.VSKSilencedFlash'
     PenetrateForce=180
     RangeAtten=0.600000
     RecoilPerShot=256.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     TraceRange=(Min=12000.000000,Max=13000.000000)
     TweenTime=0.000000
     WarnTargetPct=0.200000
     WaterRangeAtten=0.800000
     WaterRangeFactor=0.800000
     XInaccuracy=2.00000
     YInaccuracy=2.00000
}
