//=============================================================================
// M290Shotgun.
//
// Big double barreled shotgun. Primary fires both barrels at once, secondary
// fires them seperately. Slower than M763 with less range and uses up ammo
// quicker, but has tons of damage at close range.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class CoachGun extends BallisticWeapon;

var bool bLowAmmo;
var byte OldWeaponMode;
var actor ReloadSteam;
var actor ReloadSteam2;

var() Material          MatGreenShell;
var() Material          MatBlackShell;
var() name		ShellTipBone1;		// Super Slug 1.
var() name		ShellTipBone2;		// Super Slug 2
var() name		ShellTipBone3;		// Spare Super Slug 1.
var() name		ShellTipBone4;		// Spare Super Slug 2

var() name				LastShellBone;		// Name of the right shell.
var   bool				bLastShell;			// Checks if only one shell is left
var   bool				bNowEmpty;			// Checks if it should play modified animation.
var   bool				bSlugMode;


replication
{
	reliable if(Role == ROLE_Authority)
		ClientSwitchCannonMode;
}

exec simulated function WeaponSpecial(optional byte i)
{
//	ServerWeaponSpecial(i);
}


function ServerWeaponSpecial(optional byte i)
{
	if (bSlugMode)
	{
		bSlugMode=False;
     		RecoilYawFactor=default.RecoilYawFactor;
     		RecoilXFactor=default.RecoilXFactor;
     		RecoilYFactor=default.RecoilYFactor;
     		RecoilMax=default.RecoilMax;
     		RecoilDeclineTime=default.RecoilDeclineTime;
     		ViewAimFactor=default.ViewAimFactor;
     		ViewRecoilFactor=default.ViewRecoilFactor;
	}
	else
	{
		bSlugMode=True;
     		RecoilYawFactor=0.000000;
     		RecoilXFactor=1.000000;
     		RecoilYFactor=1.000000;
     		RecoilMax=9192.000000;
     		RecoilDeclineTime=2.000000;
     		ViewAimFactor=0.150000;
     		ViewRecoilFactor=0.300000;
	}
	if (!Instigator.IsLocallyControlled())
		CoachGunPrimaryFire(FireMode[0]).SwitchCannonMode(bSlugMode);
	ClientSwitchCannonMode (bSlugMode);
}

simulated function ClientSwitchCannonMode (bool bSlug)
{
	if(ReloadState > RS_None || !HasAmmo())
		return;
	PlayReload();
	if (bSlug)
	{
		SetBoneScale (2, 0.0, ShellTipBone1);
		SetBoneScale (3, 0.0, ShellTipBone2);
		SetBoneScale (4, 1.0, ShellTipBone3);
		SetBoneScale (5, 1.0, ShellTipBone4);
		Skins[2]=MatGreenShell;
		Skins[3]=MatBlackShell;
	
	}
	else
	{
		SetBoneScale (2, 1.0, ShellTipBone1);
		SetBoneScale (3, 1.0, ShellTipBone2);
		SetBoneScale (4, 0.0, ShellTipBone3);
		SetBoneScale (5, 0.0, ShellTipBone4);
		Skins[2]=MatBlackShell;
		Skins[3]=MatGreenShell;
	
	}
	CoachGunPrimaryFire(FireMode[0]).SwitchCannonMode(bSlug);
}

