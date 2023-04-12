CREATE TABLE Staff (
    StaffID serial PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50)
);


CREATE TABLE Salary (
    SalaryID serial  PRIMARY KEY,
    StaffID INT,
    Amount INT,
    DatePaid DATE,
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

CREATE TABLE Class (
    ClassID serial  PRIMARY KEY,
    Title VARCHAR(20),
    StaffID INT  references Staff(StaffID)
);

CREATE TABLE Subject (
    SubjectID serial PRIMARY KEY,
    Title VARCHAR(40)
);

CREATE TABLE Section (
    SectionID serial PRIMARY KEY ,
    Title VARCHAR(40)
);

CREATE TABLE Room (
    RoomID serial  PRIMARY KEY ,
    Room_number INT,
    RoomType VARCHAR(20),
    ClassID INT REFERENCES Class(ClassID),
    SectionID INT REFERENCES Section(SectionID),
    CHECK (RoomType IN ('classroom', 'laboratory'))
);

CREATE TABLE Student (
    RollNo serial  PRIMARY KEY ,
    FirstName VARCHAR(40),
    LastName VARCHAR(40),
    SectionID INT references Section(SectionID),
    ClassID INT references Class(ClassID)
);

CREATE TABLE Fee (
    FeeID serial  PRIMARY KEY,
    Amount INT,
    DateTime DATE,
    Status VARCHAR(10),
    RollNo INT REFERENCES Student(RollNo),
    CHECK (Status IN ('PAID', 'WAITING'))
);


CREATE TABLE Schedule (
    ScheduleID serial  PRIMARY KEY ,
    StartTime timestamp,
    EndTime timestamp,
    RoomID INT  REFERENCES Room(RoomID),
    ClassID INT  REFERENCES Class(ClassID),
    SubjectID INT  REFERENCES Subject(SubjectID)
);

CREATE TABLE SectionSubjectStaff (
    SectionID INT REFERENCES Section(SectionID),
    SubjectID INT REFERENCES Subject(SubjectID),
    StaffID INT references Staff(StaffID),
    PRIMARY KEY (SectionID, SubjectID, StaffID)
);

INSERT INTO Staff(firstname, lastname) VALUES('Askar', 'Akshabayev');
INSERT INTO Staff(firstname, lastname) VALUES('Beisenbek', 'Baisakov');
INSERT INTO Staff(firstname, lastname) VALUES('Bobur', 'Mukhsimbaev');
INSERT INTO Staff(firstname, lastname) VALUES('Askar', 'Djumadildaev');

INSERT INTO Salary(staffid, amount, datepaid)  VALUES(1, 400000, '2023-02-22');
INSERT INTO Salary(staffid, amount, datepaid)   VALUES(2, 300000, '2023-02-20');
INSERT INTO Salary(staffid, amount, datepaid)   VALUES(3, 400000, '2023-02-18');
INSERT INTO Salary(staffid, amount, datepaid)   VALUES(4, 1000000, '2023-02-24');

INSERT INTO Class(title, staffid) VALUES('11A', 1);
INSERT INTO Class(title, staffid) VALUES('10B', 2);
INSERT INTO Class(title, staffid) VALUES('9C', 3);
INSERT INTO Class(title, staffid) VALUES('8G', 4);

INSERT INTO Subject(title) VALUES('Math');
INSERT INTO Subject(title) VALUES('PE');
INSERT INTO Subject(title) VALUES('Physics');
INSERT INTO Subject(title) VALUES('History');

INSERT INTO Section(title) VALUES ('Arystan');
INSERT INTO Section(title) VALUES ('Dostyq');
INSERT INTO Section(title) VALUES ('Bereke');
INSERT INTO Section(title) VALUES ('Qanat');

INSERT INTO Room(room_number, roomtype, classid, sectionid) VALUES(100, 'classroom', 1, 1);
INSERT INTO Room(room_number, roomtype, classid, sectionid) VALUES(101, 'classroom', 2, 2);
INSERT INTO Room(room_number, roomtype, classid, sectionid) VALUES(200, 'laboratory', 3, 3);
INSERT INTO Room(room_number, roomtype, classid, sectionid) VALUES(202, 'laboratory', 4, 4);

INSERT INTO Student(firstname, lastname, sectionid, classid) VALUES ('Bauyrzhan', 'Turdalin', 1, 1);
INSERT INTO Student(firstname, lastname, sectionid, classid) VALUES ('Nurasyl', 'Balgaziev', 1, 1);
INSERT INTO Student(firstname, lastname, sectionid, classid) VALUES ('Adil', 'Ashim', 2, 2);
INSERT INTO Student(firstname, lastname, sectionid, classid) VALUES ('Zhaqsylyq', 'Zhapar', 2, 2);
INSERT INTO Student(firstname, lastname, sectionid, classid) VALUES ('Torekeldi', 'Kipshakbaev', 3, 3);
INSERT INTO Student(firstname, lastname, sectionid, classid) VALUES ('Sanzhar', 'Niyazbek', 3, 3);
INSERT INTO Student(firstname, lastname, sectionid, classid) VALUES ('Danyiar', 'Mukhambetov', 4, 4);
INSERT INTO Student(firstname, lastname, sectionid, classid) VALUES ('Nurtay', 'Zholdaskaliev', 4, 4);


INSERT INTO Fee(amount, datetime, status, rollno) VALUES (33500, '2023-01-16', 'PAID', 1)
INSERT INTO Fee(amount, datetime, status, rollno) VALUES (67000, '2023-01-16', 'PAID', 2)
INSERT INTO Fee(amount, datetime, status, rollno) VALUES (180000, '2022-12-16', 'PAID', 3)
INSERT INTO Fee(amount, datetime, status, rollno) VALUES (100000, '2022-11-20', 'PAID', 4)
INSERT INTO Fee(amount, datetime, status, rollno) VALUES (12000, '2023-03-22', 'WAITING', 5)
INSERT INTO Fee(amount, datetime, status, rollno) VALUES (33500, '2023-03-08', 'WAITING', 6)
INSERT INTO Fee(amount, datetime, status, rollno) VALUES (39000, '2023-04-01', 'WAITING', 7)
INSERT INTO Fee(amount, datetime, status, rollno) VALUES (60000, '2023-04-11', 'WAITING', 8)

INSERT INTO Schedule(starttime, endtime, roomid, classid, subjectid) VALUES ('20230222 10:00:00 AM', '20230222 12:00:00', 1, 1, 1);
INSERT INTO Schedule(starttime, endtime, roomid, classid, subjectid) VALUES ('20230222 12:00:00 PM', '20230222 14:00:00', 2, 2, 2);
INSERT INTO Schedule(starttime, endtime, roomid, classid, subjectid) VALUES ('20230222 12:00:00 PM', '20230222 14:00:00', 1, 2, 2);
INSERT INTO Schedule(starttime, endtime, roomid, classid, subjectid) VALUES ('20230222 10:00:00 AM', '20230222 16:00:00', 3, 3, 3);
INSERT INTO Schedule(starttime, endtime, roomid, classid, subjectid) VALUES ('20230222 16:00:00', '20230222 18:00:00', 3, 3, 4);
INSERT INTO Schedule(starttime, endtime, roomid, classid, subjectid) VALUES ('20230222 9:00:00 AM', '20230222 11:00:00', 4, 4, 4);
INSERT INTO Schedule(starttime, endtime, roomid, classid, subjectid) VALUES ('20230222 13:00:00', '20230222 15:00:00', 4, 3, 4);



SELECT * FROM Student
    join Class C on Student.ClassID = C.ClassID
join Staff S on S.StaffID = C.StaffID AND C.StaffID = 2;

SELECT *
FROM Staff
    INNER JOIN SectionSubjectStaff SSS on Staff.StaffID = SSS.StaffID
    INNER JOIN Subject S on SSS.SubjectID = S.SubjectID

SELECT s.ScheduleID,Staff.FirstName, Staff.LastName, Sj.title, S.StartTime
FROM Staff
    INNER JOIN Class C on Staff.StaffID = C.StaffID
    INNER JOIN Schedule S on C.ClassID = S.ClassID
    INNER JOIN Subject Sj ON S.SubjectID = Sj.SubjectID where C.StaffID=3

SELECT FirstName,LastName, Title, StartTime, EndTime, RoomID FROM Student
    INNER JOIN Schedule S on Student.ClassID = S.ClassID
    INNER JOIN Subject S2 on S.SubjectID = S2.SubjectID

-- 1 Процедура оценивания персонала школы.
-- Преподавательский состав школы состоит из сотрудников с полным высшим образованием.
-- v Раз в три года каждый из учителей обязан пройти курсы повышения квалификации.
-- v Прикрепленный триггер должен сработать в случае успешного завершения курсов и увеличить заработную плату сотрудников на 15%.
-- v Учителя, не прошедшие курсы повышения квалификации, остаются на повторную сдачу через полгода,
-- v в период которого не допускаются к преподавательской деятельности.
-- v Отказ от прохождения курсов влечет за собой увольнение и
-- v полное удаление данных о преподавателе из базы данных школы. (1.2 pts)

CREATE TABLE Qualification (
    QualificationID serial PRIMARY KEY,
    StaffID INT references Staff(StaffID),
    CourseTitle VARCHAR(50),
    DateCompleted DATE,
    Status VARCHAR(10),
    CHECK (Status IN ('COMPLETED', 'IN PROCESS', 'FAILED', 'REFUSED'))
);

-- В случае успешного завершения курсов и увеличить заработную плату сотрудников на 15%.

CREATE OR REPLACE FUNCTION update_salary() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    update salary set Amount = Amount * 1.15 where StaffID = NEW.StaffId;
    RETURN NEW;
END $$;

CREATE TRIGGER update_salary_trigger
    AFTER UPDATE ON qualification
    FOR EACH ROW
    WHEN (OLD.Status = 'IN PROCESS' and NEW.Status = 'COMPLETED')
    EXECUTE FUNCTION update_salary();

insert into qualification(staffid, coursetitle, datecompleted, status) values (1, 'Databases' , '11.04.2023', 'IN PROCESS');
update qualification set status = 'COMPLETED' where staffid = 1;



--Учителя, не прошедшие курсы повышения квалификации
CREATE OR REPLACE FUNCTION deleteFromSchedule() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    delete from schedule where scheduleid in
    (SELECT s.ScheduleID FROM Staff
        INNER JOIN Class C on Staff.StaffID = C.StaffID
        INNER JOIN Schedule S on C.ClassID = S.ClassID
        INNER JOIN Subject Sj ON S.SubjectID = Sj.SubjectID
        where Staff.StaffID = NEW.StaffId and S.StartTime >= NEW.DateCompleted::date  and NEW.DateCompleted::date + INTERVAL '6 MONTH' >= S.StartTime );
    RETURN NEW;
END $$;

CREATE TRIGGER failedExam
    AFTER UPDATE ON qualification
    FOR EACH ROW
    WHEN (OLD.Status = 'IN PROCESS' and NEW.Status = 'FAILED')
    EXECUTE FUNCTION deleteFromSchedule();

SELECT s.ScheduleID,Staff.FirstName, Staff.LastName, Sj.title, S.StartTime
FROM Staff
    INNER JOIN Class C on Staff.StaffID = C.StaffID
    INNER JOIN Schedule S on C.ClassID = S.ClassID
    INNER JOIN Subject Sj ON S.SubjectID = Sj.SubjectID where C.StaffID=3

insert into qualification(staffid, coursetitle, datecompleted, status) values (2, 'Databases' , '11.02.2023', 'IN PROCESS');
update qualification set status = 'FAILED' where staffid = 2;
insert into qualification(staffid, coursetitle, datecompleted, status) values (3, 'Databases' , '20.02.2023', 'IN PROCESS');
update qualification set status = 'FAILED' where staffid = 3;

--Отказ от прохождения курсов
CREATE OR REPLACE FUNCTION delete_staff() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    update class set staffid = NULL where staffid = NEW.StaffId;
    delete from qualification where staffid = NEW.StaffId;
    delete from salary where staffid = NEW.StaffId;
    delete from sectionsubjectstaff where staffid = NEW.StaffId;
    delete from staff where staffid = NEW.StaffId;
    RETURN NEW;
END $$;

CREATE TRIGGER refusedExam
    AFTER UPDATE ON qualification
    FOR EACH ROW
    WHEN (OLD.Status = 'IN PROCESS' and NEW.Status = 'REFUSED')
    EXECUTE FUNCTION delete_staff();


insert into qualification(staffid, coursetitle, datecompleted, status) values (3, 'Databases' , '20.02.2023', 'IN PROCESS');
update qualification set status = 'REFUSED' where staffid = 3;


-- 2 Создайте процедуру проведения учебных занятий.
-- v В школе не бывает накладок в расписании.
-- v Все занятия проходят в строго отведенное время.
-- v В случае нарушения любого из этих условий необходим вывод сообщения об ошибке.
-- v Ученики, не заплатившие за обучение до 10го числа каждого месяца, не допускаются к занятиям и необходим вывод соответствующего сообщения.
-- v Соответствующий триггер удаляет их из списка присутствующих на занятиях до тех пор, пока не будет внесена оплата за обучение.

-- В школе не бывает накладок в расписании.
CREATE OR REPLACE FUNCTION check_schedule_overlap()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM Schedule
        WHERE RoomID = NEW.RoomID
        AND NOT (EndTime <= NEW.StartTime OR StartTime >= NEW.EndTime)
        AND ScheduleID != NEW.ScheduleID
    ) THEN
        RAISE EXCEPTION 'Lesson overlaps with another lesson in the same room';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_schedule_overlap_trigger
