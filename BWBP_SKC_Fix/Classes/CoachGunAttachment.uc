//=============================================================================
// CoachGunAttachment.
//
// 3rd person weapon attachment for my sweaty applejuice
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class CoachGunAttachment extends BallisticAttachment;


var bool		bBoltEffect; //silencer bolt will not spawn tracers
var bool		bOldBoltEffect;

var() class<BallisticShotgunFire>	FireClass;
var() class<BCImpactManager>ImpactManagerAlt;		//Impact Manager to use for iATLATmpact effects
var() class<BCTraceEmitter>	TracerClassAlt;		//Type of tracer to use for alt fire effects

replication
{
	// Things the server should send to the client.
	reliable if(Role==ROLE_Authority)
		bBoltEffect;
}

simulated event PostNetReceive()
{
	if (bBoltEffect != bOldBoltEffect)
	{
		bOldBoltEffect = bBoltEffect;
	}
	Super.PostNetReceive();
}



simulated function InstantFireEffects(byte Mode)
{
	local Vector HitLocation, Dir, Start;
	local Material HitMat;

	// ================== MELEE EFFECTS ===============
	if (FiringMode != 0)
		MeleeFireEffects();
	//==================== SHOTGUN EFFECTS ===============
	else if (!bBoltEffect)
		ShotgunFireEffects(FiringMode);
	else 
	// ================== SUPERMAG EFFECTS ===============
	{

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
			ImpactManagerAlt.static.StartSpawn(WaterHitLocation, Normal((Instigator.Location + Instigator.EyePosition()) - WaterHitLocation), 9, Instigator);
		if (mHitActor == None || (!mHitActor.bWorldGeometry && Mover(mHitActor) == None && Vehicle(mHitActor) == None))
			return;
		if (ImpactManagerAlt != None)
			ImpactManagerAlt.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);

	}
}
// Do trace to find impact info and then spawn the effect
simulated function ShotgunFireEffects(byte Mode)
{
	local Vector HitLocation, Start, End;
	local Rotator R;
	local Material HitMat;
	local int i;
	local float XS, YS, RMin, RMax, Range, fX;

	if (Level.NetMode == NM_Client && FireClass != None)
	{
		XS = FireClass.default.XInaccuracy; YS = Fireclass.default.YInaccuracy;
		RMin = FireClass.default.TraceRange.Min; RMax = FireClass.default.TraceRange.Max;
		Start = Instigator.Location + Instigator.EyePosition();
		for (i=0;i<FireClass.default.TraceCount;i++)
		{
			mHitActor = None;
			Range = Lerp(FRand(), RMin, RMax);
			R = Rotator(mHitLocation);
			switch (FireClass.default.FireSpreadMode)
			{
				case FSM_Scatter:
					fX = frand();
					R.Yaw +=   XS * (frand()*2-1) * sin(fX*1.5707963267948966);
					R.Pitch += YS * (frand()*2-1) * cos(fX*1.5707963267948966);
					break;
				case FSM_Circle:
					fX = frand();
					R.Yaw +=   XS * sin ((frand()*2-1) * 1.5707963267948966) * sin(fX*1.5707963267948966);
					R.Pitch += YS * sin ((frand()*2-1) * 1.5707963267948966) * cos(fX*1.5707963267948966);
					break;
				default:
					R.Yaw += ((FRand()*XS*2)-XS);
					R.Pitch += ((FRand()*YS*2)-YS);
					break;
			}
			End = Start + Vector(R) * Range;
			mHitActor = Trace (HitLocation, mHitNormal, End, Start, false,, HitMat);
			if (mHitActor == None)
			{
				DoWaterTrace(Start, End);
				SpawnTracer(Mode, End);
			}
			else
			{
				DoWaterTrace(Start, HitLocation);
				SpawnTracer(Mode, HitLocation);
			}

			if (mHitActor == None || (!mHitActor.bWorldGeometry && Mover(mHitActor) == None))
				continue;

			if (HitMat == None)
				mHitSurf = int(mHitActor.SurfaceType);
			else
				mHitSurf = int(HitMat.SurfaceType);

			if (ImpactManager != None)
				ImpactManager.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, self);
		}
	}
}
// Do trace to find impact info and then spawn the effect
simulated function MeleeFireEffects()
{
	local Vector HitLocation, Dir, Start;
	local Material HitMat;

	if (mHitLocation == vect(0,0,0))
		return;

	if (Level.NetMode == NM_Client)
	{
		mHitActor = None;
		Start = Instigator.Location + Instigator.EyePosition();
		Dir = Normal(mHitLocation - Start);
		mHitActor = Trace (HitLocation, mHitNormal, mHitLocation + Dir*10, mHitLocation - Dir*10, false,, HitMat);
		if (mHitActor == None || (!mHitActor.bWorldGeometry))
			return;

		if (HitMat == None)
			mHitSurf = int(mHitActor.SurfaceType);
		else
			mHitSurf = int(HitMat.SurfaceType);
	}
	else
		HitLocation = mHitLocation;
	if (mHitActor == None || (!mHitActor.bWorldGeometry && Mover(mHitActor) == None && Vehicle(mHitActor) == None))
		return;
//	if (ImpactManager != None)
		class'IM_GunHit'.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
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
	if (TracerClass != None && TracerMode != MU_None && (TracerMode == MU_Both && Mode == 0) &&
		bThisShot && (TracerChance >= 1 || FRand() < TracerChance) && !bBoltEffect)
	{
		if (Dist > 200)
			Tracer = Spawn(TracerClass, self, , TipLoc, Rotator(V - TipLoc));
		if (Tracer != None)
			Tracer.Initialize(Dist);
	}
	// Spawn an alt tracer
	if (TracerClassAlt != None && TracerMode != MU_None && (TracerMode == MU_Both && Mode == 0) &&
		bThisShot && (TracerChance >= 1 || FRand() < TracerChance) && bBoltEffect)
	{
		if (Dist > 200)
			Tracer = Spawn(TracerClassAlt, self, , TipLoc, Rotator(V - TipLoc));
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


simulated function EjectBrass(byte Mode);


defaultproperties
{
     FireClass=Class'BWBP_SKC_Fix.CoachGunPrimaryFire'
     MuzzleFlashClass=Class'BallisticFix.MRT6FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Shell'
     ImpactManagerAlt=Class'BWBP_SKC_Fix.IM_ExpBullet'
     FlashScale=1.500000
     BrassClass=Class'BallisticFix.Brass_MRS138Shotgun'
     TrackAnimMode=MU_Secondary
     TracerClass=Class'BallisticFix.TraceEmitter_Shotgun'
     TracerClassAlt=Class'BWBP_SKC_Fix.TraceEmitter_X83AM'
     TracerChance=1.000000
     RelativeRotation=(Pitch=32768)
     Mesh=SkeletalMesh'BWBP_SKC_Anim.TP_DoubleShotgun'
     RelativeLocation=(X=5.000000,Y=-1.000000,Z=10.000000)
     DrawScale=0.450000
}
