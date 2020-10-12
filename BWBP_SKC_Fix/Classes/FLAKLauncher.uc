//=============================================================================
// FLAKLaycehrer
//
// A giant 105mm shotgun cannon! Turn people into delicious goo!
// Now comes with the patented anti-air FLAK grenade!
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FLAKLauncher extends BallisticWeapon;

#EXEC OBJ LOAD FILE=BWBP_SKC_Tex.utx

var() BUtil.FullSound	HatchSound;


simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if (class'BallisticReplicationInfo'.default.bNoReloading && AmmoAmount(0) > 1)
		SetBoneScale (0, 1.0, 'Rocket');

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = true;
}




simulated function PlayIdle()
{
	Super.PlayIdle();
	if (bPendingSightUp || SightingState != SS_None || !CanPlayAnim(IdleAnim, ,"IDLE"))
		return;
	FreezeAnimAt(0.0);
}


simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		if (MagAmmo < 2)
			SetBoneScale (0, 0.0, 'Rocket');
		return true;
	}

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = false;

	return false;
}


// AI Interface =====
function byte BestMode()
{
	return 0;	
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;
	local vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return Super.GetAIRating();

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	Result = Super.GetAIRating();
	if (Dist < 600)
		Result -= 0.6;
	else if (Dist > 4000)
		Result -= 0.3;
	else if (Dist > 20000)
		Result += (Dist-1000) / 2000;
	result += 0.2 - FRand()*0.4;
	return Result;
}
// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return -0.5;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return -0.9;	}
// End AI Stuff =====






simulated event AnimEnd (int Channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

	// Shovel loop ended, start it again
	if (ReloadState == RS_PostShellIn && anim == 'ReloadLoop')
	{
		PlayShovelEnd();
		ReloadState = RS_EndShovel;
		return;
	}
		Super.AnimEnd(Channel);
}

// Scope up anim just ended. Either go into scope view or move the scope back down again
simulated function ScopeUpAnimEnd()
{
 		super.ScopeUpAnimEnd();
}
simulated function Notify_CockAfterFire()
{
bNeedCock=false;
}



simulated function PlayReload()
{
	bNeedCock=false;
	if (bScopeView && Instigator.Controller.IsA( 'PlayerController' ))
	{
		PlayerController(Instigator.Controller).EndZoom();
		class'BUtil'.static.PlayFullSound(self, ZoomOutSound);
	}

	SetBoneScale (0, 1.0, 'Rocket');
	if (MagAmmo < 1)
		PlayAnim('StartReloadEmpty', StartShovelAnimRate, , 0);
	else
		PlayAnim('StartReload', ReloadAnimRate, , 0);
}
simulated function PlayShovelLoop()
{
	if (MagAmmo < 1)
	{
		ClipInSound = default.ClipInSound;
		PlayAnim('ReloadLoopEmpty', ReloadAnimRate, , 0);
	}
	else
	{
		ClipInSound = default.ClipOutSound;
		PlayAnim('ReloadLoop', ReloadAnimRate, , 0);
	}
}
simulated function PlayShovelEnd()
{
	if (MagAmmo < 2)
		SetBoneScale (0, 0.0, 'Rocket');
	Super.PlayShovelEnd();
}

simulated function Notify_G5HatchOpen ()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;
	class'BUtil'.static.PlayFullSound(self, HatchSound);
}
simulated function Notify_G5HideRocket ()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;
	if (!class'BallisticReplicationInfo'.default.bNoReloading || AmmoAmount(0) < 2)
		SetBoneScale (0, 0.0, 'Rocket');
}

