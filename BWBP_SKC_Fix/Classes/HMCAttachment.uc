//=============================================================================
// E23Attachment.
//
// 3rd person weapon attachment for E23 Plasma Rifle
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class HMCAttachment extends BallisticAttachment;

var   bool					bLaserOn;	//Is laser currently active
var   bool					bRedTeam;	//Owned by red team or special?
var   bool					bOldLaserOn;//Old bLaserOn
var   LaserActor			Laser;		//The laser actor
var   Rotator				LaserRot;
var   vector				PreviousHitLoc;
var   Emitter				LaserDot;
var   BallisticWeapon      Heavy;
var   bool					bBigLaser;
var byte		SmallCount, SmallCountOld;
var byte		BlastCount, BlastCountOld;


var   bool				bSmallCharge;			// Checks if at 25% charge.
var Actor 		Pack;			// The Backpack


replication
{
	reliable if ( Role==ROLE_Authority )
		bLaserOn, SmallCount, BlastCount, bRedTeam;
	unreliable if ( Role==ROLE_Authority )
		LaserRot, bBigLaser;
}

simulated event PostNetReceive()
{

	if (BlastCount != BlastCountOld)
	{
		FiringMode = 1;
		BlastCountOld = BlastCount;
		ThirdPersonEffects();
	}
	if (SmallCount != SmallCountOld)
	{
		FiringMode = 0;
		ThirdPersonEffects();
		SmallCountOld = SmallCount;
	}
	super.PostNetReceive();
}





simulated function SetOverlayMaterial( Material mat, float time, bool bOverride )
{
	Super.SetOverlayMaterial(mat, time, bOverride);
	if ( Pack != None )
		Pack.SetOverlayMaterial(mat, time, bOverride);
}

simulated function Hide(bool NewbHidden)
{
	super.Hide(NewbHidden);
	if (Pack!= None)
		Pack.bHidden = NewbHidden;
}

simulated function KillLaserDot()
{
	if (LaserDot != None)
	{
		LaserDot.bHidden=false;
		LaserDot.Kill();
		LaserDot = None;
	}
}
simulated function SpawnLaserDot(vector Loc)
{
	if (LaserDot == None)
	{
		if ( (Instigator.PlayerReplicationInfo.Team != None) && (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0) || bRedTeam )
			LaserDot = Spawn(class'BallisticFix.IE_GRS9LaserHit',,,Loc);
		else
			LaserDot = Spawn(class'BWBP_SKC_Fix.IE_HMCLase',,,Loc);
		laserDot.bHidden=false;
	}
}
simulated function Tick(float DT)
{
	local Vector HitLocation, Start, End, HitNormal, Scale3D, Loc;
	local Rotator X;
	local Actor Other;

	Super.Tick(DT);

	if (bLaserOn && Role == ROLE_Authority && Heavy != None)
	{
		LaserRot = Instigator.GetViewRotation();
		LaserRot += Heavy.GetAimPivot();
		LaserRot += Heavy.GetRecoilPivot();
	}

	if (bRedTeam)
		Skins[0] = Shader'BWBP_SKC_Tex.BeamCannon.RedCannonSD';

	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (Laser == None)
	{
		if ( (Instigator.PlayerReplicationInfo.Team != None) && (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0) || bRedTeam )
			Laser = Spawn(class'BWBP_SKC_Fix.LaserActor_HMCRed',,,Location);
		else
			Laser = Spawn(class'BWBP_SKC_Fix.LaserActor_HMC',,,Location);
	}
	if ( (Instigator.PlayerReplicationInfo.Team != None) && (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0) || bRedTeam )
     		TracerClass=Class'BallisticFix.TraceEmitter_HVCRedLightning';

	if (bLaserOn != bOldLaserOn)
		bOldLaserOn = bLaserOn;

	if (!bLaserOn || Instigator == None || Instigator.IsFirstPerson() || Instigator.DrivenVehicle != None)
	{
		if (!Laser.bHidden)
			Laser.bHidden = true;
		if (LaserDot != None)
			KillLaserDot();
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

	Loc = GetTipLocation();

	if (AIController(Instigator.Controller)!=None)
	{
		HitLocation = mHitLocation;
	}
	else
	{
		End = Start + (Vector(X)*3000);
		Other = Trace (HitLocation, HitNormal, End, Start, true);
		if (Other == None)
			HitLocation = End;
	}

	if (LaserDot == None && Other != None)
		SpawnLaserDot(HitLocation);
	else if (LaserDot != None && Other == None)
		KilllaserDot();
	if (LaserDot != None)
	{
		LaserDot.SetLocation(HitLocation);
		LaserDot.SetRotation(rotator(HitNormal));
	}

	Laser.SetLocation(Loc);
	Laser.SetRotation(Rotator(HitLocation - Loc));
	Scale3D.X = VSize(HitLocation-Laser.Location)/128;
	if (bBigLaser)
	{
		Scale3D.Y = 16;
		Scale3D.Z = 16;
	}
	else
	{
		Scale3D.Y = 8;
		Scale3D.Z = 8;
	}
	Laser.SetDrawScale3D(Scale3D);
}

    function InitFor(Inventory I)
    {
       Super.InitFor(I);

       if (BallisticWeapon(I) != None)
          Heavy = BallisticWeapon(I);
    }

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	Pack = Spawn(class'HVPCPack');
	if (Instigator != None)
		Instigator.AttachToBone(Pack,'Spine');
	Pack.SetBoneScale(0, 0.0001, 'Bone03');
	if ( (Instigator != None) && (Instigator.PlayerReplicationInfo != None) && (Instigator.PlayerReplicationInfo.Team != None) || bRedTeam )
	{
		if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 || bRedTeam )
			Skins[0] = Shader'BWBP_SKC_Tex.BeamCannon.RedCannonSD';
		else if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 1 )
			Skins[0] = Shader'BWBP_SKC_Tex.BeamCannon.BeamCannonSkin_SD';
	}

}

