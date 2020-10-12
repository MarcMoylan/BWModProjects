//=============================================================================
// AH104Attachment.
//
// 3rd person weapon attachment for AH104 Pistol
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class AH104Attachment extends BallisticAttachment;

var   bool					bLaserOn;	//Is laser currently active
var   bool					bOldLaserOn;//Old bLaserOn
var   LaserActor			Laser;		//The laser actor
var   Rotator				LaserRot;
var   BallisticWeapon      Heavy;

replication
{
	reliable if ( Role==ROLE_Authority )
		bLaserOn;
	unreliable if ( Role==ROLE_Authority )
		LaserRot;
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

	Loc = GetTipLocation();

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

    function InitFor(Inventory I)
    {
       Super.InitFor(I);

       if (BallisticWeapon(I) != None)
          Heavy = BallisticWeapon(I);
    }

simulated function Destroyed()
{
	if (Laser != None)
		Laser.Destroy();
	Super.Destroyed();
}

defaultproperties
{
     MuzzleFlashClass=Class'BWBP_SKC_Fix.AH104FlashEmitter'
     AltMuzzleFlashClass=Class'BWBP_SKC_Fix.AH104FlashEmitter'
     ImpactManager=Class'BWBP_SKC_Fix.IM_ExpBullet'
     AltFlashBone="ejector"
     BrassClass=Class'BallisticFix.Brass_Pistol'
     FlashMode=MU_Both
     TracerClass=Class'BallisticFix.TraceEmitter_Pistol'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=Sound'BWBP_SKC_Sounds.AH104.AH104-FlyBy',Volume=1.500000)
     Mesh=SkeletalMesh'BallisticAnims2.AM67-3rd'
     DrawScale=0.140000
     Skins(0)=Texture'BWBP_SKC_Tex.AH104.AH104-MainMk2'
}
