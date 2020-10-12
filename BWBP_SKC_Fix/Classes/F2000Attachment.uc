//=============================================================================
// F2000Attachment.
//
// Attachment for MARS Assault Carbine. Pancakes are so delicious.
// This gun is pretty.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class F2000Attachment extends BallisticCamoAttachment;

var bool		bSilenced;
var bool		bOldSilenced;


replication
{
	reliable if ( Role==ROLE_Authority )
		bSilenced;
}

simulated event PostNetReceive()
{
	if (bSilenced != bOldSilenced)
	{
		bOldSilenced = bSilenced;
		if (bSilenced)
			SetBoneScale (0, 1.0, 'Muzzle2');
		else
			SetBoneScale (0, 0.0, 'Muzzle2');
	}
	Super.PostNetReceive();
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetBoneScale (0, 0.0, 'Muzzle2');
}




//Do your camo changes here
simulated function PostNetBeginPlay()
{
	if (CamoIndex != default.CamoIndex) 
		Skins[1] = CamoWeapon.default.CamoMaterials[CamoIndex];
	if (CamoIndex == 2)
		SetBoneScale (1, 0.0, 'EOTech');
}



defaultproperties
{
     CamoWeapon=Class'BWBP_SKC_Fix.F2000AssaultRifle'
     AltMuzzleFlashClass=Class'BWBP_SKC_Fix.LK05SilencedFlash'
     bAltRapidFire=False
     bRapidFire=True
     BrassClass=Class'BallisticFix.Brass_Rifle'
     DrawScale=0.250000
     FlashMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     ImpactManager=Class'BallisticFix.IM_Bullet'
     InstantMode=MU_Both
     LightMode=MU_Both
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_MARS3'
     MuzzleFlashClass=Class'BWBP_SKC_Fix.MJ51FlashEmitter'
     Skins(1)=Texture'BWBP_SKC_TexExp.MARS.F2000-Irons'
     Skins(2)=Texture'BWBP_SKC_TexExp.LK05.LK05-EOTech'
     Skins(3)=Texture'BWBP_SKC_TexExp.MARS.F2000-Misc'
     Skins(4)=Shader'BWBP_SKC_TexExp.LK05.LK05-EOTechGlow'
     RelativeRotation=(Pitch=32768)
     RelativeLocation=(Z=4.000000)
     TracerChance=2.000000
     TracerClass=Class'BallisticFix.TraceEmitter_Default'
	 TracerMix=0 // cryo weapon
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
}
