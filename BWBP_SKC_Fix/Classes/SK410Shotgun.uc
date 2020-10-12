//=============================================================================
// SK410Shotgun.
//
// The SK410 auto shottie, aka the LASERLASER
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SK410Shotgun extends BallisticCamoWeapon;
var bool		bFirstDraw;

var name			BulletBone;


replication
{
	reliable if(Role == ROLE_Authority)
		ClientSwitchCannonMode;
}

function ServerSwitchWeaponMode (byte NewMode)
{
	super.ServerSwitchWeaponMode(NewMode);
		
	if (!Instigator.IsLocallyControlled())
		SK410PrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
	ClientSwitchCannonMode (CurrentWeaponMode);
}

simulated function ClientSwitchCannonMode (byte newMode)
{
	SK410PrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (bFirstDraw && MagAmmo > 0)
	{
     		BringUpTime=2.0;
     		SelectAnim='PulloutFancy';
		bFirstDraw=false;
	}
	else
	{
     		BringUpTime=default.BringUpTime;
		SelectAnim='Pullout';
	}
	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		SetBoneScale(0,0.0,BulletBone);
		ReloadAnim = 'ReloadEmpty';
	}
	else
	{
		ReloadAnim = 'Reload';
	}
	

	Super.BringUp(PrevWeapon);
	GunLength = default.GunLength;
}

simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();
		if ((Index == -1 && f > 0.99) || Index == 6) // 1%
		{
			Skins[1]=CamoMaterials[6];
			ReloadAnimRate=2;
			CockAnimRate=2;
			WeaponModes[0].bUnavailable=true;
			WeaponModes[1].bUnavailable=true;
			WeaponModes[2].bUnavailable=false;
			WeaponModes[3].bUnavailable=true;
     			RecoilXFactor		=0.001;
     			RecoilYFactor		=0.001;
     			RecoilYawFactor		=0.001;
     			RecoilPitchFactor	=0.001;
			RecoilDeclineDelay=0;
			RecoilDeclineTime=0.2;
			ChaosDeclineTime=0.2;
     			CurrentWeaponMode=2;
			super.ServerSwitchWeaponMode(2);
			if (!Instigator.IsLocallyControlled())
				SK410PrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
			ClientSwitchCannonMode (CurrentWeaponMode);
			CamoIndex=6;
		}

		else if ((Index == -1 && f > 0.97) || Index == 5) // 2%
		{
			Skins[1]=CamoMaterials[5];
			CamoIndex=5;
		}
		else if ((Index == -1 && f > 0.95) || Index == 4) // 2%
		{
			Skins[1]=CamoMaterials[4];
			WeaponModes[0].bUnavailable=true;
			WeaponModes[1].bUnavailable=true;
			WeaponModes[2].bUnavailable=true;
			WeaponModes[3].bUnavailable=false;
     			CurrentWeaponMode=3;
			super.ServerSwitchWeaponMode(3);
			if (!Instigator.IsLocallyControlled())
				SK410PrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
			ClientSwitchCannonMode (CurrentWeaponMode);
			CamoIndex=4;
		}
		else if ((Index == -1 && f > 0.90) || Index == 3) // 5%
		{
			Skins[1]=CamoMaterials[3];
			CamoIndex=3;
		}
		else if ((Index == -1 && f > 0.85) || Index == 2) //5%
		{	
			Skins[1]=CamoMaterials[2];
			CamoIndex=2;
		}
		else if ((Index == -1 && f > 0.70) || Index == 1) //15%
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


simulated function PlayReload()
{

    if (MagAmmo < 1)
       ReloadAnim='ReloadEmpty';
    else
       ReloadAnim='Reload';

	SafePlayAnim(ReloadAnim, ReloadAnimRate, , 0, "RELOAD");
}

// Animation notify for when the clip is stuck in
simulated function Notify_ClipUp()
{
	SetBoneScale(0,1.0,BulletBone);
}

simulated function Notify_ClipOut()
{
	Super.Notify_ClipOut();

	if(MagAmmo < 1)
		SetBoneScale(0,0.0,BulletBone);
}

simulated event AnimEnd (int Channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

	if (Anim == 'Fire' || Anim == 'ReloadEmpty')
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
		{
			SetBoneScale(0,0.0,BulletBone);
		}
	}
	super.AnimEnd(Channel);
}