simulated function Destroyed()
{
	if (Pack != None)
		Pack.Destroy();
	if (Laser != None)
		Laser.Destroy();
	KillLaserDot();
	Super.Destroyed();
}



function HMCUpdateHit(byte WeaponMode)
{
	if (!bSmallCharge)
	{
		bSmallCharge = true;
		ThirdPersonEffects();
	}
	else if (bSmallCharge)
	{
		bSmallCharge = False;
		ThirdPersonEffects();
	}
}



simulated event ThirdPersonEffects()
{
    if ( Level.NetMode != NM_DedicatedServer && Instigator != None)
	{
		if (!bSmallCharge)
			InstantFireEffects(FiringMode);
		else if (bSmallCharge)
			SmallInstantFireEffects(FiringMode);
		else
			super.ThirdPersonEffects();
    	}
}





simulated function InstantFireEffects(byte Mode)
{
	if (Mode == 0)
	{
		if ( (Instigator.PlayerReplicationInfo.Team != None) && (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0) || bRedTeam)
			ImpactManager = class'IM_HVPCProjectile';
		else
			ImpactManager = class'IM_HMCBlast';
	}
	else
	{
		if (VSize(PreviousHitLoc - mHitLocation) < 2)
			return;
		PreviousHitLoc = mHitLocation;
		if ( (Instigator.PlayerReplicationInfo.Team != None) && (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0) || bRedTeam)
			ImpactManager = class'IM_GRS9Laser';
		else
			ImpactManager = class'IM_HMCLase';
	}
	super.InstantFireEffects(Mode);
}

simulated function SmallInstantFireEffects(byte Mode)
{
	if (Mode == 0)
		ImpactManager = class'IM_HMCSmall';
	else
	{
		if (VSize(PreviousHitLoc - mHitLocation) < 2)
			return;
		PreviousHitLoc = mHitLocation;
		if ( (Instigator.PlayerReplicationInfo != None) && (Instigator.PlayerReplicationInfo.Team != None) )
			if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
				ImpactManager = class'IM_GRS9Laser';
		else
			ImpactManager = class'IM_HMCLase';
	}
	super.InstantFireEffects(Mode);
}

/*simulated function FlashMuzzleFlash(byte Mode)
{
	if (Mode == 0)
		super.FlashMuzzleFlash(Mode);
	else if (AltMuzzleFlash == None && AltMuzzleFlashClass != None)
		class'BUtil'.static.InitMuzzleFlash (AltMuzzleFlash, AltMuzzleFlashClass, DrawScale*FlashScale, self, FlashBone);
}

simulated function Timer()
{
	super.Timer();

	if (AltMuzzleFlash != None)
	{
		Emitter(AltMuzzleFlash).Kill();
		AltMuzzleFlash = None;
	}
}*/

defaultproperties
{
     MuzzleFlashClass=Class'BWBP_SKC_Fix.HMCFlashEmitter'
     AltMuzzleFlashClass=Class'BWBP_SKC_Fix.HMCFlashEmitter'
     ImpactManager=Class'BWBP_SKC_Fix.IM_HMCBlast'
     InstantMode=MU_Both
     FlashMode=MU_Both
     LightMode=MU_Both
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_HMC'
     TracerChance=2.000000
//     bHeavy=True
     bRapidFire=True
     Mesh=SkeletalMesh'BallisticAnims2.RX22A-3rd'
     DrawScale=0.330000
     RelativeLocation=(X=-5.000000,Z=3.000000)
     Skins(0)=Texture'BWBP_SKC_Tex.BeamCannon.BeamCannonSkin'
     Skins(1)=FinalBlend'BWBP_SKC_Tex.BeamCannon.BeamCannonShieldFB'
}
