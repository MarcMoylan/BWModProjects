//=============================================================================
// MJ51Attachment.
//
// 3rd person weapon attachment for MJ51 Carbine
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MJ51Attachment extends BallisticAttachment;

var   bool					bLaserOn;	//Is laser currently active
var   bool					bOldLaserOn;//Old bLaserOn
var   LaserActor			Laser;		//The laser actor
var   Rotator				LaserRot;
var	  BallisticWeapon		myWeap;
var bool		bGrenadier;
var bool		bOldGrenadier;

replication
{
	reliable if ( Role==ROLE_Authority )
		bLaserOn, bGrenadier;
	unreliable if ( Role==ROLE_Authority )
		LaserRot;
}

simulated event PostNetReceive()
{
	if (bGrenadier != bOldGrenadier)
	{
		bOldGrenadier = bGrenadier;
		if (bGrenadier)
			SetBoneScale (0, 1.0, 'Grenade');
		else
			SetBoneScale (0, 0.0, 'Grenade');
	}
	Super.PostNetReceive();
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetBoneScale (0, 0.0, 'Grenade');
}

function IAOverride(bool bGrenadier)
{
	if (bGrenadier)
		SetBoneScale (0, 1.0, 'Grenade');
	else
		SetBoneScale (0, 0.0, 'Grenade');
}


function InitFor(Inventory I)
{
	Super.InitFor(I);

	if (BallisticWeapon(I) != None)
		myWeap = BallisticWeapon(I);
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
     AltFlashBone="tip"
     AltMuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     bAltRapidFire=False
     bNetNotify=true
     bRapidFire=True
     BrassClass=Class'BallisticFix.Brass_Rifle'
     DrawScale=0.450000
     FlashMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     ImpactManager=Class'BallisticFix.IM_Bullet'
     InstantMode=MU_Both
     LightMode=MU_Both
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_M4'
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     PrePivot=(Y=-1.000000,Z=-5.000000)
     RelativeRotation=(Pitch=32768)
     TracerClass=Class'BallisticFix.TraceEmitter_Default'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
}
