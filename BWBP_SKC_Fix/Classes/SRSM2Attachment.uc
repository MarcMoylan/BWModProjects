//=============================================================================
// SRSM2Attachment.
//
// Third person actor for the SRS Mod-2 rifle
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SRSM2Attachment extends BallisticCamoAttachment;

var() Material          MatAltEO;      	// Blue + scars.
var() Material          MatAltEO2;      	// green.

simulated function Vector GetTipLocation()
{
    local Coords C;
    local Vector X, Y, Z;

	if (Instigator.IsFirstPerson())
	{
		if (SRSM2BattleRifle(Instigator.Weapon).bScopeView)
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

simulated event ThirdPersonEffects()
{
    if ( Level.NetMode != NM_DedicatedServer && Instigator != None)
	{
		if (FiringMode == 1)
			SetBoneScale (0, 1.0, 'Silencer');
		else
			SetBoneScale (0, 0.0, 'Silencer');
    }
	super.ThirdPersonEffects();
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetBoneScale (0, 0.0, 'Silencer');
}

simulated function FlashMuzzleFlash(byte Mode)
{
	if (FlashMode == MU_None || (FlashMode == MU_Secondary && Mode == 0) || (FlashMode == MU_Primary && Mode != 0))
		return;
	if (Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
		return;

	if (Mode != 0 && AltMuzzleFlashClass != None)
	{
		if (AltMuzzleFlash == None)
			class'BUtil'.static.InitMuzzleFlash (AltMuzzleFlash, AltMuzzleFlashClass, DrawScale*0.6, self, AltFlashBone);
		AltMuzzleFlash.Trigger(self, Instigator);
	}
	else if (Mode == 0 && MuzzleFlashClass != None)
	{
		if (MuzzleFlash == None)
			class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, DrawScale*FlashScale, self, FlashBone);
		MuzzleFlash.Trigger(self, Instigator);
	}
}


//Do your camo changes here
simulated function PostNetBeginPlay()
{
	if (CamoIndex != default.CamoIndex) 
	{
		Skins[0] = CamoWeapon.default.CamoMaterials[CamoIndex];
		if (CamoIndex == 4 || CamoIndex == 5 ||CamoIndex == 6)
		{
			Skins[2] = MatAltEO;
			Skins[3] = MatAltEO;
		}
		else if (CamoIndex == 3)
		{
			Skins[2] = MatAltEO2;
			Skins[3] = MatAltEO2;
		}

	}
}


defaultproperties
{

     MatAltEO=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-BSight-FB'
     MatAltEO2=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-GSight-FB'

     CamoWeapon=Class'BWBP_SKC_Fix.SRSM2BattleRifle'
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.XK2SilencedFlash'
     AltFlashBone="tip2"
     ImpactManager=Class'BallisticFix.IM_Bullet'
     FlashScale=0.900000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     TracerClass=Class'BallisticFix.TraceEmitter_Default'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     bRapidFire=True
     bAltRapidFire=True
     Mesh=SkeletalMesh'BWBP_SKC_Anim.SRS-3rd'
     DrawScale=0.250000
     RelativeRotation=(Pitch=32768)
     Skins(0)=Texture'BWBP_SKC_Tex.SKS650.SRSNSGrey'
     Skins(1)=Texture'BWBP3-Tex.SRS900.SRS900Ammo'
     Skins(2)=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-HSight-FB'
     Skins(3)=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-HSight-FB'
}
