//=============================================================================
// MARSAttachment.
//
// Attachment for MARS Assault Carbine. Pancakes are so delicious.
// This gun is pretty.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MARSAttachment extends BallisticCamoAttachment;

var Vector		SpawnOffset;


simulated function Vector GetTipLocation()
{
    local Vector X, Y, Z, Loc;

	if (Instigator.IsFirstPerson())
	{
		if (MARSAssaultRifle(Instigator.Weapon).bScopeView)
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
	if (CamoIndex != default.CamoIndex) 
		Skins[1] = CamoWeapon.default.CamoMaterials[CamoIndex];
}



defaultproperties
{
     CamoWeapon=Class'BWBP_SKC_Fix.MARSAssaultRifle'
     MuzzleFlashClass=Class'BWBP_SKC_Fix.MARSFlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.M806FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     BrassClass=Class'BallisticFix.Brass_Rifle'
     InstantMode=MU_Both
     FlashMode=MU_Both
     LightMode=MU_Both
     TracerClass=Class'BallisticFix.TraceEmitter_Default'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     bRapidFire=True
     bAltRapidFire=False
     RelativeRotation=(Pitch=32768)
     RelativeLocation=(Z=4.000000)
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_MARS2'
     DrawScale=0.250000
     Skins(1)=Shader'BWBP_SKC_TexExp.MARS.F2000-Shine'
     Skins(2)=Shader'BWBP_SKC_TexExp.MARS.F2000-ScopeShine'
     Skins(3)=Shader'BWBP_SKC_TexExp.MARS.F2000-LensShine'
}
