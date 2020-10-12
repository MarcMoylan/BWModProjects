//=============================================================================
// MRDRMachinePistol.
//
// Dual wieldable weapon with a nice spiked handguard for punching
// Small clip but very low recoil and chaos. Fairly accurate actually.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class MRDRMachinePistol extends BallisticHandGun;

static function class<Pickup> RecommendAmmoPickup(int Mode)
{
	return class'AP_MRDRClip';
}

simulated function bool CanAlternate(int Mode)
{
	if (Mode != 0)
		return false;
	return super.CanAlternate(Mode);
}

simulated function bool HasAmmoLoaded(byte Mode)
{
	if (Mode == 1)
		return true;
	if (bNoMag)
		return HasNonMagAmmo(Mode);
	else
		return HasMagAmmo(Mode);
}


//simulated function bool SlaveCanUseMode(int Mode) {return Mode == 0;}
//simulated function bool MasterCanSendMode(int Mode) {return Mode == 0;}

simulated state Lowering// extends DualAction
{
Begin:
	SafePlayAnim(PutDownAnim, 1.75, 0.1);
	FinishAnim();
	GotoState('Lowered');
}


simulated function SetDualMode (bool bDualMode)
{
	AdjustUziProperties(bDualMode);
}
simulated function AdjustUziProperties (bool bDualMode)
{
//	AimAdjustTime		= default.AimAdjustTime;
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
//	RecoilMax			= default.RecoilMax;
	RecoilDeclineTime	= default.RecoilDeclineTime;

	if (bDualMode)
	{
		if (Instigator.IsLocallyControlled() && SightingState == SS_Active)
			StopScopeView();
//		SetBoneScale(8, 0.0, SupportHandBone);
		if (AIController(Instigator.Controller) == None)
			bUseSpecialAim = true;
//		AimAdjustTime		*= 1.0;
		AimSpread			*= 1.4;
		ViewAimFactor		*= 0.6;
		ViewRecoilFactor	*= 1.75;
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
	}
	else
	{
//		SetBoneScale(8, 1.0, SupportHandBone);
		bUseSpecialAim = false;
	}
}


simulated function Notify_MRDRMelee()
{
	if (Role == ROLE_Authority)
		MRDRSecondaryFire(BFireMode[1]).NotifiedDoFireEffect();
	PlayOwnedSound(BFireMode[1].BallisticFireSound.Sound,
		BFireMode[1].BallisticFireSound.Slot,
		BFireMode[1].BallisticFireSound.Volume,
		BFireMode[1].BallisticFireSound.bNoOverride,
		BFireMode[1].BallisticFireSound.Radius,
		BFireMode[1].BallisticFireSound.Pitch,
		BFireMode[1].BallisticFireSound.bAtten);
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

	if (!HasAmmoLoaded(0))
		return 1;

	Dir = Instigator.Location - B.Enemy.Location;
	Dist = VSize(Dir);

	if (Dist > 200)
		return 0;
	if (Dist < FireMode[1].MaxRange())
		return 1;
	return Rand(2);
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;
	local vector Dir;

	if (IsSlave())
		return 0;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return Super.GetAIRating();

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	Result = Super.GetAIRating();
	if (!HasMagAmmo(0) && !HasNonMagAmmo(0))
	{
		if (Dist > 400)
			return 0;
		return Result / (1+(Dist/400));
	}

	if (Dist < 500)
		Result += 0.3;
	if (Dist > 1000)
		Result -= (Dist-1000) / 4000;

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	if (HasAmmoLoaded(0)) return 0.5;	return 1.0;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return -0.5;	}
// End AI Stuff =================================


simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		IdleAnim = 'OpenIdle';
		ReloadAnim = 'OpenReload';
	}
	else
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'Reload';
	}

}

simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);

	if (Anim == 'OpenFire' || Anim == 'Fire' || Anim == CockAnim || Anim == ReloadAnim)
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
		{
			IdleAnim = 'OpenIdle';
			ReloadAnim = 'OpenReload';
		}
		else
		{
			IdleAnim = 'Idle';
			ReloadAnim = 'Reload';
		}
	}
	Super.AnimEnd(Channel);
}

simulated function PlayCocking(optional byte Type)
{
	if (Type == 2)
		PlayAnim('ReloadEndCock', CockAnimRate, 0.2);
	else
		PlayAnim(CockAnim, CockAnimRate, 0.2);
}

