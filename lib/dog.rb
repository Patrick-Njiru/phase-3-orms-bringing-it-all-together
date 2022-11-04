class Dog

    attr_accessor :name, :id, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
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

        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
       DB[:conn].execute("SELECT * from dogs")
       .map { |row| self.new_from_db(row) }
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)
        .map { |row| self.new_from_db(row)}.first
    end

    def self.find(id)
        DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id.to_i)
        .map { |row| self.new_from_db(row)}.first
    end
end