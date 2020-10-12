//=============================================================================
// MRT6Shotgun.
//
// A very short, powerful and fast double barreled sidearm like shotgun. It has
// A very low range and ridiculous spread, but is devestaing very close up and
// reloads fast. Seondary fires only one barrel.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SawnOffShotgun extends BallisticHandGun;

var bool bLeftLoaded;
var bool bRightLoaded;

var actor ReloadSteam;
var actor ReloadSteam2;


var() name				LastShellBone;		// Name of the right shell.
var   bool				bLastShell;			// Checks if only one shell is left
var   bool				bNowEmpty;			// Checks if it should play modified animation.


simulated event PostNetBeginPlay()
{
	if (class'BallisticReplicationInfo'.default.bNoReloading)
	{
		FireMode[0].FireRate=2.0;
		FireMode[1].FireRate=1.0;
	}
	super.PostNetBeginPlay();
}



simulated function Notify_CoachShellDown()
{
	local vector start;

	if (level.NetMode != NM_DedicatedServer)
	{
		Start = Instigator.Location + Instigator.EyePosition() + class'BUtil'.static.AlignedOffset(Instigator.GetViewRotation(), vect(5,10,-5));
		if (MagAmmo == 1)
		{
			Spawn(class'Brass_Shotgun', self,, Start, Instigator.GetViewRotation() + rot(8192,0,0));
		}
		else
		{
			Spawn(class'Brass_Shotgun', self,, Start, Instigator.GetViewRotation() + rot(8192,0,0));
			Spawn(class'Brass_Shotgun', self,, Start, Instigator.GetViewRotation() + rot(8192,0,0));
		}
	}

	bLastShell = (Ammo[0].AmmoAmount == 1);
	if (bLastShell && MagAmmo != 1)
	{
		SetBoneScale(1, 0.0, LastShellBone);
		bNowEmpty=true;
	}
	else
		SetBoneScale(1, 1.0, LastShellBone);

}


// Play different reload starting anims depending on the situation
simulated function PlayReload()
{
		if (MagAmmo == 1 && !bNowEmpty)		// One shell fired and both shells in
		{
			PlayAnim('ReloadSingle', ReloadAnimRate, , 0.30);
			bLeftLoaded=true;
		}
		else					// Both shells fired
		{
			PlayAnim('Reload', ReloadAnimRate, , 0.25);
			bLeftLoaded=true;
			bRightLoaded=true;
		}
}



simulated function Notify_CoachSteam()
{
	if (ReloadSteam != None)
	{
		ReloadSteam.Destroy();
		ReloadSteam=None;
	}
	if (ReloadSteam2 != None)
	{
		ReloadSteam2.Destroy();
		ReloadSteam2=None;
	}
	if (MagAmmo == 1)
	{
		class'BUtil'.static.InitMuzzleFlash (ReloadSteam, class'CoachSteam', DrawScale, self, 'EjectorL');
	}
	else if (MagAmmo == 0)
	{
		class'BUtil'.static.InitMuzzleFlash (ReloadSteam2, class'CoachSteam', DrawScale, self, 'EjectorR');
		class'BUtil'.static.InitMuzzleFlash (ReloadSteam, class'CoachSteam', DrawScale, self, 'EjectorL');
	}

	if (bNowEmpty)
	{
		SetBoneScale(1, 0.0, LastShellBone);
		bNowEmpty=False;
	}


	ReloadSteam.SetRelativeRotation(rot(0,32768,0));
	ReloadSteam2.SetRelativeRotation(rot(0,32768,0));
}

simulated function Destroyed ()
{
	if (ReloadSteam != None)
		ReloadSteam.Destroy();
	if (ReloadSteam2 != None)
		ReloadSteam2.Destroy();

	super.Destroyed();
}