// =============================================

defaultproperties
{
     HandgunGroup=2
     PlayerSpeedFactor=1.000000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_Tex.MRDR.BigIcon_MRDR'
     BallisticInventoryGroup=4
     GunLength=0.100000
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     bWT_Machinegun=True
     SpecialInfo(0)=(Info="60.0;3.0;0.1;125.0;0.0;0.2;-999.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.XK2.XK2-Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.XK2.XK2-Putaway')
     MagAmmo=36
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.MRDR.MRDR-Cock',Volume=0.800000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_Sounds.MRDR.MRDR-ClipOut',Volume=0.700000)
     ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.MRDR.MRDR-ClipIn',Volume=0.700000)
     ClipInFrame=0.650000
     bNeedCock=True
     WeaponModes(0)=(ModeName="Semi-Automatic",bUnavailable=True)
     WeaponModes(1)=(ModeName="Small Burst",Value=2.000000,bUnavailable=True)
     WeaponModes(2)=(bUnavailable=False)
     CurrentWeaponMode=2
     SightPivot=(Pitch=900,Roll=-800)
     SightOffset=(X=-10.000000,Y=-0.800000,Z=13.100000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Misc1',Pic2=Texture'BallisticUI2.Crosshairs.A73OutA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=255,G=255,R=134,A=71),Color2=(B=99,G=228,R=255,A=161),StartSize1=99,StartSize2=33)
     CrosshairInfo=(SpreadRatios=(Y1=0.800000,Y2=1.000000),MaxScale=6.000000)
     CrosshairChaosFactor=0.300000
     CrouchAimFactor=0.800000
     JumpOffSet=(Pitch=1000,Yaw=-500)
     JumpChaos=0.200000
     AimAdjustTime=0.450000
     AimSpread=(X=(Min=-512.000000,Max=512.000000),Y=(Min=-512.000000,Max=512.000000))
     ViewAimFactor=0.050000
     ViewRecoilFactor=0.200000
     ChaosDeclineTime=0.800000
     ChaosTurnThreshold=160000.000000
     ChaosSpeedThreshold=1200.000000
     ChaosAimSpread=(X=(Min=-513.000000,Max=513.000000),Y=(Min=-513.000000,Max=513.000000))
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000),(InVal=0.600000,OutVal=0.200000),(InVal=0.800000,OutVal=0.400000),(InVal=1.000000,OutVal=0.200000)))
     RecoilYCurve=(Points=(,(InVal=0.100000,OutVal=0.200000),(InVal=0.200000,OutVal=0.500000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=1.000000,OutVal=1.000000)))
     RecoilXFactor=0.400000
     RecoilYFactor=0.400000
     RecoilMax=1024.000000
     RecoilDeclineTime=0.800000
     FireModeClass(0)=Class'BWBP_SKC_Fix.MRDRPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.MRDRsecondaryFire'
     PutDownTime=0.400000
     BringUpTime=0.500000
     SelectForce="SwitchToAssaultRifle"
     Description="MR-DR88 Machine Pistol||Manufacturer: UTC Defense Tech/Krome Firepower|Primary: Automatic 9mm rounds|Secondary: Melee bash||This bull pup style weapon, made by UTC Defense Tech, features a ring magazine holding 36 rounds of 9mm ammunition that wraps around the forearm and has a spiked steel knuckle on it. Because the bulk of the weight sits on the forearm and not on the wrist, this weapon is very easy to use either single or in pairs. With the unique magazine, some users may find reloading this weapon to be challenging, UTC designed an entirely new feed system for this weapon and as such is still in its experimental stages. This DR88 model uses the same Krome muzzle flash system as the Fifty-9 for massive amounts of style."
     Priority=143
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=2
     GroupOffset=3
     PickupClass=Class'BWBP_SKC_Fix.MRDRPickup'
     PlayerViewOffset=(X=-8.000000,Y=8.000000,Z=-8.000000)
     BobDamping=1.700000
     AttachmentClass=Class'BWBP_SKC_Fix.MRDRAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.MRDR.SmallIcon_MRDR'
     IconCoords=(X2=127,Y2=31)
     ItemName="MR-DR88 Machine Pistol"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=130.000000
     LightRadius=3.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.KnuckleBuster'
     DrawScale=0.300000
}
