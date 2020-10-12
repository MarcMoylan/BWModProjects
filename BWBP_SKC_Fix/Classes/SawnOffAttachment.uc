//=============================================================================
// MRT6Attachment.
//
// Attachemnt for MRT6 to give it double barrel abilities.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SawnOffAttachment extends BallisticAttachment;

var   BallisticHandgun		HandGun;		// The first person Handgun (only on server)
var() bool					bIsSlave;		// It's the slave (sent to clients)
var() vector				SlaveOffset;	// RelativeLocation if slave
var() rotator				SlavePivot;		// RelativeRotation if slave
var   float					SlaveAlpha;		// A counter for slave firing 'animation'
var   HandgunAttachment		OtherGun;		// The other gun's thirdpersonactor...
var() class<BallisticShotgunFire>	FireClass;


replication
{
	reliable if (bNetDirty && Role==Role_Authority)
		bIsSlave, OtherGun;
//	reliable if (bNetDirty && Role==Role_Authority && bNetOwner)
//		HandGun;
}

simulated function Hide(bool NewbHidden)
{
	super.Hide(NewbHidden);

	if (OtherGun != None && !bIsSlave)
		OtherGun.Hide(NewbHidden);
}

simulated function SetOverlayMaterial( Material mat, float time, bool bOverride )
{
	Super.SetOverlayMaterial(mat, time, bOverride);
	if ( OtherGun != None  && !bIsSlave && OtherGun.bIsSlave)
		OtherGun.SetOverlayMaterial(mat, time, bOverride);
}

simulated function InstantFireEffects(byte Mode)
{
	if (FiringMode != 0)
		ShotgunFireEffects(FiringMode);
	else
		Super.InstantFireEffects(FiringMode);
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	if (Role < ROLE_Authority && bIsSlave)
	{
		if (Instigator!= None && Instigator.Weapon != None && BallisticHandgun(Instigator.Weapon) != None && BallisticHandgun(Instigator.Weapon).OtherGun != None)
			Handgun = BallisticHandgun(Instigator.Weapon).OtherGun;
		SetRelativeRotation(SlavePivot);
		SetRelativeLocation(SlaveOffset);
	}
}

function InitFor(Inventory I)
{
	Super.InitFor(I);

	if (BallisticHandgun(I) != None)
	{
		Handgun = BallisticHandgun(I);
		if (Handgun.IsSlave())
		{
			bIsSlave = true;
			SetRelativeRotation(SlavePivot);
			SetRelativeLocation(SlaveOffset);
		}
		else
		{
			bIsSlave = false;
			SetRelativeRotation(default.RelativeRotation);
			SetRelativeLocation(default.RelativeLocation);
		}
	}
}

simulated function Tick(float DT)
{
	local rotator newRot;

	// Poiint arm and slave in pawn view direction
	if (Instigator != None && bIsSlave)
	{
		newRot = Instigator.Rotation;
		// Pitch arm up to make a slave firing anim
		if (SlaveAlpha > 0)
		{
			if (SlaveAlpha >= 0.75)
				newRot.Pitch += 7000 * (1-SlaveAlpha) * 4;
			else
				newRot.Pitch += 7000 * SlaveAlpha * 1.333;
			SlaveAlpha = FMax(0, SlaveAlpha - DT);
		}
		Instigator.SetBoneDirection('lfarm', newRot,, 1.0, 1);

		newRot.Roll += 32768;
		Instigator.SetBoneDirection(AttachmentBone, newRot,, 1.0, 1);
	}
}

