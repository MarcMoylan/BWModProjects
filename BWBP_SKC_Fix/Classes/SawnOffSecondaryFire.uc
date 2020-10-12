//=============================================================================
// SawnOffSecondaryFire.
//
// Single barrel 12G fire. Uses muzzle flash for effects instead of traditional
// attachment based code due to being dual wieldable.
// Easter.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SawnOffSecondaryFire extends BallisticShotgunFire;

var() Actor						MuzzleFlash2;		// The muzzleflash actor

event ModeDoFire()
{
	if (AllowFire())
	{
		if (!SawnOffShotgun(Weapon).bLeftLoaded)
		{
			SawnOffShotgun(Weapon).bRightLoaded=false;
		}
		else
		{
			SawnOffShotgun(Weapon).bLeftLoaded=false;
		}
	}
	super.ModeDoFire();
}
simulated function SendFireEffect(Actor Other, vector HitLocation, vector HitNormal, int Surf, optional vector WaterHitLoc)
{
	SawnOffAttachment(Weapon.ThirdPersonActor).SawnOffUpdateHit(Other, HitLocation, HitNormal, Surf, !SawnOffShotgun(Weapon).bRightLoaded);
}

function EjectBrass()
{
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
//		if (TracerClass != None && Level.DetailMode > DM_Low && class'BallisticMod'.default.EffectsDetailMode > 0 && VSize(HitLocation - HandgunAttachment(Weapon.ThirdPersonActor).GetTipLocation()) > 200 && FRand() < TracerChance)
//			Spawn(TracerClass, instigator, , HandgunAttachment(Weapon.ThirdPersonActor).GetTipLocation(), Rotator(HitLocation - HandgunAttachment(Weapon.ThirdPersonActor).GetTipLocation()));
//			Spawn(TracerClass, instigator, , tip, Rotator(HitLocation - tip);
	}
	return true;
}


defaultproperties
{
     TraceCount=12
//    TracerClass=Class'BallisticFix.TraceEmitter_Shotgun'
//     TracerClass=Class'BallisticFix.TraceEmitter_MRTsix'
     ImpactManager=Class'BallisticFix.IM_Shell'
     TraceRange=(Min=1200.000000,Max=1600.000000)
     Damage=27
     DamageHead=40
     DamageLimb=7
     RangeAtten=0.135000
     DamageType=Class'BWBP_SKC_Fix.DTSawnOff'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTSawnOff'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTSawnOff'
     KickForce=11000
     PenetrateForce=100
     bPenetrate=True
     MuzzleFlashClass=Class'BWBP_SKC_Fix.SawnOffFlashEmitter'
     FlashScaleFactor=1.000000
     BrassBone="EjectorR"
     BrassOffset=(X=-30.000000,Y=-5.000000,Z=5.000000)
     RecoilPerShot=512.000000
     VelocityRecoil=600.000000
     XInaccuracy=1800.000000
     YInaccuracy=1800.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.SawnOff.SawnOff-Sfire',Volume=1.500000)
     FireAnim="SightFire"
     TweenTime=0.000000
     FireRate=0.150000
     AmmoClass=Class'BallisticFix.Ammo_12Gauge'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
