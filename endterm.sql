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
        SET @MaxAmount = 1000000
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


SELECT s.FirstName, s.LastName, sub.Title AS SubjectTitle, sub.SubjectID
FROM Student s
JOIN SectionSubjectStaff sss ON s.SectionID = sss.SectionID
JOIN Subject sub ON sss.SubjectID = sub.SubjectID
WHERE s.RollNo = 3;


-- 4.2
CREATE TABLE ExamResult (
    ResultID INT IDENTITY(1, 1) PRIMARY KEY,
    RollNo INT FOREIGN KEY REFERENCES Student(RollNo),
    SubjectID INT FOREIGN KEY REFERENCES Subject(SubjectID),
    ExamDate DATETIME,
    Score FLOAT
);

INSERT INTO ExamResult VALUES (1, 1, '2023-04-12', 90);
INSERT INTO ExamResult VALUES (1, 2, '2023-04-12', 95);
INSERT INTO ExamResult VALUES (1, 3, '2023-04-12', 100);

INSERT INTO ExamResult VALUES (2, 1, '2023-04-12', 70);
INSERT INTO ExamResult VALUES (2, 2, '2023-04-12', 90);
INSERT INTO ExamResult VALUES (2, 3, '2023-04-12', 88);


INSERT INTO ExamResult VALUES (3, 1, '2023-04-12', 100);
INSERT INTO ExamResult VALUES (3, 2, '2023-04-12', 58);


ALTER TABLE Student
ADD ExamStatus VARCHAR(20)
CHECK (ExamStatus in ('not started', 'pass', 'fail'));


CREATE FUNCTION StudentAllExamResults(@RollNo INT)
RETURNS INT
AS
BEGIN
    DECLARE @result INT
    DECLARE @minResult INT = (SELECT MIN(Score) FROM ExamResult WHERE RollNo=@RollNo);
    IF (@minResult < 75)
        SET @result = 0
    ELSE
        SET @result = 1
    RETURN @result
end;


CREATE PROCEDURE SetStudentExamStatus
    @RollNo INT
AS
BEGIN
    DECLARE @ExamStatus VARCHAR(20)
    DECLARE @result INT = (dbo.StudentAllExamResults(@RollNo));
    if (@result = 1)
        set @ExamStatus = 'pass'
    else
        set @ExamStatus = 'fail'
    UPDATE Student SET ExamStatus=@ExamStatus WHERE RollNo=@RollNo;
end;

EXEC SetStudentExamStatus @RollNo=3;



-- set ERD
CREATE TABLE Qualification (
    QualificationID INT IDENTITY(1, 1) PRIMARY KEY,
    StaffID INT references Staff(StaffID),
    CourseTitle VARCHAR(50),
    DateCompleted DATE,
    Status VARCHAR(10),
    CHECK (Status IN ('COMPLETED', 'IN PROCESS', 'FAILED', 'REFUSED'))
);

CREATE TABLE AttendanceTeacher (
    AttendanceTeacherID INT IDENTITY (1, 1) PRIMARY KEY,
    ScheduleID INT REFERENCES Schedule(ScheduleID),
    StartTime timestamp
);
CREATE TABLE Attendance (
    AttendanceID INT IDENTITY (1,1) PRIMARY KEY,
    RollNo INT REFERENCES Student(RollNo),
    ScheduleID INT REFERENCES Schedule(ScheduleID),
    Present INT,
    CHECK (Present IN (1, 0))
);