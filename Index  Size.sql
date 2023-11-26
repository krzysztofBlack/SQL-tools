use ksx

--sp_spaceused ela_bis4

--Drop and Create Temp Tables
IF Object_id(N'tempdb..#Index_Space_Used') IS NOT NULL
  BEGIN
      DROP TABLE #Index_Space_Used
  END

IF Object_id(N'tempdb..#Temp') IS NOT NULL
  BEGIN
      DROP TABLE #Temp
  END

CREATE TABLE #Index_Space_Used
  (
     Table_Name      VARCHAR(100),
     Num_Index_Pages INT
  );

/*----------------------------------------
1:Build the List of Tables with Rows for which Estimation have to be done
------------------------------------------*/


WITH CTE_TableNames
     AS (SELECT 'ela'   AS TableName,
                1000 AS Num_Rows
         UNION ALL
         SELECT 'ela1' AS TableName,
                10000000    AS Num_Rows
                UNION ALL
                SELECT 'ela2' AS TableName,
                10000000   AS Num_Rows)
/*----------------------------------------
2:Get Storage Size for Fixed Column and Variable Columns
------------------------------------------*/
,
     CTE_DataTypes
     AS (SELECT TABLE_NAME,
                TABLE_SCHEMA,
                COLUMN_NAME,
                IS_NULLABLE,
                DATA_TYPE,
                CHARACTER_MAXIMUM_LENGTH,
                CASE
                  WHEN Data_Type = 'Int' THEN 4
                  WHEN DATA_TYPE = 'BigInt' THEN 8
                  WHEN DATA_TYPE = 'TinyInt' THEN 1
                  WHEN DATA_TYPE = 'SmallInt' THEN 2
                  WHEN DATA_TYPE = 'Bit' THEN 1
                  WHEN DATA_TYPE = 'Money' THEN 8
                  WHEN DATA_TYPE = 'SmallMoney' THEN 4
                  WHEN DATA_TYPE = 'SmallDateTime' THEN 4
                  WHEN DATA_TYPE = 'DateTime' THEN 8
                  WHEN DATA_TYPE = 'Date' THEN 3
                  WHEN DATA_TYPE = 'Real' THEN 4
                  WHEN DATA_TYPE = 'Float'
                       AND NUMERIC_PRECISION <= 24 THEN 4
                  WHEN DATA_TYPE = 'Float'
                       AND NUMERIC_PRECISION >= 25 THEN 8
                  WHEN DATA_TYPE IN ( 'Decimal', 'Numeric' )
                       AND NUMERIC_PRECISION <= 9 THEN 5
                  WHEN DATA_TYPE IN ( 'Decimal', 'Numeric' )
                       AND NUMERIC_PRECISION BETWEEN 10 AND 19 THEN 9
                  WHEN DATA_TYPE IN ( 'Decimal', 'Numeric' )
                       AND NUMERIC_PRECISION BETWEEN 20 AND 28 THEN 13
                  WHEN DATA_TYPE IN ( 'Decimal', 'Numeric' )
                       AND NUMERIC_PRECISION BETWEEN 29 AND 38 THEN 17
                  WHEN DATA_TYPE = 'Time'
                       AND DATETIME_PRECISION IN ( 0, 1, 2 ) THEN 3
                  WHEN DATA_TYPE = 'Time'
                       AND DATETIME_PRECISION IN ( 3, 4 ) THEN 4
                  WHEN DATA_TYPE = 'Time'
                       AND DATETIME_PRECISION >= 5 THEN 5
                  WHEN DATA_TYPE = 'DateTime2'
                       AND DATETIME_PRECISION < 3 THEN 6
                  WHEN DATA_TYPE = 'DateTime2'
                       AND DATETIME_PRECISION IN( 3, 4 ) THEN 7
                  WHEN DATA_TYPE = 'DateTime2'
                       AND DATETIME_PRECISION > 4 THEN 8
                  WHEN DATA_TYPE = 'DateTimeoffset'
                       AND DATETIME_PRECISION < 3 THEN 8
                  WHEN DATA_TYPE = 'DateTimeoffset'
                       AND DATETIME_PRECISION IN( 3, 4 ) THEN 9
                  WHEN DATA_TYPE = 'DateTimeoffset'
                       AND DATETIME_PRECISION > 4 THEN 10
                  ELSE CHARACTER_OCTET_LENGTH --This is going to cover CHAR,NCHAR,VARCHAR,NVARCHAR Columns
                END AS SIZE_IN_BYTES
         FROM   INFORMATION_SCHEMA.COLUMNS),
     CTE_Num_Cols
     AS (SELECT TD.Table_NAME,
                Count(TD.COLUMN_NAME) Num_Cols,
                Sum(SIZE_IN_BYTES)    AS SIZE_IN_BYTES,
                TN.Num_Rows
         FROM   CTE_DataTypes TD
                INNER JOIN CTE_TableNames TN
                        ON TD.TABLE_NAME = TN.TableName
         GROUP  BY TD.Table_NAME,
                   TN.Num_Rows),
     NullBitMap_RowSize
     AS (SELECT Table_Name,
                Num_Rows,
                Num_Cols,
                Size_In_Bytes,
                2 + ( ( Num_Cols + 7 ) / 8 )                         AS NullBitMap,
                Size_In_Bytes + ( 2 + ( ( Num_Cols + 7 ) / 8 ) ) + 4 AS Row_Size,
                Size_In_Bytes + ( 2 + ( ( Num_Cols + 7 ) / 8 ) ) + 4 + 1--(for row header overhead of an index row)
                + 7--(for the child page ID pointer)
                                                                     AS Index_Row_Size
         FROM   CTE_Num_Cols),
     Rows_Per_Page
     AS (SELECT TABLE_NAME,
                Num_Rows,
                Num_Cols,
                SIZE_IN_BYTES,
                NullBitMap,
                Row_Size,
                8096 / ( Row_Size + 2 )       AS Rows_Per_Page,
                Index_Row_Size,
                8096 / ( Index_Row_Size + 2 ) AS Index_Rows_Per_Page
         FROM   NullBitMap_RowSize),
     Free_Rows_Per_Page
     AS (SELECT TABLE_NAME,
                Num_Rows,
                Num_Cols,
                SIZE_IN_BYTES,
                NullBitMap,
                Row_Size,
                Rows_Per_Page,
                Ceiling(8096 * ( ( 100 - 95 ) / 100.0 ) / ( Row_Size + 2 )) AS Free_Rows_Per_Page,
                Index_Row_Size,
                Index_Rows_Per_Page
         FROM   Rows_Per_Page),
     Num_Leaf_Pages
     AS (SELECT TABLE_NAME,
                Num_Rows,
                Num_Cols,
                SIZE_IN_BYTES,
                NullBitMap,
                Row_Size,
                Rows_Per_Page,
                Free_Rows_Per_Page,
                Ceiling(Num_Rows / ( Rows_Per_Page - Free_Rows_Per_Page )) AS Num_Leaf_Pages,
                Index_Row_Size,
                Index_Rows_Per_Page
         FROM   Free_Rows_Per_Page),
     Leaf_Space_Used
     AS (SELECT TABLE_NAME,
                Num_Rows,
                Num_Cols,
                SIZE_IN_BYTES,
                NullBitMap,
                Row_Size,
                Rows_Per_Page,
                Free_Rows_Per_Page,
                Num_Leaf_Pages,
                8192 * Num_Leaf_Pages                                                           AS Leaf_Space_used_In_Bytes,
                Ceiling(( 8192 * Num_Leaf_Pages ) / 1024)                                       AS Leaf_Space_used_in_KB,
                Index_Row_Size,
                Index_Rows_Per_Page,
                Ceiling(1 + Log (Index_Rows_Per_Page) * ( Num_Leaf_Pages / Index_Rows_Per_Page )) AS Non_leaf_Levels
         FROM   Num_Leaf_Pages)
