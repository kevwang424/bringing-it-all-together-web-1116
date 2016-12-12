class Dog

  attr_accessor :id, :breed, :name

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      self.update
    else
      sql =<<-SQL
        INSERT INTO dogs(name,breed)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(attributes)
    dog_instance = Dog.new(attributes)
    dog_instance.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    dog_in_row = DB[:conn].execute(sql,id)[0]
    self.new_from_db(dog_in_row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    dog_in_row = DB[:conn].execute(sql,name)[0]
    self.new_from_db(dog_in_row)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.new_from_db(array)
    key_val_pair = {
      id: array[0],
      name: array[1],
      breed: array[2]
    }
    self.new(key_val_pair)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? and breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = self.create(name: name,breed: breed)
    end
    dog
  end

end