simulated function SetDualMode (bool bDualMode)
{
	if (bDualMode)
	{
		if (Instigator.IsLocallyControlled() && SightingState == SS_Active)
			StopScopeView();
		SetBoneScale(8, 0.0, SupportHandBone);
		if (AIController(Instigator.Controller) == None)
			bUseSpecialAim = true;
		if (bAimDisabled)
			return;
//		AimAdjustTime		*= 1.0;
		AimSpread			*= 1.4;
		ViewAimFactor		*= 0.6;
		ViewRecoilFactor	*= 0.75;
		ChaosDeclineTime	*= 1.2;
		ChaosTurnThreshold	*= 0.8;
		ChaosSpeedThreshold	*= 0.8;
		ChaosAimSpread		*= 1.2;
		RecoilPitchFactor	*= 1.2;
		RecoilYawFactor		*= 1.2;
		RecoilXFactor		*= 1.2;
		RecoilYFactor		*= 1.2;
//		RecoilMax			*= 1.0;
		RecoilDeclineTime	*= 1.2;
     		PutDownAnim='PrepSwipe';
		ReloadAnimRate		*= 1.2;
		
	}
	else
	{
		SetBoneScale(8, 1.0, SupportHandBone);
		bUseSpecialAim = false;
		if (bAimDisabled)
			return;
//		AimAdjustTime		= default.AimAdjustTime;
		AimSpread 			= default.AimSpread;
		ViewAimFactor		= default.ViewAimFactor;
		ViewRecoilFactor	= default.ViewRecoilFactor;
		ChaosDeclineTime	= default.ChaosDeclineTime;
		ChaosTurnThreshold	= default.ChaosTurnThreshold;
		ChaosSpeedThreshold	= default.ChaosSpeedThreshold;
		ChaosAimSpread		= default.ChaosAimSpread;
		ChaosAimSpread 		*= BCRepClass.default.AccuracyScale;
		RecoilPitchFactor	= default.RecoilPitchFactor;
		RecoilYawFactor		= default.RecoilYawFactor;
		RecoilXFactor		= default.RecoilXFactor;
		RecoilYFactor		= default.RecoilYFactor;
//		RecoilMax			= default.RecoilMax;
		RecoilDeclineTime	= default.RecoilDeclineTime;
     		PutDownAnim='Putaway';
		ReloadAnimRate		= default.ReloadAnimRate;
	}
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

	if (Dist > 700)
		return 1;
	else if (Dist < 300)
		return 0;
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

	Result = Super.GetAIRating();
	// Enemy too far away
	if (Dist > 2000)
		Result = 0.1;
	else if (Dist < 500)
		Result += 0.06 * B.Skill;
	else if (Dist > 700)
		Result -= (Dist-700) / 1400;
	// If the enemy has a knife, this gun is handy
	if (B.Enemy.Weapon != None && B.Enemy.Weapon.bMeleeWeapon)
		Result += 0.1 * B.Skill;
	// Sniper bad, very bad
	else if (B.Enemy.Weapon != None && B.Enemy.Weapon.bSniping && Dist > 500)
		Result -= 0.4;

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


//Check Sounds and damage types.

defaultproperties
{
     LastShellBone="ShellR"
     PlayerSpeedFactor=1.000000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_Tex.SawnOff.BigIcon_Sawn'
     BallisticInventoryGroup=3
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     InventorySize=20
     bWT_Shotgun=True
     SpecialInfo(0)=(Info="120.0;8.0;0.3;40.0;0.0;0.35;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M290.M290Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M290.M290Putaway')
     MagAmmo=2
     IdleAnimRate=0.100000
     CockAnimRate=0.700000
     ClipInFrame=0.800000
     bNonCocking=True
     bAltTriggerReload=True
     WeaponModes(0)=(ModeName="Single Fire")
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     SightPivot=(Pitch=1024,Yaw=32)
     SightOffset=(X=-10.000000,Y=-2.000000,Z=40.000000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Misc1',Pic2=Texture'BallisticUI2.Crosshairs.M806OutA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(G=255,A=101),Color2=(G=0,R=0),StartSize1=92,StartSize2=82)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.375000,X2=1.000000,Y2=1.000000),MaxScale=3.000000)
     CrosshairChaosFactor=0.600000
     GunLength=24.000000
     CrouchAimFactor=0.850000
     SightAimFactor=0.650000
     JumpOffSet=(Pitch=200,Yaw=-500)
     JumpChaos=1.000000
     AimSpread=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000))
     ViewAimFactor=0.150000
     ViewRecoilFactor=0.900000
     ChaosAimSpread=(X=(Min=-256.000000,Max=256.000000),Y=(Min=-512.000000,Max=512.000000))
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=-0.100000),(InVal=0.300000,OutVal=-0.200000),(InVal=1.000000,OutVal=-0.300000)))
     RecoilYCurve=(Points=(,(InVal=0.300000,OutVal=0.500000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.000000
     RecoilXFactor=0.200000
     RecoilYFactor=0.200000
     RecoilMax=8192.000000
     RecoilDeclineTime=0.900000
     FireModeClass(0)=Class'BWBP_SKC_Fix.SawnOffPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.SawnOffSecondaryFire'
     AIRating=0.600000
     CurrentRating=0.600000
     Description="Redwood Sawn-Off Shotgun||Manufacturer: Redwood Firearms|Primary: Double Barrel Shot|Secondary: Single Barrel Shot||The layers of caked blood and dirt are the only indication of the passing of time on this ancient weapon, once used by the ring leader of a now long gone gang in the old west. Having cut off most of the barrel, the owner found it much easier to conceal and found he could carry a second one, inspiring fear and false loyalty in those around him. Though he's gone, his weapon remains as formidable as it was then, firing 12 gauge buckshot rounds, either in pairs or single shot. Without most of its barrel, the ease of use due to being much lighter is readily apparent, even in the hands of an amateur. Still packs one hell of a kick."
     DisplayFOV=55.000000
     Priority=38
     PutDownAnimRate=1.400000
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=7
     PickupClass=Class'BWBP_SKC_Fix.SawnOffPickup'
     PlayerViewOffset=(X=0.000000,Y=4.000000,Z=-5.000000)
     BobDamping=1.700000
     AttachmentClass=Class'BWBP_SKC_Fix.SawnOffAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.SawnOff.SmallIcon_Sawn'
     IconCoords=(X2=127,Y2=40)
     ItemName="Redwood Sawn-Off"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=25
     LightSaturation=150
     LightBrightness=180.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.SawnOff_FP'
     DrawScale=1.150000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
}