// Animation notify for when cocking action starts. Used to time sounds
simulated function Notify_CockSim()
{
	PlayOwnedSound(CockSound.Sound,CockSound.Slot,CockSound.Volume,CockSound.bNoOverride,CockSound.Radius,CockSound.Pitch,CockSound.bAtten);
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
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_Tex.SK410.BigIcon_SK410'
     BallisticInventoryGroup=3
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Shotgun=True
     bWT_Machinegun=True
     BulletBone="Bullet1"

     CamoMaterials[0]=Texture'BWBP_SKC_Tex.SK410.SK410-Main'
     CamoMaterials[1]=Texture'BWBP_SKC_Tex.SK410.SK410-C-CamoSnow' //Snow
     CamoMaterials[2]=Texture'BWBP_SKC_Tex.SK410.SK410-UC-CamoJungle' //Jungle
     CamoMaterials[3]=Texture'BWBP_SKC_Tex.SK410.SK410-UC-CamoDigital' //Digital
     CamoMaterials[4]=Texture'BWBP_SKC_Tex.SK410.SK410-R-CamoTiger' //Tiger
     CamoMaterials[5]=Texture'BWBP_SKC_Tex.SK410.SK410-R-CamoBlood' //Bloodied
     CamoMaterials[6]=Shader'BWBP_SKC_Tex.SK410.SK410-Charged' //Corrupt

     SpecialInfo(0)=(Info="300.0;30.0;0.5;60.0;0.0;1.0;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M763.M763Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M763.M763Putaway')
     MagAmmo=6
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.Saiga.SK410-Cock',Volume=1.400000)
     ReloadAnim="Reload"
     ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.Saiga.SK410-MagIn',Volume=1.300000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_Sounds.Saiga.SK410-MagOut',Volume=1.300000)
     bCockOnEmpty=False
     bNeedCock=False
     bFirstDraw=True
     bCanSkipReload=False
     bShovelLoad=False
     WeaponModes(0)=(ModeName="Automatic",ModeID="WM_FullAuto")
     WeaponModes(1)=(ModeName="Automatic Slug",ModeID="WM_FullAuto")
     WeaponModes(2)=(ModeName="0451-EXECUTE",bUnavailable=True,ModeID="WM_FullAuto")
     WeaponModes(3)=(ModeName="Rapid Fire",bUnavailable=True,ModeID="WM_FullAuto")
     CurrentWeaponMode=0
     SightPivot=(Pitch=150)
     SightOffset=(X=-8.000000,Y=-10.000000,Z=21.000000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M763OutA',Pic2=Texture'BallisticUI2.Crosshairs.M763InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=255,G=255,A=192),Color2=(G=0,A=192),StartSize1=113,StartSize2=120)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.375000,X2=1.000000,Y2=1.000000),SizeFactors=(X1=0.750000,X2=0.750000),MaxScale=8.000000)
     GunLength=48.000000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     JumpOffSet=(Pitch=1000,Yaw=-3000)
     ChaosAimSpread=(X=(Min=-1960.000000,Max=1960.000000),Y=(Min=-1960.000000,Max=1960.000000))
     JumpChaos=0.700000
     ViewAimFactor=0.250000
     ViewRecoilFactor=0.900000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=-0.100000),(InVal=0.300000,OutVal=-0.200000),(InVal=1.000000,OutVal=-0.300000)))
     RecoilYCurve=(Points=(,(InVal=0.300000,OutVal=0.500000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.000000
     RecoilXFactor=0.400000
     RecoilYFactor=0.400000
     RecoilMax=4096.000000
     RecoilDeclineTime=1.500000
     RecoilDeclineDelay=0.300000
     SightingTime=0.250000
     FireModeClass(0)=Class'BWBP_SKC_Fix.SK410PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.SK410SecondaryFire'
     AIRating=0.600000
     CurrentRating=0.600000
     Description="SK-410 Assault Shotgun||Manufacturer: Zavod Tochnogo Voorujeniya (ZTV Export)|Primary: 8-Gauge Explosive Shot|Secondary: Melee||The SK-410 shotgun is a large-bore, compact shotgun based off the popular AK-490 design. While it is illegal on several major planets, this powerful weapon and its signature explosive shotgun shells are almost ubiquitous. A weapon originally designed for breaching use, the SK-410 is now found in the hands of civillians and terrorists throughout the worlds. It had become so prolific with outer colony terrorist groups that the UTC began the SKAS assault weapon program in an effort to find a powerful shotgun of their own."
     Priority=245
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=7
     PickupClass=Class'BWBP_SKC_Fix.SK410Pickup'
     PlayerViewOffset=(X=-4.000000,Y=13.000000,Z=-16.000000)
     BobDamping=1.700000
     PutDownTime=0.800000
     BringUpTime=1.000000
     AttachmentClass=Class'BWBP_SKC_Fix.SK410Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.Sk410.SmallIcon_SK410'
     IconCoords=(X2=127,Y2=35)
     ItemName="SK-410 Assault Shotgun"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=25
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.SK410_FP'
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_Tex.SK410.SK410-Main'
     Skins(2)=Texture'BWBP_SKC_Tex.SK410.SK410-Misc'
     Skins(3)=Shader'BWBP_SKC_Tex.SK410.SK410-LightsOn'
     DrawScale=0.350000
}
