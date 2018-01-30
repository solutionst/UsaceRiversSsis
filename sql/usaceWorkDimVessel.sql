USE [UsaceRiversDW]
GO

-- Create a temporary table for lock chamber dimensions found in the raw input
DROP TABLE IF EXISTS #FoundDimVessel;
CREATE TABLE #FoundDimVessel (
	[VesselId] [int]  NULL,
	[VesselName] [varchar](50) NULL,
	[VesselNumber] [varchar](50) NULL,
	[VesselType] [varchar](50) NULL,
	[TimeCreated] [datetime] NULL)
  ON [PRIMARY];
GO

INSERT into #FoundDimVessel
(VesselName, VesselNumber)
SELECT DISTINCT 
VesselName, VesselNumber
  FROM [UsaceRiversDW].[dbo].[InputLockQueue]

--SELECT * from #FoundDimVessel;

-- Update the temp table HourId values
UPDATE #FoundDimVessel
SET 
  VesselId = v.vesselId
FROM
  DimVessel v RIGHT OUTER JOIN #FoundDimVessel f 
  on f.VesselName = v.VesselName and f.VesselNumber = v.VesselNumber
WHERE f.VesselId is null;

--SELECT * from #FoundDimVessel where LockChamberId is not null;

-- Insert the missing dimensions
USE [UsaceRiversDW]
GO

INSERT INTO [dbo].DimVessel
           (VesselName, VesselNumber)
     SELECT
		VesselName, VesselNumber
	FROM #FoundDimVessel
	WHERE VesselId is null;

GO

-- SELECT * FROM DimVessel;

GO

