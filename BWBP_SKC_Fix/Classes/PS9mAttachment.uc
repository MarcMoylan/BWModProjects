//=============================================================================
//=============================================================================
// PS9mttachment.
//
// 3rd person weapon attachment for PS9m dart pistol
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class PS9mAttachment extends BallisticCamoHandgunAttachment;

var() class<BCImpactManager>ImpactManagerAlt;		//Impact Manager to use for special impacts
var() class<BCTraceEmitter>	TracerClassAlt;		//Type of tracer to use for instant fire effects

var bool		bGrenadier;
var bool		bOldGrenadier;

replication
{
	reliable if ( Role==ROLE_Authority )
		bGrenadier;
}

simulated event PostNetReceive()
{
	if (bGrenadier != bOldGrenadier)
	{
		bOldGrenadier = bGrenadier;
		if (bGrenadier)
		{
			SetBoneScale (0, 1.0, 'Dart');
			SetBoneScale (1, 1.0, 'FartAssist');
		}
		else
		{
			SetBoneScale (0, 0.0, 'Dart');
			SetBoneScale (1, 0.0, 'FartAssist');
		}
	}
	Super.PostNetReceive();
}

function IAOverride(bool bDart)
{
	if (bDart)
	{
		SetBoneScale (0, 1.0, 'Dart');
		SetBoneScale (1, 1.0, 'FartAssist');
	}
	else
	{
		SetBoneScale (0, 0.0, 'Dart');
		SetBoneScale (1, 0.0, 'FartAssist');
	}
}


//Do your camo changes here
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	
	if (CamoIndex != default.CamoIndex) 
		Skins[0] = CamoWeapon.default.CamoMaterials[CamoIndex];
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetBoneScale (0, 0.0, 'Dart');
	SetBoneScale (1, 0.0, 'FartAssist');
}


// Does all the effects for an instant-hit kind of fire.
// On the client, this uses mHitLocation to find all the other info needed.
simulated function InstantFireEffects(byte Mode)
{
	local Vector HitLocation, Dir, Start;
	local Material HitMat;

	if (InstantMode == MU_None || (InstantMode == MU_Secondary && Mode == 0) || (InstantMode == MU_Primary && Mode != 0))
		return;
	if (mHitLocation == vect(0,0,0))
		return;
	if (Instigator == none)
		return;
	SpawnTracer(Mode, mHitLocation);
	FlyByEffects(Mode, mHitLocation);
	// Client, trace for hitnormal, hitmaterial and hitactor
	if (Level.NetMode == NM_Client)
	{
		mHitActor = None;
		Start = Instigator.Location + Instigator.EyePosition();

		if (WallPenetrates != 0)				{
			WallPenetrates = 0;
			DoWallPenetrate(Start, mHitLocation);	}

		Dir = Normal(mHitLocation - Start);
		mHitActor = Trace (HitLocation, mHitNormal, mHitLocation + Dir*10, mHitLocation - Dir*10, false,, HitMat);
		// Check for water and spawn splash
		if (ImpactManager!= None && bDoWaterSplash)
			DoWaterTrace(Start, mHitLocation);

		if (mHitActor == None)
			return;
		// Set the hit surface type
		if (Vehicle(mHitActor) != None)
			mHitSurf = 3;
		else if (HitMat == None)
			mHitSurf = int(mHitActor.SurfaceType);
		else
			mHitSurf = int(HitMat.SurfaceType);
	}
	// Server has all the info already...
 	else
		HitLocation = mHitLocation;

	if (level.NetMode != NM_Client && ImpactManager!= None && WaterHitLocation != vect(0,0,0) && bDoWaterSplash && Level.DetailMode >= DM_High && class'BallisticMod'.default.EffectsDetailMode > 0)
		ImpactManager.static.StartSpawn(WaterHitLocation, Normal((Instigator.Location + Instigator.EyePosition()) - WaterHitLocation), 9, Instigator);
	if (mHitActor == None || (!mHitActor.bWorldGeometry && Mover(mHitActor) == None && Vehicle(mHitActor) == None))
		return;
	if (ImpactManagerAlt != None && CamoIndex == 3)
		ImpactManagerAlt.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
	if (ImpactManager != None && CamoIndex != 3)
		ImpactManager.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
}

