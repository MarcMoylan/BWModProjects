//=============================================================================
// R78NSRifle.
//
// Powerful, accurate rifle with quick cocking after each shot and reasonable
// reload time, but low clip capacity. Secondary fire makes it use the iron
// sights. This is a No Scoped version of the R78A1.
//
// Makes use of Camo System V4. Online functional!
//
// by Sergeant Kelly with an imported bit from Kaboodles
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class R78NSRifle extends BallisticCamoWeapon;

var() name		ScopeBone;			// Bone to use for hiding scope

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

simulated function AdjustCamoProperties(int Index)
{
	local float f;

		f = FRand();
		if ( (Index == -1 && f > 0.99) || Index == 8)
		{
			Skins[0]=CamoMaterials[8];
			bAimDisabled=True;
			GunLength = 0;
			BallisticInstantFire(FireMode[0]).Damage = 130;
			BallisticInstantFire(FireMode[0]).DamageHead = 190;
			BallisticInstantFire(FireMode[0]).DamageLimb = 70;
			CamoIndex=8;
		}
		else if ( (Index == -1 && f > 0.97) || Index == 7)
		{
			Skins[0]=CamoMaterials[7];
			CockAnimRate=1.5;
			ReloadAnimRate=1.25;
			CamoIndex=7;
		}
		else if ( (Index == -1 && f > 0.95) ||  Index == 6)
		{
			Skins[0]=CamoMaterials[6];
			CockAnimRate=0;
			ReloadAnimRate=0.8;
			BallisticInstantFire(FireMode[0]).Damage = 95;
			BallisticInstantFire(FireMode[0]).DamageHead = 140;
			BallisticInstantFire(FireMode[0]).DamageLimb = 40;
			CamoIndex=6;
		}
		else if ( (Index == -1 && f > 0.85) || Index == 5)
		{
			Skins[0]=CamoMaterials[5];
			BallisticInstantFire(FireMode[0]).Damage = 115;
			BallisticInstantFire(FireMode[0]).DamageHead = 180;
			BallisticInstantFire(FireMode[0]).DamageLimb = 50;
			CrouchAimFactor		= 0.7;
			RecoilYawFactor		*= 0.7;
			ChaosTurnThreshold	*= 0.8;
			RecoilXFactor		*= 0.6;
			RecoilYFactor		*= 0.6;
			ChaosSpeedThreshold	*= 0.8;
			CamoIndex=5;
		}
		else if ( (Index == -1 && f > 0.75) || Index == 4)
		{
			Skins[0]=CamoMaterials[4];
			BallisticInstantFire(FireMode[0]).Damage = 115;
			BallisticInstantFire(FireMode[0]).DamageHead = 180;
			BallisticInstantFire(FireMode[0]).DamageLimb = 55;
			CrouchAimFactor		= 0.7;
			RecoilYawFactor		*= 0.7;
			ChaosTurnThreshold	*= 0.8;
			RecoilXFactor		*= 0.6;
			RecoilYFactor		*= 0.6;
			ChaosSpeedThreshold	*= 0.8;
			CamoIndex=4;
		}
		else if ( (Index == -1 && f > 0.60) || Index == 3)
		{
			Skins[0]=CamoMaterials[3];
			CamoIndex=3;
		}
		else if ( (Index == -1 && f > 0.40) || Index == 2)
		{
			Skins[0]=CamoMaterials[2];
			CamoIndex=2;
		}
		else if ( (Index == -1 && f > 0.20) || Index == 1)
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



simulated function BringUp(optional Weapon PrevWeapon)
{
	SetBoneScale (0, 0.0, ScopeBone);
	super.BringUp(PrevWeapon);

}



simulated function PlayCocking(optional byte Type)
{
	if (Type == 2 && HasAnim(CockAnimPostReload))
		SafePlayAnim(CockAnimPostReload, CockAnimRate, 0.2, , "RELOAD");
	else
		SafePlayAnim(CockAnim, CockAnimRate, 0.2, , "RELOAD");

	if (SightingState != SS_None && Type != 1)
		TemporaryScopeDown(0.5);
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
function byte BestMode()	{	return 0;	}

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
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny',SkinNum=2)
     TeamSkins(1)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny',SkinNum=3)
     BigIconMaterial=Texture'BWBP_SKC_Tex.NoScope.BigIcon_R98'
     BallisticInventoryGroup=7
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="280.0;25.0;0.5;60.0;2.5;0.0;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.R78.R78Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.R78.R78Putaway')
     MagAmmo=5
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.R78NS.R78NS-Cock')
     ClipHitSound=(Sound=Sound'BallisticSounds2.R78.R78-ClipHit')
     ClipOutSound=(Sound=Sound'BallisticSounds2.R78.R78-ClipOut')
     ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.R78NS.R78NS-ClipIn')
     ClipInFrame=0.650000
     ScopeBone="Scope"

     CamoMaterials[8]=Shader'BWBP_SKC_Tex.NoScope.GoldRifle-Shine'
     CamoMaterials[7]=Shader'BWBP_SKC_Tex.NoScope.R98_Fire-SD'
     CamoMaterials[6]=Shader'BWBP_SKC_Tex.NoScope.R98_Winter-SD'
     CamoMaterials[5]=Shader'BWBP_SKC_Tex.NoScope.R98_RTiger-SD'
     CamoMaterials[4]=Shader'BWBP_SKC_Tex.NoScope.R98_JTiger-SD'
     CamoMaterials[3]=Texture'BWBP_SKC_Tex.NoScope.RifleSkinUrbanCamo'
     CamoMaterials[2]=Texture'BWBP_SKC_Tex.NoScope.RifleSkinDesertCamo'
     CamoMaterials[1]=Shader'BWBP_SKC_Tex.NoScope.R98_UTiger-SD'
     CamoMaterials[0]=Shader'BallisticWeapons2.R78.R78_Main-SD'
     CamoIndex=-1

     bNeedCock=True
     WeaponModes(0)=(ModeName="Single Fire")
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     FullZoomFOV=50.000000
     bNoCrosshairInScope=True
     SightPivot=(Pitch=-32,Roll=-1024)
     SightOffset=(X=10.000000,Y=-1.180000,Z=11.950000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.R78OutA',Pic2=Texture'BallisticUI2.Crosshairs.M50InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(A=81),StartSize1=66,StartSize2=57)
     GunLength=80.000000
     CrouchAimFactor=0.300000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     AimAdjustTime=0.400000
     AimSpread=(X=(Min=-512.000000,Max=512.000000),Y=(Min=-256.000000,Max=256.000000))
     ViewAimFactor=0.350000
     JumpChaos=0.200000
     FallingChaos=0.100000
     SprintChaos=0.400000
     SightAimFactor=0.200000
     ChaosDeclineTime=0.850000
     CrosshairChaosFactor=1.000000
//     ChaosTurnThreshold=120000.000000
     ChaosSpeedThreshold=800.000000
     ChaosAimSpread=(X=(Min=-1024.000000,Max=1024.000000),Y=(Min=-512.000000,Max=512.000000))
     RecoilYawFactor=0.100000
     RecoilXFactor=0.200000
     RecoilYFactor=0.250000
     RecoilDeclineTime=1.000000
     RecoilDeclineDelay=0.300000
     FireModeClass(0)=Class'BWBP_SKC_Fix.R78NSPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.R78ScopeFire'
     BringUpTime=0.200000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     bSniping=True
     Description="R98 Hunting Rifle||Manufacturer: UTC Defense Tech|Primary: Single Powerful Shot|Secondary: Engage Iron-Sights||The R98 Hunting Rifle is the designated civillian version of the popular R78A1 Sniper Rifle. While it lacks the military scope and superb accuracy of the original, the R98 is still a force to be reckoned with. Comes with a variety of custom camo finishes and a quick action bolt perfect for hunting in the woods. (Good for approx 300 uses.) Like the R78, the R98 is only as good as the soldier using it."
     DisplayFOV=55.000000
     Priority=202
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.R78NSPickup'
     PlayerViewOffset=(X=8.000000,Y=4.000000,Z=-10.000000)
     BobDamping=1.800000
     AttachmentClass=Class'BWBP_SKC_Fix.R78NSAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.NoScope.SmallIcon_R98'
     IconCoords=(X2=127,Y2=31)
     ItemName="R98 Hunting Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.R78Noscope'
	Skins(0)=Shader'BallisticWeapons2.R78.R78_Main-SD'
     DrawScale=0.450000
}
