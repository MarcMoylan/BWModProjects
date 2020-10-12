//=============================================================================
// M30A2Attachment.
//
// 3rd person weapon attachment for M30A2 Tactical Rifle
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class M30A2Attachment extends BallisticCamoAttachment;

var   bool					bLaserOn;	//Is laser currently active
var   bool					bOldLaserOn;//Old bLaserOn
var   LaserActor			Laser;		//The laser actor
var   Rotator				LaserRot;
var	  BallisticWeapon		myWeap;
var Vector		SpawnOffset;
var() class<BCTraceEmitter>	AltTracerClass;		//Type of tracer to use for alt fire effects

replication
{
	reliable if ( Role==ROLE_Authority )
		bLaserOn;
	unreliable if ( Role==ROLE_Authority )
		LaserRot;
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
		bThisShot && (TracerChance >= 1 || FRand() < TracerChance))
	{
		if (Dist > 200)
			Tracer = Spawn(TracerClass, self, , TipLoc, Rotator(V - TipLoc));
		if (Tracer != None)
			Tracer.Initialize(Dist);
	}
	// Spawn an alt tracer
	if (AltTracerClass != None && TracerMode != MU_None && (TracerMode == MU_Both && Mode != 0) && (TracerChance >= 1 || FRand() < TracerChance))
	{
		if (Dist > 200)
			Tracer = Spawn(AltTracerClass, self, , TipLoc, Rotator(V - TipLoc));
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

simulated function Vector GetTipLocation()
{
    local Vector X, Y, Z, Loc;

	if (Instigator.IsFirstPerson())
	{
		if (M30A2AssaultRifle(Instigator.Weapon).bScopeView)
		{
			Instigator.Weapon.GetViewAxes(X,Y,Z);
			Loc = Instigator.Location + Instigator.EyePosition() + X*20 + Z*-10;
		}
		else
			Loc = Instigator.Weapon.GetBoneCoords('tip').Origin + class'BUtil'.static.AlignedOffset(Instigator.GetViewRotation(), SpawnOffset);
	}
	else
		Loc = GetBoneCoords('tip').Origin;
	if (VSize(Loc - Instigator.Location) > 200)
		return Instigator.Location;
    return Loc;
}


function InitFor(Inventory I)
{
	Super.InitFor(I);

	if (BallisticWeapon(I) != None)
		myWeap = BallisticWeapon(I);
}


//Do your camo changes here
simulated function PostNetBeginPlay()
{
	if (CamoIndex != default.CamoIndex) 
	{
		if (CamoIndex == 1) //N6-BMG
		{
			Skins[0]=CamoWeapon.default.CamoMaterials[3];
			Skins[1]=CamoWeapon.default.CamoMaterials[4];
		}
		else
		{
			Skins[0]=CamoWeapon.default.CamoMaterials[1];
			Skins[1]=CamoWeapon.default.CamoMaterials[2];
		}

	}
}



simulated function Tick(float DT)
{
	local Vector HitLocation, Start, End, HitNormal, Scale3D, Loc;
	local Rotator X;
	local Actor Other;

	Super.Tick(DT);

	if (bLaserOn && Role == ROLE_Authority && myWeap != None)
	{
		LaserRot = Instigator.GetViewRotation();
		LaserRot += myWeap.GetAimPivot();
		LaserRot += myWeap.GetRecoilPivot();
	}

	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (Laser == None)
		Laser = Spawn(class'BallisticFix.LaserActor_Third',,,Location);

	if (bLaserOn != bOldLaserOn)
		bOldLaserOn = bLaserOn;

	if (!bLaserOn || Instigator == None || Instigator.IsFirstPerson() || Instigator.DrivenVehicle != None)
	{
		if (!Laser.bHidden)
			Laser.bHidden = true;
		return;
	}
	else
	{
		if (Laser.bHidden)
			Laser.bHidden = false;
	}

	if (Instigator != None)
		Start = Instigator.Location + Instigator.EyePosition();
	else
		Start = Location;
	X = LaserRot;

//	Loc = GetTipLocation();
	Loc = GetBoneCoords('tip2').Origin;

	End = Start + (Vector(X)*5000);
	Other = Trace (HitLocation, HitNormal, End, Start, true);
	if (Other == None)
		HitLocation = End;

	Laser.SetLocation(Loc);
	Laser.SetRotation(Rotator(HitLocation - Loc));
	Scale3D.X = VSize(HitLocation-Laser.Location)/128;
	Scale3D.Y = 1;
	Scale3D.Z = 1;
	Laser.SetDrawScale3D(Scale3D);
}

simulated function Destroyed()
{
	if (Laser != None)
		Laser.Destroy();
	Super.Destroyed();
}

defaultproperties
{
     CamoWeapon=Class'BWBP_SKC_Fix.M30A2AssaultRifle'
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.M806FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     BrassClass=Class'BallisticFix.Brass_Rifle'
     InstantMode=MU_Both
     FlashMode=MU_Both
     LightMode=MU_Both
     TracerMode=MU_Both
     TracerClass=Class'BallisticFix.TraceEmitter_Default'
     AltTracerClass=Class'BWBP_SKC_Fix.TraceEmitter_M30Gauss'
     TracerChance=2.000000
     TracerMix=-3
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     bRapidFire=True
     bAltRapidFire=True
     Mesh=SkeletalMesh'BallisticAnims2.M50Third'
     DrawScale=0.160000
     Skins(0)=Texture'BWBP_SKC_Tex.M30A2.M30A2-SA'
     Skins(1)=Texture'BWBP_SKC_Tex.M30A2.M30A2-SB'
     Skins(2)=Texture'ONSstructureTextures.CoreGroup.Invisible'
     Skins(3)=Texture'BWBP_SKC_Tex.M30A2.M30A2-Laser'
     Skins(4)=Texture'BWBP_SKC_Tex.M30A2.M30A2-Gauss'
     Skins(5)=Texture'ONSstructureTextures.CoreGroup.Invisible'
}
