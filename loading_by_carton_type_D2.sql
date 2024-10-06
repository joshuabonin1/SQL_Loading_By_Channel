WITH isdts AS (
             SELECT DISTINCT WHISDT AS iisdt
                 FROM SHV21BAPD.CUDHDR00
                 WHERE WHSTAT = '10'
                 LIMIT 1),
     totaltotal AS (
         SELECT
--Substr(chmis8, 2, 8) AS "ISDT",
             chcrtp AS TOTTYPE,
             CAST(Nvl(COUNT(DISTINCT chcasn), 1) AS FLOAT) AS "TOTALCTNS",
             CAST(NVL(COUNT(
                         CASE
                             WHEN chstat IN ('60', '85')
                                 AND prtxtp = '800'
                                 AND prtxcd = '006' THEN prcasn
                         END), 1) AS FLOAT) AS "CTNS",
             CAST(COUNT(
                     CASE
                         WHEN prtxtp = '800'
                             AND prtxcd = '006'
                             AND usDept = 'TASKERS' THEN prcasn
                     END) AS FLOAT) AS "LOADED",
             CAST(COUNT(
                     CASE
                         WHEN prtxtp = '800'
                             AND prtxcd = '006'
                             AND usDept <> 'TASKERS' THEN prcasn
                     END) AS FLOAT) AS "LOADED2",
             CHMIS1--,
             CASE
                 WHEN chstat = '85' THEN 'Y'
                 ELSE 'N'
             END AS CLOSED
--FROM shv21bapd.chcart00
             FROM shv21bapd.prtran00
                  JOIN shv21bapd.chcart00
                      ON prcasn = chcasn
                  JOIN shv21bapd.ususer00
                      ON ususer = pruser
             WHERE chmis8 <> ''
                   AND SUBSTR(chmis8, 2, 8) IN (SELECT TRIM(iisdt)
                           FROM isdts)
                   AND CHMIS1 = '0002'
                   AND CHCRTP <> 'TST'
                   AND CHSTAT <> '99'
             GROUP BY chcrtp,
                      CHMIS1--,
                      chstat,
                      prtxtp,
                      prtxcd,
                      usdept
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
     TYPES AS (
             SELECT
                    CASE
                        WHEN
                            ctcrtp IN ('AMT',
                                'AMC', 'AMN', 'ACT', 'ACC', 'FRC', 'FRT', 'HVT', 'PRC', 'PRT', 'TST', 'FRH', 'HZC', 'HZT')
                            THEN 'Wholesale'
                        WHEN ctcrtp IN ('AMP', 'CLP', 'CLC') THEN 'PTS'
                        WHEN ctcrtp IN ('BKR') THEN 'Bakery'
                        WHEN ctcrtp IN ('CSY', 'PIZ') THEN 'CSY'
                        WHEN ctcrtp IN ('CGT', 'CGU') THEN 'CIG'
                    END AS TYPE99,
                    ctcrtp
                 FROM SHV21BAPD.CtCART00
                     --where ctcrtp not in ('TST')
                 ORDER BY 1)
    SELECT DISTINCT ctcrtp "CARTON TYPE",
                    (SELECT iisdt "INSTORE DATE"
                            FROM isdts),
                    NVL(TOTALCTNS, 0) AS "TOTAL CARTONS",
                    NVL(loaded2, 0) AS "RF SCANNED CARTONS",
                    NVL(loaded, 0) AS "TASKER SCANNED CARTONS",
                    NVL(ROUND(((NVL(loaded2, 0) + NVL(loaded, 0))),
                            2), 0) AS "TOTAL SCANNED CARTONS",
                    NVL(ROUND((((NVL(loaded2, 0)) / NULLIF(ctns, 0)) * 100),
                            2), 0) AS "RF SCANNED%",
                    NVL(ROUND((((NVL(loaded, 0)) / NULLIF(ctns, 0)) * 100),
                            2), 0) AS "TASKER SCANNED%",
                    NVL(ROUND((((NVL(loaded2, 0) + NVL(loaded, 0)) / TOTALCTNS) * 100),
                            2), 0) AS "TOTAL SCANNED%"
                        --case when (select count(CLOSED) from totalcartons) = 5 then 1 else 0 end as "NOTIFY"
                        -- NVL(round(( (NVL(loaded, 0) / ctns  )* 100), 2),0) AS "TASKER%LOADED"
        FROM TYPES
/*
 left JOIN LOADED ON CTCRTP=TYPE1
left JOIN LOADED1 ON CTCRTP=TYPE2
left JOIN totalcartons ON CTCRTP=TYPE
*/
             LEFT JOIN totaltotal
                 ON CTCRTP = TOTTYPE
        WHERE TYPE99 = ? -- '?' character used as parameter from loading by channel module
              AND CTCRTP NOT IN ('CGU', 'CLC', 'TST', 'PIZ')
        GROUP BY ctcrtp,
                 LOADED2,
                 LOADED,
                 CTNS,
                 TOTALCTNS,
                 TYPE99--,
                 CLOSED
        ORDER BY CTCRTP
