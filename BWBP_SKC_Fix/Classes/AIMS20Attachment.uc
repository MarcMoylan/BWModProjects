//=============================================================================
// M30A2Attachment.
//
// 3rd person weapon attachment for M30A2 Tactical Rifle
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AIMS20Attachment extends BallisticShotgunAttachment;

var	  BallisticWeapon		myWeap;
var Vector		SpawnOffset;


simulated function Vector GetTipLocation()
{
    local Vector X, Y, Z, Loc;

	if (Instigator.IsFirstPerson())
	{
		if (AIMS20AssaultRifle(Instigator.Weapon).bScopeView)
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


function InitFor(Inventory I)
{
	Super.InitFor(I);

	if (BallisticWeapon(I) != None)
		myWeap = BallisticWeapon(I);
}

defaultproperties
{
     FireClass=Class'BWBP_SKC_Fix.AIMS20PrimaryFire'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     FlashScale=1.800000
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.M806FlashEmitter'
//     ImpactManager=Class'BallisticFix.IM_Bullet'
     BrassClass=Class'BallisticFix.Brass_Rifle'
     InstantMode=MU_Both
     FlashMode=MU_Both
     LightMode=MU_Both
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_AIMS'
     TracerChance=1.000000
     TracerMix=0
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     bRapidFire=True
     bAltRapidFire=True
     Mesh=SkeletalMesh'BallisticAnims2.M50Third'
     DrawScale=0.160000
}
