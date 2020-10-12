//=============================================================================
// RS04Attachment.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class RS04Attachment extends BallisticCamoHandgunAttachment;

var bool		bLightsOn, bLightsOnOld;
var Projector	FlashLightProj;
var Emitter		FlashLightEmitter;

replication
{
	reliable if ( Role==ROLE_Authority )
		bLightsOn;
}



simulated function Hide(bool NewbHidden)
{
	super.Hide(NewbHidden);
	SwitchFlashLight();
	if (NewbHidden)
	{
		KillProjector();
		if (FlashLightEmitter!=None)
			FlashLightEmitter.Destroy();
	}
	else if (bLightsOn)
	{
		SwitchFlashLight();
	}
}

simulated event PostNetReceive()
{
	super.PostNetReceive();
	if (level.NetMode != NM_Client)
		return;
}

simulated function StartProjector()
{
	if (FlashLightProj == None)
		FlashLightProj = Spawn(class'MRS138TorchProjector',self,,location);
	AttachToBone(FlashLightProj, 'tip2');
	FlashLightProj.SetRelativeLocation(vect(-32,0,0));
}
simulated function KillProjector()
{
	if (FlashLightProj != None)
	{
		FlashLightProj.Destroy();
		FlashLightProj = None;
	}
}

simulated function SwitchFlashLight ()
{
	if (bLightsOn)
	{
		if (FlashLightEmitter == None)
		{
			FlashLightEmitter = Spawn(class'MRS138TorchEffect',self,,location);
			class'BallisticEmitter'.static.ScaleEmitter(FlashLightEmitter, DrawScale);
			AttachToBone(FlashLightEmitter, 'tip2');
			FlashLightEmitter.bHidden = false;
			FlashLightEmitter.bCorona = true;
		}
		if (!Instigator.IsFirstPerson())
			StartProjector();
	}
	else
	{
		FlashLightEmitter.Destroy();
		KillProjector();
	}
}

simulated event Tick(float DT)
{
	super.Tick(DT);

	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (bLightsOn != bLightsOnOld)	
	{
		SwitchFlashLight();
		bLightsOnOld = bLightsOn;	
	}
	if (!bLightsOn)
		return;

	if (Instigator.IsFirstPerson())
	{
		KillProjector();
		if (FlashLightEmitter != None && FlashLightEmitter.bCorona)
			FlashLightEmitter.bCorona = false;
	}
	else
	{
		if (FlashLightProj == None)
			StartProjector();
		if (FlashLightEmitter != None && !FlashLightEmitter.bCorona)
			FlashLightEmitter.bCorona = true;
	}
}

simulated function Destroyed()
{
	if (FlashLightEmitter != None)
		FlashLightEmitter.Destroy();
	KillProjector();
	super.Destroyed();
}


//simulated event ThirdPersonEffects()
//{
//	SetBoneScale (0, 0.0, 'Silencer');
//	super.ThirdPersonEffects();
//}

defaultproperties
{
     CamoWeapon=Class'BWBP_SKC_Fix.RS04Pistol'
     SlavePivot=(Pitch=0,Roll=32768)
     RelativeRotation=(Pitch=32768)
     MuzzleFlashClass=Class'BallisticFix.XK2FlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.XK2SilencedFlash'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     AltFlashBone="tip2"
     BrassClass=Class'BallisticFix.Brass_Pistol'
     BrassMode=MU_Both
     InstantMode=MU_Both
     FlashMode=MU_Both
     TracerClass=Class'BallisticFix.TraceEmitter_Default'
     TracerMix=-3
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     bRapidFire=True
     bAltRapidFire=True
     Mesh=SkeletalMesh'BWBP_SKC_Anim.TP_RS04'
     PrePivot=(Z=-2.000000)
     DrawScale=0.210000
}
