//=============================================================================
// VSKttachment.
//
// 3rd person weapon attachment for VSK Tranquilizer Rifle
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class VSKAttachment extends BallisticAttachment;

simulated function Vector GetTipLocation()
{
    local Coords C;
    local Vector X, Y, Z;

	if (Instigator.IsFirstPerson())
	{
		if (VSKTranqRifle(Instigator.Weapon).bScopeView)
		{
			Instigator.Weapon.GetViewAxes(X,Y,Z);
			return Instigator.Location + X*20 + Z*5;
		}
		else
			C = Instigator.Weapon.GetBoneCoords('tip');
	}
	else
		C = GetBoneCoords('tip');
    return C.Origin;
}

defaultproperties
{
     bRapidFire=True
     BrassClass=Class'BWBP_SKC_Fix.Brass_Tranq'
     DrawScale=0.160000
     FlashScale=0.300000
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     ImpactManager=Class'BWBP_SKC_Fix.IM_Tranq'
     Mesh=SkeletalMesh'BallisticAnims2.M50Third'
     MuzzleFlashClass=Class'BWBP_SKC_Fix.VSKSilencedFlash'
     Skins(0)=Texture'BWBP_SKC_Tex.M30A2.M30A2-SA'
     Skins(1)=Texture'BWBP_SKC_Tex.M30A2.M30A2-SB'
     Skins(2)=Texture'ONSstructureTextures.CoreGroup.Invisible'
     Skins(3)=Texture'BWBP_SKC_Tex.M30A2.M30A2-Laser'
     Skins(4)=Texture'BWBP_SKC_Tex.M30A2.M30A2-Gauss'
     Skins(5)=Texture'ONSstructureTextures.CoreGroup.Invisible'
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_Tranq'
	 TracerChance=1
	 TracerMix=0
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
}
