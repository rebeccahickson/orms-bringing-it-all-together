require 'pry'

class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:, breed:)
        Dog.new(name: name, breed: breed).save
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        new_dog = self.new(name: name, breed: breed)
        new_dog.id = id
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE dogs.id = ?
        SQL
        new_from_db(DB[:conn].execute(sql, id).first)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE dogs.name = ? AND dogs.breed = ?
        SQL
        finder = DB[:conn].execute(sql, name, breed).first
        if finder.nil?
            dog = Dog.create(name: name, breed: breed)
        else
            find_by_id(finder[0])
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE dogs.name = ?
        SQL
        new_from_db(DB[:conn].execute(sql, name).first)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end