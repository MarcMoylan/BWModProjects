//=============================================================================
// PS9mPistol.
//
// Soviet assassin pistol. Fires darts that blur screen. Alt is medical dart.
// This gun is for cool people.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class PS9mPistol extends BallisticCamoHandGun;


var() name		GrenBone;			
var() name		GrenBoneBase;
var() name		GrenadeLoadAnim;	//Anim for grenade reload
var   bool		bLoaded;


var() Sound		GrenSlideSound;		//Sounds for grenade reloading
var() Sound		GrenLoadSound;		//	

var() sound		PartialReloadSound;	// Silencer stuck on sound
var() name		HealAnim;		// Anim for murdering Simon
var() sound		HealSound;		// The sound of a thousand dying orphans


simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();

		if ((Index == -1 && f > 0.95) || Index == 3) //5% Tiger
		{
			Skins[1]=CamoMaterials[3];
			CamoIndex=3;
		}
		else if ((Index == -1 && f > 0.85) || Index == 2) //10% Jungle
		{
			Skins[1]=CamoMaterials[2];
			CamoIndex=2;
		}
		else if ((Index == -1 && f > 0.75) || Index == 1) //10% Black
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

simulated function bool SlaveCanUseMode(int Mode) {return Mode == 0;}
simulated function bool MasterCanSendMode(int Mode) {return Mode == 0;}

simulated function BringUp(optional Weapon PrevWeapon)
{

	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		AimSpread *= 0.50;
		ChaosAimSpread *= 0.50;
	}


	if (!bLoaded)
	{
		SetBoneScale (0, 0.0, GrenBone);
		SetBoneScale (1, 0.0, GrenBoneBase);
	}

	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		ReloadAnim = 'ReloadOpen';
		IdleAnim = 'IdleOpen';
	}
	else
	{
		ReloadAnim = 'Reload';
		IdleAnim = 'Idle';
	}

	super.BringUp(PrevWeapon);

}

function ServerWeaponSpecial(optional byte i)
{
	if (bLoaded)
	{
		PlayAnim(HealAnim, 1.1, , 0);
		ReloadState = RS_Cocking;
	}
}



//simulated function DoWeaponSpecial(optional byte i)
exec simulated function WeaponSpecial(optional byte i)
{
	if (ReloadState != RS_None)
		return;
	if (Clientstate != WS_ReadyToFire)
		return;
	TemporaryScopeDown(0.5);
	ServerWeaponSpecial();
	if (bLoaded)
	{
		PlayAnim(HealAnim, 1.1, , 0);
		ReloadState = RS_Cocking;
	}
}

simulated function Notify_DartHeal()
{
	PlaySound(HealSound, SLOT_Misc, 1.5, ,64);
	DoDartEffect(Instigator, Instigator);
	Ammo[1].UseAmmo (1, True);
	bLoaded = false;
}

static function DoDartEffect(Actor Victim, Pawn Instigator)
{
	local PS9mDartHeal HP;

	if(Pawn(Victim) == None || Vehicle(Victim) != None || Pawn(Victim).Health <= 0)
		Return;


	HP = Victim.Level.Spawn(class'PS9mDartHeal', Pawn(Victim).Owner);

	HP.Instigator = Instigator;

    if(Victim.Role == ROLE_Authority && Instigator != None && Instigator.Controller != None)
		HP.InstigatorController = Instigator.Controller;

	HP.Initialize(Victim);
}

// Load in a grenade
simulated function LoadGrenade()
{
	if (Ammo[1].AmmoAmount < 1 || bLoaded)
		return;
	if (ReloadState == RS_None)
		PlayAnim(GrenadeLoadAnim, 1.1, , 0);
}


// Notifys for greande loading sounds
simulated function Notify_GrenVisible()	{	SetBoneScale (0, 1.0, GrenBone); SetBoneScale (1, 1.0, GrenBoneBase);	ReloadState = RS_PreClipOut;}
simulated function Notify_GrenLoaded()	
{
	PS9mAttachment(ThirdPersonActor).bGrenadier=true;
	PS9mAttachment(ThirdPersonActor).IAOverride(True);	
	PlaySound(GrenLoadSound, SLOT_Misc, 0.5, ,64);	
	Ammo[1].UseAmmo (1, True);
}
simulated function Notify_GrenReady()	{	ReloadState = RS_None; bLoaded = true;	}
simulated function Notify_GrenLaunch()	
{
	SetBoneScale (0, 0.0, GrenBone); 
	PS9mAttachment(ThirdPersonActor).IAOverride(False);
	PS9mAttachment(ThirdPersonActor).bGrenadier=false;	
}
simulated function Notify_GrenInvisible()	{ SetBoneScale (1, 0.0, GrenBoneBase);	}


simulated function PlayReload()
{

    if (MagAmmo < 1)
    {
       ReloadAnim='ReloadOpen';
       ClipInSound.Sound=default.ClipInSound.Sound;
    }
    else
    {
       ReloadAnim='Reload';
       ClipInSound.Sound=PartialReloadSound;
    }
	SafePlayAnim(ReloadAnim, ReloadAnimRate, , 0, "RELOAD");
}

simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);
	if (Anim == HealAnim)
		ReloadState = RS_None;
	if (Anim == 'FireOpen' || Anim == 'Pullout' || Anim == 'Fire' || Anim == 'Dart_Fire' || Anim == 'Dart_FireOpen' ||Anim == CockAnim || Anim == ReloadAnim)
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
		{
			IdleAnim = 'IdleOpen';
			ReloadAnim = 'ReloadOpen';
		}
		else
		{
			IdleAnim = 'Idle';
			ReloadAnim = 'Reload';
		}
	}
	Super.AnimEnd(Channel);
}


