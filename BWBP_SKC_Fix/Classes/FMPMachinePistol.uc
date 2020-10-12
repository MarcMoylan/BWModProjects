//=============================================================================
// FMP machine pistol
//
// muh MP40
//
// by Sarge.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FMPMachinePistol extends BallisticWeapon;

var   bool		bAmped;				// AMPED UP!!! YEAH!!! WOOOO!!!! WHITE CLAWW!!!!
var() name		AmplifierBone;			// Bone to use for hiding cool shit
var() name		AmplifierBone2;			// Xav likes to make my life difficult
var() name		AmplifierOnAnim;			//
var() name		AmplifierOffAnim;		//
var() sound		AmplifierOnSound;		// Silencer stuck on sound
var() sound		AmplifierOffSound;		//
var() sound		AmplifierPowerOnSound;		// Silencer stuck on sound
var() sound		AmplifierPowerOffSound;		//
var() float		AmplifierSwitchTime;		//

var() array<Material> CamoMaterials;

replication
{
   	reliable if( Role<ROLE_Authority )
		ServerSwitchAmplifier;
		
}

//==============================================
// Amp Code
//==============================================

function ServerSwitchAmplifier(bool bNewValue)
{
	AmplifierSwitchTime = level.TimeSeconds + 2.0;
	bAmped = bNewValue;
	if (bAmped)
	{
			WeaponModes[0].bUnavailable=true;
			WeaponModes[1].bUnavailable=false;
			WeaponModes[2].bUnavailable=false;
			CurrentWeaponMode=1;
			ServerSwitchWeaponMode(1);
	}
	else
	{
			WeaponModes[0].bUnavailable=false;
			WeaponModes[1].bUnavailable=true;
			WeaponModes[2].bUnavailable=true;
			CurrentWeaponMode=2;
			ServerSwitchWeaponMode(0);
	}
}

exec simulated function WeaponSpecial(optional byte i)
{
	if (level.TimeSeconds < AmplifierSwitchTime || ReloadState != RS_None)
		return;
	TemporaryScopeDown(0.5);
	AmplifierSwitchTime = level.TimeSeconds + 2.0;
	bAmped = !bAmped;
	ServerSwitchAmplifier(bAmped);
	SwitchAmplifier(bAmped);
}
simulated function SwitchAmplifier(bool bNewValue)
{
	if (bNewValue)
		PlayAnim(AmplifierOnAnim);
	else
		PlayAnim(AmplifierOffAnim);
}
simulated function Notify_SilencerOn()	{	PlaySound(AmplifierOnSound,,0.5);	}
simulated function Notify_SilencerOff()	{	PlaySound(AmplifierOffSound,,0.5);	}

simulated function Notify_SilencerShow()
{	
	SetBoneScale (0, 1.0, AmplifierBone);	
	SetBoneScale (2, 0.0, AmplifierBone2);	
}
simulated function Notify_SilencerHide()
{	
	SetBoneScale (0, 0.0, AmplifierBone);	
	SetBoneScale (2, 1.0, AmplifierBone2);	
}

simulated function Notify_ClipOutOfSight()	{	SetBoneScale (1, 1.0, 'Bullet');	}

function ServerSwitchWeaponMode (byte newMode)
{
	super.ServerSwitchWeaponMode (newMode);
	if (!Instigator.IsLocallyControlled())
		FMPPrimaryFire(FireMode[0]).SwitchWeaponMode(CurrentWeaponMode);
	ClientSwitchWeaponMode (CurrentWeaponMode);
}
simulated function ClientSwitchWeaponMode (byte newMode)
{
	FMPPrimaryFire(FireMode[0]).SwitchWeaponMode(newMode);
	if (newMode == 1)
	{
		Skins[3]=CamoMaterials[1];
	}
	else if (newMode == 2)
	{
		Skins[3]=CamoMaterials[0];
	}
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	super.BringUp(PrevWeapon);

	if (AIController(Instigator.Controller) != None)
		bAmped = (FRand() > 0.5);

	if (bAmped)
	{
		SetBoneScale (0, 1.0, AmplifierBone);
		SetBoneScale (2, 0.0, AmplifierBone2);
	}		
	else
	{
		SetBoneScale (0, 0.0, AmplifierBone);
		SetBoneScale (2, 1.0, AmplifierBone2);	
	}

	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		AimSpread *= 0.4;
		ChaosAimSpread *= 0.4;
		RecoilMax *= 0.4;
	}

}

// HARDCODED SIGHTING TIME
simulated function TickSighting (float DT)
{
	if (SightingState == SS_None || SightingState == SS_Active)
		return;

	if (SightingState == SS_Raising)
	{	// Raising gun to sight position
		if (SightingPhase < 1.0)
		{
			if ((bScopeHeld || bPendingSightUp) && CanUseSights())
				SightingPhase += DT/0.20;
			else
			{
				SightingState = SS_Lowering;

				Instigator.Controller.bRun = 0;
			}
		}
		else
		{	// Got all the way up. Now go to scope/sight view
			SightingPhase = 1.0;
			SightingState = SS_Active;
			ScopeUpAnimEnd();
		}
	}
	else if (SightingState == SS_Lowering)
	{	// Lowering gun from sight pos
		if (SightingPhase > 0.0)
		{
			if (bScopeHeld && CanUseSights())
				SightingState = SS_Raising;
			else
				SightingPhase -= DT/0.20;
		}
		else
		{	// Got all the way down. Tell the system our anim has ended...
			SightingPhase = 0.0;
			SightingState = SS_None;
			ScopeDownAnimEnd();
			DisplayFOv = default.DisplayFOV;
		}
	}
}




