//=============================================================================
// M50PrimaryFire.
//
// Very automatic, bullet style instant hit. Shots are long ranged, powerful
// and accurate when used carefully. The dissadvantages are severely screwed up
// accuracy after firing a shot or two and the rapid rate of fire means ammo
// dissapeares quick.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class CYLOFS_PrimaryFire extends BallisticInstantFire;

var   float		StopFireTime;
var() Sound			FailSound;


simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(2, 64, DamageType, 1, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}

simulated function bool AllowFire()
{
	if ((CYLOFS_AssaultWeapon(Weapon).HeatLevel >= 10.0) || !super.AllowFire())
		return false;
	return true;
}

function PlayFiring()
{
	Super.PlayFiring();
	if (CYLOFS_AssaultWeapon(Weapon).CamoIndex == 1) 
		CYLOFS_AssaultWeapon(BW).AddHeat(0.05);
	else
		CYLOFS_AssaultWeapon(BW).AddHeat(0.75);
}


function StopFiring()
{
	bIsFiring=false;
	StopFireTime = level.TimeSeconds;
}

// Get aim then run trace...
function DoFireEffect()
{
	Super.DoFireEffect();
	if (level.Netmode == NM_DedicatedServer)
	{
		if (CYLOFS_AssaultWeapon(Weapon).CamoIndex == 1) 
			CYLOFS_AssaultWeapon(BW).AddHeat(0.05);
		else
			CYLOFS_AssaultWeapon(BW).AddHeat(0.75);
	}
}

defaultproperties
{
     TraceRange=(Min=10000.000000,Max=12000.000000)
     WaterRangeFactor=0.200000
     MaxWallSize=20.000000
     MaxWalls=1
     Damage=22
     DamageHead=42
     DamageLimb=15
     RangeAtten=0.550000
     WaterRangeAtten=0.200000
     DamageType=Class'BWBP_SKC_Fix.DTCYLOMk2Rifle'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTCYLOMk2RifleHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTCYLOMk2Rifle'
     KickForce=20000
     PenetrateForce=180
     bPenetrate=True
     RunningSpeedThresh=1000.000000
     ClipFinishSound=(Sound=Sound'BallisticSounds3.Misc.ClipEnd-1',Volume=0.800000,Radius=48.000000,bAtten=True)
     DryFireSound=(Sound=Sound'BallisticSounds3.Misc.DryRifle',Volume=0.700000)
     bCockAfterEmpty=True
     MuzzleFlashClass=Class'BWBP_SKC_Fix.CYLOMk2HeatEmitter'
     FlashBone="Muzzle"
     FlashScaleFactor=0.400000
     RecoilPerShot=110.000000
     FireChaos=0.020000
     XInaccuracy=128.000000
     YInaccuracy=128.000000
     UnjamMethod=UJM_Fire
     JamChance=0.002000
     JamSound=(Sound=Sound'BallisticSounds3.Misc.DryRifle',Volume=0.900000)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.CYLO.CYLO-Fire',Slot=SLOT_Interact,Pitch=1.250000,bNoOverride=False)
     bPawnRapidFireAnim=True
     PreFireAnim=
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.085500
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_CYLOInc'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
