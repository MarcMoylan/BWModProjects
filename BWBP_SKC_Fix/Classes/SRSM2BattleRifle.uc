//=============================================================================
// SRSM2RangerRifle.
//
// A simple, semi-auto, unscoped, accuracte, medium power, long range
// rifle. Secondary fire is holosights. Has a large mag but packs less punch
// than the R9. 
//
// Makes use of Camo System V2.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class SRSM2BattleRifle extends BallisticCamoWeapon;


var   bool		bSilenced;				// Silencer on. Silenced
var() name		SilencerBone;			// Bone to use for hiding silencer
var() name		SilencerOnAnim;			// Think hard about this one...
var() name		SilencerOffAnim;		//
var() sound		SilencerOnSound;		// Silencer stuck on sound
var() sound		SilencerOffSound;		//
var() float		SilencerSwitchTime;		//


var() Material          MatAltEO;      	// Blue + scars.
var() Material          MatAltEO2;      	// green.

replication
{
   	reliable if( Role<ROLE_Authority )
		ServerSwitchSilencer;
		
}


function ServerSwitchSilencer(bool bNewValue)
{
	SilencerSwitchTime = level.TimeSeconds + 2.0;
	bSilenced = bNewValue;
	BFireMode[0].bAISilent = bSilenced;
	if (bSilenced)
	{
		BallisticInstantFire(BFireMode[0]).TraceRange.Max = 10000;
		BallisticInstantFire(BFireMode[0]).TraceRange.Min = 10000;
	}
	else
		BallisticInstantFire(BFireMode[0]).TraceRange = BallisticInstantFire(BFireMode[0]).default.TraceRange;
}

exec simulated function WeaponSpecial(optional byte i)
{
	if (level.TimeSeconds < SilencerSwitchTime || ReloadState != RS_None)
		return;
	TemporaryScopeDown(0.5);
	SilencerSwitchTime = level.TimeSeconds + 2.0;
	bSilenced = !bSilenced;
	ServerSwitchSilencer(bSilenced);
	SwitchSilencer(bSilenced);
}
simulated function SwitchSilencer(bool bNewValue)
{
	if (bNewValue)
		PlayAnim(SilencerOnAnim);
	else
		PlayAnim(SilencerOffAnim);
}
simulated function Notify_SilencerOn()	{	PlaySound(SilencerOnSound,,0.5);	}
simulated function Notify_SilencerOff()	{	PlaySound(SilencerOffSound,,0.5);	}

simulated function Notify_SilencerShow(){	SetBoneScale (0, 1.0, SilencerBone);	}
simulated function Notify_SilencerHide(){	SetBoneScale (0, 0.0, SilencerBone);	}

simulated function Notify_ClipOutOfSight()	{	SetBoneScale (1, 1.0, 'Bullet');	}

simulated function PlayReload()
{
	super.PlayReload();

	if (MagAmmo < 1)
		SetBoneScale (1, 0.0, 'Bullet');

	if (bSilenced)
		SetBoneScale (0, 1.0, SilencerBone);
	else
		SetBoneScale (0, 0.0, SilencerBone);
}

static function class<Pickup> RecommendAmmoPickup(int Mode)
{
	return class'AP_SRS900Clip';
}


//Kaboodles' neat idle anim fix.
simulated function PlayIdle()
{
	if (BFireMode[0].IsFiring())
		return;
	if (bPendingSightUp)
		ScopeBackUp();
	else if (SightingState != SS_None)
	{
		if (SafePlayAnim(IdleAnim, 1.0))
			FreezeAnimAt(0.0);
	}
	else if (bScopeView)
	{
		if(SafePlayAnim(ZoomOutAnim, 1.0))
			FreezeAnimAt(0.0);
	}
	else
	    SafeLoopAnim(IdleAnim, IdleAnimRate, IdleTweenTime, ,"IDLE");
}

simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();

		if ((Index == -1 && f > 0.95) || Index == 6)
		{
			Skins[0]=CamoMaterials[6];
			Skins[4]=MatAltEO;
			FireMode[0].FireRate 	= 0.25;
			CockAnimRate=1.5;
			ReloadAnimRate=1.25;
			WeaponModes[2].bUnavailable=false;
     			ItemName="SRS-655 Battle Rifle";
			BallisticInstantFire(FireMode[0]).Damage = 65;
			BallisticInstantFire(FireMode[0]).DamageLimb = 40;
     			CurrentWeaponMode=2;
			CamoIndex=6;
		}
		else if ((Index == -1 && f > 0.85) || Index == 5)
		{
			Skins[0]=CamoMaterials[5];
			Skins[4]=MatAltEO;
			Skins[5]=MatAltEO;
			BallisticInstantFire(FireMode[0]).Damage = 45;
			BallisticInstantFire(FireMode[0]).DamageLimb = 25;
			CamoIndex=5;
		}
		else if ((Index == -1 && f > 0.75) || Index == 4)
		{
			Skins[0]=CamoMaterials[4];
			Skins[4]=MatAltEO;
			Skins[5]=MatAltEO;
			BallisticInstantFire(FireMode[0]).Damage = 45;
			BallisticInstantFire(FireMode[0]).DamageLimb = 25;
			CamoIndex=4;
		}
		else if ((Index == -1 && f > 0.70) || Index == 3)
		{
			Skins[0]=CamoMaterials[3];
			Skins[4]=MatAltEO2;
			Skins[5]=MatAltEO2;
			bSilenced=True;
			BFireMode[0].RecoilPerShot = 64;
			CamoIndex=3;
		}
		else if ((Index == -1 && f > 0.55) || Index == 2)
		{
			Skins[0]=CamoMaterials[2];
			CamoIndex=2;
		}
		else if ((Index == -1 && f > 0.40) || Index == 1)
		{
			Skins[0]=CamoMaterials[1];
			CamoIndex=1;
		}
		else
		{
			Skins[0]=CamoMaterials[0];
			CamoIndex=0;
		}
}

function ServerSwitchCamo(int bNewValue)
{
	AdjustCamoProperties(bNewValue);
}


// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();

	bUseNetAim = bScopeView;
	if (bScopeView)
	{
		CrouchAimFactor *= 3;
		ChaosDeclineTime *= 1.2;
		RecoilPitchFactor = 1.5;
                RecoilYawFactor = 1;
		RecoilYFactor = 1;
		RecoilXFactor = 1;
        	FireMode[0].FireAnim='SightFire';
	}
	else
	{
		CrouchAimFactor = default.CrouchAimFactor;
		ChaosDeclineTime = default.ChaosDeclineTime;
		RecoilPitchFactor = default.RecoilPitchFactor;
		RecoilYFactor = default.RecoilYFactor;
		RecoilXFactor = default.RecoilXFactor;
        	FireMode[0].FireAnim='Fire';
	}
}