simulated function float RateSelf()
{
	if (!HasAmmo())
		CurrentRating = 0;
	else if (Ammo[0].AmmoAmount < 1 && MagAmmo < 1)
		CurrentRating = Instigator.Controller.RateWeapon(self)*0.3;
	else
		return Super.RateSelf();
	return CurrentRating;
}
// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (B.Skill > Rand(6))
	{
		if (Chaos < 0.1 || Chaos < 0.5 && VSize(B.Enemy.Location - Instigator.Location) > 500)
			return 1;
	}
	else if (FRand() > 0.75)
		return 1;
	return 0;
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	Result = Super.GetAIRating();
	if (Dist < 500)
		Result -= 1-Dist/500;
	else if (Dist < 3000)
		Result += (Dist-1000) / 2000;
	else
		Result = (Result + 0.66) - (Dist-3000) / 2500;
	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.0;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====



defaultproperties
{
     CamoMaterials[0]=Shader'BWBP_SKC_TexExp.Amp.Amp-FinalGreen'
     CamoMaterials[1]=Shader'BWBP_SKC_TexExp.Amp.Amp-FinalRed'
     AmplifierBone="Amplifier1"
     AmplifierBone2="Amplifier2"
     AmplifierOnAnim="AmplifierOn"
     AmplifierOffAnim="AmplifierOff"
     AmplifierOnSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOn'
     AmplifierOffSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOff'
     AmplifierPowerOnSound=Sound'BWBP4-Sounds.VPR.VPR-ClipIn'
     AmplifierPowerOffSound=Sound'BWBP4-Sounds.VPR.VPR-ClipOut'
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_TexExp.MP40.BigIcon_MP40'
     BallisticInventoryGroup=4
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="240.0;25.0;0.9;80.0;0.7;0.7;0.4")
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     MagAmmo=28
     CockAnimPostReload="Cock"
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.MP40.MP40-Cock',Volume=1.000000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.MP40.MP40-MagOut',Volume=1.500000)
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.MP40.MP40-MagHit',Volume=1.500000)
     ClipHitSound=(Sound=Sound'BWBP_SKC_SoundsExp.MP40.MP40-MagIn',Volume=1.500000)
     ClipInFrame=0.650000
     bNeedCock=False
     WeaponModes(0)=(ModeName="Automatic",ModeID="WM_FullAuto")
     WeaponModes(1)=(ModeName="Amplified: Incendiary",ModeID="WM_FullAuto",bUnavailable=True)
     WeaponModes(2)=(ModeName="Amplified: Corrosive",ModeID="WM_FullAuto",bUnavailable=True)
     SightPivot=(YAW=10)
     SightOffset=(X=5.000000,Y=-7.670000,Z=18.900000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M50Out',Pic2=Texture'BallisticUI2.Crosshairs.M50In',Color1=(A=158),StartSize1=75,StartSize2=72)
     CrouchAimFactor=0.500000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     ChaosAimSpread=(X=(Min=-1024.000000,Max=1024.000000),Y=(Min=-1024.000000,Max=1024.000000))
     AimSpread=(X=(Min=-128.125000,Max=128.125000),Y=(Min=-128.125000,Max=128.125000))
//     ChaosAimSpread=(X=(Min=-2250.000000,Max=2250.000000),Y=(Min=-2250.000000,Max=2250.000000))
     ViewAimFactor=0.200000
     ViewRecoilFactor=0.400000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.800000
     RecoilPitchFactor=1.000000
     RecoilXFactor=0.200000
     RecoilYFactor=0.600000
     RecoilDeclineDelay=0.100000
     RecoilDeclineTime=0.5
     ChaosDeclineTime=1.0
     SightingTime=0.200000
     FireModeClass(0)=Class'BWBP_SKC_Fix.FMPPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.FMPSecondaryFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     SightAimFactor=0.3
     Description="FMP-2012 Machine Pistol||Manufacturer: Black & Wood|Primary: Accurate Rifle Fire|Secondary: Attach Smoke Grenade||The MJ51 is a 3-round burst carbine based off the popular M50 assault rifle. It fires the 5.56mm UTC round and is more controllable than its larger cousin, though at the expense of long range accuracy and power. While the S-AR 12 is the UTC's weapon of choice for close range engagements, the MJ51 is often seen in the hands of MP and urban security details. When paired with its native CM3 Rifle Grenade attachment, the MJ51 makes an efficient riot control weapon."
     Priority=41
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.FMPPickup'
     PlayerViewOffset=(X=-5.000000,Y=12.000000,Z=-15.000000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.FMPAttachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.MP40.SmallIcon_MP40'
     IconCoords=(X2=127,Y2=31)
     ItemName="FMP-2012 Machine Pistol"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.MP40_FP'
     DrawScale=0.300000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_TexExp.MP40.MP40-MainShine'
     Skins(2)=Shader'BWBP_SKC_TexExp.MP40.MP40-MagShine'
     Skins(3)=Shader'BWBP_SKC_TexExp.Amp.Amp-FinalRed'
}