BEFORE INSERT OR UPDATE ON Schedule
FOR EACH ROW
EXECUTE FUNCTION check_schedule_overlap();

insert into schedule(starttime, endtime, roomid, classid, subjectid) values ('2023-02-22 11:00:00.000000', '2023-02-22 12:00:00.000000', 1,1,2);

-- Все занятия проходят в строго отведенное время.
CREATE TABLE AttendanceTeacher (
    AttendanceTeacherID serial PRIMARY KEY,
    ScheduleID INT REFERENCES Schedule(ScheduleID),
    StartTime timestamp
);
CREATE TABLE Attendance (
    AttendanceID serial PRIMARY KEY,
    RollNo INT REFERENCES Student(RollNo),
    ScheduleID INT REFERENCES Schedule(ScheduleID),
    Present BOOLEAN,
    CHECK (Present IN (TRUE, FALSE))
);

CREATE OR REPLACE FUNCTION check_start_time() RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Schedule WHERE ScheduleID = NEW.ScheduleID AND StartTime >= NEW.StartTime
    ) THEN
        RAISE EXCEPTION 'Teacher started lesson late';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_start_time_trigger
AFTER INSERT ON AttendanceTeacher
FOR EACH ROW
EXECUTE FUNCTION check_start_time();
insert into attendanceteacher(scheduleid, starttime) VALUES (22,'2023-02-22 10:00:00.000000')

--удаляет их из списка присутствующих на занятиях до тех пор, пока не будет внесена оплата за обучение.

-- CREATE OR REPLACE FUNCTION check_payment() RETURNS TRIGGER AS $$
-- BEGIN
--     IF EXISTS (
--         SELECT *
--         FROM Fee
--         WHERE RollNo = NEW.RollNo AND DateTime >= DATE_TRUNC('month', NOW()) + INTERVAL '10 days' AND Status = 'PAID'
--     ) THEN
--         RETURN NEW;
--     ELSE
--         RAISE EXCEPTION 'Not paid';
--     END IF;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_payment() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT *
        FROM Fee
        WHERE RollNo = NEW.RollNo AND ((Status = 'PAID') OR (STATUS = 'WAITING' AND DateTime >= DATE_TRUNC('month', NOW()) + INTERVAL '10 days'))
    ) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Not paid';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER attendance_check_payment
BEFORE INSERT ON Attendance
FOR EACH ROW
EXECUTE FUNCTION check_payment();

insert into attendance(rollno, scheduleid, present) VALUES (1, 22, True);
insert into attendance(rollno, scheduleid, present) VALUES (3, 22, True);