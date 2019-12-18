
require 'bundler'
Bundler.require
class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    new_student = self.new  # self.new is the same as running Song.new
    new_student.id = row[0]
    new_student.name =  row[1]
    new_student.grade = row[2]
    new_student  # return the newly created instance
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
    SQL

    all_rows = DB[:conn].execute(sql)
    all_rows.map {|row| self.new_from_db(row)}
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1;
    SQL
     
    student = DB[:conn].execute(sql,name)[0]
    self.new_from_db(student)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.all_students_in_grade_X(val)
    sql = <<-SQL
      SELECT * FROM students WHERE grade = ?;
    SQL

    DB[:conn].execute(sql, val)
  end

  # This is a class method that does 
  # not need an argument. This method should 
  # return an array of all the students in grade 9.
  def self.all_students_in_grade_9
    Student.all_students_in_grade_X(9)
  end

  def self.students_below_12th_grade
    i = 1
    grades_array = []
    while(i < 12)
      if(Student.all_students_in_grade_X(i) != [])
       student = Student.new_from_db(Student.all_students_in_grade_X(i)[0])
         grades_array << student
      end
      i += 1
    end
    grades_array
  end

  def self.first_X_students_in_grade_10(x)
    sql = <<-SQL
    SELECT * FROM students WHERE grade = 10 LIMIT ?;
    SQL
    grade10 = []
    grade10_array = DB[:conn].execute(sql, x)
    grade10_array.each {|s| grade10 << Student.new_from_db(s)}
    grade10
  end


  def self.first_student_in_grade_10
    sql = <<-SQL
    SELECT * FROM students WHERE grade = 10 LIMIT 1;
    SQL
    row = DB[:conn].execute(sql)
    Student.new_from_db(row[0])
  end
end
