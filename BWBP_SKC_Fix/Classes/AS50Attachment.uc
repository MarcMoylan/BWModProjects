//=============================================================================
// AS50Attachment.
//
// 3rd person weapon attachment for SSG-50 Sniper
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AS50Attachment extends BallisticCamoAttachment;

// Return the location of the muzzle.
simulated function Vector GetTipLocation()
{
    local Coords C;
    local Vector X, Y, Z, Loc;

	if (Instigator != None && Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
	{
		if (X82Rifle(Instigator.Weapon).bScopeView)
		{
			Instigator.Weapon.GetViewAxes(X,Y,Z);
			Loc = Instigator.Location + Instigator.EyePosition() + X*20 + Z*-10;
			return Loc;
		}
		else
		{
			C = Instigator.Weapon.GetBoneCoords('tip');
    			return C.Origin;
		}
	}
	else if (BallisticTurret(Instigator) != None)
	{
		C = Instigator.GetBoneCoords('tip');
    		return C.Origin;
	}
	else
	{
		C = GetBoneCoords('tip');
	     return C.Origin;
	}
	if (Instigator != None && VSize(C.Origin - Instigator.Location) > 250)
		return Instigator.Location;

}
// Return location of brass ejector
simulated function Vector GetEjectorLocation(optional out Rotator EjectorAngle)
{
    local Coords C;
	if (Instigator != None && Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
		C = Instigator.Weapon.GetBoneCoords(BrassBone);
	else if (BallisticTurret(Instigator) != None)
		C = Instigator.GetBoneCoords(BrassBone);
	else
		C = GetBoneCoords(BrassBone);
	if (Instigator != None && VSize(C.Origin - Instigator.Location) > 200)
	{
		EjectorAngle = Instigator.Rotation;
		return Instigator.Location;
	}
	if (BallisticTurret(Instigator) != None)
		EjectorAngle = Instigator.GetBoneRotation(BrassBone);
	else
		EjectorAngle = GetBoneRotation(BrassBone);
    return C.Origin;
}

simulated function FlashMuzzleFlash(byte Mode)
{
	local rotator R;

	if (FlashMode == MU_None || (FlashMode == MU_Secondary && Mode == 0) || (FlashMode == MU_Primary && Mode != 0))
		return;
	if (Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
		return;

	if (Mode != 0 && AltMuzzleFlashClass != None)
	{
		if (AltMuzzleFlash == None)
		{
			if (BallisticTurret(Instigator) != None)
				class'BUtil'.static.InitMuzzleFlash (AltMuzzleFlash, AltMuzzleFlashClass, DrawScale*1.666, Instigator, AltFlashBone);
			else
				class'BUtil'.static.InitMuzzleFlash (AltMuzzleFlash, AltMuzzleFlashClass, DrawScale*FlashScale, self, AltFlashBone);
		}
		AltMuzzleFlash.Trigger(self, Instigator);
		if (bRandomFlashRoll)	SetBoneRotation(AltFlashBone, R, 0, 1.f);
	}
	else if (Mode == 0 && MuzzleFlashClass != None)
	{
		if (MuzzleFlash == None)
		{
			if (BallisticTurret(Instigator) != None)
				class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, DrawScale*1.666, Instigator, FlashBone);
			else
				class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, DrawScale*FlashScale, self, FlashBone);
		}
		MuzzleFlash.Trigger(self, Instigator);
		if (bRandomFlashRoll)	SetBoneRotation(FlashBone, R, 0, 1.f);
	}
}


//Do your camo changes here
simulated function PostNetBeginPlay()
{
	if (CamoIndex != default.CamoIndex) 
	{
		if (CamoIndex == 2) //No scope
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[3];
			Skins[3]=CamoWeapon.default.CamoMaterials[0];
		}
		else if (CamoIndex == 1) //N6-BMG
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[2];
			Skins[3]=CamoWeapon.default.CamoMaterials[1];
		}
		else
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[2];
			Skins[3]=CamoWeapon.default.CamoMaterials[0];
		}

	}
	super(BallisticAttachment).PostNetBeginPlay();
}


defaultproperties
{
     BrassClass=Class'BWBP_SKC_Fix.Brass_BMGInc'
     CamoWeapon=Class'BWBP_SKC_Fix.AS50Rifle'
     DrawScale=0.400000
     FlyBySound=(Sound=Sound'BWBP_SKC_Sounds.AH104.AH104-FlyBy',Volume=1.500000)
     ImpactManager=Class'BWBP_SKC_Fix.IM_IncendiaryBullet'
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_FSG-50'
     MuzzleFlashClass=Class'BallisticFix.M925FlashEmitter'
     PrePivot=(Y=-5.000000,Z=-1.000000)
     RelativeLocation=(X=-17.000000,Z=2.000000)
     RelativeRotation=(Pitch=32768)
     Skins(0)=Texture'BWBP_SKC_TexExp.FSG50.FSG-Main'
     Skins(1)=Texture'BWBP_SKC_TexExp.FSG50.FSG-Scope'
     Skins(2)=Texture'BallisticWeapons2.A73.A73Energy'
     Skins(3)=Texture'BWBP_SKC_TexExp.FSG50.FSG-Misc'
     Skins(4)=Texture'BWBP_SKC_TexExp.FSG50.FSG-Stock'
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_HMG'
	 TracerChance=1
	 TracerMix=0
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
}
