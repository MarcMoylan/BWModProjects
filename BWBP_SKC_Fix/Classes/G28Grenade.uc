//=============================================================================
// T10Grenade.
//
// A handgrenade that emits a toxic gas. A special actor is spawned for the
// grenade and handles the actual clouds.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class G28Grenade extends BallisticHandGrenade;

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	SetBoneScale (0, 1.0, GrenadeBone);
	SetBoneScale (1, 1.0, PinBone);
}

simulated function DoExplosionEffects()
{
//	HandExplodeTime = Level.TimeSeconds;
//	ClipReleaseTime = level.TimeSeconds - 3;
	if (FireMode[1].bIsFiring)
	{
//		FireMode[1].HoldTime = 0;
//		FireMode[1].ModeDoFire();
//		FireMode[1].bIsFiring = false;
	}
	else
	{
//		FireMode[0].HoldTime = 0;
//		FireMode[0].ModeDoFire();
//		FireMode[0].bIsFiring = false;
	}
//	ClipReleaseTime = 666;
}

simulated function DoExplosion()
{
	if (Role == ROLE_Authority)
	{
		CheckNoGrenades();
	}
}

simulated function ExplodeInHand()
{
	ClipReleaseTime=666;
	KillSmoke();
//	HandExplodeTime = Level.TimeSeconds + 1.0;

	HandExplodeTime = Level.TimeSeconds;
//	ClipReleaseTime = level.TimeSeconds - 3;
	if (IsFiring())
	{
		FireMode[0].HoldTime = 0;
		FireMode[0].bIsFiring=false;
		FireMode[1].HoldTime = 0;
		FireMode[1].bIsFiring=false;
	}
	else
	{
		FireMode[0].HoldTime = 0;
		FireMode[0].ModeDoFire();
		FireMode[0].bIsFiring = false;
	}
	if (Role == Role_Authority)
	{
		DoExplosionEffects();
		MakeNoise(1.0);
//		ConsumeAmmo(0, 1);
	}
	SetTimer(0.1, false);

//	ClipReleaseTime = 0.0;
}

simulated function ClientStartReload(optional byte i)
{
	ClipReleaseTime = Level.TimeSeconds+0.2;
	SetTimer(FuseDelay + 0.2, false);

	SpawnSmoke();
	BFireMode[0].EjectBrass();
	class'BUtil'.static.PlayFullSound(self, ClipReleaseSound);

	if(!IsFiring())
		PlayAnim(ClipReleaseAnim, 1.0, 0.1);
}


simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);
	if (Anim == ClipReleaseAnim)
	{
		SetBoneRotation('MOACTop', rot(9192,0,0));
		IdleAnim = 'OpenIdle';
//		BallisticGrenadeFire(FireMode[0]).PreFireAnim = NoClipPreFireAnim;
//		BallisticGrenadeFire(FireMode[1]).PreFireAnim = NoClipPreFireAnim;
	}
	else if (Anim == FireMode[0].FireAnim || Anim == FireMode[1].FireAnim)
	{
		SetBoneScale (1, 1.0, PinBone);
		SetBoneScale (0, 1.0, GrenadeBone);
		CheckNoGrenades();
		IdleAnim='Idle';
//		BallisticGrenadeFire(FireMode[0]).PreFireAnim = default.BallisticGrenadeFire(FireMode[0]).PreFireAnim;
//		BallisticGrenadeFire(FireMode[1]).PreFireAnim = default.BallisticGrenadeFire(FireMode[1]).PreFireAnim;
	}
	else if (Anim == SelectAnim)
	{
		IdleAnim='Idle';
//		BallisticGrenadeFire(FireMode[0]).PreFireAnim = default.BallisticGrenadeFire(FireMode[0]).PreFireAnim;
//		BallisticGrenadeFire(FireMode[1]).PreFireAnim = default.BallisticGrenadeFire(FireMode[1]).PreFireAnim;
		PlayIdle();
	}
	else	
    		AnimEnded(Channel, anim, frame, rate);
}


defaultproperties
{
     FuseDelay=2.000000
     ClipReleaseSound=(Sound=Sound'BallisticSounds3.NRP57.NRP57-ClipOut',Volume=0.500000,Radius=48.000000,Pitch=1.000000,bAtten=True)
     PinPullSound=(Sound=Sound'BallisticSounds2.NRP57.NRP57-PinOut',Volume=0.500000,Radius=48.000000,Pitch=1.000000,bAtten=True)
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_Tex.G28.BigIcon_G28'
     BallisticInventoryGroup=0
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Hazardous=False
     bWT_Splash=True
     bWT_Grenade=True
     GrenadeBone="G28"
     PinBone="Pin"
     SmokeBone="G28"
     IdleAnimRate=0.25
     SpecialInfo(0)=(Info="0.0;0.0;0.0;-1.0;0.0;0.0;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.NRP57.NRP57-Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.NRP57.NRP57-Putaway')
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.NRP57OutA',pic2=Texture'BallisticUI2.Crosshairs.Cross1',USize1=256,VSize1=256,USize2=128,VSize2=128,Color1=(B=255,G=255,R=255,A=128),Color2=(B=0,G=0,R=255,A=165),StartSize1=98,StartSize2=54)
     CrosshairInfo=(SpreadRatios=(Y2=0.500000),MaxScale=8.000000)
     FireModeClass(0)=Class'BWBP_SKC_Fix.G28PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.G28SecondaryFire'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.400000
     CurrentRating=0.400000
     Description="FMD G28 Medicinal Aerosol||Manufacturer: UTC Defense Tech|Primary: Throw Grenade|Secondary: Roll Grenade|Special: Release Clip||The FMD G28 Medicinal Aerosol is a lightweight smoke grenade filled with various healing compounds and nano-assemblers for quick wound repair on the fly. It is a medic's best friend, and has been used to save many soldiers' lives. It has unfortunately also been the cause of a few deaths, as the gas can be ignited under the right conditions and the grenade itself is quite heavy and can cause concussions if thrown with sufficient velocity. || Surgeon General's Warning: The G28 Medicinal Aerosol is a temporary healing agent, and should not be used in place of quality medical care. May cause cancer."
     Priority=14
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=3
     GroupOffset=10
     PickupClass=Class'BWBP_SKC_Fix.G28Pickup'
     PlayerViewOffset=(X=30.000000,Y=0.000000,Z=-12.000000)
     PlayerViewPivot=(Pitch=1024,Yaw=-1024)
     BobDamping=1.000000
     AttachmentClass=Class'BWBP_SKC_Fix.G28Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.G28.SmallIcon_G28'
     IconCoords=(X2=127,Y2=31)
     ItemName="FMD G28 Medicinal Aerosol"
     Mesh=SkeletalMesh'BWBP_SKC_Anim.G28_FP'
     DrawScale=0.400000
//     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
//     Skins(1)=Texture'BWBP_SKC_Tex.G28.G28-Main'
}
