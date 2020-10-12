//=============================================================================
// LS14Attachment.
//
// Third person actor for the LS-14 Laser Carbine.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class LS14Attachment extends BallisticAttachment;

var Vector		SpawnOffset;
var bool		bDouble, FireIndex;


replication
{
	// Things the server should send to the client.
	reliable if(Role==ROLE_Authority)
		bDouble;
}

simulated function SpawnTracer(byte Mode, Vector V)
{
	local TraceEmitter_LS14C TER;
	local TraceEmitter_LS14B TEL;
	local TraceEmitter_LS14B TEA;
	local float Dist;

	if (VSize(V) < 2)
		V = Instigator.Location + Instigator.EyePosition() + V * 10000;
	Dist = VSize(V-GetTipLocation());

	// Spawn Trace Emitter Effect
	if (bDouble || (LS14Carbine(Instigator.weapon) != None && LS14Carbine(Instigator.weapon).CurrentWeaponMode == 1))
	{
		TER = Spawn(class'TraceEmitter_LS14C', self, , GetTipLocation(), Rotator(V - GetTipLocation()));
		TEL = Spawn(class'TraceEmitter_LS14B', self, , GetTipLocationStyleTwo(), Rotator(V - GetTipLocation()));
		TEL.Initialize(Dist, 1);
		TER.Initialize(Dist, 1);
	}
 	else if (level.Netmode != NM_Standalone)
 	{
  		TEA = Spawn(class'TraceEmitter_LS14B', self, , GetTipLocation(), Rotator(V - GetTipLocation()));
  		TEA.Initialize(Dist, 1);
 	}
	else if (!LS14Carbine(Instigator.weapon).bBarrelsOnline && LS14Carbine(Instigator.weapon).CurrentWeaponMode == 0)
	{
		TEA = Spawn(class'TraceEmitter_LS14B', self, , GetTipLocation(), Rotator(V - GetTipLocation()));
		TEA.Initialize(Dist, 1);
	}
	else
	{
		TER = Spawn(class'TraceEmitter_LS14C', self, , GetTipLocationStyleTwo(), Rotator(V - GetTipLocation()));
		TER.Initialize(Dist, 1);
	}



/*	if (bDouble)
	{
		TER = Spawn(class'TraceEmitter_LS14C', self, , GetTipLocation(), Rotator(V - GetTipLocation()));
		TEL = Spawn(class'TraceEmitter_LS14B', self, , GetTipLocationStyleTwo(), Rotator(V - GetTipLocation()));
		TEL.Initialize(Dist, 1);
		TER.Initialize(Dist, 1);
	}
	else if (FireIndex)
	{
		TEA = Spawn(class'TraceEmitter_LS14B', self, , GetTipLocation(), Rotator(V - GetTipLocation()));
		TEA.Initialize(Dist, 1);
	}
	else
	{
		TER = Spawn(class'TraceEmitter_LS14C', self, , GetTipLocationStyleTwo(), Rotator(V - GetTipLocation()));
		TER.Initialize(Dist, 1);
	}
	FireIndex = !FireIndex; */
}


simulated function Vector GetTipLocation()
{
    local Vector X, Y, Z, Loc;

	if (Instigator.IsFirstPerson())
	{

		if (LS14Carbine(Instigator.Weapon).bScopeView)
		{
			Instigator.Weapon.GetViewAxes(X,Y,Z);
				Loc = Instigator.Location + Instigator.EyePosition() + X*20 + Z*-10;
		}
		else
		{
			Loc = Instigator.Weapon.GetBoneCoords('tip').Origin + class'BUtil'.static.AlignedOffset(Instigator.GetViewRotation(), SpawnOffset);
		}
	}
	else
		Loc = GetBoneCoords('tip').Origin;
	if (VSize(Loc - Instigator.Location) > 200)
		return Instigator.Location;
    return Loc;
}

simulated function Vector GetTipLocationStyleTwo()
{
    local Vector X, Y, Z, Loc;

	if (Instigator.IsFirstPerson())
	{

		if (LS14Carbine(Instigator.Weapon).bScopeView)
		{
			Instigator.Weapon.GetViewAxes(X,Y,Z);
			Loc = Instigator.Location + Instigator.EyePosition() + X*20 + Z*-10;
		}
		else
			Loc = Instigator.Weapon.GetBoneCoords('tip2').Origin + class'BUtil'.static.AlignedOffset(Instigator.GetViewRotation(), SpawnOffset);
	}
	else
		Loc = GetBoneCoords('tip2').Origin + Y*200;
	if (VSize(Loc - Instigator.Location) > 200)
		return Instigator.Location;
    return Loc;
}

simulated function EjectBrass(byte Mode);

defaultproperties
{
//     SpawnOffset=(X=-160.000000,Z=2.000000)
     SpawnOffset=(X=-30.000000)
     AltFlashBone="tip3"
     MuzzleFlashClass=Class'BWBP_SKC_Fix.GRSXXLaserFlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.M50M900FlashEmitter'
     ImpactManager=Class'BWBP_SKC_Fix.IM_LS14Impacted'
     BrassClass=Class'BallisticFix.Brass_Railgun'
     FlashMode=MU_Both
     LightMode=MU_Both
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_LS14C'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=Sound'BWBP_SKC_Sounds.LS14.Gauss-FlyBy',Volume=0.700000)
     FlyByBulletSpeed=-1.000000
	bRapidFire=true;
     RelativeLocation=(X=-3.000000,Z=2.000000)
     RelativeRotation=(Pitch=32768)
     Mesh=SkeletalMesh'BWBP_SKC_Anim.3RD-LS14'
     DrawScale=0.200000
}
