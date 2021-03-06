SET NOCOUNT ON;

SELECT Isnull([failed], 0)      AS Failed,
       Isnull([in progress], 0) AS [In Progress],
       Isnull([success], 0)     AS Success
FROM   (SELECT CASE psdSumm.installstatus
                 WHEN 'Content monitoring' THEN 'Failed'
                 WHEN 'Package installation failed' THEN 'Failed'
                 WHEN 'Retrying package installation' THEN 'Failed'
                 WHEN 'Content updating' THEN 'In Progress'
                 WHEN 'Waiting to install package' THEN 'In Progress'
                 WHEN 'Package Installation complete' THEN 'Success'
               END        AS Status,
               Count(CASE psdSumm.installstatus
                       WHEN 'Content monitoring' THEN 'Failed'
                       WHEN 'Package installation failed' THEN 'Failed'
                       WHEN 'Retrying package installation' THEN 'Failed'
                       WHEN 'Content updating' THEN 'In Progress'
                       WHEN 'Waiting to install package' THEN 'In Progress'
                       WHEN 'Package Installation complete' THEN 'Success'
                     END) AS TotalByStatus
        FROM   v_systemresourcelist srl INNER JOIN v_packagestatusdistpointssumm psdSumm ON psdSumm.servernalpath = srl.nalpath
                                        LEFT OUTER JOIN v_packagestatusrootsummarizer psrSumm ON psrSumm.packageid = psdSumm.packageid
        WHERE  srl.rolename = 'SMS Distribution Point'
        GROUP  BY srl.servername,
                  CASE psdSumm.installstatus
                    WHEN 'Content monitoring' THEN 'Failed'
                    WHEN 'Package installation failed' THEN 'Failed'
                    WHEN 'Retrying package installation' THEN 'Failed'
                    WHEN 'Content updating' THEN 'In Progress'
                    WHEN 'Waiting to install package' THEN 'In Progress'
                    WHEN 'Package Installation complete' THEN 'Success'
                  END) MyTable
       PIVOT ( Sum(totalbystatus) FOR [status] IN ([Failed], [In Progress],  [Success]) ) AS mypivot  