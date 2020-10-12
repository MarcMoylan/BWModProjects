//=============================================================================
// HVPCMk5PrimaryFire.
//
// Large plasma charges. Travel fairly fast and pack a punch.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class HVPCMk5PrimaryFire extends BallisticProjectileFire;

var   float		StopFireTime;



simulated function bool AllowFire()
{
	if ((HVPCMk5PlasmaCannon(BW).HeatLevel >= 11.5) || HVPCMk5PlasmaCannon(BW).bIsVenting || !super.AllowFire())
		return false;
	return true;
}


function PlayFiring()
{
	Super.PlayFiring();
	HVPCMk5PlasmaCannon(BW).AddHeat(1.50);
}


function StopFiring()
{
	bIsFiring=false;
	StopFireTime = level.TimeSeconds;
}

function DoFireEffect()
{

	Super.DoFireEffect();
	if (level.Netmode == NM_DedicatedServer)
		HVPCMk5PlasmaCannon(BW).AddHeat(1.50);
}

defaultproperties
{
     SpawnOffset=(X=10.000000,Y=10.000000,Z=-9.000000)
     MuzzleFlashClass=Class'BallisticFix.HVCMk9RedMuzzleFlash'
     RecoilPerShot=270.000000
     FireChaos=0.750000
     XInaccuracy=12.000000
     YInaccuracy=8.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.XavPlas.Xav-Fire',Volume=2.500000,Slot=SLOT_Interact,bNoOverride=False)
     FireAnim="Fire2"
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.720000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_HVPCCells'
     AmmoPerFire=5
     ShakeRotMag=(X=32.000000,Y=8.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=1.500000
     ShakeOffsetMag=(X=-4.000000)
     ShakeOffsetRate=(X=-1200.000000)
     ShakeOffsetTime=1.500000
     ProjectileClass=Class'BWBP_SKC_Fix.HVPCMk5Projectile'
     WarnTargetPct=0.200000
}
