CREATE TABLE Class (
    ClassID INT PRIMARY KEY,
    Name VARCHAR(10),
)

CREATE TABLE Section (
    SectionID INT PRIMARY KEY,
    StaffID INT REFERENCES Staff(StaffID),
    SubjectID INT REFERENCES Subject(SubjectID)
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    Name VARCHAR(50),
    ClassId INT FOREIGN KEY REFERENCES Class(ClassID)
);

CREATE TABLE Salary (
    SalaryID INT PRIMARY KEY,
    StaffID INT,
    Amount INT,
    DatePaid DATE,
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

CREATE TABLE Student (
    RollNo VARCHAR(40) PRIMARY KEY ,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    SectionID INT FOREIGN KEY REFERENCES Section(SectionID),
    ClassID INT FOREIGN KEY REFERENCES Class(ClassID)
);

CREATE TABLE Subject (
    SubjectID INT PRIMARY KEY,
    Name VARCHAR(40)
);

CREATE TABLE Room (
    RoomID INT PRIMARY KEY,
    Section VARCHAR(10),
    RoomNo VARCHAR(10),
    RoomType VARCHAR(20),
    ClassID INT FOREIGN KEY REFERENCES Class(ClassID),
    UNIQUE (Section, RoomNo),
    CHECK (RoomType IN ('classroom', 'laboratory'))
);

CREATE TABLE Fee (
    FeeID INT PRIMARY KEY,
    RollNo VARCHAR(40),
    Amount INT,
    DatePaid DATE,
    FOREIGN KEY (RollNo) REFERENCES Student(RollNo)
);