simulated function Notify_CoachShellDown()
{
	local vector start;

	if (level.NetMode != NM_DedicatedServer)
	{
		Start = Instigator.Location + Instigator.EyePosition() + class'BUtil'.static.AlignedOffset(Instigator.GetViewRotation(), vect(5,10,-5));
		if (MagAmmo == 1)
		{
			Spawn(class'Brass_MRS138Shotgun', self,, Start, Instigator.GetViewRotation() + rot(8192,0,0));
		}
		else
		{
			Spawn(class'Brass_MRS138Shotgun', self,, Start, Instigator.GetViewRotation() + rot(8192,0,0));
			Spawn(class'Brass_MRS138Shotgun', self,, Start, Instigator.GetViewRotation() + rot(8192,0,0));
		}
	}
	if (bSlugMode)
	{
		Skins[2]=MatBlackShell;
		Skins[3]=MatBlackShell;
		SetBoneScale (2, 1.0, ShellTipBone1);
		SetBoneScale (3, 1.0, ShellTipBone2);
		SetBoneScale (4, 1.0, ShellTipBone3);
		SetBoneScale (5, 1.0, ShellTipBone4);
	}
	else
	{
		Skins[2]=MatGreenShell;
		Skins[3]=MatGreenShell;
		SetBoneScale (2, 0.0, ShellTipBone1);
		SetBoneScale (3, 0.0, ShellTipBone2);
		SetBoneScale (4, 0.0, ShellTipBone3);
		SetBoneScale (5, 0.0, ShellTipBone4);
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
			PlayAnim('ReloadSingle', CockAnimRate, , 0.25);
		else					// Both shells fired
			PlayAnim('Reload', ReloadAnimRate, , 0.25);
}


simulated function BringUp(optional Weapon PrevWeapon)
{
	if (bSlugMode)
	{
		Skins[2]=MatBlackShell;
		Skins[3]=MatBlackShell;
		SetBoneScale (2, 1.0, ShellTipBone1);
		SetBoneScale (3, 1.0, ShellTipBone2);
		SetBoneScale (4, 1.0, ShellTipBone3);
		SetBoneScale (5, 1.0, ShellTipBone4);
     		RecoilYawFactor=0.000000;
     		RecoilXFactor=1.000000;
     		RecoilYFactor=1.000000;
     		RecoilMax=9192.000000;
     		RecoilDeclineTime=2.000000;
     		ViewAimFactor=0.150000;
     		ViewRecoilFactor=0.300000;
	}
	else
	{
		Skins[2]=MatGreenShell;
		Skins[3]=MatGreenShell;
		SetBoneScale (2, 0.0, ShellTipBone1);
		SetBoneScale (3, 0.0, ShellTipBone2);
		SetBoneScale (4, 0.0, ShellTipBone3);
		SetBoneScale (5, 0.0, ShellTipBone4);
     		RecoilYawFactor=default.RecoilYawFactor;
     		RecoilXFactor=default.RecoilXFactor;
     		RecoilYFactor=default.RecoilYFactor;
     		RecoilMax=default.RecoilMax;
     		RecoilDeclineTime=default.RecoilDeclineTime;
     		ViewAimFactor=default.ViewAimFactor;
     		ViewRecoilFactor=default.ViewRecoilFactor;
	}
	Super.BringUp(PrevWeapon);

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
		class'BUtil'.static.InitMuzzleFlash (ReloadSteam, class'CoachSteam', DrawScale, self, 'Ejector');
	}
	else if (MagAmmo == 0)
	{
		class'BUtil'.static.InitMuzzleFlash (ReloadSteam2, class'CoachSteam', DrawScale, self, 'Ejector');
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


simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);

	if (CurrentWeaponMode != OldWeaponMode)
	{
		if (CurrentWeaponMode == 1 && !bSlugMode)
			FireMode[0].FireRate = 0.08;
		else
			FireMode[0].FireRate = FireMode[0].default.FireRate;
		OldWeaponMode = CurrentWeaponMode;
	}
	if (MagAmmo == 1)
		bLowAmmo=True;
	else
		bLowAmmo=False;

}


