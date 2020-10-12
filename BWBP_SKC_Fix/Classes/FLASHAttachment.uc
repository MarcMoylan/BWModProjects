//=============================================================================
// FLASHAttachment.
//
// 3rd person weapon attachment for my plump rump
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FLASHAttachment extends BallisticCamoAttachment;



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
			if (FLASHLauncher(Instigator.Weapon) != None)
			{
				if (FLASHLauncher(Instigator.Weapon).MagAmmo >= 4)
					AttachToBone(AltMuzzleFlash, 'back1');
				else if (FLASHLauncher(Instigator.Weapon).MagAmmo == 3)
					AttachToBone(AltMuzzleFlash, 'back2');
				else if (FLASHLauncher(Instigator.Weapon).MagAmmo == 2)
					AttachToBone(AltMuzzleFlash, 'back3');
				else if (FLASHLauncher(Instigator.Weapon).MagAmmo <= 1)
					AttachToBone(AltMuzzleFlash, 'back4');
			}
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
			if (FLASHLauncher(Instigator.Weapon) != None)
			{
				if (FLASHLauncher(Instigator.Weapon).MagAmmo >= 4)
					AttachToBone(MuzzleFlash, 'tip');
				else if (FLASHLauncher(Instigator.Weapon).MagAmmo == 3)
					AttachToBone(MuzzleFlash, 'tip2');
				else if (FLASHLauncher(Instigator.Weapon).MagAmmo == 2)
					AttachToBone(MuzzleFlash, 'tip3');
				else if (FLASHLauncher(Instigator.Weapon).MagAmmo <= 1)
					AttachToBone(MuzzleFlash, 'tip4');
			}
		}
		MuzzleFlash.Trigger(self, Instigator);
	}
}

defaultproperties
{
     CamoWeapon=Class'BWBP_SKC_Fix.FLASHLauncher'
     MuzzleFlashClass=Class'BallisticFix.G5FlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.G5BackFlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     AltFlashBone="back1"
     FlashScale=1.200000
     FlashMode=MU_Both
     BrassMode=MU_None
     InstantMode=MU_None
     PrePivot=(Z=5.000000)
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_FLASH'
     DrawScale=0.600000
}
