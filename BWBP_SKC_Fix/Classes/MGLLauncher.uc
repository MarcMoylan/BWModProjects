//=============================================================================
// MGLLauncher.
//
// Multiple Grenade Launcher Launcher!
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MGLLauncher extends BallisticWeapon;

var() Material	MatDef;
var() Material	MatArmed;
var() Rotator	DrumRot;

var bool bRemoteGrenadeOut;

replication
{
	reliable if (Role == ROLE_Authority)
        ClientSwitchCannonMode;
	unreliable if (Role == ROLE_Authority)
		ClientUpdateGrenadeStatus;
}

simulated function AnimEnded (int Channel, name anim, float frame, float rate)
{
	if (anim == FireMode[0].FireAnim || (FireMode[1] != None && anim == FireMode[1].FireAnim))
	{
		bPreventReload=false;
		DrumRot.Roll -= 65535 / 6 ;
		SetBoneRotation('drum',DrumRot);	
	}
	
	//Phase out Channel 1 if a sight fire animation has just ended.
	if (anim == BFireMode[0].AimedFireAnim || anim == BFireMode[1].AimedFireAnim)
	{
		AnimBlendParams(1, 0);
		//Cut the basic fire anim if it's too long.
		if (SightingState > FireAnimCutThreshold && SafePlayAnim(IdleAnim, 1.0))
			FreezeAnimAt(0.0);
		bPreventReload=False;
		DrumRot.Roll -= 65535 / 6 ;
		SetBoneRotation('drum',DrumRot);	
	}

	// Modified stuff from Engine.Weapon
	if ((ClientState == WS_ReadyToFire || (ClientState == WS_None && Instigator.Weapon == self)) && ReloadState == RS_None)
    {
        if (anim == FireMode[0].FireAnim && HasAnim(FireMode[0].FireEndAnim)) // rocket hack
			SafePlayAnim(FireMode[0].FireEndAnim, FireMode[0].FireEndAnimRate, 0.0);
        else if (FireMode[1]!=None && anim== FireMode[1].FireAnim && HasAnim(FireMode[1].FireEndAnim))
            SafePlayAnim(FireMode[1].FireEndAnim, FireMode[1].FireEndAnimRate, 0.0);
        else if (MeleeState < MS_Held)
			bPreventReload=false;
		if (Channel == 0)
			PlayIdle();
    }
	// End stuff from Engine.Weapon

	// Start Shovel ended, move on to Shovel loop
	if (ReloadState == RS_StartShovel)
	{
		ReloadState = RS_Shovel;
		PlayShovelLoop();
		return;
	}
	// Shovel loop ended, start it again
	if (ReloadState == RS_PostShellIn)
	{
		if (MagAmmo >= default.MagAmmo || Ammo[0].AmmoAmount < 1 )
		{
			PlayShovelEnd();
			ReloadState = RS_EndShovel;
			return;
		}
		ReloadState = RS_Shovel;
		PlayShovelLoop();
		return;
	}
	// End of reloading, either cock the gun or go to idle
	if (ReloadState == RS_PostClipIn || ReloadState == RS_EndShovel)
	{
		if (bNeedCock && MagAmmo > 0)
			CommonCockGun();
		else
		{
			bNeedCock=false;
			ReloadState = RS_None;
			ReloadFinished();
			PlayIdle();
			ReAim(0.05);
		}
		return;
	}
	//Cock anim ended, goto idle
	if (ReloadState == RS_Cocking)
	{
		bNeedCock=false;
		ReloadState = RS_None;
		ReloadFinished();
		PlayIdle();
		ReAim(0.05);
	}
	
	if (ReloadState == RS_GearSwitch)
		ReloadState = RS_None;
}


function ServerSwitchWeaponMode (byte newMode)
{
	if (CurrentWeaponMode > 0 && FireMode[0].IsFiring())
		return;
	super.ServerSwitchWeaponMode (newMode);
	if (!Instigator.IsLocallyControlled())
		MGLPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
	ClientSwitchCannonMode (CurrentWeaponMode);
}
simulated function ClientSwitchCannonMode (byte newMode)
{
	MGLPrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
}

function UpdateGrenadeStatus(bool bDetonatable)
{
	bRemoteGrenadeOut = bDetonatable;
	
	if (bDetonatable)
		Skins[2]=MatArmed;
	else
		Skins[2]=MatDef;
		
	if (Role == ROLE_Authority && !Instigator.IsLocallyControlled())
		ClientUpdateGrenadeStatus(bDetonatable);
}

simulated function ClientUpdateGrenadeStatus(bool bDet)
{
	bRemoteGrenadeOut = bDet;
	if (bDet)
		Skins[2]=MatArmed;
	else
		Skins[2]=MatDef;
}

simulated function bool HasAmmo()
{
	if (bRemoteGrenadeOut)
		return true;
	return Super.HasAmmo();
}

