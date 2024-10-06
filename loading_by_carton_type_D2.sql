﻿WITH isdts AS (
SELECT DISTINCT WHISDT AS iisdt FROM SHV21BAPD.CUDHDR00 WHERE WHSTAT='10' LIMIT 1
),
totaltotal as (
SELECT 
--Substr(chmis8, 2, 8) AS "ISDT",
chcrtp as TOTTYPE,
Cast(Nvl(Count(DISTINCT chcasn), 1) AS FLOAT) AS "TOTALCTNS", cast(NVL(count(case when chstat IN ('60', '85') and prtxtp = '800' AND prtxcd = '006' then prcasn end),1) as FLOAT) AS "CTNS",
CAST(count(case when prtxtp = '800' AND prtxcd = '006' and usDept='TASKERS' then prcasn end) as FLOAT) AS "LOADED",
CAST(count(case when prtxtp = '800' AND prtxcd = '006' and usDept<>'TASKERS' then prcasn end) as FLOAT) AS "LOADED2",
 CHMIS1--, case when chstat='85' then 'Y' else 'N' end as CLOSED
--FROM shv21bapd.chcart00
FROM shv21bapd.prtran00
JOIN shv21bapd.chcart00 ON prcasn = chcasn
JOIN shv21bapd.ususer00 ON ususer = pruser
WHERE chmis8 <> ''
AND Substr(chmis8, 2, 8) IN (SELECT trim(iisdt) FROM isdts)
AND CHMIS1='0002'
AND CHCRTP<>'TST'
AND CHSTAT<>'99'
GROUP BY chcrtp ,CHMIS1--, chstat, prtxtp, prtxcd, usdept
),
/*
totalcartons AS (
SELECT 
Substr(chmis8, 2, 8) AS "ISDT",
Cast(Nvl(Count(DISTINCT chcasn), 0) AS FLOAT) AS "CTNS", chcrtp as TYPE
FROM shv21bapd.chcart00
JOIN shv21bapd.prtran00 ON prcasn = chcasn
--JOIN shv21bapd.ususer00 ON ususer = pruser
WHERE chmis8 <> ''
AND Substr(chmis8, 2, 8) IN (SELECT trim(iisdt) FROM isdts)
AND prtxtp = '800'
AND prtxcd = '006'
AND chstat IN ('60', '85')
AND CHMIS1='0006'
AND CHCRTP<>'TST'
GROUP BY Substr(chmis8, 2, 8), chcrtp

), loaded AS (
SELECT 
Substr(chmis8, 2, 8) AS "INSTORE",
--usdept AS "WM_DEPARTMENT",
Cast(Count(DISTINCT prcasn) AS FLOAT) AS "LOADED", chcrtp as TYPE1
FROM shv21bapd.prtran00
JOIN shv21bapd.chcart00 ON prcasn = chcasn
JOIN shv21bapd.ususer00 ON ususer = pruser
WHERE prtxtp = '800'
AND prtxcd = '006'
AND chmis8 <> ''
and usDept='TASKERS'
AND Substr(chmis8, 2, 8) IN (SELECT trim(iisdt) FROM isdts)
AND CHMIS1 = '0006'
GROUP BY Substr(chmis8, 2, 8), chcrtp 
ORDER BY Substr(chmis8, 2, 8) DESC

),
loaded1 AS (
SELECT 
Substr(chmis8, 2, 8) AS "INSTORE",
--usdept AS "WM_DEPARTMENT",
Cast(Count(DISTINCT prcasn) AS FLOAT) AS "LOADED2", chcrtp as TYPE2
FROM shv21bapd.prtran00
JOIN shv21bapd.chcart00 ON prcasn = chcasn
JOIN shv21bapd.ususer00 ON ususer = pruser
WHERE prtxtp = '800'
AND prtxcd = '006'
AND chmis8 <> ''
and usDept<>'TASKERS'
AND Substr(chmis8, 2, 8) IN (SELECT trim(iisdt) FROM isdts)
AND CHMIS1 = '0006'
GROUP BY Substr(chmis8, 2, 8), chcrtp
ORDER BY Substr(chmis8, 2, 8) DESC), */
TYPES AS ( SELECT CASE WHEN ctcrtp IN ('AMT','AMC','AMN','ACT','ACC','FRC','FRT','HVT','PRC','PRT', 'TST','FRH','HZC','HZT') THEN 'Wholesale'
    when ctcrtp in ('AMP','CLP','CLC') then 'PTS' when ctcrtp in ('BKR') then 'Bakery' when ctcrtp in ('CSY','PIZ') then 'CSY' when ctcrtp in ('CGT','CGU') then 'CIG' END AS TYPE99, ctcrtp
    FROM SHV21BAPD.CtCART00
    --where ctcrtp not in ('TST')
    ORDER BY 1)
SELECT
    DISTINCT ctcrtp "CARTON TYPE",
    (select iisdt "INSTORE DATE" from isdts),
    NVL(TOTALCTNS,0) as "TOTAL CARTONS",
    NVL(loaded2, 0) AS "RF SCANNED CARTONS",
    NVL(loaded, 0) AS "TASKER SCANNED CARTONS",
  NVL(round(( (NVL(loaded2, 0) +NVL(loaded, 0)) ), 2),0) AS "TOTAL SCANNED CARTONS",
  NVL(round(( ((NVL(loaded2, 0) ) / NULLIF(ctns,0)  )* 100), 2),0) AS "RF SCANNED%",
  NVL(round(( ((NVL(loaded, 0) ) / NULLIF(ctns,0)  )* 100), 2),0) AS "TASKER SCANNED%",
  NVL(round(( ((NVL(loaded2, 0) +NVL(loaded, 0)) / TOTALCTNS  )* 100), 2),0) AS "TOTAL SCANNED%"
  --case when (select count(CLOSED) from totalcartons) = 5 then 1 else 0 end as "NOTIFY"
  
 -- NVL(round(( (NVL(loaded, 0) / ctns  )* 100), 2),0) AS "TASKER%LOADED"
FROM TYPES
/*
 left JOIN LOADED ON CTCRTP=TYPE1
left JOIN LOADED1 ON CTCRTP=TYPE2
left JOIN totalcartons ON CTCRTP=TYPE
*/
LEFT JOIN totaltotal ON CTCRTP=TOTTYPE
WHERE TYPE99=?
AND CTCRTP NOT IN ('CGU','CLC','TST','PIZ')
group by  ctcrtp , LOADED2, LOADED, CTNS, TOTALCTNS, TYPE99--, CLOSED
ORDER BY CTCRTP