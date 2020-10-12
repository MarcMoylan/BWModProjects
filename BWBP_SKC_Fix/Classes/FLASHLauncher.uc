//=============================================================================
// FLASHLauncher.
//
// Four barrels! Firey rockets! Watch them STREAk through the sky!
// These rockets melt the shiznit out of stuff.
// I love biscuits. Bizcitz.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FLASHLauncher extends BallisticCamoWeapon;

#EXEC OBJ LOAD FILE=BWBP_SKC_TexExp.utx

var bool		bFirstDraw;
var() BUtil.FullSound	HatchSound;

 

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (bFirstDraw && MagAmmo > 0)
	{
     		BringUpTime=2.5;
     		SelectAnim='PulloutFancy';
		bFirstDraw=false;
	}
	else
	{
     		BringUpTime=default.BringUpTime;
		SelectAnim='Pullout';
	}

	Super.BringUp(PrevWeapon);

	if (class'BallisticReplicationInfo'.default.bNoReloading && AmmoAmount(0) > 1)
		SetBoneScale (0, 1.0, 'Rocket');

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = true;
}

simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();
			if ((Index == -1 && f > 0.99 ) || Index == 4) //1%
			{
				Skins[2]=CamoMaterials[4];

				if (bAllowCamoEffects)
				{
					FLASHPrimaryFire(FireMode[0]).ProjectileClass=Class'BWBP_SKC_Fix.SMATRocket';
					FLASHSecondaryFire(FireMode[1]).ProjectileClass=Class'BWBP_SKC_Fix.SMATRocket';
					ReloadAnimRate=2;
				}
				CamoIndex=4;
			}
			else if ((Index == -1 && f > 0.95) || Index == 3) //4%
			{
				Skins[2]=CamoMaterials[3];

				if (bAllowCamoEffects)
				{
					FLASHPrimaryFire(FireMode[0]).ProjectileClass=Class'BallisticFix.BOGPFlare';
					FLASHSecondaryFire(FireMode[1]).ProjectileClass=Class'BallisticFix.BOGPFlare';
				}
				CamoIndex=3;
			}
			else if ((Index == -1 && f > 0.85) || Index == 2) //10%
			{
				Skins[2]=CamoMaterials[2];
				CamoIndex=2;
			}
			else if ((Index == -1 && f > 0.75) || Index == 1) // 10%
			{
				Skins[2]=CamoMaterials[1];
				CamoIndex=1;
			}
			else
			{
				Skins[2]=CamoMaterials[0];
				CamoIndex=0;
			}

}

