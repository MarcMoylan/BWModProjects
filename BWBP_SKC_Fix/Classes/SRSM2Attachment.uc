//=============================================================================
// SRSM2Attachment.
//
// Third person actor for the SRS Mod-2 rifle
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SRSM2Attachment extends BallisticCamoAttachment;

var() class<BCImpactManager>ImpactManagerAmp1;		
var() class<BCImpactManager>ImpactManagerAmp2;		
var() class<BCTraceEmitter>	TracerClassAmp1;		
var() class<BCTraceEmitter>	TracerClassAmp2;		
var() class<actor>			MuzzleFlashClassAmp1;	
var   actor					MuzzleFlashAmp1;		
var() class<actor>			MuzzleFlashClassAmp2;
var   actor					MuzzleFlashAmp2;		
var bool		bAmp1;
var bool		bAmp2;
var bool		bAmped;
var bool		bOldAmped;

replication
{
	reliable if ( Role==ROLE_Authority )
		bAmp1, bAmp2, bAmped;
}



simulated function Vector GetTipLocation()
{
    local Coords C;
    local Vector X, Y, Z;

	if (Instigator.IsFirstPerson())
	{
		if (SRSM2BattleRifle(Instigator.Weapon).bScopeView)
		{
			Instigator.Weapon.GetViewAxes(X,Y,Z);
			return Instigator.Location + X*20 + Z*5;
		}
		else
			C = Instigator.Weapon.GetBoneCoords('tip');
	}
	else
		C = GetBoneCoords('tip');
    return C.Origin;
}

simulated event ThirdPersonEffects()
{
    if ( Level.NetMode != NM_DedicatedServer && Instigator != None)
	{
		if (FiringMode == 1)
			SetBoneScale (0, 1.0, 'Silencer');
		else
			SetBoneScale (0, 0.0, 'Silencer');
    }
	super.ThirdPersonEffects();
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetBoneScale (0, 0.0, 'Silencer');
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
		
	if (ImpactManager != None && (!bAmp1 && !bAmp2))
		ImpactManager.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
	if (ImpactManagerAmp1 != None && bAmp1)
		ImpactManagerAmp1.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
	if (ImpactManagerAmp2 != None && bAmp2)
		ImpactManagerAmp2.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
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
	if (TracerClassAmp1 != None && bThisShot && bAmp1 )
	{
		if (Dist > 200)
			Tracer = Spawn(TracerClassAmp1, self, , TipLoc, Rotator(V - TipLoc));
		if (Tracer != None)
			Tracer.Initialize(Dist);
	}
	// Spawn a tracer
	if (TracerClassAmp1 != None && bThisShot && bAmp2)
	{
		if (Dist > 200)
			Tracer = Spawn(TracerClassAmp2, self, , TipLoc, Rotator(V - TipLoc));
		if (Tracer != None)
			Tracer.Initialize(Dist);
	}
	else if (TracerClass != None && bThisShot && ((!bAmp1 && !bAmp2) || Mode == 0))
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

simulated function FlashMuzzleFlash(byte Mode)
{
	local rotator R;
	if (bRandomFlashRoll)
		R.Roll = Rand(65536);
		
	if (FlashMode == MU_None || (FlashMode == MU_Secondary && Mode == 0) || (FlashMode == MU_Primary && Mode != 0))
		return;
	if (Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
		return;
	
	if (bAmp1 && MuzzleFlashClassAmp1 != None)
	{
		if (MuzzleFlashAmp1 == None)
			class'BUtil'.static.InitMuzzleFlash (MuzzleFlashAmp1, MuzzleFlashClassAmp1, DrawScale*FlashScale, self, AltFlashBone);
		MuzzleFlashAmp1.Trigger(self, Instigator);
		if (bRandomFlashRoll)	SetBoneRotation(AltFlashBone, R, 0, 1.f);
	}
	else if (bAmp2 && MuzzleFlashClassAmp2 != None)
	{
		if (MuzzleFlashAmp2 == None)
			class'BUtil'.static.InitMuzzleFlash (MuzzleFlashAmp2, MuzzleFlashClassAmp2, DrawScale*FlashScale, self, AltFlashBone);
		MuzzleFlashAmp2.Trigger(self, Instigator);
		if (bRandomFlashRoll)	SetBoneRotation(AltFlashBone, R, 0, 1.f);
	}
	else if (Mode != 0 && AltMuzzleFlashClass != None)
	{
		if (AltMuzzleFlash == None)
			class'BUtil'.static.InitMuzzleFlash (AltMuzzleFlash, AltMuzzleFlashClass, DrawScale*0.6, self, AltFlashBone);
		AltMuzzleFlash.Trigger(self, Instigator);
	}
	else if (Mode == 0 && MuzzleFlashClass != None)
	{
		if (MuzzleFlash == None)
			class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, DrawScale*FlashScale, self, FlashBone);
		MuzzleFlash.Trigger(self, Instigator);
	}
}


//Do your camo changes here
simulated function PostNetBeginPlay()
{
	if (bAmped != bOldAmped)
	{
		bOldAmped = bAmped;
		if (bAmped)
			SetBoneScale (0, 1.0, 'Amplifier');
		else
			SetBoneScale (0, 0.0, 'Amplifier');
	}

	/*if (CamoIndex != default.CamoIndex) 
	{
		Skins[0] = CamoWeapon.default.CamoMaterials[CamoIndex];
		if (CamoIndex == 4 || CamoIndex == 5 ||CamoIndex == 6)
		{
			Skins[2] = MatAltEO;
			Skins[3] = MatAltEO;
		}
		else if (CamoIndex == 3)
		{
			Skins[2] = MatAltEO2;
			Skins[3] = MatAltEO2;
		}

	}*/
}

function IAOverride(bool bAmped)
{
	if (bAmped)
		SetBoneScale (0, 1.0, 'Amplifier');
	else
		SetBoneScale (0, 0.0, 'Amplifier');
}

defaultproperties
{

     MuzzleFlashClassAmp1=Class'BWBP_SKC_Fix.AH104FlashEmitter'
     MuzzleFlashClassAmp2=Class'BallisticFix.A500FlashEmitter'
     ImpactManagerAmp1=Class'BWBP_SKC_Fix.IM_BulletHE'
     ImpactManagerAmp2=Class'BWBP_SKC_Fix.IM_BulletAcid'

     CamoWeapon=Class'BWBP_SKC_Fix.SRSM2BattleRifle'
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.XK2SilencedFlash'
     AltFlashBone="tip2"
     ImpactManager=Class'BallisticFix.IM_Bullet'
     FlashScale=0.900000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     TracerClass=Class'BallisticFix.TraceEmitter_Default'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     bRapidFire=True
     bAltRapidFire=True
     Mesh=SkeletalMesh'BWBP_SKC_Anim.SRS-3rd'
     DrawScale=0.250000
     RelativeRotation=(Pitch=32768)
     Skins(0)=Texture'BWBP_SKC_Tex.SKS650.SRSNSGrey'
     Skins(1)=Texture'BWBP3-Tex.SRS900.SRS900Ammo'
     Skins(2)=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-HSight-FB'
     Skins(3)=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-HSight-FB'
}
