//=============================================================================
// LS440SecondaryFire.
//
// Death super laser. Is actually primary fire.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class LS440SecondaryFire extends BallisticInstantFire;

function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	super.DoDamage(Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount, WaterHitLocation);
	if (Mover(Other) != None || Vehicle(Other) != None)
		return;
	LS440Instagib(BW).TargetedHurtRadius(50, 96, class'DTLS440Body', 0, HitLocation, Pawn(Other));
}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(50, 96, DamageType, 0, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}

defaultproperties
{

     TraceRange=(Min=1500000.000000,Max=1500000.000000)
     MaxWallSize=64.000000
     MaxWalls=3
     Damage=180
     DamageHead=200
     DamageLimb=110
     DamageType=Class'BWBP_SKC_Fix.DTInstagib'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTInstagib'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTInstagib'
     KickForce=25000
     PenetrateForce=500
     bPenetrate=True
	FireAnim="FireBig"
     ClipFinishSound=(Sound=Sound'BWBP_SKC_Sounds.LS14.Gauss-LastShot',Volume=1.000000,Radius=48.000000,bAtten=True)
     MuzzleFlashClass=Class'BWBP_SKC_Fix.A48FlashEmitter'
//     MuzzleFlashClass=Class'BWBP_SKC_Fix.GRSXXLaserFlashEmitter'
//     MuzzleFlashClass=Class'BWBP_SKC_Fix.VSKSilencedFlash'
     FlashScaleFactor=0.400000
     RecoilPerShot=100.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.LS14.Gauss-FireInstagib',Volume=2.000000)
     FireEndAnim=
	AmmoPerFire=25
     TweenTime=0.000000
     FireRate=2.500000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_HVPCCells'
     ShakeRotMag=(X=200.000000,Y=16.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=1.000000
     ShakeOffsetMag=(X=-2.500000)
     ShakeOffsetRate=(X=-500.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=1.050000
     WarnTargetPct=0.050000
     aimerror=800.000000
}
