//=============================================================================
// SKASShotgun.
//
// Super weapon shotgun. Fully automatic 10 gauge. Multiple fire modes.
// Camo system enabled.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SKASShotgun extends BallisticCamoWeapon;

var float		lastModeChangeTime;


var() sound      	QuickCockSound;
var() sound		UltraDrawSound;       	//56k MODEM ACTION.

var()     float Heat;
var()     float CoolRate;

replication
{
	reliable if(Role == ROLE_Authority)
		ClientSwitchCannonMode;
}



static function class<Pickup> RecommendAmmoPickup(int Mode)
{
	return class'AP_SKASDrum';
}

function ServerSwitchWeaponMode (byte NewMode)
{
	if (CurrentWeaponMode > 0 && FireMode[0].IsFiring())
		return;
	super.ServerSwitchWeaponMode(NewMode);
	if (!Instigator.IsLocallyControlled())
		SKASPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
	ClientSwitchCannonMode (CurrentWeaponMode);
}
simulated function ClientSwitchCannonMode (byte newMode)
{
	SKASPrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
	if (CamoIndex == 5)
		SKASSecondaryFire(FireMode[1]).SwitchCannonMode(newMode);
}
simulated function AdjustCamoProperties(optional int Index)
{
	local float f;
		f = FRand();
		if ((Index == -1 && f > 0.99) || Index == 6) //Blue
		{
			Skins[1]=CamoMaterials[6];
			ReloadAnimRate=2;
			CockAnimRate=2;
			WeaponModes[0].bUnavailable=true;
			WeaponModes[1].bUnavailable=true;
			WeaponModes[2].bUnavailable=true;
			WeaponModes[3].bUnavailable=true;
			WeaponModes[4].bUnavailable=true;
			WeaponModes[5].bUnavailable=true;
			WeaponModes[6].bUnavailable=false;
     			RecoilXFactor		=0.001;
     			RecoilYFactor		=0.001;
     			RecoilYawFactor		=0.001;
     			RecoilPitchFactor	=0.001;
			RecoilDeclineDelay=0;
			RecoilDeclineTime=0.2;
			ChaosDeclineTime=0.2;
     			CockSound.Sound=QuickCockSound;
     			BringUpSound.Sound=UltraDrawSound;
     			CurrentWeaponMode=6;
			super.ServerSwitchWeaponMode(6);
			if (!Instigator.IsLocallyControlled())
			{
				SKASPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
				SKASSecondaryFire(FireMode[1]).SwitchCannonMode(CurrentWeaponMode);
			}
			ClientSwitchCannonMode (CurrentWeaponMode);
			CamoIndex=6;
		}
		else if ((Index == -1 && f > 0.98) || Index == 5) //Red
		{
			Skins[1]=CamoMaterials[5];
			ReloadAnimRate=2;
			CockAnimRate=2;
			WeaponModes[0].bUnavailable=true;
			WeaponModes[1].bUnavailable=true;
			WeaponModes[2].bUnavailable=true;
			WeaponModes[3].bUnavailable=true;
			WeaponModes[4].bUnavailable=true;
			WeaponModes[5].bUnavailable=false;
			WeaponModes[6].bUnavailable=true;
     			RecoilXFactor		=0.1;
     			RecoilYFactor		=0.1;
     			RecoilYawFactor		=0.4;
     			RecoilPitchFactor	=0.4;
     			CockSound.Sound=QuickCockSound;
     			BringUpSound.Sound=UltraDrawSound;
     			CurrentWeaponMode=5;
			super.ServerSwitchWeaponMode(5);
			if (!Instigator.IsLocallyControlled())
			{
				SKASPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
				SKASSecondaryFire(FireMode[1]).SwitchCannonMode(CurrentWeaponMode);
			}
			ClientSwitchCannonMode (CurrentWeaponMode);
			CamoIndex=5;
		}
		else if ((Index == -1 && f > 0.90) || Index == 4) //German
		{
			BallisticInstantFire(FireMode[0]).FireRate=0.22;
			Skins[1]=CamoMaterials[4];
			CamoIndex=4;
		}
		else if ((Index == -1 && f > 0.80) || Index == 3)
		{
			Skins[1]=CamoMaterials[3];
			CamoIndex=3;
		}
		else if ((Index == -1 && f > 0.70) || Index == 2)
		{
			Skins[1]=CamoMaterials[2];
			CamoIndex=2;
		}
		else if ((Index == -1 && f > 0.60) || Index == 1)
		{	
			Skins[1]=CamoMaterials[1];
			CamoIndex=1;
		}
		else
		{
			Skins[1]=CamoMaterials[0];
			CamoIndex=0;
		}

}


