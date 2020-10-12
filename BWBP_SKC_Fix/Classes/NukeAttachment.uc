//=============================================================================
// NukeAttachment.
//
// 3rd person weapon attachment for the Nuke
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class NukeAttachment extends BallisticAttachment;


var() Sound		NukeSound;		//

// This assumes flash actors are triggered to make them work
// Override this in subclassed for better control
simulated function FlashMuzzleFlash(byte Mode)
{
	if (Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
		return;

	if (AltMuzzleFlashClass != None)
	{
		if (AltMuzzleFlash == None)
		{	// Spawn, Attach, Scale, Initialize emitter flashes
			AltMuzzleFlash = Spawn(AltMuzzleFlashClass, self);
			if (Emitter(AltMuzzleFlash) != None)
				class'BallisticEmitter'.static.ScaleEmitter(Emitter(AltMuzzleFlash), DrawScale*FlashScale);
			AltMuzzleFlash.SetDrawScale(DrawScale*FlashScale);
			if (DGVEmitter(AltMuzzleFlash) != None)
				DGVEmitter(AltMuzzleFlash).InitDGV();
			AttachToBone(AltMuzzleFlash, 'tip2');
		}
		AltMuzzleFlash.Trigger(self, Instigator);
	}
	if (MuzzleFlashClass != None)
	{	// Spawn, Attach, Scale, Initialize emitter flashes
		if (MuzzleFlash == None)
		{
			MuzzleFlash = Spawn(MuzzleFlashClass, self);
			if (Emitter(MuzzleFlash) != None)
				class'BallisticEmitter'.static.ScaleEmitter(Emitter(MuzzleFlash), DrawScale*FlashScale);
			MuzzleFlash.SetDrawScale(DrawScale*FlashScale);
			if (DGVEmitter(MuzzleFlash) != None)
				DGVEmitter(MuzzleFlash).InitDGV();
			AttachToBone(MuzzleFlash, 'tip');
		}
		MuzzleFlash.Trigger(self, Instigator);
	}
}


simulated function PlayAlarm()
{
	PlayAlarmServer();
	if (Level.NetMode != NM_DedicatedServer)
	{
		Level.GetLocalPlayerController().ClientPlaySound(NukeSound,true,2,SLOT_Talk);
//		PlayNukeAnnouncement('Incoming_air', 0, true);
//		Level.GetLocalPlayerController().PlayStatusAnnouncement('Incoming_air', 0, true);
	}
}
function PlayAlarmServer()
{
PlaySound(NukeSound);	
}


defaultproperties
{
     NukeSound=Sound'BWBP_SKC_Sounds.Misc.LAW-NukeAlarm'
     MuzzleFlashClass=Class'BallisticFix.G5FlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.G5BackFlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     AltFlashBone="tip2"
     FlashScale=1.200000
     BrassMode=MU_None
     InstantMode=MU_None
     bRapidFire=True
     Mesh=SkeletalMesh'BallisticAnims2.Bazooka-3rd'
     DrawScale=0.230000
}