simulated function bool CanAlternate(int Mode)
{
	if (Mode != 0)
		return false;
	return super.CanAlternate(Mode);
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
		SetBoneScale(8, 0.0, SupportHandBone);
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
		SetBoneScale(8, 1.0, SupportHandBone);
		bUseSpecialAim = false;
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
     AIRating=0.600000
     AIReloadTime=1.000000
     AttachmentClass=Class'BWBP_SKC_Fix.PS9mAttachment'
     BallisticInventoryGroup=4
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     BigIconMaterial=Texture'BWBP_SKC_TexExp.Stealth.BigIcon_PS9M'
     bLoaded=False
     bNeedCock=True
     BobDamping=2.000000
     BringUpSound=(Sound=Sound'BWBP_SKC_SoundsExp.Stealth.Stealth-Pickup')
     bWT_Bullet=True
     CamoMaterials[0]=Texture'BWBP_SKC_TexExp.Stealth.Stealth-Main'
     CamoMaterials[1]=Texture'BWBP_SKC_TexExp.Stealth.Stealth-Black'
     CamoMaterials[2]=Texture'BWBP_SKC_TexExp.Stealth.Stealth-TigerGreen'
     CamoMaterials[3]=Texture'BWBP_SKC_TexExp.Stealth.Stealth-Tiger'
     ChaosAimSpread=(X=(Min=-1748.000000,Max=1748.000000),Y=(Min=-1748.000000,Max=1748.000000))
     ClipHitSound=(Sound=Sound'BWBP_SKC_SoundsExp.Stealth.Stealth-MagInS1',Volume=1.200000)
     ClipInFrame=0.650000
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.Stealth.Stealth-MagIn',Volume=1.200000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.Stealth.Stealth-MagOut',Volume=1.200000)
     CockSound=(Sound=Sound'BallisticSounds2.M806.M806-Cock')
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Cross4',pic2=Texture'BallisticUI2.Crosshairs.A73OutA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=25,G=122,R=11,A=255),Color2=(B=255,G=255,R=255,A=255),StartSize1=22,StartSize2=59)
     CrouchAimFactor=0.500000
     CurrentRating=0.600000
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     Description=" PS-9m Stealth Pistol||Manufacturer: Zavod Tochnogo Voorujeniya (ZTV Export)|Primary: Tranquilizer Dart Fire|Secondary: FMD Medical Dart||The PS-9m Stealth Pistol is a rare weapon seldom seen outside the walls of the Earth-based Russian Federation and black ops PMCs. It is mainly used as a tool for covert assassination and as such fires darts filled with highly potent neurotoxins. Every dart carries a 100% chance of death without medical aid and a 95% chance with. Subjects injected with the concoction report immediate vision impairment and excruciating pain, after 20 minutes subjects lose the ability to respond, and after 1 hour lethal convulsions set in. In order to make up for that unacceptable 95% success rate, the stealth pistol additionally comes with a fully automatic firing mode. This has been a cause for major concern, because there have been several times where the weapon's rapid fire recoil has directed darts into hapless civilians. It should be noted that the PS-9m's darts are instantly lethal on a headshot and are additionally filled with corrosive acids to neutralize mechanized threats. General Alexi 'Rasputin' Volkov is the only known man to have survived more than 9 darts and famously killed his attacker in hand-to-hand combat."
     DrawScale=0.300000
     FireModeClass(0)=Class'BWBP_SKC_Fix.PS9mPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.PS9mSecondaryFire'
     GrenadeLoadAnim="DartOn"
     GrenBone="Dart"
     GrenBoneBase="MuzzleAttachment"
     GrenLoadSound=Sound'BallisticSounds2.M50.M50GrenLoad'
     GrenSlideSound=Sound'BallisticSounds2.M50.M50GrenOpen'
     HealAnim="Heal"
     HealSound=Sound'BWBP_SKC_SoundsExp.Stealth.Stealth-Heal'
     IconCoords=(X2=127,Y2=31)
     IconMaterial=Texture'BWBP_SKC_TexExp.Stealth.SmallIcon_PS9M'
     InventoryGroup=2
     ItemName="PS-9m Stealth Pistol"
     LightBrightness=150.000000
     LightEffect=LE_NonIncidence
     LightHue=30
     LightRadius=4.000000
     LightSaturation=150
     LightType=LT_Pulse
     MagAmmo=10
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.Stealth_FP'
	 //Mesh=SkeletalMesh'BallisticAnims_25.MD24'
     PartialReloadSound=Sound'BWBP_SKC_SoundsExp.Stealth.Stealth-MagInS2'
     PickupClass=Class'BWBP_SKC_Fix.PS9mPickup'
     PlayerViewOffset=(X=3.000000,Y=-2.000000,Z=-8.500000)
     Priority=65
     PutDownSound=(Sound=Sound'BallisticSounds2.M806.M806Putaway')
     PutDownTime=0.700000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilXFactor=0.300000
     RecoilYawFactor=0.400000
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYFactor=0.200000
     SelectForce="SwitchToAssaultRifle"
     SightDisplayFOV=40.000000
     SightingTime=0.200000
     SightOffset=(X=-10.000000,Y=11.40000,Z=11.50000)
     SightPivot=(Pitch=1024)
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_TexExp.Stealth.Stealth-Main'
     SpecialInfo(0)=(Info="320.0;25.0;1.0;110.0;2.0;0.1;0.1")
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     ViewAimFactor=0.200000
     ViewRecoilFactor=0.600000
     WeaponModes(0)=(ModeName="Semi-Automatic")
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(ModeName="Repeating")
}