simulated function Destroyed ()
{
	if (ReloadSteam != None)
		ReloadSteam.Destroy();
	if (ReloadSteam2 != None)
		ReloadSteam2.Destroy();

	super.Destroyed(); 
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
	if (Dist > 750)
		Result = 0.1;
	else if (Dist < 300)
		Result += 0.06 * B.Skill;
	else if (Dist > 500)
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


simulated function TickFireCounter (float DT)
{
    if (CurrentWeaponMode == 0 && class'BallisticReplicationInfo'.default.bNoReloading)
    {
        if (!IsFiring() && FireCount > 0 && FireMode[0].NextFireTime - level.TimeSeconds < -0.5)
            FireCount = 0;
    }
    else if (CurrentWeaponMode == 1 && class'BallisticReplicationInfo'.default.bNoReloading)
    {
        if (!IsFiring() && FireCount > 0 && FireMode[0].NextFireTime - level.TimeSeconds < -1.0)
            FireCount = 0;
    }
    else
        super.TickFireCounter(DT);
}

//Check Sounds and damage types.

defaultproperties
{
     LastShellBone="ShellR"
     PlayerSpeedFactor=1.100000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_Tex.CoachGun.BigIcon_Coach'
     BallisticInventoryGroup=3
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Shotgun=True
     SpecialInfo(0)=(Info="160.0;10.0;0.3;40.0;0.0;1.0;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M290.M290Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M290.M290Putaway')
     PutDownAnimRate=0.900000
     PutDownTime=1.000000

     MatGreenShell=Texture'BWBP_SKC_Tex.CoachGun.DBL-Misc'
     MatBlackShell=Texture'BWBP_SKC_Tex.CoachGun.DBL-MiscBlack'
     ShellTipBone1="ShellLSuper"
     ShellTipBone2="ShellRSuper"
     ShellTipBone3="SpareShellLSuper"
     ShellTipBone4="SpareShellRSuper"

     MagAmmo=2
     CockAnimRate=0.700000
     ClipInFrame=0.800000
     bNonCocking=True
     WeaponModes(0)=(ModeName="Single Fire")
     WeaponModes(1)=(ModeName="Double Fire",Value=2.000000)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=1
     SightPivot=(Pitch=256)
//     SightOffset=(X=-40.000000,Y=12.000000,Z=40.000000)
     SightOffset=(X=-40.000000,Y=9.500000,Z=32.000000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Misc1',Pic2=Texture'BallisticUI2.Crosshairs.M806OutA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(G=255,A=101),Color2=(G=0,R=0),StartSize1=92,StartSize2=82)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.375000,X2=1.000000,Y2=1.000000),MaxScale=3.000000)
     CrosshairChaosFactor=0.600000
     GunLength=60.000000
     LongGunPivot=(Pitch=6000,Roll=2048,Yaw=-9000)
     LongGunOffset=(X=-30.000000,Y=11.000000,Z=-20.000000)
     CrouchAimFactor=0.850000
     SightAimFactor=0.650000
     JumpOffSet=(Pitch=200,Yaw=-500)
     JumpChaos=1.000000
     AimSpread=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000))
     ViewAimFactor=0.150000
     ViewRecoilFactor=0.900000
     ChaosAimSpread=(X=(Min=-768.000000,Max=768.000000),Y=(Min=-768.000000,Max=768.000000))
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=-0.100000),(InVal=0.300000,OutVal=-0.200000),(InVal=1.000000,OutVal=-0.300000)))
     RecoilYCurve=(Points=(,(InVal=0.300000,OutVal=0.500000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.000000
     RecoilXFactor=0.200000
     RecoilYFactor=0.200000
//     RecoilMax=4096.000000
     RecoilMax=9192.000000
     RecoilDeclineTime=0.900000
     FireModeClass(0)=Class'BWBP_SKC_Fix.CoachGunPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.CoachGunSecondaryFire'
     AIRating=0.600000
     CurrentRating=0.600000
     Description="Redwood Super-10 Double Barreled Shotgun||Manufacturer: Redwood Firearms|Primary: Single Shot|Secondary: Melee Swipe||This primitive artifact has managed to survive the passage of time. Behind it trails a brutal story of bloodshed and sacrifice. For every scar, a life taken; every gouge, a life saved."
     DisplayFOV=55.000000
     Priority=38
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=18
     PickupClass=Class'BWBP_SKC_Fix.CoachGunPickup'
//     PlayerViewOffset=(X=-24.000000,Y=20.000000,Z=-30.000000)
     PlayerViewOffset=(X=0.000000,Y=20.000000,Z=-30.000000)
     BobDamping=1.700000
     AttachmentClass=Class'BWBP_SKC_Fix.CoachGunAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.CoachGun.SmallIcon_Coach'
     IconCoords=(X2=127,Y2=40)
     ItemName="Redwood Super-10"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=25
     LightSaturation=150
     LightBrightness=180.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.DoubleShotgun_FP'
//     DrawScale=1.250000
     DrawScale=1.000000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_Tex.CoachGun.DBL-Main'
     Skins(2)=Texture'BWBP_SKC_Tex.CoachGun.DBL-Misc'
     Skins(3)=Texture'BWBP_SKC_Tex.CoachGun.DBL-Misc'
}