// Draw the scope view
simulated event RenderOverlays (Canvas Canvas)
{
	if (!bScopeView)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
		return;
	}
	if (!bNoMeshInScope)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
	}
	else
	{
		SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
		SetRotation(Instigator.GetViewRotation());
	}

	// Draw Scope View
    if (ScopeViewTex != None)
    {
   		Canvas.SetDrawColor(255,255,255,255);

        	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
    		Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
	}
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

     CamoMaterials[4]=Shader'BWBP_SKC_TexExp.Flash.FLASH-Charged'
     CamoMaterials[3]=Texture'BWBP_SKC_TexExp.Flash.FLASH-CamoFAB'
     CamoMaterials[2]=Texture'BWBP_SKC_TexExp.Flash.FLASH-CamoWhite'
     CamoMaterials[1]=Texture'BWBP_SKC_TexExp.Flash.FLASH-CamoBlack'
     CamoMaterials[0]=Texture'BWBP_SKC_TexExp.Flash.FLASH-Main'

     PlayerSpeedFactor=0.800000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny',SkinNum=5)
     AIReloadTime=4.000000
     BigIconMaterial=Texture'BWBP_SKC_TexExp.FLASH.BigIcon_FLASH'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     InventorySize=51
     bWT_Hazardous=True
     bWT_Splash=True
     bWT_Projectile=True
     bWT_Super=True
     SpecialInfo(0)=(Info="500.0;60.0;1.0;80.0;2.0;0.0;1.5")
     BringUpSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-PullOut',Volume=2.200000)
     PutDownSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-Putaway',Volume=2.200000)
     MagAmmo=4
     CockSound=(Sound=Sound'BallisticSounds2.G5.G5-Lever')
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.Flash.FLASH-PullOut',Volume=1.100000)
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.Flash.FLASH-Insert',Volume=1.100000)
     bNeedCock=False
     bCockOnEmpty=False
     bNonCocking=True
     bFirstDraw=True
     WeaponModes(0)=(ModeName="Incendiary Rocket",ModeID="WM_FullAuto")
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     ScopeViewTex=Texture'BWBP_SKC_TexExp.FLASH.AT40ScopeView'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
     FullZoomFOV=30.000000
     SightDisplayFOV=30.000000
	 ZoomType=ZT_Fixed
     bNoMeshInScope=True
     bNoCrosshairInScope=True
     SightOffset=(X=0.000000,Y=5.300000,Z=23.300000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.NRP57OutA',Pic2=Texture'BallisticUI2.Crosshairs.Misc9',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=0,R=255,A=192),Color2=(B=0,G=255,R=255,A=86),StartSize1=89,StartSize2=130)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.250000,X2=1.000000,Y2=1.000000),MaxScale=3.000000)
     CrosshairChaosFactor=0.750000
     CrouchAimFactor=0.400000
     SightAimFactor=0.100000
     SprintOffSet=(Pitch=-6000,Yaw=-8000)
     JumpOffSet=(Pitch=-7000)
     AimSpread=(X=(Min=-480.000000,Max=480.000000),Y=(Min=-480.000000,Max=480.000000))
     ViewAimFactor=0.300000
     ViewRecoilFactor=1.000000
     AimDamageThreshold=300.000000
     ChaosDeclineTime=2.800000
     ChaosSpeedThreshold=380.000000
     ChaosAimSpread=(X=(Min=-2000.000000,Max=2000.000000),Y=(Min=-2000.000000,Max=2000.000000))
     RecoilYawFactor=0.000000
     RecoilMax=1024.000000
     RecoilDeclineTime=0.750000
     FireModeClass(0)=Class'BWBP_SKC_Fix.FLASHPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.FLASHSecondaryFire'
     PutDownTime=1.400000
     BringUpTime=1.500000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.750000
     CurrentRating=0.750000
     Description="AT40 Suppressive Thermal-Rocket Assault Weapon||Manufacturer: UTC Defense Tech|Primary: Rocket Strike|Secondary: Rocket Barrage||The G5 is an excellent tool against armored vehicles, but against infantry it loses some of its effectiveness. In response to field tester imput, the UTC is currently trying a new anti-infantry rocket launcher called the STREAK. This specialized rocket launcher uses a standard warhead filled with a mixture of napalm, tar and thermite, along with an igniting agent. This means that the STREAK can both take out infantry quickly with a direct blast and incinerate those caught in its wide area of effect. Another bonus of the STREAK is that the user can fire the rockets singlely to dispose of individuals or four at a time to wipe out larger groups. A scope can be used for larger ranges. Note: Make sure that the device is not used in tight areas, due to the large back blast of the weapon."
     Priority=164
     CenteredOffsetY=10.000000
     CenteredRoll=0
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=8
     PickupClass=Class'BWBP_SKC_Fix.FLASHPickup'
     PlayerViewOffset=(X=10.000000,Y=0.000000,Z=-12.000000)
     BobDamping=1.800000
     AttachmentClass=Class'BWBP_SKC_Fix.FLASHAttachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.FLASH.SmallIcon_FLASH'
     IconCoords=(X2=127,Y2=31)
     ItemName="AT40 STREAK"
     ShovelIncrement=4;
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=25
     LightSaturation=100
     LightBrightness=192.000000
     LightRadius=12.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.FLASH_FP'
     DrawScale=0.400000
     Skins(0)=Texture'BWBP_SKC_TexExp.FLASH.FLASH-Scope'
     Skins(1)=Texture'BallisticWeapons2.M353.M353_Ammo'
     Skins(2)=Texture'BWBP_SKC_TexExp.FLASH.FLASH-Main'
     Skins(3)=Texture'BWBP_SKC_TexExp.FLASH.FLASH-Lens'
     Skins(4)=Texture'BWBP_SKC_TexExp.FLASH.FLASH-Rocket'
     Skins(5)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
}
