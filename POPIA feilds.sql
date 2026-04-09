USE [DEV_EV_Data]
GO

SELECT 
    SchemaName = s.name,
    TableName = t.name,
    ColumnName = c.name,
    DataType = ut.name,
    POPIACategory = CASE 
        WHEN c.name LIKE '%IDNumber%' OR c.name LIKE '%Identity%' THEN 'National ID / Passport'
        WHEN c.name LIKE '%Name%' OR c.name LIKE '%Surname%' THEN 'Direct Identifier (Name)'
        WHEN c.name LIKE '%Phone%' OR c.name LIKE '%Cell%' OR c.name LIKE '%Mobile%' THEN 'Contact Detail (Phone)'
        WHEN c.name LIKE '%Email%' THEN 'Contact Detail (Email)'
        WHEN c.name LIKE '%Address%' OR c.name LIKE '%Street%' OR c.name LIKE '%Postal%' THEN 'Physical Location'
        WHEN c.name LIKE '%DOB%' OR c.name LIKE '%Birth%' THEN 'Date of Birth'
        WHEN c.name LIKE '%Gender%' OR c.name LIKE '%Sex%' THEN 'Demographic Info'
        WHEN c.name LIKE '%Race%' OR c.name LIKE '%Ethnicity%' THEN 'Special Personal Info (High Risk)'
        WHEN c.name LIKE '%Medical%' OR c.name LIKE '%Health%' OR c.name LIKE '%Blood%' THEN 'Medical History'
        WHEN c.name LIKE '%Salary%' OR c.name LIKE '%Income%' OR c.name LIKE '%Bank%' OR c.name LIKE '%AccNo%' THEN 'Financial Info'
        ELSE 'Potential PII - Review Needed'104
    END
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.types ut ON c.user_type_id = ut.user_type_id
WHERE 
    c.name LIKE '%Name%'   OR c.name LIKE '%Surname%'  OR
    c.name LIKE '%ID%'     OR c.name LIKE '%Identity%' OR
    c.name LIKE '%Email%'  OR c.name LIKE '%Phone%'    OR
    c.name LIKE '%Cell%'   OR c.name LIKE '%Address%'  OR
    c.name LIKE '%Birth%'  OR c.name LIKE '%DOB%'      OR
    c.name LIKE '%Gender%' OR c.name LIKE '%Sex%'      OR
    c.name LIKE '%Race%'   OR c.name LIKE '%Salary%'   OR
    c.name LIKE '%Bank%'   OR c.name LIKE '%Credit%'   OR
    c.name LIKE '%Health%' OR c.name LIKE '%Medical%'
ORDER BY POPIACategory, TableName;