defaultproperties
{
     HatchSound=(Sound=Sound'BallisticSounds2.M75.M75Cliphit',Volume=0.700000,Pitch=1.000000)

     PlayerSpeedFactor=0.800000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=4.000000
     BigIconMaterial=Texture'BWBP_SKC_Tex.SMAA.BigIcon_SMAA'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     InventorySize=51
     SpecialInfo(0)=(Info="500.0;60.0;1.0;80.0;2.0;0.0;1.5")
     BringUpSound=(Sound=Sound'BWBP4-Sounds.Artillery.Art-Deploy',Volume=1.100000)
     PutDownSound=(Sound=Sound'BWBP4-Sounds.Artillery.Art-Undeploy',Volume=1.100000)
     MagAmmo=4
     CockAnimRate=0.650000
     CockSound=(Sound=Sound'BallisticSounds2.G5.G5-Lever')
     ReloadAnim="ReloadLoop"
     ReloadAnimRate=0.650000
     ClipOutSound=(Sound=Sound'BWBP4-Sounds.MRL.MRL-BigOn',Volume=1.100000)
     ClipInSound=(Sound=Sound'BWBP4-Sounds.MRL.MRL-Cycle',Volume=1.100000)
     bNeedCock=False
     bShovelLoad=True
     StartShovelAnim="StartReload"
     EndShovelAnim="FinishReload"
     WeaponModes(0)=(ModeName="Canister Shot",ModeID="WM_FullAuto")
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     bWT_Shotgun=True
     SightOffset=(X=-6.000000,Y=-7.500000,Z=5.500000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.G5InA',Pic2=Texture'BallisticUI2.Crosshairs.M763InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=0,R=255,A=145),Color2=(B=0,G=255,R=255,A=45),StartSize1=110,StartSize2=152)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.250000,X2=1.000000,Y2=1.000000),MaxScale=3.000000)
     CrosshairChaosFactor=0.750000
     CrouchAimFactor=0.500000
     SightAimFactor=0.100000
     AimAdjustTime=1.000000
     SprintOffSet=(Pitch=-6000,Yaw=-8000)
     JumpOffSet=(Pitch=-7000)
     AimSpread=(X=(Min=-2048.000000,Max=2048.000000),Y=(Min=-2048.000000,Max=2048.000000))
     ViewAimFactor=0.300000
     ViewRecoilFactor=1.000000
     AimDamageThreshold=300.000000
     ChaosDeclineTime=1.400000
     ChaosSpeedThreshold=380.000000
     ChaosAimSpread=(X=(Min=-3600.000000,Max=3600.000000),Y=(Min=-3600.000000,Max=3600.000000))
     RecoilYawFactor=0.500000
     RecoilXFactor=2.000000
     RecoilYFactor=2.000000
     RecoilMax=2048.000000
     RecoilDeclineTime=2.000000
     RecoilDeclineDelay=0.500000
     FireModeClass(0)=Class'BWBP_SKC_Fix.FLAKPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.FLAKSecondaryFire'
     SelectAnimRate=0.400000
     PutDownAnimRate=0.700000
     PutDownTime=1.400000
     BringUpTime=1.500000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.750000
     CurrentRating=0.750000
     bShowChargingBar=True
     Description="REX-M2 CAWS||Manufacturer: UTC Defense Tech|Primary: 66mm Shotgun|Secondary: DANCE Rocket||The REX Universal Launcher has served as the basis for many different weapon types. This model is the type 2 Close Assault Weapon System, or CAWS. The CAWS is the weapon brought out when no other gun will provide the raw lethal power needed in a mission. It is designed to cause massive collateral damage, extremely painful wounds, and maim all in its firing cone. Firing a 66mm cannister of flechettes and buckshot, this weapon decimates even armored opponents and can fatally wound targets in excess of 100 meters. Due to its excessively lethal nature, the CAWS is banned on all major planets so its presence on the battlefield lets you know that, for whoever is fielding it, the gloves have been taken off."
     Priority=164
     CenteredOffsetY=10.000000
     CenteredRoll=0
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=8
     PickupClass=Class'BWBP_SKC_Fix.FLAKPickup'
     PlayerViewOffset=(X=10.000000,Y=10.500000,Z=-6.000000)
     BobDamping=1.800000
     AttachmentClass=Class'BWBP_SKC_Fix.FLAKAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.SMAA.SmallIcon_SMAA'
     IconCoords=(X2=127,Y2=31)
     ItemName="[B]REX-M2 CAWS"
     ShovelIncrement=4;
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=25
     LightSaturation=100
     LightBrightness=192.000000
     LightRadius=12.000000
     Mesh=SkeletalMesh'BallisticAnims2.G5Bazooka'
     DrawScale=0.400000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_Tex.SMAA.SMAA-Shine'
     Skins(2)=Texture'ONSstructureTextures.CoreGroup.Invisible'
     Skins(4)=Texture'BWBP_SKC_Tex.SMAA.SMAARocket'
     Skins(5)=Texture'BWBP_SKC_Tex.SMAA.SMAALauncher'
}
