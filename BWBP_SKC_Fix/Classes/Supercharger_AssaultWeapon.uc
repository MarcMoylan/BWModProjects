//=============================================================================
// CYLO Mk2 UAW
//
// The upgraded version of the CYLO Urban Assault Rifle. Fires incendiary rounds instead of the normals.
// Has blade as secondary.
// The gun can overheat with use and will jam and damage the player if heat is too high.
// When the gun is overheated it does more damage.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Supercharger_AssaultWeapon extends BallisticWeapon;



var   Supercharger_ChargeControl	ChargeControl;

var float		HeatLevel;			// Current Heat level, duh...
var bool		bCriticalHeat;		// Heat is at critical levels
var() Sound		OverHeatSound;		// Sound to play when it overheats
var() Sound		HighHeatSound;		// Sound to play when heat is dangerous
var() Sound		MedHeatSound;		// Sound to play when heat is moderate
var Actor 			GlowFX;		// Code from the BFG.
var float		NextChangeMindTime;	// For AI

replication
{
	reliable if (Role==ROLE_Authority)
		ChargeControl;
}


simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = true;
}
simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		return true;
	}

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = false;

	return false;
}


simulated function PostNetBeginPlay()
{
	local Supercharger_ChargeControl FC;

	super.PostNetBeginPlay();
	if (Role == ROLE_Authority && ChargeControl == None)
	{
		foreach DynamicActors (class'Supercharger_ChargeControl', FC)
		{
			ChargeControl = FC;
			return;
		}
		ChargeControl = Spawn(class'Supercharger_ChargeControl', None);
	}
}


function Supercharger_ChargeControl GetChargeControl()
{
	return ChargeControl;
}


function ServerSwitchWeaponMode (byte newMode)
{
	if (CurrentWeaponMode > 0 && (FireMode[0].IsFiring() || FireMode[1].IsFiring()) )
		return;
	super.ServerSwitchWeaponMode (newMode);
	if (!Instigator.IsLocallyControlled())
	{
		Supercharger_PrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
		Supercharger_SecondaryFire(FireMode[1]).SwitchCannonMode(CurrentWeaponMode);
	}
	ClientSwitchCannonMode (CurrentWeaponMode);
}
simulated function ClientSwitchCannonMode (byte newMode)
{
	Supercharger_PrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
	Supercharger_SecondaryFire(FireMode[1]).SwitchCannonMode(CurrentWeaponMode);
}

simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);


		if (CurrentWeaponMode == 1)
		{
     			RecoilXFactor=0.200000;
     			RecoilYFactor=0.350000;
			BallisticInstantFire(FireMode[0]).AmmoPerFire = 2;
			BallisticInstantFire(FireMode[1]).AmmoPerFire = 25;
			Supercharger_Attachment(ThirdPersonActor).bPlasmaMode=True;
		}
		else
		{
     			RecoilXFactor		= default.RecoilXFactor;
     			RecoilYFactor		= default.RecoilYFactor;
			BallisticInstantFire(FireMode[0]).AmmoPerFire = 1;
			BallisticInstantFire(FireMode[1]).AmmoPerFire = 10;
			Supercharger_Attachment(ThirdPersonActor).bPlasmaMode=False;
		}

}

// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	local float Result, Height, Dist, VDot;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (HeatLevel > 5)
		Result -= 0.1 * B.Skill * ((HeatLevel-5)/5);
	if (AmmoAmount(1) < 1)
		return 0;
	else if (MagAmmo < 1)
		return 1;

	if (NextChangeMindTime > level.TimeSeconds)
		return 0;


	Dist = VSize(B.Enemy.Location - Instigator.Location);
	Height = B.Enemy.Location.Z - Instigator.Location.Z;
	VDot = Normal(B.Enemy.Velocity) Dot Normal(Instigator.Location - B.Enemy.Location);

	Result = FRand()-0.3;
	// Too far for grenade
	if (Dist > 800)
		Result -= (Dist-800) / 2000;
	if (VSize(B.Enemy.Velocity) > 50)
	{
		// Straight lines
		if (Abs(VDot) > 0.8)
			Result += 0.1;
		// Enemy running away
		if (VDot < 0)
			Result -= 0.2;
		else
			Result += 0.2;
	}
	// Higher than enemy
//	if (Height < 0)
//		Result += 0.1;
	// Improve grenade acording to height, but temper using horizontal distance (bots really like grenades when right above you)
	Dist = VSize(B.Enemy.Location*vect(1,1,0) - Instigator.Location*vect(1,1,0));
	if (Height < -100)
		Result += Abs((Height/2) / Dist);

	NextChangeMindTime = level.TimeSeconds + 4;

	if (Result > 0.5)
		return 1;
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
	if (Dist > 700)
		Result += 0.3;
	else if (B.Enemy.Weapon != None && B.Enemy.Weapon.bMeleeWeapon)
		Result -= 0.05 * B.Skill;
	if (Dist > 3000)
		Result -= (Dist-3000) / 4000;

	return Result;
}
// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.1;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

