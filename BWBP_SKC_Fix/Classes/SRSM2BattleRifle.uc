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
var() name		SightBone;			// Bone to use for rotating sight
var() name		SilencerBone;			// Bone to use for hiding silencer
var() name		SilencerOnAnim;			// Think hard about this one...
var() name		SilencerOffAnim;		//
var() sound		SilencerOnSound;		// Silencer stuck on sound
var() sound		SilencerOffSound;		//
var() float		SilencerSwitchTime;		//

var   bool		bAmped;				// Amp installed, gun has new effects
var() name		AmplifierBone;			// Bone to use for hiding amp
var() name		AmplifierOnAnim;			//
var() name		AmplifierOffAnim;		//
var() sound		AmplifierOnSound;		// Silencer stuck on sound
var() sound		AmplifierOffSound;		//
var() sound		AmplifierPowerOnSound;		// Silencer stuck on sound
var() sound		AmplifierPowerOffSound;		//
var() float		AmplifierSwitchTime;		//

var() Material          MatAltEO;      	// Blue + scars.
var() Material          MatAltEO2;      	// green.
var() Material          MatDarkBody;      	// green.
var() Material          MatInvis;      	// green.

//Scripted Ammo Screen Texture
var() ScriptedTexture WeaponScreen; //Scripted texture to write on
var() Material	WeaponScreenShader; //Scripted Texture with self illum applied
var() Material	ScreenBase;
var() Material	ScreenAmmoBlue; //Norm
var() Material	ScreenAmmoRed; //Low Ammo
var protected const color MyFontColor; //Why do I even need this?

var	float	AmmoBarPos;

replication
{
   	reliable if( Role<ROLE_Authority )
		ServerSwitchSilencer, ServerSwitchAmplifier;
		
}


//==============================================
// Screen Code
//==============================================

simulated function ClientScreenStart()
{
	ScreenStart();
}
// Called on clients from camera when it gets to postnetbegin
simulated function ScreenStart()
{
	if (Instigator.IsLocallyControlled())
		WeaponScreen.Client = self;
	//if (CamoIndex >= 3)
		Skins[13] = WeaponScreenShader; //Set up scripted texture.
	UpdateScreen();//Give it some numbers n shit
	if (Instigator.IsLocallyControlled())
		WeaponScreen.Revision++;
}

simulated event RenderTexture( ScriptedTexture Tex )
{
	// 0 is full, 256 is empty
	AmmoBarPos = 256-(((MagAmmo)/20.0f)*256);

	//Tex.DrawTile(0,0,256,256,0,0,256,256,ScreenBase, MyFontColor); //Basic screen
	if (MagAmmo > 5)
	{
		Tex.DrawTile(AmmoBarPos,0,256,256,0,0,512,256,ScreenAmmoBlue, MyFontColor); //Ammo
	}
	else
	{
		Tex.DrawTile(AmmoBarPos,0,256,256,0,0,512,256,ScreenAmmoRed, MyFontColor); //Ammo
	}
	
}
	
simulated function UpdateScreen()
{
	if (Instigator.IsLocallyControlled())
	{
			WeaponScreen.Revision++;
	}
}
	
// Consume ammo from one of the possible sources depending on various factors
simulated function bool ConsumeMagAmmo(int Mode, float Load, optional bool bAmountNeededIsMax)
{

	if (bNoMag || (BFireMode[Mode] != None && BFireMode[Mode].bUseWeaponMag == false))
		ConsumeAmmo(Mode, Load, bAmountNeededIsMax);
	else
	{
		if (MagAmmo < Load)
			MagAmmo = 0;
		else
			MagAmmo -= Load;
	}

	UpdateScreen();
	return true;
}

// Animation notify for when the clip is stuck in
simulated function Notify_ClipIn()
{
	local int AmmoNeeded;

	if (ReloadState == RS_None)
		return;
	ReloadState = RS_PostClipIn;
	PlayOwnedSound(ClipInSound.Sound,ClipInSound.Slot,ClipInSound.Volume,ClipInSound.bNoOverride,ClipInSound.Radius,ClipInSound.Pitch,ClipInSound.bAtten);
	if (level.NetMode != NM_Client)
	{
		AmmoNeeded = default.MagAmmo-MagAmmo;
		if (AmmoNeeded > Ammo[0].AmmoAmount)
			MagAmmo+=Ammo[0].AmmoAmount;
		else
			MagAmmo = default.MagAmmo;
		Ammo[0].UseAmmo (AmmoNeeded, True);
	}
	UpdateScreen();
}

