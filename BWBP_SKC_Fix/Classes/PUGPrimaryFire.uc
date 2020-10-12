//  =============================================================================
//   PUGPrimaryFire.
//  
//   Rapid fire, but weak rubber shot spread
//   Shoots 4 pellets for 25. Pellets slow down targets.
//
//   Copyright 3053 Sergeant Kelly. ALL RIGHTS RESERVED BRAH.
//  =============================================================================
class PUGPrimaryFire extends BallisticShotgunFire;
var() class<actor>			AltBrassClass1;			//Alternate Fire's brass
var() class<actor>			AltBrassClass2;			//Alternate Fire's brass (whole FRAG-12)

simulated event ModeDoFire()
{
	if (PUGAssaultCannon(Weapon).bReady)
	{
		PUGAssaultCannon(Weapon).UnPrepAltFire();
		return;
	}
	if (PUGAssaultCannon(Weapon).ReloadState == RS_Shovel)	
	{
		PUGAssaultCannon(Weapon).bWantsToShoot=true;
		return;
	}
	if (!AllowFire())
		return;
		
	super.ModeDoFire();
    

}


simulated function DestroyEffects()
{
    if (MuzzleFlash != None)
		MuzzleFlash.Destroy();
	Super.DestroyEffects();
}



//Spawn shell casing for first person
function EjectFRAGBrass()
{
	local vector Start, X, Y, Z;
	local Coords C;

	if (Level.NetMode == NM_DedicatedServer)
		return;
	if (!class'BallisticMod'.default.bEjectBrass || Level.DetailMode < DM_High)
		return;
	if (BrassClass == None)
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;
	if (AIController(Instigator.Controller) != None)
		return;
	C = Weapon.GetBoneCoords(BrassBone);
//	Start = C.Origin + C.XAxis * BrassOffset.X + C.YAxis * BrassOffset.Y + C.ZAxis * BrassOffset.Z;
    Weapon.GetViewAxes(X,Y,Z);
	Start = C.Origin + X * BrassOffset.X + Y * BrassOffset.Y + Z * BrassOffset.Z;
	Spawn(AltBrassClass2, weapon,, Start, Rotator(C.XAxis));
}

defaultproperties
{
     TraceRange=(Min=2000.000000,Max=5000.000000)
     WaterRangeFactor=0.300000
     MaxWallSize=1.000000
     MaxWalls=1
     TraceCount=4
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_Flechette'
     Damage=25
     DamageHead=35
     DamageLimb=20
     RangeAtten=0.400000
     WaterRangeAtten=0.600000
     DamageType=Class'BWBP_SKC_Fix.DTBulldog'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTBulldogHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTBulldog'
     KickForce=35000
     PenetrateForce=250
     bPenetrate=False
     HookStopFactor=0.2
     HookPullForce=-10
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bDryUncock=True
     MuzzleFlashClass=Class'BallisticFix.M925FlashEmitter'
     FlashScaleFactor=1.100000
     BrassClass=Class'BWBP_SKC_Fix.Brass_BOLT'
     AltBrassClass1=Class'BWBP_SKC_Fix.Brass_FRAGSpent'
     AltBrassClass2=Class'BWBP_SKC_Fix.Brass_FRAG'
     BrassBone="ejector"
     BrassOffset=(X=-30.000000,Y=1.000000)
     RecoilPerShot=1024.000000
     VelocityRecoil=200.000000
//     FireChaos=10.000000
     FireRate=0.200000
     FireAnimRate=1.5
     XInaccuracy=100.000000
     YInaccuracy=100.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.PUG.PUG-Fire',Volume=7.500000)
     FireEndAnim=
     TweenTime=0.000000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_10GaugeDart'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