simulated function float RateSelf()
{
	if (PlayerController(Instigator.Controller) != None && Ammo[0].AmmoAmount <=0 && MagAmmo <= 0)
		CurrentRating = Super.RateSelf() * 0.2;
	else
		return Super.RateSelf();
	return CurrentRating;
}
// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	local float Dist;
	local Vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	Dir = Instigator.Location - B.Enemy.Location;
	Dist = VSize(Dir);

	if (Dist > 400)
		return 0;
	if (Dist < FireMode[1].MaxRange() && FRand() > 0.3)
		return 1;
	if (vector(B.Enemy.Rotation) dot Normal(Dir) < 0.0 && (VSize(B.Enemy.Velocity) < 100 || Normal(B.Enemy.Velocity) dot Normal(B.Velocity) < 0.5))
		return 1;

	return Rand(2);
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

	// Enemy too far away
	if (Dist > 1000)
		Result -= (Dist-1000) / 2000;
	// If the enemy has a knife too, a gun looks better
	if (B.Enemy.Weapon != None && B.Enemy.Weapon.bMeleeWeapon)
		Result += 0.1 * B.Skill;
	// Sniper bad, very bad
	else if (B.Enemy.Weapon != None && B.Enemy.Weapon.bSniping && Dist > 500)
		Result -= 0.3;
	Result += 1 - Dist / 1000;

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()
{
	if (AIController(Instigator.Controller) == None)
		return 0.5;
	return AIController(Instigator.Controller).Skill / 7;
}

// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return -0.5;

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	Result = -1 * (B.Skill / 6);
	Result *= (1 - (Dist/4000));
    return FClamp(Result, -1.0, -0.3);
}
// End AI Stuff =====

simulated function Notify_BrassOut()
{
//	BFireMode[0].EjectBrass();
}


defaultproperties
{
     AIRating=0.600000
     AttachmentClass=class'BWBP_SKC_Fix.MGLAttachment'
     BallisticInventoryGroup=8
//     bCanSkipReload=True
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     IconMaterial=Texture'BWBP_SKC_TexExp.MGL.SmallIcon_MGL'
     BigIconMaterial=Texture'BWBP_SKC_TexExp.MGL.BigIcon_MGL'
     BobDamping=1.700000
     BringUpSound=(Sound=Sound'BallisticSounds2.M763.M763Pullout')
//     bShovelLoad=True
     bWT_Hazardous=True
     bWT_Projectile=True
     bWT_Splash=True
     ClipInFrame=0.325000
     //ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.Misc.GL-NadeInsert',Volume=1.700000)
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.M781.M781-Pump',Volume=2.300000)
	 ClipOutSound=(Sound=Sound'BallisticSounds2.BX5.BX5-SecOff',Volume=1.700000,Radius=32.000000)
     ClipInSound=(Sound=Sound'BallisticSounds2.BX5.BX5-SecOn',Volume=1.700000,Radius=32.000000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.G5InA',pic2=Texture'BallisticUI2.Crosshairs.NRP57InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=255,G=255,R=255,A=127),Color2=(B=0,G=255,R=255,A=192),StartSize1=113,StartSize2=244)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.375000,X2=1.000000,Y2=1.000000),SizeFactors=(X1=0.750000,X2=0.750000),MaxScale=8.000000)
     CurrentRating=0.600000
     CurrentWeaponMode=0
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     Description="VMDW-620c Conqueror Multiple Grenade Launcher||Manufacturer: Black & Wood|Primary: Single Grenade|Secondary: SUICIDE ALT FIRE!?||You are currently reading the description of a gun I haven't really finished yet! This gun is going to shoot grenades and stuff. It's made by waffle shake. It doesn't actually have a suicide alt fire. :("
     DrawScale=0.130000
     EndShovelAnim="ReloadEnd"
     FireModeClass(0)=Class'BWBP_SKC_Fix.MGLPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.MGLSecondaryFire'
     GunLength=48.000000
     IconCoords=(X2=127,Y2=35)
     InventoryGroup=7
     ItemName="VMDW-620c Conqueror MGL"
     JumpChaos=0.700000
     JumpOffSet=(Pitch=1000,Yaw=-3000)
     LightBrightness=150.000000
     LightEffect=LE_NonIncidence
     LightHue=25
     LightRadius=5.000000
     LightSaturation=150
     LightType=LT_Pulse
     MagAmmo=6
     MatArmed=Texture'BWBP_SKC_TexExp.MGL.MGL-Screen'
     MatDef=Texture'BWBP_SKC_TexExp.MGL.MGL-ScreenBase'
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.MGL_FP'
     PickupClass=Class'BWBP_SKC_Fix.MGLPickup'
     PlayerViewOffset=(X=5.000000,Y=-1.000000,Z=-7.000000)
     Priority=245
     PutDownSound=(Sound=Sound'BallisticSounds2.M763.M763Putaway')
     RecoilDeclineTime=0.900000
     RecoilMax=4096.000000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=-0.100000),(InVal=0.300000,OutVal=-0.200000),(InVal=1.000000,OutVal=-0.300000)))
     RecoilXFactor=0.400000
     RecoilYawFactor=0.000000
     RecoilYCurve=(Points=(,(InVal=0.300000,OutVal=0.500000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYFactor=0.400000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     SightOffset=(X=-30.000000,Y=12.45,Z=14.8500000)
     SightPivot=(Pitch=512)
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_TexExp.MGL.MGL-Main'
     Skins(2)=Texture'BWBP_SKC_TexExp.MGL.MGL-ScreenBase'
     Skins(3)=Shader'BWBP_SKC_TexExp.MGL.MGL-HolosightGlow'
     SpecialInfo(0)=(Info="300.0;30.0;0.5;60.0;0.0;1.0;0.0")
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     StartShovelAnim="ReloadStart"
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny',SkinNum=0)
     TeamSkins(1)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny',SkinNum=0)
     ViewAimFactor=0.450000
     ViewRecoilFactor=0.900000
     WeaponModes(0)=(ModeName="Timed",ModeID="WM_FullAuto")
     WeaponModes(1)=(ModeName="Impact",ModeID="WM_FullAuto")
     WeaponModes(2)=(ModeName="4-Round Burst",bUnavailable=True)
}