// Return the location of the muzzle.
// Specifies muzzle because moved tip didn't work (offset the tracer in much the same way as the muzzle)
simulated function Vector GetTipLocation()
{
    local Coords C;
	
	if (Instigator != None && Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
	{
		if (HandGun != None)
		{
			C = HandGun.GetBoneCoords('Muzzle');
		}
		else
			C = Instigator.Weapon.GetBoneCoords('Muzzle');
	}
	else
		C = GetBoneCoords('tip');
		
	if (Instigator != None && VSize(C.Origin - Instigator.Location) > 200)
		return Instigator.Location;
    return C.Origin;
}

// Spawn a tracer and water tracer
simulated function SpawnTracer(byte Mode, Vector V)
{
	local BCTraceEmitter Tracer;
	local Vector TipLoc, WLoc, WNorm;
	local float Dist;
	local bool bThisShot;

	if (Level.DetailMode < DM_High || class'BallisticMod'.default.EffectsDetailMode == 0)
		return;

	TipLoc = GetTipLocation();
	Dist = VSize(V - TipLoc);

	// Count shots to determine if it's time to spawn a tracer
	if (TracerMix == 0)
		bThisShot=true;
	else
	{
		TracerCounter++;
		if (TracerMix < 0)
		{
			if (TracerCounter >= -TracerMix)	{
				TracerCounter = 0;
				bThisShot=false;			}
			else
				bThisShot=true;
		}
		else if (TracerCounter >= TracerMix)	{
			TracerCounter = 0;
			bThisShot=true;					}
	}
	// Spawn a tracer
	if (TracerClassAlt != None && CamoIndex == 3 && TracerMode != MU_None && (TracerMode == MU_Both || (TracerMode == MU_Secondary && Mode != 0) || (TracerMode == MU_Primary && Mode == 0)) &&
		bThisShot && (TracerChance >= 1 || FRand() < TracerChance))
	{
		if (Dist > 200)
			Tracer = Spawn(TracerClassAlt, self, , TipLoc, Rotator(V - TipLoc));
		if (Tracer != None)
			Tracer.Initialize(Dist);
	}
	if (TracerClass != None && CamoIndex != 3 && TracerMode != MU_None && (TracerMode == MU_Both || (TracerMode == MU_Secondary && Mode != 0) || (TracerMode == MU_Primary && Mode == 0)) &&
		bThisShot && (TracerChance >= 1 || FRand() < TracerChance))
	{
		if (Dist > 200)
			Tracer = Spawn(TracerClass, self, , TipLoc, Rotator(V - TipLoc));
		if (Tracer != None)
			Tracer.Initialize(Dist);
	}
	// Spawn under water bullet effect
	if ( Instigator != None && Instigator.PhysicsVolume.bWaterVolume && level.DetailMode == DM_SuperHigh && WaterTracerClass != None &&
		 WaterTracerMode != MU_None && (WaterTracerMode == MU_Both || (WaterTracerMode == MU_Secondary && Mode != 0) || (WaterTracerMode == MU_Primary && Mode == 0)))
	{
		if (!Instigator.PhysicsVolume.TraceThisActor(WLoc, WNorm, TipLoc, V))
			Tracer = Spawn(WaterTracerClass, self, , TipLoc, Rotator(WLoc - TipLoc));
		if (Tracer != None)
			Tracer.Initialize(VSize(WLoc - TipLoc));
	}
}

defaultproperties
{
     bNetNotify=true
     bRapidFire=True
     BrassClass=Class'BWBP_SKC_Fix.Brass_Tranq'
     CamoWeapon=Class'BWBP_SKC_Fix.PS9mPistol'
     DrawScale=0.250000
     FlashScale=0.300000
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     ImpactManager=Class'BWBP_SKC_Fix.IM_Tranq'
     ImpactManagerAlt=Class'BWBP_SKC_Fix.IM_IncendiaryBullet'
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_Stealth'
     MuzzleFlashClass=Class'BWBP_SKC_Fix.VSKSilencedFlash'
     //PrePivot=(Z=-1.000000) - use relativelocation instead
     Skins(0)=Texture'BWBP_SKC_TexExp.Stealth.Stealth-Main'
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_Tranq'
     TracerClassAlt=Class'BWBP_SKC_Fix.TraceEmitter_Incendiary'
	 TracerChance=1
	 TracerMix=0
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
}
