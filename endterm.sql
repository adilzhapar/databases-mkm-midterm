-- 3
CREATE FUNCTION GetMaxFeeAmount ()
RETURNS INT
AS
BEGIN
    DECLARE @MaxAmount INT
    SELECT @MaxAmount = MAX(Amount) FROM Fee

    -- Check if there are any students with fees
    IF @MaxAmount IS NULL
    BEGIN
        -- Set new fee amount to a default of 100 if there are no existing fees
        SET @MaxAmount = 100
    END

    RETURN @MaxAmount
END

CREATE PROCEDURE IncreaseFeeForNewStudent
    @RollNo INT
AS
BEGIN
    -- Check if student is new
    IF NOT EXISTS (SELECT * FROM Fee WHERE RollNo = @RollNo)
    BEGIN
        -- Calculate new fee amount
        DECLARE @NewAmount INT
        IF ((SELECT SocialVulnerability from Student) = 1)
            SET @NewAmount = dbo.GetMaxFeeAmount() * 0.7
        ELSE
            SET @NewAmount = dbo.GetMaxFeeAmount() * 1.05

        -- Insert new fee record with increased amount
        INSERT INTO Fee (Amount, DateTime, Status, RollNo)
        VALUES (@NewAmount, GETDATE(), 'WAITING', @RollNo)
    END
END;


-- INSERT INTO Student VALUES ('Aibar', 'Zhapar', 4, 4) ;
-- INSERT INTO Student VALUES ('Lionel', 'Messi', 3, 4) ;
-- EXEC IncreaseFeeForNewStudent @RollNo = 1068;

ALTER TABLE Student
add SocialVulnerability INT;

-- 4

CREATE TABLE PotentialStudent (
    id int primary key ,
    FirstName VARCHAR(40),
    LastName VARCHAR(40),
    ExamResult INT
);

CREATE FUNCTION isExamResultEnough(@ExamResult INT)
returns INT
AS
BEGIN
    DECLARE @result INT;
    IF( @ExamResult > 60)
        set @result = 1
    ELSE
        set @result = 0
    return @result
end;

CREATE PROCEDURE CheckPotentialStudentResult
    @id INT
AS
BEGIN
    DECLARE @ExamResult int
    SET @ExamResult = (SELECT ExamResult from PotentialStudent WHERE id = @id);
    IF(dbo.isExamResultEnough(@ExamResult) = 0)
        DELETE FROM PotentialStudent WHERE id=@id;
end

-- INSERT INTO PotentialStudent VALUES (1, 'Torekeldi', 'Niyazbek', 70);
-- EXEC CheckPotentialStudentResult @id=1;


SELECT s.FirstName, s.LastName, sub.Title AS SubjectTitle
FROM Student s
JOIN SectionSubjectStaff sss ON s.SectionID = sss.SectionID
JOIN Subject sub ON sss.SubjectID = sub.SubjectID
WHERE s.RollNo = 2;


