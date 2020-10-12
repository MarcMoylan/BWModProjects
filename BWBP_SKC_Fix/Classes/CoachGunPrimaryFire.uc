//=============================================================================
// CoachGunPrimaryFire.
//
// Individual barrel fire for Coach Gun. Uses 10-gauge shells and has a longer
// barrel than the MRS138 and SKAS-21. Deals superior damage with good range.
// Lengthy reload after each shot balances the gun.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class CoachGunPrimaryFire extends BallisticInstantFire;

var() Actor						MuzzleFlash2;		// The muzzleflash actor
var() sound		SlugFireSound;

//SHOTGUN VARS ----------------------------------------------------------------
var() int						TraceCount;		// Number of fire traces to use
var() class<Emitter>			TracerClass;	// Type of tracer to use
var() float						TracerChance;	// Chance of tracer effect spawning per trace. 0=never, 1=always
var() class<BCImpactManager>	ImpactManager;	// Impact manager to use for ListenServer and StandAlone impacts
var() bool						bDoWaterSplash;	// splash when hitting water, duh...
//-----------------------------------------------------------------------------



simulated function SwitchCannonMode (bool bSlugMode)
{
	if (bSlugMode) //Slug Mode
	{
		XInaccuracy=48;
		YInaccuracy=48;
		TraceCount=1;
		TraceRange.Min=6000;
		TraceRange.Max=6500;
     		RangeAtten=0.350000;
     		FlashScaleFactor=3.000000;
		Damage=155;
		DamageHead=310;
		DamageLimb=100;
     		RecoilPerShot=4096.000000;
     		FireRate=1.050000;
		BallisticFireSound.Sound=SlugFireSound;
		BallisticFireSound.Volume=7.1;
		CoachGunAttachment(Weapon.ThirdPersonActor).bBoltEffect=true;
		GotoState('Slug');
	}
	else //Shot Mode
	{
		XInaccuracy=default.XInaccuracy;
		YInaccuracy=default.YInaccuracy;
		TraceCount=default.TraceCount;
		TraceRange.Min=default.TraceRange.Min;
		TraceRange.Max=default.TraceRange.Max;
		RangeAtten=default.RangeAtten;
		FlashScaleFactor=default.FlashScaleFactor;
		Damage = Default.Damage;
		DamageHead = Default.DamageHead;
		DamageLimb = Default.DamageLimb;
		RecoilPerShot=Default.RecoilPerShot;
     		FireRate=default.FireRate;
		BallisticFireSound.Sound=default.BallisticFireSound.Sound;
		BallisticFireSound.Volume=default.BallisticFireSound.Volume;
		CoachGunAttachment(Weapon.ThirdPersonActor).bBoltEffect=false;
		GotoState('Shot');
	}
}



////=========================================
//// Super Magnum code
////=========================================
simulated state Slug
{
}


////=========================================
//// Shotgun code
////=========================================
auto simulated state Shot
{

// Get aim then run several individual traces using different spread for each one
function DoFireEffect()
{
    local Vector StartTrace;
    local Rotator R, Aim;
	local int i;

	Aim = GetFireAim(StartTrace);
	for (i=0;i<TraceCount;i++)
	{
		R = Rotator(GetFireSpread() >> Aim);
		DoTrace(StartTrace, R);
	}
	// Tell the attachment the aim. It will calculate the rest for the clients
	SendFireEffect(none, Vector(Aim)*TraceRange.Max, StartTrace, 0);

	Super(BallisticFire).DoFireEffect();
}

// Even if we hit nothing, this is already taken care of in DoFireEffects()...
function NoHitEffect (Vector Dir, optional vector Start, optional vector HitLocation, optional vector WaterHitLoc)
{
	local Vector V;

	V = Instigator.Location + Instigator.EyePosition() + Dir * TraceRange.Min;
	if (TracerClass != None && Level.DetailMode > DM_Low && class'BallisticMod'.default.EffectsDetailMode > 0 && VSize(V - BallisticAttachment(Instigator.Weapon.ThirdPersonActor).GetTipLocation()) > 200 && FRand() < TracerChance)
		Spawn(TracerClass, instigator, , BallisticAttachment(Instigator.Weapon.ThirdPersonActor).GetTipLocation(), Rotator(V - BallisticAttachment(Instigator.Weapon.ThirdPersonActor).GetTipLocation()));
	if (ImpactManager != None && WaterHitLoc != vect(0,0,0) && Weapon.EffectIsRelevant(WaterHitLoc,false) && bDoWaterSplash)
		ImpactManager.static.StartSpawn(WaterHitLoc, Normal((Instigator.Location + Instigator.EyePosition()) - WaterHitLoc), 9, Instigator);
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
		if (TracerClass != None && Level.DetailMode > DM_Low && class'BallisticMod'.default.EffectsDetailMode > 0 && VSize(HitLocation - BallisticAttachment(Weapon.ThirdPersonActor).GetTipLocation()) > 200 && FRand() < TracerChance)
			Spawn(TracerClass, instigator, , BallisticAttachment(Weapon.ThirdPersonActor).GetTipLocation(), Rotator(HitLocation - BallisticAttachment(Weapon.ThirdPersonActor).GetTipLocation()));
	}
	return true;
}


} ////=============================== END STATE


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
	local Actor MuzzleSmoke;
	local vector Start, X, Y, Z;

    if ((Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;

    if (!Coachgun(Weapon).bLowAmmo && MuzzleFlash2 != None)
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
    Weapon.GetViewAxes(X,Y,Z);
//	Start = C.Origin + C.XAxis * -80 + C.YAxis * 3 + C.ZAxis * 0;
	Start = C.Origin + X * -180 + Y * 3;
	MuzzleSmoke = Spawn(class'MRT6Smoke', weapon,, Start, Rotator(X));

	if (!bBrassOnCock)
		EjectBrass();
}
//Check Sounds and damage types.

defaultproperties
{
     SlugFireSound=Sound'BWBP_SKC_Sounds.Redwood.SuperMagnum-Fire'
     TraceCount=10
     TracerClass=Class'BallisticFix.TraceEmitter_MRTsix'
     ImpactManager=Class'BallisticFix.IM_Shell'
     MaxWalls=1
     TraceRange=(Min=2500.000000,Max=4500.000000)
     Damage=30
     DamageHead=45
     DamageLimb=15
//     RangeAtten=0.700000
     RangeAtten=0.400000
     DamageType=Class'BWBP_SKC_Fix.DTCoachGun'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTCoachGun'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTCoachGun'
     KickForce=11000
     PenetrateForce=100
     bPenetrate=True
     MuzzleFlashClass=Class'BallisticFix.MRT6FlashEmitter'
     FlashScaleFactor=1.500000
     BrassBone="EjectorR"
     BrassOffset=(X=-30.000000,Y=-5.000000,Z=5.000000)
     RecoilPerShot=256.000000
     VelocityRecoil=450.000000
//     XInaccuracy=1150.000000
//     YInaccuracy=950.000000
     XInaccuracy=900.000000
     YInaccuracy=750.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.Redwood.Redwood-Fire',Volume=1.200000)
     TweenTime=0.000000
     FireRate=0.150000
     AmmoClass=Class'BallisticFix.Ammo_MRS138Shells'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.100000
     WarnTargetPct=0.100000
}
