//=============================================================================
// AH104FlashEmitter.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AH104FlashEmitter extends BallisticEmitter;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (WeaponAttachment(Owner) != None)
		Emitters[1].ZTest = true;
}

defaultproperties
{
     Emitters(0)=MeshEmitter'BallisticFix.M806FlashEmitter.MeshEmitter7'

     Emitters(1)=SpriteEmitter'BallisticFix.M806FlashEmitter.SpriteEmitter11'

     Emitters(2)=SpriteEmitter'BallisticFix.M806FlashEmitter.SpriteEmitter12'

     bNoDelete=False
}
