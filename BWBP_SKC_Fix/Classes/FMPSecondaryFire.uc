//=============================================================================
// M30PrimaryFire.
//
//[11:09:19 PM] Captain Xavious: make sure its noted to be an assault rifle
//[11:09:26 PM] Marc Moylan: lol Calypto
//[11:09:28 PM] Matteo 'Azarael': mp40 effective range
//[11:09:29 PM] Matteo 'Azarael': miles
//=============================================================================
class FMPSecondaryFire extends BallisticInstantFire;


simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(10, 92, DamageType, 1, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}

//Do the spread on the client side
function PlayFiring()
{
    	if (FMPMachinePistol(Weapon).bScopeView)
		FireAnim = 'SightFire';
	else
		FireAnim = 'Fire';
	super.PlayFiring();
}

defaultproperties
{
     TraceRange=(Min=9000.000000,Max=9000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=16.000000
     MaxWalls=0
     Damage=30
     DamageHead=90
     DamageLimb=20
     WaterRangeAtten=0.700000
     RangeAtten=0.700000
     DamageType=Class'BWBP_SKC_Fix.DT_MP40Chest'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_MP40Head'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_MP40Chest'
     KickForce=18000
     PenetrateForce=150
     bPenetrate=False
     HookStopFactor=0.2
     HookPullForce=-10
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bCockAfterEmpty=False
     MuzzleFlashClass=Class'BallisticFix.XK2FlashEmitter'
     FlashScaleFactor=0.900000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassBone="tip"
     BrassOffset=(X=-50.000000,Y=1.000000)
     RecoilPerShot=512.000000
     XInaccuracy=20.000000
     YInaccuracy=20.000000
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_SoundsExp.MP40.MP40-HotFire',Volume=3.200000)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.235000
     AmmoClass=Class'BallisticFix.Ammo_XRS10Bullets'
     ShakeRotMag=(X=64.000000,Y=32.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=1.500000
     ShakeOffsetMag=(X=-3.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.500000
     aimerror=900.000000
}
