require_relative "../config/environment.rb"

class Student
	attr_accessor :name, :grade, :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
  	sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students
    (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER);
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
  	drop = 'DROP TABLE IF EXISTS students'
  	DB[:conn].execute(drop)
  end

  def insert
  	sql = <<-SQL
  	INSERT INTO students (name, grade)
  	VALUES (?,?)
  	SQL
  	values = [self.name, self.grade]
  	DB[:conn].execute(sql, *values)[0]
  	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end


  def self.create(name, grade)
  	student = Student.new(name, grade)
  	student.name = name
  	student.grade = grade
  	student.insert
  end

  def self.new_from_db(row)
  	student = self.new(row[1], row[2])
  	student.id = row[0]
  	student
  	# student.name = row[1]
  	# student.grade = row[2]

  end

  def self.find_by_name(name)
  	sql_row = <<-SQL
  		SELECT * FROM students
  		WHERE name = ?
  		LIMIT 1
  	SQL

  	row = DB[:conn].execute(sql_row, name)[0]
  	self.new_from_db(row)

  end

  def save
  	if self.id.nil?
  		self.insert
  	else
  		self.update
  	end
  end

  def update
  	sql = <<-SQL
  		UPDATE students 
  		SET name = ?, grade =?
  		WHERE '#{self.id}' = id
  	SQL

  	values = [self.name, self.grade]
  	DB[:conn].execute(sql, *values)

  end



end
