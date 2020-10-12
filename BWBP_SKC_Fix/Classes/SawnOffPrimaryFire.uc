//=============================================================================
// SawnOffPrimaryFire.
//
// Double barrel shot for the Sawn Off Coach Gun.
// Full reload is required after each shot.
// This shot is less damaging but slightly more accurate than an MRT6 one.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SawnOffPrimaryFire extends BallisticShotgunFire;

var() Actor						MuzzleFlash2;		// The muzzleflash actor

simulated function bool AllowFire()
{
	local bool bResult;

	AmmoPerFire=1;
	bResult=super.AllowFire();
	AmmoPerFire=2;

	return bResult;
}

event ModeDoFire()
{
//	if (!SawnOffShotgun(Weapon).bLeftLoaded && SawnOffShotgun(Weapon).bRightLoaded)
	if (SawnOffShotgun(Weapon).MagAmmo == 1)
		BW.BFireMode[1].ModeDoFire();
	else
		super.ModeDoFire();

}


function InitEffects()
{
	super.InitEffects();
    if ((MuzzleFlashClass != None) && ((MuzzleFlash2 == None) || MuzzleFlash2.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlash2, MuzzleFlashClass, Weapon.DrawScale*FlashScaleFactor, weapon, 'tip2');
}

//Trigger muzzleflash emitter
function FlashMuzzleFlash()
{
	local Coords C;
	local vector Start;
	local Actor MuzzleSmoke;

    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;

    if (!SawnOffShotgun(Weapon).bRightLoaded && MuzzleFlash2 != None)
    {
		C = Weapon.GetBoneCoords('tip2');
        MuzzleFlash2.Trigger(Weapon, Instigator);
    }
    else if (MuzzleFlash != None)
    {
		C = Weapon.GetBoneCoords('tip');
        MuzzleFlash.Trigger(Weapon, Instigator);
    }
	if (!class'BallisticMod'.default.bMuzzleSmoke)
		return;
	Start = C.Origin + C.XAxis * -5 + C.YAxis * 3 + C.ZAxis * 0;
	MuzzleSmoke = Spawn(class'MRT6Smoke', weapon,, Start, Rotator(C.XAxis));

	if (!bBrassOnCock)
		EjectBrass();
}


function EjectBrass()
{
}



// Spawn the impact effects here for StandAlone and ListenServers cause the attachment won't do it
simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	local int Surf;

	if (ImpactManager != None && WaterHitLoc != vect(0,0,0) && Weapon.EffectIsRelevant(WaterHitLoc,false) && bDoWaterSplash)
		ImpactManager.static.StartSpawn(WaterHitLoc, Normal((Instigator.Location + Instigator.EyePosition()) - WaterHitLoc), 9, Instigator);

	if (!Other.bWorldGeometry && Mover(Other) == None)
		return false;

	if (!bAISilent)
		Instigator.MakeNoise(1.0);
	if (ImpactManager != None && Weapon.EffectIsRelevant(HitLocation,false))
	{
		if (Vehicle(Other) != None)
			Surf = 3;
		else if (HitMat == None)
			Surf = int(Other.SurfaceType);
		else
			Surf = int(HitMat.SurfaceType);
		ImpactManager.static.StartSpawn(HitLocation, HitNormal, Surf, instigator);
//		C = Weapon.GetBoneCoords('tip');
//		if (TracerClass != None && Level.DetailMode > DM_Low && class'BallisticMod'.default.EffectsDetailMode > 0 && VSize(HitLocation - C.Origin) > 200 && FRand() < TracerChance)
//			Spawn(TracerClass, instigator, , SawnOffAttachment(Weapon.ThirdPersonActor).GetTipLocation(), Rotator(HitLocation - SawnOffAttachment(Weapon.ThirdPersonActor).GetTipLocation()));
//			Spawn(TracerClass, instigator, , C.Origin, Rotator(HitLocation - C.Origin));
	}
	return true;
}

/*function FlashMuzzleFlash()
{
	local Coords C;
	local vector Start;
	local Actor MuzzleSmoke;

    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;

	BW.BFireMode[1].MuzzleFlash.Trigger(Weapon, Instigator);
	SawnOffSecondaryFire(BW.BFireMode[0]).MuzzleFlash2.Trigger(Weapon, Instigator);

	if (!class'BallisticMod'.default.bMuzzleSmoke)
		return;
	C = Weapon.GetBoneCoords('tip2');
	Start = C.Origin + C.XAxis * -5 + C.YAxis * 3 + C.ZAxis * 0;
	MuzzleSmoke = Spawn(class'MRT6Smoke', weapon,, Start, Rotator(C.XAxis));
	C = Weapon.GetBoneCoords('tip');
	Start = C.Origin + C.XAxis * -5 + C.YAxis * 3 + C.ZAxis * 0;
	MuzzleSmoke = Spawn(class'MRT6Smoke', weapon,, Start, Rotator(C.XAxis));

	if (!bBrassOnCock)
		EjectBrass();
}
*/

defaultproperties
{
     TraceCount=24
 //    TracerClass=Class'BallisticFix.TraceEmitter_MRTsix'
     ImpactManager=Class'BallisticFix.IM_Shell'
     TraceRange=(Min=1200.000000,Max=1500.000000)
     Damage=25
     DamageHead=35
     DamageLimb=6
     RangeAtten=0.130000
     DamageType=Class'BWBP_SKC_Fix.DTSawnOff'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTSawnOff'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTSawnOff'
     KickForce=11000
     PenetrateForce=100
     bPenetrate=True
     MuzzleFlashClass=Class'BWBP_SKC_Fix.SawnOffFlashEmitter'
     FlashScaleFactor=1.100000
     BrassBone="EjectorR"
     BrassOffset=(X=-30.000000,Y=-5.000000,Z=5.000000)
     RecoilPerShot=1024.000000
     VelocityRecoil=1200.000000
     XInaccuracy=2500.000000
     YInaccuracy=1800.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.SawnOff.SawnOff-DFire',Volume=1.800000)
     FireAnim="Fire"
     TweenTime=0.000000
     FireRate=0.150000
     AmmoClass=Class'BallisticFix.Ammo_12Gauge'
     AmmoPerFire=2
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.100000
     WarnTargetPct=0.100000
}