//==============================================
// Amp Code
//==============================================

exec simulated function ToggleAmplifier(optional byte i)
{
	if (level.TimeSeconds < AmplifierSwitchTime || ReloadState != RS_None)
		return;
		
	if (bSilenced)
	{
		WeaponSpecial();
		return;
	}
	TemporaryScopeDown(0.5);
	AmplifierSwitchTime = level.TimeSeconds + 2.0;
	bAmped = !bAmped;
	ServerSwitchAmplifier(bAmped);
	SwitchAmplifier(bAmped);
}

function ServerSwitchAmplifier(bool bNewValue)
{
	AmplifierSwitchTime = level.TimeSeconds + 2.0;
	bAmped = bNewValue;
	if (bAmped)
	{
			WeaponModes[0].bUnavailable=true;
			WeaponModes[3].bUnavailable=false;
			WeaponModes[4].bUnavailable=false;
			CurrentWeaponMode=3;
			ServerSwitchWeaponMode(3);
	}
	else
	{
			WeaponModes[0].bUnavailable=false;
			WeaponModes[3].bUnavailable=true;
			WeaponModes[4].bUnavailable=true;
			CurrentWeaponMode=0;
			ServerSwitchWeaponMode(0);
	}
}
simulated function SwitchAmplifier(bool bNewValue)
{
	if (bNewValue)
		PlayAnim(AmplifierOnAnim);
	else
		PlayAnim(AmplifierOffAnim);
}

function ServerSwitchWeaponMode (byte newMode)
{
	super.ServerSwitchWeaponMode (newMode);
	if (!Instigator.IsLocallyControlled())
		SRSM2PrimaryFire(FireMode[0]).SwitchWeaponMode(CurrentWeaponMode);
	ClientSwitchWeaponMode (CurrentWeaponMode);
}
simulated function ClientSwitchWeaponMode (byte newMode)
{
	SRSM2PrimaryFire(FireMode[0]).SwitchWeaponMode(newMode);
	if (newMode == 3)
	{
		Skins[1]=CamoMaterials[8];
	}
	else if (newMode == 4)
	{
		Skins[1]=CamoMaterials[9];
	}
}

//==============================================
// Suppressor Code
//==============================================

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
	if (bAmped)
	{
		ToggleAmplifier();
		return;
	}
		
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

simulated function Notify_AmplifierOn()	{	PlaySound(AmplifierOnSound,,0.5);	}
simulated function Notify_AmplifierOff()	{	PlaySound(AmplifierOffSound,,0.5);	}

