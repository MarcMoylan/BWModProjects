//=============================================================================
// GoldenPistol.
//
// A one-shot 5,000 damage golden gun. A tribute to Goldeneye!
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class GoldenPistol extends BallisticWeapon;

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

simulated function PlayCocking(optional byte Type)
{
	if (Type == 2)
		PlayAnim('Cock', CockAnimRate, 0.2);
	else
		PlayAnim(CockAnim, CockAnimRate, 0.2);
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
// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();

	bUseNetAim = default.bUseNetAim || bScopeView;
	if (bScopeView)
	{
		ViewRecoilFactor = 0.3;
		ChaosDeclineTime *= 1.5;
	}
}



// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()	{	return 0;	}


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
function float SuggestAttackStyle()	{	return 0.3;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

defaultproperties
{
     PlayerSpeedFactor=1.100000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.500000
     BigIconMaterial=Texture'BWBP_SKC_Tex.GoldEagle.BigIcon_GoldEagle'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="999.0;70.0;2.0;125.0;15.0;2.0;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M806.M806Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M806.M806Putaway')
     MagAmmo=1
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-Cock',Volume=5.100000)
     ReloadAnim="Cock"
     ClipHitSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-ClipHit',Volume=2.500000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-ClipOut',Volume=2.500000)
     ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-ClipIn',Volume=2.500000)
     ClipInFrame=0.650000
     bCockOnEmpty=True
     bNeedCock=True
     WeaponModes(0)=(ModeName="Semi-Automatic")
     WeaponModes(1)=(ModeName="Mode-2",bUnavailable=True,Value=7.000000)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     FullZoomFOV=60.000000
     SightPivot=(Pitch=1024,Roll=-1024)
     SightOffset=(X=-10.000000,Y=-7.750000,Z=48.000000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Dot1',Pic2=Texture'BallisticUI2.Crosshairs.Misc8',USize2=256,VSize2=256,Color1=(G=155,R=155,A=217),Color2=(G=0,R=0,A=0),StartSize1=12,StartSize2=11)
     CrosshairInfo=(SpreadRatios=(X1=0.750000,Y1=0.750000,X2=0.300000,Y2=0.300000))
     GunLength=4.000000
     JumpOffSet=(Pitch=1000,Yaw=-500)
     JumpChaos=0.000000
     AimSpread=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000))
     ViewAimFactor=0.150000
     ViewRecoilFactor=0.200000
     ChaosDeclineTime=0.000000
     ChaosTurnThreshold=550000.000000
     ChaosSpeedThreshold=5400.000000
     ChaosAimSpread=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000))
     RecoilYawFactor=0.000000
     RecoilMax=256.000000
     RecoilDeclineTime=0.100000
     RecoilDeclineDelay=0.100000
     FireModeClass(0)=Class'BWBP_SKC_Fix.GoldenFire'
     FireModeClass(1)=Class'BCoreFix.BallisticScopeFire'
     PutDownTime=0.600000
     BringUpTime=0.900000
     SelectForce="SwitchToAssaultRifle"
     bSniping=True
     bUseOldWeaponMesh=True
     Description="The Golden Gun||Manufacturer: Auric Enterprises|Primary: Golden Bullet|Secondary: Iron Sights||One bullet against my six? I only need one."
     Priority=44
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     GroupOffset=10
     PickupClass=Class'BWBP_SKC_Fix.GoldenPickup'
     PlayerViewOffset=(X=-10.000000,Y=17.500000,Z=-22.000000)
     PlayerViewPivot=(Yaw=32768,Roll=16384)
     BobDamping=1.200000
     AttachmentClass=Class'BWBP_SKC_Fix.GoldenAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.GoldEagle.SmallIcon_GoldEagle'
     IconCoords=(X2=127,Y2=31)
     ItemName="The Golden Gun"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.DesertEagle'
     DrawScale=0.900000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_Tex.GoldEagle.GoldEagle-Shine'
}
