//=============================================================================
// HVCMk9RedMuzzleFlash.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class HVPCMuzzleFlash extends BallisticEmitter;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (WeaponAttachment(Owner) != None)
		Emitters[0].ZTest = true;
}

defaultproperties
{
     Emitters(0)=SpriteEmitter'BallisticFix.HVCMk9RedMuzzleFlash.SpriteEmitter5'

     Emitters(1)=BeamEmitter'BallisticFix.HVCMk9RedMuzzleFlash.BeamEmitter5'

     Emitters(2)=BeamEmitter'BallisticFix.HVCMk9RedMuzzleFlash.BeamEmitter6'

     Emitters(3)=SpriteEmitter'BallisticFix.HVCMk9RedMuzzleFlash.SpriteEmitter6'

     Emitters(4)=SpriteEmitter'BallisticFix.HVCMk9RedMuzzleFlash.SpriteEmitter8'

     bNoDelete=False
}
