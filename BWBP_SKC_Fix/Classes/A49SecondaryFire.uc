//=============================================================================
// A49SecondaryFire.
//
// Weak close range pulse attack.
// Main use in overheating gun for primary fire and for pulse jumping.
// Can damage gun to state beyond repair with overuse.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class A49SecondaryFire extends BallisticShotgunFire;

simulated function bool AllowFire()
{
	if ((A49SkrithBlaster(BW).HeatLevel >= 11.5) || A49SkrithBlaster(BW).bIsVenting || !super.AllowFire())
		return false;
	return true;
}


simulated function bool CheckWeaponMode()
{
	if (Weapon.IsInState('DualAction') || Weapon.IsInState('PendingDualAction'))
		return false;
	return true;
}

function PlayFiring()
{
	Super.PlayFiring();
	A49SkrithBlaster(BW).AddHeat(5.50);
}


// Get aim then run trace...
function DoFireEffect()
{
 	local Vector Start;
 	local Rotator Aim;
	A49SkrithBlaster(BW).AddHeat(5.50);
 
 	Start = Instigator.Location + Instigator.EyePosition();
 
 	Aim = GetFireAim(Start);
 	Aim = Rotator(GetFireSpread() >> Aim);
 
 	A49SkrithBlaster(BW).ConicalBlast(25, 512, Vector(Aim));
	Super.DoFireEffect();
}


defaultproperties
{
     FlashBone="MuzzleTip"
     TraceCount=20
     TracerChance=0.000000
     TracerClass=none
     ImpactManager=Class'BWBP_SKC_Fix.IM_GRSXXLaser'
     TraceRange=(Min=600.000000,Max=600.000000)
     Damage=5
     DamageHead=10
     DamageLimb=3
     RangeAtten=0.200000
     DamageType=Class'BWBP_SKC_Fix.DTA49Shockwave'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTA49Shockwave'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTA49Shockwave'
//     KickForce=16000
     KickForce=12000
     PenetrateForce=100
     bPenetrate=True
//     MuzzleFlashClass=Class'A73FlashEmitter'
     MuzzleFlashClass=Class'A49FlashEmitter'
     AmmoPerFire=10
     FlashScaleFactor=1.200000
     BrassOffset=(X=15.000000,Y=-13.000000,Z=7.000000)
     RecoilPerShot=2048.000000
     VelocityRecoil=2000.000000
     FireChaos=0.500000
     XInaccuracy=2000.000000
     YInaccuracy=2000.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.A49.A49-ShockWave',Volume=2.000000)
     FireAnim="AltFire"
     TweenTime=0.000000
     FireRate=1.700000
     AmmoClass=Class'BallisticFix.Ammo_Cells'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
