//=============================================================================
// BulldogAttachment.
//
// 3rd person weapon attachment for the Suzuki XL7
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class PUGAttachment extends BallisticShotgunAttachment;
var() class<actor>			AltBrassClass1;			//Alternate Fire's brass
var() class<actor>			AltBrassClass2;			//Alternate Fire's brass (whole FRAG-12)

// Fling out shell casing
simulated function EjectBrass(byte Mode)
{
	local Rotator R;
	if (!class'BallisticMod'.default.bEjectBrass || Level.DetailMode < DM_High)
		return;
	if (BrassClass == None)
		return;
	if (BrassMode == MU_None || (BrassMode == MU_Secondary && Mode == 0) || (BrassMode == MU_Primary && Mode != 0))
		return;
	if (Instigator != None && Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
		return;
	if (Mode == 0)
		Spawn(BrassClass, self,, GetEjectorLocation(R), R);
	else if (Mode != 0)
		Spawn(AltBrassClass1, self,, GetEjectorLocation(R), R);
}

defaultproperties
{
     FireClass=Class'BWBP_SKC_Fix.PUGPrimaryFire'
     MuzzleFlashClass=Class'BWBP_SKC_Fix.AH104FlashEmitter'
     AltMuzzleFlashClass=Class'BWBP_SKC_Fix.AH104FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Shell'
     AltFlashBone="ejector"
     BrassClass=Class'BWBP_SKC_Fix.Brass_BOLT'
     AltBrassClass1=Class'BWBP_SKC_Fix.Brass_FRAGSpent'
     AltBrassClass2=Class'BWBP_SKC_Fix.Brass_FRAG'
     FlashMode=MU_Both
     BrassMode=MU_Both
     TracerChance=1.000000
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_Flechette'
     TracerMode=MU_Primary
     InstantMode=MU_Primary
     Mesh=SkeletalMesh'BWBP_SKC_Anim.3RD-Bulldog'
     RelativeLocation=(X=-2.000000,Y=0.000000,Z=0.000000)
     RelativeRotation=(Pitch=32768)
     DrawScale=0.300000
}
