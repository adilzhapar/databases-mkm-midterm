CREATE TABLE Staff (
    StaffID INT IDENTITY(1, 1) PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50)
);


CREATE TABLE Salary (
    SalaryID INT IDENTITY(1, 1) PRIMARY KEY,
    StaffID INT,
    Amount INT,
    DatePaid DATE,
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

CREATE TABLE Class (
    ClassID INT IDENTITY(1, 1) PRIMARY KEY,
    Title VARCHAR(20),
    StaffID INT FOREIGN KEY references Staff(StaffID)
);

CREATE TABLE Subject (
    SubjectID INT IDENTITY(1, 1) PRIMARY KEY,
    Title VARCHAR(40)
);

CREATE TABLE Section (
    SectionID INT IDENTITY(1, 1) PRIMARY KEY ,
    Title VARCHAR(40)
);

CREATE TABLE Room (
    RoomID INT IDENTITY(1, 1) PRIMARY KEY ,
    Room_number INT,
    RoomType VARCHAR(20),
    ClassID INT REFERENCES Class(ClassID),
    SectionID INT REFERENCES Section(SectionID),
    CHECK (RoomType IN ('classroom', 'laboratory'))
);

CREATE TABLE Student (
    RollNo INT IDENTITY(1, 1) PRIMARY KEY ,
    FirstName VARCHAR(40),
    LastName VARCHAR(40),
    SectionID INT references Section(SectionID),
    ClassID INT references Class(ClassID)
);

CREATE TABLE Fee (
    FeeID INT IDENTITY(1, 1) PRIMARY KEY,
    Amount INT,
    DateTime DATE,
    Status VARCHAR(10),
    RollNo INT FOREIGN KEY REFERENCES Student(RollNo),
    CHECK (Status IN ('PAID', 'WAITING'))
);


CREATE TABLE Schedule (
    ScheduleID INT IDENTITY (1, 1) PRIMARY KEY ,
    StartTime date,
    EndTime date,
    RoomID INT FOREIGN KEY REFERENCES Room(RoomID),
    ClassID INT FOREIGN KEY REFERENCES Class(ClassID),
    SubjectID INT FOREIGN KEY REFERENCES Subject(SubjectID)
);

CREATE TABLE SectionSubjectStaff (
    SectionID INT FOREIGN KEY REFERENCES Section(SectionID),
    SubjectID INT FOREIGN KEY REFERENCES Subject(SubjectID),
    StaffID INT FOREIGN KEY references Staff(StaffID),
    PRIMARY KEY (SectionID, SubjectID, StaffID)
);


