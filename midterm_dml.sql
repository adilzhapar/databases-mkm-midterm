INSERT INTO Staff VALUES('Askar', 'Akshabayev');
INSERT INTO Staff VALUES('Beisenbek', 'Baisakov');
INSERT INTO Staff VALUES('Bobur', 'Mukhsimbaev');
INSERT INTO Staff VALUES('Askar', 'Djumadildaev');

INSERT INTO Salary VALUES(1, 400000, '2023-02-22');
INSERT INTO Salary VALUES(2, 300000, '2023-02-20');
INSERT INTO Salary VALUES(3, 400000, '2023-02-18');
INSERT INTO Salary VALUES(4, 1000000, '2023-02-24');

INSERT INTO Class VALUES('11A', 1);
INSERT INTO Class VALUES('10B', 2);
INSERT INTO Class VALUES('9C', 3);
INSERT INTO Class VALUES('8G', 4);

INSERT INTO Subject VALUES('Math');
INSERT INTO Subject VALUES('PE');
INSERT INTO Subject VALUES('Physics');
INSERT INTO Subject VALUES('History');

INSERT INTO Section VALUES ('Arystan');
INSERT INTO Section VALUES ('Dostyq');
INSERT INTO Section VALUES ('Bereke');
INSERT INTO Section VALUES ('Qanat');

INSERT INTO Room VALUES(100, 'classroom', 1, 1);
INSERT INTO Room VALUES(101, 'classroom', 2, 2);
INSERT INTO Room VALUES(200, 'laboratory', 3, 3);
INSERT INTO Room VALUES(202, 'laboratory', 4, 4);

INSERT INTO Student VALUES ('Bauyrzhan', 'Turdalin', 1, 1);
INSERT INTO Student VALUES ('Nurasyl', 'Balgaziev', 1, 1);
INSERT INTO Student VALUES ('Adil', 'Ashim', 2, 2);
INSERT INTO Student VALUES ('Zhaqsylyq', 'Zhapar', 2, 2);
INSERT INTO Student VALUES ('Torekeldi', 'Kipshakbaev', 3, 3);
INSERT INTO Student VALUES ('Sanzhar', 'Niyazbek', 3, 3);
INSERT INTO Student VALUES ('Danyiar', 'Mukhambetov', 4, 4);
INSERT INTO Student VALUES ('Nurtay', 'Zholdaskaliev', 4, 4);


INSERT INTO Fee VALUES (33500, '2023-01-16', 'PAID', 1)
INSERT INTO Fee VALUES (67000, '2023-01-16', 'PAID', 2)
INSERT INTO Fee VALUES (180000, '2022-12-16', 'PAID', 3)
INSERT INTO Fee VALUES (100000, '2022-11-20', 'PAID', 4)
INSERT INTO Fee VALUES (12000, '2023-03-22', 'WAITING', 5)
INSERT INTO Fee VALUES (33500, '2023-03-08', 'WAITING', 6)
INSERT INTO Fee VALUES (39000, '2023-04-01', 'WAITING', 7)
INSERT INTO Fee VALUES (60000, '2023-04-11', 'WAITING', 8)

INSERT INTO Schedule VALUES ('20230222 10:00:00 AM', '20230222 12:00:00 PM', 1, 1, 1);
INSERT INTO Schedule VALUES ('20230222 12:00:00 PM', '20230222 14:00:00 PM', 2, 2, 2);
INSERT INTO Schedule VALUES ('20230222 12:00:00 PM', '20230222 14:00:00 PM', 1, 2, 2);
INSERT INTO Schedule VALUES ('20230222 10:00:00 AM', '20230222 16:00:00 PM', 3, 3, 3);
INSERT INTO Schedule VALUES ('20230222 16:00:00 PM', '20230222 18:00:00 PM', 3, 3, 4);
INSERT INTO Schedule VALUES ('20230222 9:00:00 AM', '20230222 11:00:00 AM', 4, 4, 4);
INSERT INTO Schedule VALUES ('20230222 13:00:00 PM', '20230222 15:00:00 PM', 4, 3, 4);


SELECT * FROM Student
    join Class C on Student.ClassID = C.ClassID
join Staff S on S.StaffID = C.StaffID AND C.StaffID = 2;

SELECT *
FROM Staff
    INNER JOIN SectionSubjectStaff SSS on Staff.StaffID = SSS.StaffID
    INNER JOIN Subject S on SSS.SubjectID = S.SubjectID

SELECT Staff.FirstName, Staff.LastName, Sj.title
FROM Staff
    INNER JOIN Class C on Staff.StaffID = C.StaffID
    INNER JOIN Schedule S on C.ClassID = S.ClassID
    INNER JOIN Subject Sj ON S.SubjectID = Sj.SubjectID

SELECT FirstName,LastName, Title, StartTime, EndTime, RoomID FROM Student
    INNER JOIN Schedule S on Student.ClassID = S.ClassID
    INNER JOIN Subject S2 on S.SubjectID = S2.SubjectID
