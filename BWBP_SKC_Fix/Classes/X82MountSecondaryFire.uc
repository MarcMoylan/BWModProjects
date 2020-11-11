class X82MountSecondaryFire extends M353SecondaryFire;

function DoFireEffect()
{
	if (BallisticTurret(Instigator) != None)
//		X82Rifle_TW(Weapon).Notify_Undeploy();
		FireAnim='Undeploy';
	else
		X82Rifle(Weapon).Notify_Deploy();
}
simulated function bool AllowFire()
{
	if (BallisticTurret(Instigator) == None && Instigator.HeadVolume.bWaterVolume)
		return false;
	return super.AllowFire();
}

defaultproperties
{
     FireRate=1.000000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_50BMG'
}
