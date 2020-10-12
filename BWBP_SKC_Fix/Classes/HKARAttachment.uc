//=============================================================================
// MJ51Attachment.
//
// 3rd person weapon attachment for MJ51 Carbine
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class HKARAttachment extends BallisticAttachment;
var Vector		SpawnOffset;

simulated function InstantFireEffects(byte Mode)
{
	local vector L, Dir;

	if (Mode == 0)
	{
		super.InstantFireEffects(Mode);
		return;
	}
	L = Instigator.Location + Instigator.EyePosition();
	Dir = Normal(mHitLocation - L);

	if (Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
		Spawn(class'AM67FlashProjector',Instigator,,L+Dir*25,rotator(Dir));
	else
		Spawn(class'AM67FlashProjector',Instigator,,GetTipLocation(),rotator(Dir));
}

simulated function Vector GetTipLocation()
{
    local Vector X, Y, Z, Loc;

	if (Instigator.IsFirstPerson())
	{
		if (HKARCarbine(Instigator.Weapon).bScopeView)
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

simulated function FlashMuzzleFlash(byte Mode)
{
	local rotator R;
	local float DF;

	if (Instigator.IsFirstPerson() && PlayerController(Instigator.Controller).ViewTarget == Instigator)
		return;

	if (Mode != 0 && AltMuzzleFlashClass != None)
	{
		if (AltMuzzleFlash == None)
			class'BUtil'.static.InitMuzzleFlash (AltMuzzleFlash, AltMuzzleFlashClass, DrawScale*FlashScale, self, AltFlashBone);

		Emitter(AltMuzzleFlash).Emitters[0].StartSizeRange.X.Min = (200 + DF*600) * DrawScale * FlashScale;
		Emitter(AltMuzzleFlash).Emitters[0].StartSizeRange.X.Max = Emitter(AltMuzzleFlash).Emitters[0].StartSizeRange.X.Min;

		AltMuzzleFlash.Trigger(self, Instigator);
	}
	else if (Mode == 0 && MuzzleFlashClass != None)
	{
		if (MuzzleFlash == None)
			class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, DrawScale*FlashScale, self, FlashBone);
		MuzzleFlash.Trigger(self, Instigator);
		if (bRandomFlashRoll)	SetBoneRotation(FlashBone, R, 0, 1.f);
	}
}


defaultproperties
{
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.AM67FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     AltFlashBone="tip"
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
     PrePivot=(Y=-1.000000,Z=-5.000000)
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_M4'
     DrawScale=0.450000
}