simulated function Notify_AmplifierShow(){	SetBoneScale (2, 1.0, AmplifierBone);	}
simulated function Notify_AmplifierHide(){	SetBoneScale (2, 0.0, AmplifierBone);	}

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

		if ((Index == -1 && f > 0.95) || Index == 6) //Fancy Red [95-100]
		{
			Skins[4]=CamoMaterials[6];
			//Skins[13]=MatAltEO;
			FireMode[0].FireRate 	= 0.25;
			SetBoneScale (3, 0.0, SightBone);
			CockAnimRate=1.5;
			ReloadAnimRate=1.25;
			WeaponModes[2].bUnavailable=false;
     			ItemName="SRS-655 Battle Rifle";
			BallisticInstantFire(FireMode[0]).Damage = 65;
			BallisticInstantFire(FireMode[0]).DamageLimb = 40;
     			CurrentWeaponMode=2;
			CamoIndex=6;
		}
		else if ((Index == -1 && f > 0.80) || Index == 5) //High Tech Yellow [80-95]
		{
			Skins[4]=CamoMaterials[5];
			SetBoneScale (3, 0.0, SightBone);
     		ItemName="SRX Mod-2 Battle Rifle";
			//BallisticInstantFire(FireMode[0]).Damage = 45;
			//BallisticInstantFire(FireMode[0]).DamageLimb = 25;
			CamoIndex=5;
		}
		else if ((Index == -1 && f > 0.65) || Index == 4) //High Tech Green [65-80]
		{
			Skins[4]=CamoMaterials[4];
			SetBoneScale (3, 0.0, SightBone);
     		ItemName="SRX Mod-2 Battle Rifle";
			//BallisticInstantFire(FireMode[0]).Damage = 45;
			//BallisticInstantFire(FireMode[0]).DamageLimb = 25;
			CamoIndex=4;
		}
		else if ((Index == -1 && f > 0.50) || Index == 3) //High Tech Black + Red [50-65]
		{
			Skins[4]=CamoMaterials[3];
			SetBoneScale (3, 0.0, SightBone);
     		ItemName="SRX Mod-2 Battle Rifle";
			bSilenced=True;
			//BFireMode[0].RecoilPerShot = 64;
			CamoIndex=3;
		}
		else if ((Index == -1 && f > 0.35) || Index == 2) //Gray [35-50]
		{
			Skins[4]=CamoMaterials[2];
			Skins[6]=MatInvis;
			Skins[7]=MatInvis;
			Skins[8]=MatInvis;
			Skins[13]=MatInvis;
			Skins[14]=MatInvis;
			CamoIndex=2;
		}
		else if ((Index == -1 && f > 0.20) || Index == 1) //Black [20-35]
		{
			bSilenced=True;
			Skins[3]=CamoMaterials[7];
			Skins[4]=CamoMaterials[1];
			Skins[6]=MatInvis;
			Skins[7]=MatInvis;
			Skins[8]=MatInvis;
			Skins[13]=MatInvis;
			Skins[14]=MatInvis;
			CamoIndex=1;
		}
		else //Brown [0-20]
		{
			Skins[4]=CamoMaterials[0];
     		BallisticInstantFire(FireMode[0]).FireRate=0.200000;
			Skins[6]=MatInvis;
			Skins[7]=MatInvis;
			Skins[8]=MatInvis;
			Skins[13]=MatInvis;
			Skins[14]=MatInvis;
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

	if (Instigator != None && AIController(Instigator.Controller) == None) //Player Screen ON
	{
		ScreenStart();
		if (!Instigator.IsLocallyControlled())
			ClientScreenStart();
	}
	
	SetBoneScale (2, 0.0, AmplifierBone);

	if (AIController(Instigator.Controller) != None)
		bSilenced = (FRand() > 0.5);

	if (bAmped)
		SetBoneScale (2, 1.0, AmplifierBone);
	else
		SetBoneScale (2, 0.0, AmplifierBone);
	
	if (bSilenced)
		SetBoneScale (0, 1.0, SilencerBone);
	else
		SetBoneScale (0, 0.0, SilencerBone);

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
	 CamoMaterials[9]=Shader'BWBP_SKC_TexExp.Amp.Amp-FinalGreen'	// Amp: Orange
	 CamoMaterials[8]=Shader'BWBP_SKC_TexExp.Amp.Amp-FinalRed'	// Amp: Red
	 CamoMaterials[7]=Texture'BWBP_SKC_TexExp.SRX.SRX-RifleDark'	// Body: Dark
     CamoMaterials[6]=Texture'BWBP_SKC_TexExp.SRX.SRX-StockRedCamo'	// Red vietnam tiger stripes.
     CamoMaterials[5]=Texture'BWBP_SKC_TexExp.SRX.SRX-StockYellowCamo' // Red Stripes
     CamoMaterials[4]=Texture'BWBP_SKC_TexExp.SRX.SRX-StockJungle' // Green Stripes
     CamoMaterials[3]=Texture'BWBP_SKC_TexExp.SRX.SRX-StockRedBlack' // Red and Black
     CamoMaterials[2]=Texture'BWBP_SKC_TexExp.SRX.SRX-StockUrban' // MARPAT desert.
     CamoMaterials[1]=Texture'BWBP_SKC_TexExp.SRX.SRX-StockBlack' // Black
     CamoMaterials[0]=Texture'BWBP_SKC_TexExp.SRX.SRX-Stock'  // Brown.
	 
	 MatInvis=Texture'ONSstructureTextures.CoreGroup.Invisible'
	 MatDarkBody=Texture'BWBP_SKC_TexExp.SRX.SRX-RifleDark'
     MatAltEO=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-BSight-FB'
     MatAltEO2=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-GSight-FB'

	 MyFontColor=(R=255,G=255,B=255,A=255)
     WeaponScreen=ScriptedTexture'BWBP_SKC_TexExp.SRX.SRX-ScriptLCD'
     WeaponScreenShader=Shader'BWBP_SKC_TexExp.SRX.SRX-ScriptLCD-SD'
	 ScreenBase=Texture'BWBP_SKC_TexExp.SRX.SRX-Screen'
	 ScreenAmmoBlue=Texture'BWBP_SKC_TexExp.SRX.SRX-Screen'
	 ScreenAmmoRed=FinalBlend'BWBP_SKC_TexExp.SRX.SRX-ScreenRed-FB'
	 
     AmplifierBone="Amp"
     AmplifierOnAnim="AddAMP"
     AmplifierOffAnim="RemoveAMP"
     AmplifierOnSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOn'
     AmplifierOffSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOff'
	 
	 SilencerBone="Silencer"
     SilencerOnAnim="AddSilencer"
     SilencerOffAnim="RemoveSilencer"
     SilencerOnSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOn'
     SilencerOffSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOff'
	 
	 SightBone="Sight"
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
     WeaponModes(3)=(ModeName="Amplified: Incendiary",ModeID="WM_SemiAuto",Value=1.000000,bUnavailable=True)
     WeaponModes(4)=(ModeName="Amplified: Corrosive",ModeID="WM_Burst",Value=3.000000,bUnavailable=True)
     CurrentWeaponMode=0
     FullZoomFOV=60.000000
     SightPivot=(Pitch=-128,Yaw=16)
//     SightOffset=(X=-2.000000,Z=13.300000)
     SightOffset=(X=-10.000000,Y=-0.700000,Z=26.100000)
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
     FireModeClass(1)=Class'BWBP_SKC_Fix.SRSM2SecondaryFire'
     BringUpTime=0.500000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     bSniping=True
     Description="SRX Battle Rifle||Manufacturer: NDTR Industries|Primary: Powerful Rifle Fire|Secondary: Iron Sights||Popular demand for a civillian variant of the SRS-655 Battle Rifle spurred the creation of the versatile semi-automatic SRS Mod-2 Battle Rifle. Designed and refined in NDTR Industries' top notch R&D labs before the war, the Mod-2 is the precursor to the now-famous SRS-900. Customers can choose from a variety of targeting scopes, calibers and camouflage patterns to personalize their firearm. This specific version has been custom-modified with a suppressor mount and holographic sight. The SRS Mod-2 was awarded a 10 out of 10 by the Gentleman's Rifle Association for amazing precision and accuracy and was quoted to be 'the best gun for big game and home defense!' Gold variants are unfortunately currently out of stock."
     Priority=174
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.SRSM2Pickup'
//     PlayerViewOffset=(X=2.000000,Y=9.000000,Z=-10.000000)
     PlayerViewOffset=(X=-2.000000,Y=10.000000,Z=-20.000000)
     BobDamping=1.800000
     AttachmentClass=Class'BWBP_SKC_Fix.SRSM2Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.SKS650.SmallIcon_SRSM2'
     IconCoords=(X2=127,Y2=31)
     ItemName="SRS Battle Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.SRX_FP'
     DrawScale=0.500000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_TexExp.Amp.Amp-BaseCyan'
     Skins(2)=Texture'BWBP_SKC_TexExp.MG36.MG36-Supp'
     Skins(3)=Texture'BWBP_SKC_TexExp.SRX.SRX-Rifle'
     Skins(4)=Texture'BWBP_SKC_TexExp.SRX.SRX-Stock' //CAMO
     Skins(5)=Texture'BWBP_SKC_TexExp.SRX.SRX-Irons'
     Skins(6)=Texture'BWBP_SKC_TexExp.SRX.SRX-Holo'
     Skins(7)=Texture'BWBP_SKC_TexExp.SRX.SRX-Cable'
     Skins(8)=Texture'BWBP_SKC_TexExp.SRX.SRX-Plating'
     Skins(9)=Texture'BWBP_SKC_TexExp.SRX.SRX-Barrel'
     Skins(10)=Texture'BWBP_SKC_TexExp.SRX.SRX-Misc'
     Skins(11)=Texture'BWBP_SKC_TexExp.SRX.SRX-Muzzle'
     Skins(12)=Texture'UCGeneric.SolidColours.Black'
     Skins(13)=Texture'BWBP_SKC_TexExp.SRX.SRX-ScreenMask'
     Skins(14)=Shader'BWBP_SKC_TexExp.SRX.SRX-Reticle-S'
}
