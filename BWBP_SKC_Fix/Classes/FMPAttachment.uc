//=============================================================================
// FMP Attachment
//
// FMP-2012's 3rd
//=============================================================================
class FMPAttachment extends BallisticAttachment;

var() class<BCImpactManager>ImpactManagerRed;		//Impact Manager to use for iATLATmpact effects
var() class<BCImpactManager>ImpactManagerGreen;		//Impact Manager to use for iATLATmpact effects
var() class<BCTraceEmitter>	TracerClassRed;		//Type of tracer to use for alt fire effects
var() class<BCTraceEmitter>	TracerClassGreen;		//Type of tracer to use for alt fire effects
var() class<actor>			MuzzleFlashClassRed;	//Effect to spawn fot mode 0 muzzle flash
var   actor					MuzzleFlashRed;		//The flash actor itself
var() class<actor>			MuzzleFlashClassGreen;//Effect to spawn fot mode 1 muzzle flash
var   actor					MuzzleFlashGreen;		//The flash actor itself
var bool		bRedAmp;
var bool		bGreenAmp;
var bool		bAmped;
var bool		bOldAmped;

replication
{
	// Things the server should send to the client.
	reliable if(Role==ROLE_Authority)
		bRedAmp, bGreenAmp, bAmped;
}

simulated event PostNetReceive()
{
	if (bAmped != bOldAmped)
	{
		bOldAmped = bAmped;
		if (bAmped)
			SetBoneScale (0, 1.0, 'Amplifier');
		else
			SetBoneScale (0, 0.0, 'Amplifier');
	}
	Super.PostNetReceive();
}

function IAOverride(bool bAmped)
{
	if (bAmped)
		SetBoneScale (0, 1.0, 'Amplifier');
	else
		SetBoneScale (0, 0.0, 'Amplifier');
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
		
	if (ImpactManager != None && (!bRedAmp && !bGreenAmp))
		ImpactManager.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
	if (ImpactManagerRed != None && (bRedAmp ))
		ImpactManagerRed.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
	if (ImpactManagerGreen != None && (bGreenAmp))
		ImpactManagerGreen.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
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
	if (TracerClassRed != None && bThisShot && bRedAmp )
	{
		if (Dist > 200)
			Tracer = Spawn(TracerClassRed, self, , TipLoc, Rotator(V - TipLoc));
		if (Tracer != None)
			Tracer.Initialize(Dist);
	}
	// Spawn a tracer
	if (TracerClassGreen != None && bThisShot && bGreenAmp)
	{
		if (Dist > 200)
			Tracer = Spawn(TracerClassGreen, self, , TipLoc, Rotator(V - TipLoc));
		if (Tracer != None)
			Tracer.Initialize(Dist);
	}
	else if (TracerClass != None && bThisShot && ((!bRedAmp && !bGreenAmp) || Mode == 0))
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

// This assumes flash actors are triggered to make them work
// Override this in subclassed for better control
simulated function FlashMuzzleFlash(byte Mode)
{
	local rotator R;

	if (FlashMode == MU_None || (FlashMode == MU_Secondary && Mode == 0) || (FlashMode == MU_Primary && Mode != 0))
		return;
	if (Instigator != None && Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
		return;

	if (bRandomFlashRoll)
		R.Roll = Rand(65536);

	if (bRedAmp && MuzzleFlashClassRed != None)
	{
		if (MuzzleFlashRed == None)
			class'BUtil'.static.InitMuzzleFlash (MuzzleFlashRed, MuzzleFlashClassRed, DrawScale*FlashScale, self, AltFlashBone);
		MuzzleFlashRed.Trigger(self, Instigator);
		if (bRandomFlashRoll)	SetBoneRotation(AltFlashBone, R, 0, 1.f);
	}
	else if (bGreenAmp && MuzzleFlashClassGreen != None)
	{
		if (MuzzleFlashGreen == None)
			class'BUtil'.static.InitMuzzleFlash (MuzzleFlashGreen, MuzzleFlashClassGreen, DrawScale*FlashScale, self, AltFlashBone);
		MuzzleFlashGreen.Trigger(self, Instigator);
		if (bRandomFlashRoll)	SetBoneRotation(AltFlashBone, R, 0, 1.f);
	}
	else if (Mode == 0 && MuzzleFlashClass != None)
	{
		if (MuzzleFlash == None)
			class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, DrawScale*FlashScale, self, FlashBone);
		MuzzleFlash.Trigger(self, Instigator);
		if (bRandomFlashRoll)	SetBoneRotation(FlashBone, R, 0, 1.f);
	}
}

defaultproperties
{
	 TracerMix=0
	 TracerChance=1
     AltFlashBone="tip2"
     MuzzleFlashClassRed=Class'BWBP_SKC_Fix.AH104FlashEmitter'
     MuzzleFlashClassGreen=Class'BallisticFix.A500FlashEmitter'
     bAltRapidFire=True
     bRapidFire=True
     BrassClass=Class'BallisticFix.Brass_Rifle'
     DrawScale=0.160000
     FlashMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     ImpactManager=Class'BallisticFix.IM_Bullet'
     ImpactManagerRed=Class'BWBP_SKC_Fix.IM_BulletHE'
     ImpactManagerGreen=Class'BWBP_SKC_Fix.IM_BulletAcid'
     InstantMode=MU_Both
     LightMode=MU_Both
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_MP40'
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     RelativeLocation=(Z=3)
     RelativeRotation=(Yaw=32768,Roll=-16384)
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_MARS'
     TracerClassRed=Class'BWBP_SKC_Fix.TraceEmitter_HMG'
     TracerClassGreen=Class'BWBP_SKC_Fix.TraceEmitter_Tranq'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
}
