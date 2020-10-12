//=============================================================================
// Longhorn Primary Fire.
//
// ModeHoldFire will fire a grenade. ModeDoFire will detonate that grenade if 
// firing was held long enough.
//
// by Azarael
//=============================================================================
class LonghornPrimaryFire extends BallisticProjectileFire;

var() 	Actor								MuzzleFlash2;		// The muzzleflash actor
var	LonghornClusterGrenade	LastGrenade;		// Last grenade fired.
var	float								ArtilleryDelay;		// Empower grenades launched after this time.

function ServerPlayFiring()
{
	super.ServerPlayFiring();
	LonghornLauncher(Weapon).LonghornFired();
}

//Do the spread on the client side
function PlayFiring()
{
	super.PlayFiring();
	LonghornLauncher(Weapon).LonghornFired();
}

function SpawnProjectile (Vector Start, Rotator Dir)
{
	Proj = Spawn (ProjectileClass,,, Start, Dir);
	Proj.Instigator = Instigator;
	LastGrenade = LonghornClusterGrenade(Proj);
}

function StopFiring()
{
	Super.StopFiring();
	
	if (Weapon.Role == ROLE_Authority && LastGrenade != None)
	{
		if(HoldTime > 0.35) //was 0.25
		{
			if (HoldTime > ArtilleryDelay && !LastGrenade.bNoArtillery)
				LastGrenade.ManualDetonate(True);
			else LastGrenade.ManualDetonate(false);
		}
		else LastGrenade.bFireReleased = True;
	}
		
	HoldTime = 0;
}

simulated event ModeHoldFire()
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
    else if (!BW.bUseNetAim && !BW.bScopeView)
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
    
    Load = AmmoPerFire;

    if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    {
        bIsFiring = false;
        Weapon.PutDown();
    }

	if (BW != None)
	{
		BW.bNeedReload = BW.MayNeedReload(ThisModeNum, ConsumedLoad);
	};
}

simulated event ModeDoFire()
{
	if (!AllowFire())
		return;
		
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
        NextFireTime += FireRate;
        NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    }
    
    if (BW != None)
    {
    	if (bCockAfterFire || (bCockAfterEmpty && BW.MagAmmo - ConsumedLoad < 1))
			BW.bNeedCock=true;
		if (!BW.bPreventReload && BW.bNeedCock)
			BW.CommonCockGun(0);
	}
}	

defaultproperties
{
	 ArtilleryDelay=1.5
     bCockAfterFire=True
     MuzzleFlashClass=Class'BallisticFix.MRT6FlashEmitter'
     FlashScaleFactor=1.500000
     FlashBone="tip"
     BrassBone="Ejector"
     BrassClass=Class'BWBP_SKC_Fix.Brass_Longhorn'
     BrassOffset=(X=0.000000,Y=.000000,Z=5.000000)
     RecoilPerShot=512.000000
     VelocityRecoil=300.000000
     XInaccuracy=150.000000
     YInaccuracy=300.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.Longhorn.Longhorn-Fire',Volume=1.500000)
     FireAnim="Fire"
     TweenTime=0.000000
     FireRate=0.40000
     bCockAfterEmpty=False
     bBrassOnCock=True
     bReleaseFireOnDie=True
     bFireOnRelease=True
     ProjectileClass=Class'BWBP_SKC_Fix.LonghornClusterGrenade'
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_Longhorn'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