// Return the location of the muzzle.
simulated function Vector GetTipLocation()
{
    local Coords C;

	if (Instigator != None && Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
	{
		if (HandGun != None)
			C = HandGun.GetBoneCoords('tip');
		else
			C = Instigator.Weapon.GetBoneCoords('tip');
	}
	else
		C = GetBoneCoords('tip');
	if (Instigator != None && VSize(C.Origin - Instigator.Location) > 200)
		return Instigator.Location;
    return C.Origin;
}

simulated function Destroyed()
{
	if (bIsSlave && Instigator != None)
	{
		Instigator.SetBoneDirection(AttachmentBone, Rotation,, 0, 0);
		Instigator.SetBoneDirection('lfarm', Rotation,, 0, 0);
	}
    Super.Destroyed();
}

// Do trace to find impact info and then spawn the effect
// This should be called from sub-classes
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
				TracerClass = class<BCTraceEmitter>(FireClass.default.TracerClass);
				DoWaterTrace(Start, End);
				SpawnTracer(Mode, End);
				TracerClass = default.TracerClass;
			}
			else
			{
				TracerClass = class<BCTraceEmitter>(FireClass.default.TracerClass);
				DoWaterTrace(Start, HitLocation);
				SpawnTracer(Mode, HitLocation);
				TracerClass = default.TracerClass;
			}

			if (mHitActor == None || (!mHitActor.bWorldGeometry && Mover(mHitActor) == None))
				continue;

			if (HitMat == None)
				mHitSurf = int(mHitActor.SurfaceType);
			else
				mHitSurf = int(HitMat.SurfaceType);

			if (FireClass.default.ImpactManager != None)
				FireClass.default.ImpactManager.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, self);
		}
	}
}


simulated function FlashMuzzleFlash(byte Mode)
{
	local rotator R;

	if (FlashMode == MU_None || (FlashMode == MU_Secondary && Mode == 0) || (FlashMode == MU_Primary && Mode != 0))
		return;
	if (Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
		return;

	if (AltMuzzleFlashClass != None && AltMuzzleFlash == None)
		class'BUtil'.static.InitMuzzleFlash (AltMuzzleFlash, AltMuzzleFlashClass, DrawScale*FlashScale, self, AltFlashBone);
	if (MuzzleFlashClass != None && MuzzleFlash == None)
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, DrawScale*FlashScale, self, FlashBone);

	R = Instigator.Rotation;
	R.Pitch = Rotation.Pitch;
	if (Mode == 0 || Mode == 2)
	{
		if (class'BallisticMod'.default.bMuzzleSmoke)
			Spawn(class'MRT6Smoke',,, AltMuzzleFlash.Location, R);
		AltMuzzleFlash.Trigger(self, Instigator);
	}
	if (Mode == 0 || Mode == 1)
	{
		if (class'BallisticMod'.default.bMuzzleSmoke)
			Spawn(class'MRT6Smoke',,, MuzzleFlash.Location, R);
		MuzzleFlash.Trigger(self, Instigator);
	}
	super.FlashMuzzleFlash (Mode);
	if (bIsSlave)
		SlaveAlpha = 1.0;

}

simulated function FlashWeaponLight(byte Mode)
{
	if (LightMode == MU_None || (LightMode == MU_Secondary && Mode == 0) || (LightMode == MU_Primary && Mode != 0))
		return;
	if (Instigator == None || Level.bDropDetail || ((Level.TimeSeconds - LastRenderTime > 0.2) && (PlayerController(Instigator.Controller) == None)))
	{
//		Timer();
		return;
	}
	if (HandGun != None)
		LightWeapon = HandGun;
	else
		LightWeapon = self;

	LightWeapon.bDynamicLight = true;
	SetTimer(WeaponLightTime, false);
}

function SawnOffUpdateHit(Actor HitActor, vector HitLocation, vector HitNormal, int HitSurf, optional bool bIsRight)
{
	mHitNormal = HitNormal;
	mHitActor = HitActor;
	mHitLocation = HitLocation;
	if (bIsRight)
		FiringMode = 2;
	else
		FiringMode = 1;
	FireCount++;
	ThirdPersonEffects();
}

simulated function EjectBrass(byte Mode);

defaultproperties
{
     SlaveOffset=(X=17.000000,Y=-7.000000,Z=-7.000000)
     SlavePivot=(Pitch=32768,Roll=30000)
     FireClass=Class'BWBP_SKC_Fix.SawnOffPrimaryFire'
     MuzzleFlashClass=Class'BWBP_SKC_Fix.SawnOffFlashEmitter'
     AltMuzzleFlashClass=Class'BWBP_SKC_Fix.SawnOffFlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Shell'
     AltFlashBone="tip2"
     FlashScale=1.200000
     BrassClass=Class'BallisticFix.Brass_M290Left'
     TracerMode=MU_Both
     InstantMode=MU_Both
     FlashMode=MU_Both
     LightMode=MU_Both
     TracerClass=Class'BallisticFix.TraceEmitter_Shotgun'
     TracerChance=0.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.SawnOff_3rd'
     RelativeLocation=(X=25.000000,Y=-5.000000,Z=-4.000000)
     DrawScale=0.200000
}