SELECT *
INTO   #Temp
FROM   Leaf_Space_Used

--Calculate the number of non-leaf pages
DECLARE @TableName VARCHAR(100)
DECLARE Table_Cursor CURSOR FOR
  SELECT Table_Name
  FROM   #Temp

OPEN Table_Cursor

FETCH NEXT FROM Table_Cursor INTO @TableName

WHILE @@FETCH_STATUS = 0
  BEGIN
      DECLARE @Cnt INT
      DECLARE @Num_Leaf_Pages INT
      DECLARE @Non_Leaf_Levels INT
      DECLARE @Index_Row_Per_Page INT
      DECLARE @VarSUM INT

      SET @VarSUM=0

      SELECT @Num_Leaf_Pages = Num_Leaf_Pages,
             @Non_Leaf_Levels = Non_Leaf_Levels,
             @Index_Row_Per_Page = Index_Rows_Per_Page
      FROM   #Temp
      WHERE  TABLE_NAME = @TableName

      WHILE ( @Non_Leaf_Levels <> 0 )
        BEGIN
            BEGIN TRY
                SET @VarSUM=@VarSUM + ( Ceiling(Cast(@Num_Leaf_Pages AS NUMERIC(38, 0)) / Power(Cast(@Index_Row_Per_Page AS NUMERIC(38, 0)), @Non_Leaf_Levels)) )
            END TRY

            BEGIN CATCH
            END CATCH

            SET @Non_Leaf_Levels=@Non_Leaf_Levels - 1
        END

      INSERT INTO #Index_Space_Used
      VALUES      (@TableName,
                   @VarSUM)

      FETCH NEXT FROM Table_Cursor INTO @TableName
  END

CLOSE Table_Cursor

DEALLOCATE Table_Cursor

SELECT T.*,
       ISU.Num_Index_Pages,
       T.Leaf_Space_used_in_KB
       + Ceiling(((8192*ISU.Num_Index_Pages)/1024)) AS Clustered_Index_Size_in_KB
FROM   #Temp T
       INNER JOIN #Index_Space_Used ISU
               ON T.TABLE_NAME = ISU.Table_Name