simulated function Notify_BrassOut()
{
//	BFireMode[0].EjectBrass();
}

defaultproperties
{
     OverHeatSound=Sound'BWBP_SKC_Sounds.CYLO.CYLO-OverHeat'
     HighHeatSound=Sound'BWBP_SKC_Sounds.CYLO.CYLO-HighHeat'
     MedHeatSound=Sound'BWBP_SKC_Sounds.CYLO.CYLO-MedHeat'
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_Tex.CYLO.BigIcon_CYLOMk2'
     BallisticInventoryGroup=6
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Hazardous=True
     bWT_Splash=True
     bWT_RapidProj=True
     bWT_Projectile=True
     bWT_Super=True
     SpecialInfo(0)=(Info="240.0;25.0;0.9;80.0;0.2;0.7;0.4")
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     MagAmmo=100
     CockAnimPostReload="Cock"
     CockSound=(Sound=Sound'BallisticSounds2.M50.M50Cock')
     ClipHitSound=(Sound=Sound'BallisticSounds2.M50.M50ClipHit')
     ClipOutSound=(Sound=Sound'BallisticSounds2.M50.M50ClipOut')
     ClipInSound=(Sound=Sound'BallisticSounds2.M50.M50ClipIn')
     ClipInFrame=0.700000
     bNeedCock=False
     bCockOnEmpty=False
     WeaponModes(0)=(bUnavailable=True,ModeID="WM_None")
     WeaponModes(1)=(ModeName="Energy Accelerator Matrix",Value=5.000000)
     WeaponModes(2)=(ModeName="Ion Impulse Array")
	CurrentWeaponMode=2
     RecoilXCurve=(Points=(,(InVal=0.100000,OutVal=0.010000),(InVal=0.200000,OutVal=0.250000),(InVal=0.300000,OutVal=-0.300000),(InVal=0.600000,OutVal=-0.250000),(InVal=0.700000,OutVal=0.250000),(InVal=1.000000,OutVal=-0.300000)))
     RecoilYCurve=(Points=(,(InVal=0.100000,OutVal=0.180000),(InVal=0.200000,OutVal=-0.200000),(InVal=0.300000,OutVal=0.300000),(InVal=0.600000,OutVal=-0.150000),(InVal=0.700000,OutVal=0.300000),(InVal=1.000000,OutVal=0.600000)))
     SightPivot=(Pitch=900)
     SightOffset=(X=-25.000000,Z=8.000000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.R78OutA',Pic2=Texture'BallisticUI2.Crosshairs.G5InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=0,R=0,A=255),Color2=(B=0,G=0,R=255,A=255),StartSize1=90,StartSize2=93)
     GunLength=16.500000
     LongGunPivot=(Pitch=2000,Yaw=-1024)
     LongGunOffset=(X=-10.000000,Y=0.000000,Z=-5.000000)
     CrouchAimFactor=0.800000
     JumpOffSet=(Pitch=1000,Yaw=-500)
     JumpChaos=0.300000
     AimAdjustTime=0.400000
     AimSpread=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000))
     ChaosAimSpread=(X=(Min=-1048.000000,Max=1048.000000),Y=(Min=-1600.000000,Max=1600.000000))
     ViewAimFactor=0.050000
     ViewRecoilFactor=0.200000
     ChaosDeclineTime=1.000000
     ChaosTurnThreshold=170000.000000
     ChaosSpeedThreshold=1200.000000
     RecoilXFactor=0.250000
     RecoilYFactor=0.250000
     RecoilMax=1600.000000
     RecoilDeclineTime=0.800000
     FireModeClass(0)=Class'BWBP_SKC_Fix.Supercharger_PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.Supercharger_SecondaryFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     bShowChargingBar=True
     Description="Type-93 XM Supercharger||Manufacturer: Dipheox Combat Arms|Primary: Directed Energy Fire|Secondary: Magnetically Contained Projectile||Not much is known about this enigmatic CYLO variation. It is extremely rare and a cloesly guarded secret."
     DisplayFOV=55.000000
     Priority=41
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=4
     PickupClass=Class'BWBP_SKC_Fix.Supercharger_Pickup'
     PlayerViewOffset=(X=17.000000,Y=4.000000,Z=-6.000000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.Supercharger_Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.CYLO.SmallIcon_CYLOMk2'
     IconCoords=(X2=127,Y2=31)
     ItemName="[B]Type-93 XM Supercharger"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.CYLO.CYLO'
     DrawScale=0.360000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_Tex.CYLO.CYLO-MainShine'
}
