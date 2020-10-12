//=============================================================================
// A42PrimaryFire.
//
// Rapid fire projectiles. Ammo regen timer is also here.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class A49PrimaryFire extends BallisticProjectileFire;

var   float		StopFireTime;

simulated function bool AllowFire()
{
	if ((A49SkrithBlaster(BW).HeatLevel >= 11.5) || A49SkrithBlaster(BW).bIsVenting || !super.AllowFire())
		return false;
	return true;
}
simulated event ModeDoFire()
{
	if (level.Netmode == NM_Standalone)
	{
	if (A49SkrithBlaster(BW).HeatLevel >= 5)
		FireRate = default.FireRate - FRand()/20 - (0.1/A49SkrithBlaster(BW).HeatLevel);
	else
		FireRate = default.FireRate - FRand()/8 + (A49SkrithBlaster(BW).HeatLevel/25);
	}
	Super.ModeDoFire();

}
simulated event ModeTick(float DT)
{
	Super.ModeTick(DT);

	if (Weapon.SoundPitch != 56)
	{
		if (Instigator.DrivenVehicle!=None)
			Weapon.SoundPitch = 56;
		else
			Weapon.SoundPitch = Max(56, Weapon.SoundPitch - 8*DT);
	}
}


function PlayFiring()
{
	if (A49SkrithBlaster(BW).HeatLevel >= 5)
		A49SkrithBlaster(BW).AddHeat(0.5);
	else
		A49SkrithBlaster(BW).AddHeat(0.8);

	Super.PlayFiring();

}


function StopFiring()
{
	bIsFiring=false;
	StopFireTime = level.TimeSeconds;
}


defaultproperties
{
     FlashBone="MuzzleTip"
     SpawnOffset=(X=10.000000,Y=10.000000,Z=-9.000000)
     MuzzleFlashClass=Class'A42FlashEmitter'
     FlashScaleFactor=0.600000
     RecoilPerShot=24.000000
     XInaccuracy=8.000000
     YInaccuracy=4.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.A49.A49-Fire',Pitch=1.200000,Volume=0.700000)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.100000
     AmmoClass=Class'BallisticFix.Ammo_Cells'
     AmmoPerFire=1
     ShakeRotMag=(X=32.000000,Y=8.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=1.500000
     ShakeOffsetMag=(X=-3.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.500000
     ProjectileClass=Class'BWBP_SKC_Fix.A49ProjectileA'
     WarnTargetPct=0.300000
}
