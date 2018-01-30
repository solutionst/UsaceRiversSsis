USE [UsaceRiversDW]
GO

-- Create a temporary table for lock chamber dimensions found in the raw input
DROP TABLE IF EXISTS #FoundDimLockChamber;
CREATE TABLE #FoundDimLockChamber (
	[LockChamberId] [int] NULL,
	[District] [varchar](50) NULL,
	[River] [varchar](50) NULL,
	[LockNumber] [tinyint] NULL,
	[LockName] [varchar](50) NULL,
	[ChamberNumber] [tinyint] NULL,
	[TimeCreated] [datetime]  NULL)
  ON [PRIMARY];
GO
INSERT into #FoundDimLockChamber
(District, River, LockNumber, LockName, ChamberNumber)
SELECT DISTINCT [District]
      ,[River]
      ,[LockNumber]
      ,[LockName]
      ,ChamberNumber
  FROM [UsaceRiversDW].[dbo].[InputLockQueue]

-- Update the temp table HourId values
UPDATE #FoundDimLockChamber
SET 
  LockChamberId = lc.LockChamberId
FROM
  DimLockChamber lc RIGHT OUTER JOIN #FoundDimLockChamber f 
  on f.District = lc.District and f.River = lc.River
    AND f.LockNumber = lc.LockNumber AND f.LockName = lc.LockName
	AND f.ChamberNumber = lc.ChamberNumber
WHERE f.LockChamberId is null;

--SELECT * from #FoundDimLockChamber where LockChamberId is not null;

-- Insert the missing dimensions
USE [UsaceRiversDW]
GO

INSERT INTO [dbo].[DimLockChamber]
           ([District]
           ,[River]
           ,[LockNumber]
           ,[LockName]
           ,[ChamberNumber])
     SELECT
		District
		,River
		,LockNumber
		,LockName
		,ChamberNumber
	FROM #FoundDimLockChamber
	WHERE LockChamberId is null;

GO

SELECT * FROM DimLockChamber;

GO

