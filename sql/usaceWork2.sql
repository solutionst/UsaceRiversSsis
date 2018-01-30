USE [UsaceRiversDW]
GO




-- Create a temporary table for hour dimensions found in the raw input
DROP TABLE IF EXISTS #FoundDimHour;
CREATE TABLE #FoundDimHour (
	[HourId] [int] NULL,
	[HourMatch] [varchar](50) NULL,
	[Year] [smallint]  NULL,
	[MonthNumberOfYear] [tinyint]  NULL,
	[DayOfMonth] [tinyint]  NULL,
	[HourOfDay] [tinyint]  NULL,
	[DayNumberOfWeek] [tinyint]  NULL,
	[DayNameOfWeek] [nvarchar](10)  NULL,
	[DayNumberOfYear] [smallint]  NULL,
	[WeekNumberOfYear] [tinyint]  NULL,
	[MonthName] [nvarchar](10)  NULL,
	[CalendarQuarter] [tinyint]  NULL,
	[TimeCreated] [datetime] NULL)
  ON [PRIMARY];
  
-- Find the earliest and latest dates in the InputLockQueue table
DECLARE @MinDate DateTime;
DECLARE @MaxDate DateTime;

SET @MinDate = (SELECT MIN (StartOfLockage) FROM InputLockQueue);
PRINT @MinDate;
SET @MaxDate = (SELECT MAX (StartOfLockage) FROM InputLockQueue);
PRINT @MaxDate;

-- Loop for all dates
DECLARE @LoopDate DateTime;
SET @LoopDate = @MinDate;

WHILE @LoopDate <= @MaxDate
BEGIN

INSERT INTO #FoundDimHour
([HourMatch]
           ,[Year]
           ,[MonthNumberOfYear]
           ,[DayOfMonth]
           ,[HourOfDay]
           ,[DayNumberOfWeek]
           ,[DayNameOfWeek]
           ,[DayNumberOfYear]
           ,[WeekNumberOfYear]
           ,[MonthName]
           ,[CalendarQuarter]
		   )
VALUES (
CAST(DATEPART("yyyy", @LoopDate) AS char(4)) + '-' + 
RIGHT('0' + CAST(DATEPART("mm", @LoopDate) AS varchar), 2) + '-' + 
RIGHT('0' + CAST(DATEPART("dd", @LoopDate) AS varchar), 2) + ' ' + 
RIGHT('0' + CAST(DATEPART("Hh", @LoopDate) AS varchar), 2)
,DATEPART("yyyy", @LoopDate)
,DATEPART("mm", @LoopDate)
,DATEPART("dd", @LoopDate)
,DATEPART("Hh", @LoopDate)
,DATEPART("dw", @LoopDate)
,DATENAME("dw", @LoopDate)
,DATENAME("dy", @LoopDate)
,DATEPART(wk, @LoopDate)
,DATENAME(m, @LoopDate)
,DATEPART(q, @LoopDate)
)

SET @LoopDate = DATEADD(hour, 1, @LoopDate);
END;


GO

select top 200 * from #FoundDimHour;

--SELECT top 100
--CAST(DATEPART("yyyy", StartOfLockage) AS char(4)) + '-' + 
--LEFT('0' + CAST(DATEPART("mm", StartOfLockage) AS char(2)), 2) + '-' + 
--LEFT('0' + CAST(DATEPART("dd", StartOfLockage) AS char(2)), 2) + ' ' + 
--LEFT('0' + CAST(DATEPART("Hh", StartOfLockage) AS char(2)), 2)
--FROM InputLockQueue;
