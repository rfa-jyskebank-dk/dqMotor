USE [DataKvalitet]
GO
/****** Object:  StoredProcedure [DQRestricted].[danKoerselsListe]    Script Date: 20-03-2025 14:28:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
;

ALTER   PROCEDURE [DQRestricted].[danKoerselsListe]
(
    @Debug BIT = 0,
    @ErrorMessage NVARCHAR(4000) OUTPUT,
    @afviklingsdato DATETIME2(6) = NULL,
    @regelIdListe NVARCHAR(4000) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrorSeverity INTEGER;
    DECLARE @ErrorState INTEGER;

    IF (@afviklingsdato IS NULL)
    BEGIN
        SET @afviklingsdato = CONVERT(DATE, GETDATE());
    END;

    DROP TABLE IF EXISTS #REGEL_ID_LISTE;

    SELECT regelId
    INTO #regelListeId
    FROM DQRestricted.regelBeskrivelse
    WHERE 1 = 0;

    IF (@regelIdListe IS NULL)
    BEGIN
        INSERT INTO #regelListeId
        (
            regelId
        )
        SELECT regelId
        FROM DQRestricted.regelBeskrivelse;
    END;
    ELSE
    BEGIN
        INSERT INTO #regelListeId
        (
            regelId
        )
        SELECT regelId
        FROM DQRestricted.regelBeskrivelse
        WHERE regelId IN
              (
                  SELECT value FROM STRING_SPLIT(@regelIdListe, ',')
              );
    END;

    -- Use a set-based approach instead of a cursor
    INSERT INTO DQRestricted.regelKoeselsListe
    (
        [beskrivelseVersionsnummer],
        [regelId],
        [maalingId],
        [afviklingsdato],
        [afviklingsStatus]
    )
    SELECT rb.versionsnummer,
           rb.regelId,
           NULL,
           @afviklingsdato,
           NULL
    FROM DQRestricted.regelBeskrivelse rb
        LEFT JOIN DQRestricted.regelKoeselsListe rkl
            ON rb.regelId = rkl.regelId
               AND rkl.afviklingsdato = @afviklingsdato
    WHERE rb.status IN ( 1 )
          AND rkl.afviklingsdato IS NULL
          AND NOT EXISTS
    (
        SELECT 1 FROM #regelListeId rl WHERE rl.regelId = rkl.regelId
    )
          AND (
              rb.afviklingsfrekvens = 'ALLEDAGE'
              OR EXISTS
              (
                  SELECT 1
                  FROM DQRestricted.frekvensOpslagsdatoMapping fdm
                  JOIN DQRestricted.kalender k
                      ON k.DATO = @afviklingsdato
                      AND k.[fdm.jnKolonne] = 'J'
                  WHERE fdm.frekvens = rb.afviklingsfrekvens
              )
          );

    IF @Debug = 1
    BEGIN
        PRINT 'Inserted rows into DQRestricted.regelKoeselsListe';
    END;

END;