simulated function BringUp(optional Weapon PrevWeapon)
{
	super.BringUp(PrevWeapon);


	if (AIController(Instigator.Controller) != None)
		bSilenced = (FRand() > 0.5);

	if (bSilenced)
		SetBoneScale (0, 1.0, SilencerBone);
	else
		SetBoneScale (0, 0.0, SilencerBone);

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
				SightingPhase += DT/0.25;
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
				SightingPhase -= DT/0.25;
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


// Secondary fire doesn't count for this weapon
simulated function bool HasAmmo()
{
	//First Check the magazine
	if (!bNoMag && FireMode[0] != None && MagAmmo >= FireMode[0].AmmoPerFire)
		return true;
	//If it is a non-mag or the magazine is empty
	if (Ammo[0] != None && FireMode[0] != None && Ammo[0].AmmoAmount >= FireMode[0].AmmoPerFire)
			return true;
	return false;	//This weapon is empty
}

// AI Interface =====
function byte BestMode()	
{		
	if (CurrentWeaponMode != 2)
	{
		CurrentWeaponMode = 2;
	}

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
	Result += (Dist-1000) / 2000;

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return -0.5;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.8;	}
// End AI Stuff =====

defaultproperties
{

     CamoMaterials[6]=Texture'BWBP_SKC_Tex.SKS650.SRSNSFlame'	// Red vietnam tiger stripes.
     CamoMaterials[5]=Texture'BWBP_SKC_Tex.SKS650.SRSNSTiger' // Red Stripes
     CamoMaterials[4]=Texture'BWBP_SKC_Tex.SKS650.SRSNSJungle' // Green Stripes
     CamoMaterials[3]=Texture'BWBP_SKC_Tex.SKS650.SRSM2German' // Blotchy things
     CamoMaterials[2]=Texture'BWBP_SKC_Tex.SKS650.SRSNSDesert' // MARPAT desert.
     CamoMaterials[1]=Texture'BWBP_SKC_Tex.SKS650.SRSNSUrban' // SRS-900 Gray.
     CamoMaterials[0]=Texture'BWBP_SKC_Tex.SKS650.SRSNSGrey'  // Black.

     MatAltEO=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-BSight-FB'
     MatAltEO2=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-GSight-FB'

     SilencerBone="Silencer"
     SilencerOnAnim="SilencerOn"
     SilencerOffAnim="SilencerOff"
     SilencerOnSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOn'
     SilencerOffSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOff'
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny',SkinNum=3)
     BigIconMaterial=Texture'BWBP_SKC_Tex.SKS650.BigIcon_SRSM2'
     BallisticInventoryGroup=7
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="480.0;25.0;0.5;70.0;1.0;0.2;0.0")
     BringUpSound=(Sound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOn')
     PutDownSound=(Sound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOff')
     MagAmmo=20
     CockSound=(Sound=Sound'BWBP3-Sounds.SRS900.SRS-Cock',Volume=0.650000)
     ClipHitSound=(Sound=Sound'BWBP3-Sounds.SRS900.SRS-ClipHit')
     ClipOutSound=(Sound=Sound'BWBP3-Sounds.SRS900.SRS-ClipOut')
     ClipInSound=(Sound=Sound'BWBP3-Sounds.SRS900.SRS-ClipIn')
     ClipInFrame=0.650000
     ReloadAnimRate=1.200000
     bNeedCock=True
     bNoCrosshairInScope=True
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     FullZoomFOV=60.000000
//     SightPivot=(Pitch=512)
//     SightOffset=(X=-2.000000,Z=13.300000)
     SightOffset=(X=8.000000,Z=10.460000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Cross3',pic2=Texture'BallisticUI2.Crosshairs.M50InA',USize1=128,VSize1=128,USize2=256,VSize2=256,Color1=(B=0,G=0,R=255,A=192),Color2=(B=255,G=255,R=255,A=123),StartSize1=20,StartSize2=57)
     GunLength=80.000000
     CrouchAimFactor=0.200000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     AimAdjustTime=0.600000
     AimSpread=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000))
     ViewAimFactor=0.350000
     ViewRecoilFactor=1.0
     RecoilDeclineDelay=0.150000
     RecoilDeclineTime=2.000000
     SightingTime=0.250000
     ChaosSpeedThreshold=500.000000
     ChaosAimSpread=(X=(Min=-2648.000000,Max=2648.000000),Y=(Min=-2648.000000,Max=2648.000000))
     RecoilYawFactor=0.200000
     RecoilPitchFactor=3.000000
     RecoilXFactor=0.250000
     RecoilYFactor=0.250000
     FireModeClass(0)=Class'BWBP_SKC_Fix.SRSM2PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.R78ScopeFire'
     BringUpTime=0.500000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     bSniping=True
     Description="SRS Mod-2 Battle Rifle||Manufacturer: NDTR Industries|Primary: Powerful Rifle Fire|Secondary: Iron Sights||Popular demand for a civillian variant of the SRS-655 Battle Rifle spurred the creation of the versatile semi-automatic SRS Mod-2 Battle Rifle. Designed and refined in NDTR Industries' top notch R&D labs before the war, the Mod-2 is the precursor to the now-famous SRS-900. Customers can choose from a variety of targeting scopes, calibers and camouflage patterns to personalize their firearm. This specific version has been custom-modified with a suppressor mount and holographic sight. The SRS Mod-2 was awarded a 10 out of 10 by the Gentleman's Rifle Association for amazing precision and accuracy and was quoted to be 'the best gun for big game and home defense!' Gold variants are unfortunately currently out of stock."
     Priority=174
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.SRSM2Pickup'
//     PlayerViewOffset=(X=2.000000,Y=9.000000,Z=-10.000000)
     PlayerViewOffset=(X=-5.000000,Y=7.000000,Z=-7.000000)
     BobDamping=1.800000
     AttachmentClass=Class'BWBP_SKC_Fix.SRSM2Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.SKS650.SmallIcon_SRSM2'
     IconCoords=(X2=127,Y2=31)
     ItemName="SRS Mod-2 Battle Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.SRS-1st'
     DrawScale=0.500000
     Skins(0)=Texture'BWBP_SKC_Tex.SKS650.SRSNSGrey'
     Skins(1)=Texture'BWBP3-Tex.SRS900.SRS900Scope'
     Skins(2)=Texture'BWBP3-Tex.SRS900.SRS900Ammo'
     Skins(3)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(4)=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-HSight-FB'
     Skins(5)=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-HSight-FB'
}
