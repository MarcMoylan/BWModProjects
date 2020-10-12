//=============================================================================
// NEXAttachment.
//
// Attachment for NEX plasma sword.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class NEXAttachment extends BallisticMeleeAttachment;
var   bool			bMeleeing;		//zip zop zobbidy bop.

simulated function InstantFireEffects(byte Mode)
{

	if (bMeleeing)
	{

		ImpactManager = class'IM_GunHit';
	}
	else
	{
		ImpactManager=default.ImpactManager;
	}
		super.InstantFireEffects(Mode);
}

defaultproperties
{
     ImpactManager=Class'BWBP_SKC_Fix.IM_NEX'
     BrassMode=MU_None
     InstantMode=MU_Both
     FlashMode=MU_None
     LightMode=MU_None
     TrackAnimMode=MU_Both
     bHeavy=True
     Mesh=SkeletalMesh'BWBP_SKC_Anim.3RD-NEX'
     DrawScale=0.130000
}
