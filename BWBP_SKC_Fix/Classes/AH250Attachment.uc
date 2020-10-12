//=============================================================================
// AH250Attachment.
//
// 3rd person weapon attachment for AH208 Pistol
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class AH250Attachment extends BallisticCamoHandgunAttachment;
var Vector		SpawnOffset;

simulated function Vector GetTipLocation()
{
    local Vector X, Y, Z, Loc;

	if (Instigator.IsFirstPerson())
	{
		if (AH250Pistol(Instigator.Weapon).bScopeView)
		{
			Instigator.Weapon.GetViewAxes(X,Y,Z);
			Loc = Instigator.Location + Instigator.EyePosition() + X*20 + Z*-10;
		}
		else
			Loc = Instigator.Weapon.GetBoneCoords('tip').Origin + class'BUtil'.static.AlignedOffset(Instigator.GetViewRotation(), SpawnOffset);
	}
	else
		Loc = GetBoneCoords('tip').Origin;
	if (VSize(Loc - Instigator.Location) > 200)
		return Instigator.Location;
    return Loc;
}


//Do your camo changes here
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	
	SetBoneScale (2, 0.0, 'RedDotSight');

	if (CamoIndex != default.CamoIndex) 
	{
		if (CamoIndex == 4) //Golden
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[4];
			Skins[3]=CamoWeapon.default.CamoMaterials[6];
			SetBoneScale (0, 0.0, 'LAM');
			SetBoneScale (3, 0.0, 'Compensator');
		}
		else if (CamoIndex == 3) //Silver Scopeless!
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[3];
			Skins[4]=CamoWeapon.default.CamoMaterials[9];
			SetBoneScale (0, 0.0, 'LAM');
			SetBoneScale (1, 0.0, 'Scope');
		}
		else if (CamoIndex == 2) //white
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[2];
			Skins[3]=CamoWeapon.default.CamoMaterials[5];
			Skins[4]=CamoWeapon.default.CamoMaterials[7];
			SetBoneScale (0, 0.0, 'LAM');
		}
		else if (CamoIndex == 1) //LAM equipped
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[2];
			Skins[3]=CamoWeapon.default.CamoMaterials[5];
		}
		else
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[1];
			Skins[3]=CamoWeapon.default.CamoMaterials[5];
			Skins[4]=CamoWeapon.default.CamoMaterials[8];
			SetBoneScale (0, 0.0, 'LAM');
		}
	}
}


defaultproperties
{
     CamoWeapon=Class'BWBP_SKC_Fix.AH250Pistol'
     MuzzleFlashClass=Class'BallisticFix.D49FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_BigBullet'
     FlashScale=0.250000
     BrassClass=Class'BallisticFix.Brass_Pistol'
     TracerClass=Class'BallisticFix.TraceEmitter_Pistol'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     Mesh=SkeletalMesh'BWBP_SKC_Anim.TP_Eagle'
     RelativeLocation=(X=3.000000,Y=-1.000000,Z=4.000000)
     RelativeRotation=(Pitch=32768)
     DrawScale=0.540000
}