simulated function BringUp(optional Weapon PrevWeapon)
{
	super.BringUp(PrevWeapon);

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = true;

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

simulated function Notify_ManualBrassOut()
{
	BFireMode[0].EjectBrass();
}

simulated function float ChargeBar()
{
    return FMin((Heat + SKASSecondaryFire(Firemode[1]).RailPower), 1);
}


simulated event WeaponTick(float DT)
{

	Heat = FMax(0, Heat - CoolRate*DT);
	super.WeaponTick(DT);


		if (CurrentWeaponMode == 1)
		{
     			RecoilXFactor		=1.3;
     			RecoilYFactor		=1.2;
     			RecoilYawFactor		=0.8;
     			RecoilPitchFactor	=0.8;
		}
		else
		{
     			RecoilXFactor		= default.RecoilXFactor;
     			RecoilYFactor		= default.RecoilYFactor;
     			RecoilYawFactor		= default.RecoilYawFactor;
     			RecoilPitchFactor	= default.RecoilPitchFactor;
		}

}


defaultproperties
{
     CoolRate=0.700000
     bShowChargingBar=True
     QuickCockSound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-Cock'
     UltraDrawSound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-UltraDraw'

     CamoMaterials[6]=Shader'BWBP_SKC_Tex.SKAS.SKAS-BlueGlow' //Blue
     CamoMaterials[5]=Shader'BWBP_SKC_Tex.SKAS.SKAS-Charged' //Red
     CamoMaterials[4]=Texture'BWBP_SKC_Tex.SKAS.SKAS-CamoG' //German
     CamoMaterials[3]=Texture'BWBP_SKC_Tex.SKAS.SKAS-CamoD' //Desert
     CamoMaterials[2]=Texture'BWBP_SKC_Tex.SKAS.SKAS-CamoT' //Tiger?
     CamoMaterials[1]=Texture'BWBP_SKC_Tex.SKAS.SKAS-CamoU' //Urban
     CamoMaterials[0]=Texture'BWBP_SKC_Tex.SKAS.SKASShotgun'//Default

     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_Tex.SKAS.BigIcon_SKAS'
     BallisticInventoryGroup=3
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Shotgun=True
     bWT_Machinegun=True
     SpecialInfo(0)=(Info="360.0;30.0;0.9;120.0;0.0;3.0;0.0")
     BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-Select')
     PutDownSound=(Sound=Sound'BallisticSounds2.M763.M763Putaway')
     PutDownTime=0.800000
     MagAmmo=36
     InventorySize=25
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-CockLong',Volume=1.000000)
     ReloadAnim="Reload"
     ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-ClipIn',Volume=2.000000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-ClipOut1',Volume=2.000000)
     ClipInFrame=0.650000
     IdleAnimRate=0.100000
     bCockOnEmpty=True
     bNeedCock=True
     WeaponModes(0)=(ModeName="Semi-Automatic",ModeID="WM_SemiAuto",Value=1.000000)
     WeaponModes(1)=(ModeName="Manual",ModeID="WM_SemiAuto",Value=1.000000)
     WeaponModes(2)=(ModeName="Automatic",ModeID="WM_FullAuto")
     WeaponModes(3)=(ModeName="Suppression",ModeID="WM_FullAuto",bUnavailable=True)
     WeaponModes(4)=(ModeName="Semi-Auto",ModeID="WM_SemiAuto",Value=1.000000,bUnavailable=True)
     WeaponModes(5)=(ModeName="1110011",ModeID="WM_FullAuto",bUnavailable=True)
     WeaponModes(6)=(ModeName="XR4 System",ModeID="WM_FullAuto",bUnavailable=True)
     CurrentWeaponMode=2
     SightPivot=(Pitch=512,Roll=-1024,Yaw=-512)
     SightOffset=(X=-10.000000,Y=2.000000,Z=14.000000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M763OutA',Pic2=Texture'BallisticUI2.Crosshairs.Misc6',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=255,G=255,R=255,A=192),Color2=(B=0,G=0,R=255,A=98),StartSize1=113,StartSize2=120)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.375000,X2=1.000000,Y2=1.000000),SizeFactors=(X1=0.750000,X2=0.750000),MaxScale=8.000000)
     GunLength=32.000000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     JumpOffSet=(Pitch=1000,Yaw=-3000)
     JumpChaos=0.700000
     ViewAimFactor=0.350000
     ViewRecoilFactor=0.900000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=-0.100000),(InVal=0.300000,OutVal=-0.200000),(InVal=1.000000,OutVal=-0.300000)))
     RecoilYCurve=(Points=(,(InVal=0.300000,OutVal=0.500000),(InVal=1.000000,OutVal=1.000000)))
     RecoilXFactor=1.000000
     RecoilYFactor=1.000000
     RecoilYawFactor=0.00000
     RecoilPitchFactor=0.000000
     RecoilMax=2048.000000
     ChaosAimSpread=(X=(Min=-1024.000000,Max=1024.000000),Y=(Min=-1024.000000,Max=1024.000000))
     AimSpread=(X=(Min=-512.000000,Max=512.000000),Y=(Min=-512.000000,Max=512.000000))
     RecoilDeclineDelay=0.200000
     RecoilDeclineTime=1.000000
     FireModeClass(0)=Class'BWBP_SKC_Fix.SKASPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.SKASSecondaryFire'
     AIRating=0.600000
     CurrentRating=0.600000
     Description="SKAS-21 Super Shotgun||Manufacturer: UTC Defense Tech|Primary: Variable Fire Buckshot|Secondary: Tri-Barrel Blast||The SKAS-21 Super Assault Shotgun is a brand-new, state-of-the-art weapons system developed by UTC Defense Tech. It has been nicknamed 'The Decimator' for its ability to sweep entire streets clean of hostiles in seconds. Built to provide sustained suppressive fire, the fully automatic SKAS fires from an electrically assisted, rotating triple-barrel system. An electric motor housed in the stock operates various internal functions, making this gun one of the few gas-operated/gatling hybrids. Non-ambidexterous models can disable this system for use with low-impulse ammunition, however use with standard ammunition is not recommended due to the resulting overpressurization. This heavy duty shotgun fires 10 gauge ammunition from a 18 round U drum by default, however 12 gauge (SKAS/M-21), grenade launching (SRAC/G-21), and box fed (SAS/CE-3) variants exist as well. Handle with care, as this is one expensive gun. This particular variant has a smart choke enabled on manual fire for increased accuracy."
     Priority=245
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=7
     PickupClass=Class'BWBP_SKC_Fix.SKASPickup'
//     PlayerViewOffset=(X=-4.000000,Y=0.000000,Z=-8.000000)
     PlayerViewOffset=(X=-4.000000,Y=1.000000,Z=-10.000000)
     BobDamping=1.700000
     AttachmentClass=Class'BWBP_SKC_Fix.SKASAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.SKAS.SmallIcon_SKAS'
     IconCoords=(X2=127,Y2=30)
     ItemName="SKAS-21 Super Shotgun"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=25
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.SKASShotgunFP'
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_Tex.SKAS.SKASShotgun'
     DrawScale=0.260000
}
